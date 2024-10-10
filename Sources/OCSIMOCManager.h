//
//  OCSIMOCManager.h
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OCSIMOCAPPType) {
    app68 = 0, // 68
    app4e = 1 // 4e
};

typedef NS_ENUM(NSUInteger, OCSIMOCENVType) {
    pro = 0, // 生产环境
    uat = 1, // UAT环境
    test = 2 // 测试环境
};

typedef NS_ENUM(NSUInteger, OCSIMOCPageType) {
    identify = 0, // 跳转XX号添加好友（已经是好友直接进入单聊页面）
    groupShareLink = 1, // 通过群分享链加入群（如果已经在群里直接进入群）
    groupAlianName = 2, // 通过群别名跳转加入群（如果已经在群里直接进入群）
    auth = 3, // 去授权
    otc = 4, // 进入OTC功能页面
};
typedef void (^JumpAuthBlock)(NSDictionary *_Nonnull);
@interface OCSIMOCManager : NSObject

+ (instancetype _Nonnull)sharedInstance;
- (void)handleUrl: (nullable NSURL *)url;
- (void)handleUrls: (nullable NSArray<NSURL *> *)urls;

@end
@interface NSString (UrlPath)
- (nonnull NSString *)appendPath:(nullable NSString *)path;
- (nonnull NSString *)appendParamWithKey:(nullable NSString *)key val:(nullable NSString *)val;
- (nonnull NSString *)appendParamWithParams:(nullable NSDictionary<NSString *, NSString*> *)params;
- (nonnull NSMutableDictionary<NSString *, NSString *> *)urlParams;
@end
