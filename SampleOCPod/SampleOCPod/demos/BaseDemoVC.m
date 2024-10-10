//
//  BaseDemoVC.m
//  SampleOCPod
//
//  Created by flow on 10/10/24.
//

#import "BaseDemoVC.h"

@interface BaseDemoVC ()

@end

@implementation BaseDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view insertSubview:self.baseScrollView atIndex:0];
    [self.baseScrollView addSubview: self.baseContentView];
    self.baseScrollView.contentSize = self.baseContentView.bounds.size;
    
    [self addCommonTop];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.baseContentView addGestureRecognizer:tap];
}

- (void)tapClick {
    [self.view endEditing:YES];
}

- (void)addCommonTop {
    self.appBtnList = [self createSelectBtnsY:150 btnW:60 tips:@"选择要跳转的app类型" list:@[
                       @{@"title" : @"68", @"tag": @0},
                       @{@"title" : @"4e", @"tag": @1},
    ] defaultIdx:0];
    
    self.envBtnList = [self createSelectBtnsY:(self.appBtnMaxY + 10) btnW:100 tips:@"选择要跳转的环境类型" list:@[
                           @{@"title" : @"线上环境", @"tag": @0},
                           @{@"title" : @"UAT环境", @"tag": @2},
                           @{@"title" : @"测试环境", @"tag": @3},
        ] defaultIdx:2];
}

- (void)updateMaxContentSize {
    CGFloat maxY = 0;
    for (UIView *v in self.baseContentView.subviews) {
        if (CGRectGetMaxY(v.frame) > maxY) {
            maxY = CGRectGetMaxY(v.frame);
        }
    }
    CGFloat realMaxY =  MAX(UIScreen.mainScreen.bounds.size.height, maxY + 30);
    self.baseContentView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, realMaxY);
    self.baseScrollView.contentSize = self.baseContentView.bounds.size;
}

- (NSArray<UIButton *> *)createSelectBtnsY: (CGFloat)y btnW: (CGFloat)btnW tips:(NSString *)tips list: (NSArray<NSDictionary *>*)list defaultIdx: (NSInteger)defaultIdx {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 200, 40)];
    lbl.textColor = UIColor.blackColor;
    lbl.text = tips;
    [self.baseContentView addSubview:lbl];
    NSMutableArray *btnList = [NSMutableArray new];
    NSInteger count = list.count;
    UIView *preView = lbl;
    for (NSInteger i=0; i< count; i++) {
        NSDictionary *data = list[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = [((NSNumber *)data[@"tag"]) intValue];
        
        [btn setTitle:data[@"title"] forState: UIControlStateNormal];
        [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat btnX = 10;
        if (i == 0) {
            btnX = 10;
        } else {
            btnX = CGRectGetMaxX(preView.frame) + 10;
        }
        if (i == defaultIdx) {
            btn.selected = YES;
        }
        btn.frame = CGRectMake(btnX, y+40, btnW, 30);
        [btn setImage:[UIImage imageNamed:@"check_unselected"] forState: UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"check_selected"] forState: UIControlStateSelected];
        [btn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.baseContentView addSubview:btn];
        [btnList addObject:btn];
        preView = btn;
    }
    
    return btnList;
}

- (void)selectBtnClick:(UIButton *)sender {
    BOOL isSelected = sender.isSelected;
    if ([self.appBtnList containsObject:sender]) {
        for (UIButton *btn in self.appBtnList) {
            btn.selected = NO;
        }
        sender.selected = !isSelected;
    } else {
        for (UIButton *btn in self.envBtnList) {
            btn.selected = NO;
        }
        sender.selected = !isSelected;
    }
}

- (UIScrollView *)baseScrollView {
    if (_baseScrollView == nil) {
        _baseScrollView = [[UIScrollView alloc] initWithFrame: UIScreen.mainScreen.bounds];
        _baseScrollView.clipsToBounds = YES;
        _baseScrollView.clipsToBounds = YES;
        _baseScrollView.showsVerticalScrollIndicator = NO;
        _baseScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        if (@available(iOS 12.0, *)) {
            _baseScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _baseScrollView;
}

- (UIView *)baseContentView {
    if (_baseContentView == nil) {
        CGFloat sHeight = UIScreen.mainScreen.bounds.size.height;
        CGFloat sWidth = UIScreen.mainScreen.bounds.size.width;
        _baseContentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, sWidth, sHeight*2)];
   }
   return _baseContentView;
}

- (UIColor *)btnColor {
    return [UIColor colorWithRed:23.0/255 green:138.0/255 blue:1 alpha:1];
}
- (CGFloat)appBtnMaxY {
    NSInteger count = self.appBtnList.count;
    if (count > 0) {
        return CGRectGetMaxY(self.appBtnList[count-1].frame);
    }
    return 0;
}
- (CGFloat)envBtnMaxY {
    NSInteger count = self.envBtnList.count;
    if (count > 0) {
        return CGRectGetMaxY(self.envBtnList[count-1].frame);
    }
    return 0;
}
@end
