//
//  UIView+DZExposure.h
//  DZUIExposureManager


#import <UIKit/UIKit.h>

static NSInteger DZEffectiveExposureTime = 0; //默认的有效曝光时间300ms
static NSInteger DZEffectiveExposureRatio = 50;  //默认的有效曝光比例

@interface UIView (DZExposure)

/**
     UIView 曝光时的操作（可用于统计）
 */
@property (nonatomic, copy, setter=DZ_setExposuerBlock:) void(^DZ_exposureBlock)(UIView *);

/**
    UIView 曝光补偿（原来的曝光区域+这里的补偿，CGRectMake(x-.width, y-.heigh, w+2*.widht, h+2*.heigh)）
    时机：最好在设置曝光操作（DZ_setExposuerBlock:）前设置 -- 默认时CGSizeZero
 */
@property (nonatomic, assign, setter=DZ_setECompensationSize:) CGSize DZ_ECompensationSize;

/// 设置为YES时，忽略进行曝光的操作，NO就正常曝光，默认NO
@property (nonatomic, assign, setter=DZ_setIgnoreExposure:) BOOL DZ_ignoreExposure;

/// 设置为YES时，忽略进行曝光的操作，NO就正常曝光，默认NO
/// 当superView的hm_ignoreExposure为YES时，DZ_ignoreExposureFromSuperView就会跟随变为YES
@property (nonatomic, assign, setter=DZ_setIgnoreExposureFromSuperView:) BOOL DZ_ignoreExposureFromSuperView;

/// 有效曝光时长，只有曝光时长大于hm_EffectiveExposureTime才算有效曝光, 单位是毫秒
/// 默认是300毫秒（DZEffectiveExposureTime）
@property (nonatomic, assign, setter=DZ_setEffectiveExposureTime:) NSInteger DZ_EffectiveExposureTime;

/// 有效曝光比例，只有曝光面积大于hm_EffectiveExposureRatio时才算曝光（0～100），小于0就等于0，只要有曝光即可，大于100就等于100，要全部曝光
/// 默认是0，即露出就算曝光（DZEffectiveExposureRatio）
@property (nonatomic, assign, setter=DZ_setEffectiveExposureRatio:) NSInteger DZ_EffectiveExposureRatio;
 
@end
