#import "MenuViewController.h"
#import <DZDramaSDK/DZDramaSDK-Swift.h>
@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DZDramaSDK OC Demo";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 4; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @[@"推荐页", @"剧场页", @"搜索页", @"收藏页"][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *page = [DZDramaSDKManager.shared viewControllerForPage:(DZDramaPage)indexPath.row];
    [self.navigationController pushViewController:page animated:YES];
}
@end
