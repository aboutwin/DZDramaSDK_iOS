# frozen_string_literal: true
# 保持 Xcode 脚本沙箱开启，补齐 CocoaPods 1.15 复制二进制和资源时的输出路径。
module DZDramaSDKPodSupport
  def self.post_install(installer)
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
    support_dirs(installer).each do |dir|
      Dir.glob(File.join(dir, '*.sh')).each do |path|
        script = File.read(path)
        script.gsub!('realpath -mq', 'realpath -q')
        script.gsub!('RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt',
                     'RESOURCES_TO_COPY=${TEMP_DIR}/resources-to-copy-${TARGETNAME}.txt')
        script.gsub!('rsync --delete -av', 'rsync --inplace --delete -av')
        script.gsub!('rsync -avr', 'rsync --inplace -avr')
        File.write(path, script)
      end
    end
  end

  def self.framework_outputs(installer)
    outputs = []
    Dir.glob(File.join(installer.sandbox.root.to_s, 'AliPlayerSDK_iOS', '*.framework')).each do |framework|
      name = File.basename(framework)
      root = "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/#{name}"
      Dir.glob(File.join(framework, '**', '*'), File::FNM_DOTMATCH).each do |file|
        relative = file.delete_prefix(framework + '/')
        next if ['.', '..', 'Headers', 'Modules'].include?(File.basename(file))
        next if relative.start_with?('Headers/', 'Modules/')
        outputs << "#{root}/#{relative}"
      end
      %W[#{File.basename(framework, '.framework')}.lipo #{File.basename(framework, '.framework')}.cstemp Info.plist.cstemp _CodeSignature _CodeSignature/CodeResources _CodeSignature/CodeResources.cstemp].each do |file|
        outputs << "#{root}/#{file}"
      end
    end
    outputs
  end

  def self.resource_outputs(installer, outputs)
    expanded = outputs.dup
    outputs.select { |path| path.end_with?('.bundle') }.each do |bundle|
      expanded.concat(["#{bundle}/Info.plist", "#{bundle}/PrivacyInfo.xcprivacy"])
    end
    bundles = [File.join(installer.sandbox.root.to_s, 'MJRefresh/MJRefresh/MJRefresh.bundle')]
    sdk = installer.pod_targets.find { |target| target.pod_name == 'DZDramaSDK' }
    bundles << File.join(installer.sandbox.pod_dir('DZDramaSDK').to_s, 'DZDramaSDKResources.bundle') if sdk
    bundles.select { |bundle| File.directory?(bundle) }.each do |bundle|
      Dir.glob(File.join(bundle, '**', '*')).each do |file|
        expanded << "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/#{File.basename(bundle)}/#{file.delete_prefix(bundle + '/')}"
      end
    end
    expanded.uniq
  end

  def self.post_integrate(installer)
    support_dirs(installer).each do |dir|
      Dir.glob(File.join(dir, '*frameworks-*-output-files.xcfilelist')).each do |path|
        File.write(path, (File.readlines(path, chomp: true) + framework_outputs(installer)).uniq.join("\n") + "\n")
      end
      Dir.glob(File.join(dir, '*resources-*-output-files.xcfilelist')).each do |path|
        File.write(path, resource_outputs(installer, File.readlines(path, chomp: true)).join("\n") + "\n")
      end
    end
    # 老格式 .xcodeproj 使用 inputPaths/outputPaths；也补齐这些工程的声明。
    installer.aggregate_targets.map(&:user_project).uniq.each do |project|
      project.native_targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
        target.shell_script_build_phases.each do |phase|
          next unless Array(phase.output_file_list_paths).empty?
          if phase.name == '[CP] Embed Pods Frameworks'
            phase.output_paths = (phase.output_paths + framework_outputs(installer)).uniq
          elsif phase.name == '[CP] Copy Pods Resources'
            phase.output_paths = resource_outputs(installer, phase.output_paths)
          end
        end
      end
      project.save
    end
  end

  def self.support_dirs(installer)
    Dir.glob(File.join(installer.sandbox.root.to_s, 'Target Support Files', 'Pods-*'))
  end
end
