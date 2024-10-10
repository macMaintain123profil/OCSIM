//
//  ViewController.m
//  SampleOCPod
//
//  Created by 68 on 2024/10/10.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, Class> *> *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = @[
        @{@"title": @"授权demo", @"clz": NSClassFromString(@"AuthDemoVC")},
        @{@"title": @"68号加好友demo", @"clz": NSClassFromString(@"P2PDemoVC")},
        @{@"title": @"群分享链接进入群聊demo", @"clz": NSClassFromString(@"GroupShareLinkDemoVC")},
        @{@"title": @"群别名进入群聊demo", @"clz": NSClassFromString(@"GroupAlianNameDemoVC")},
        @{@"title": @"otc展示demo", @"clz": NSClassFromString(@"OTCDemoVC")},
        @{@"title": @"帮h5获取AccessToken", @"clz": NSClassFromString(@"AccessTokenVC")},
    ];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"cell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview: self.tableView];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.whiteColor;
    NSDictionary *data = self.dataList[indexPath.row];
    cell.textLabel.text = data[@"title"];
    cell.textLabel.textColor = UIColor.blackColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.dataList[indexPath.row];
    Class vcClz = data[@"clz"];
    UIViewController *vc = [[vcClz alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
