//
//  BaseDemoVC.h
//  SampleOCPod
//
//  Created by flow on 10/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseDemoVC : UIViewController
@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, strong) UIView *baseContentView;
@property (nonatomic, strong) NSArray<UIButton *> *appBtnList;
@property (nonatomic, strong) NSArray<UIButton *> *envBtnList;
@property (nonatomic, strong) UILabel *topLabel;
- (UIColor *)btnColor;
- (CGFloat) appBtnMaxY;
- (CGFloat) envBtnMaxY;

@end

NS_ASSUME_NONNULL_END
