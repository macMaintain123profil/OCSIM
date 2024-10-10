//
//  OCSIMOCManager.m
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSIMOCManager.h"

@interface OCSIMOCManager()
@property (nonatomic, strong) NSMutableDictionary<NSString*, JumpAuthBlock> *callbackDict;
@end


@implementation OCSIMOCManager
static OCSIMOCManager *_instance;
- (NSMutableDictionary<NSString *,JumpAuthBlock> *)callbackDict {
    if (_callbackDict == nil) {
        _callbackDict = [NSMutableDictionary dictionary];
    }
    return _callbackDict;
}
+ (instancetype) sharedInstance {
     static dispatch_once_t oneToken;
     dispatch_once(&oneToken, ^{
        _instance = [[self alloc] init];
     });
     return _instance;
 }
 + (instancetype)allocWithZone:(NSZone *) zone {
       static dispatch_once_t onetoken;
       dispatch_once(&onetoken, ^{
           _instance = [super allocWithZone: zone];
       });
       return _instance;
 }
#pragma mark - 处理回调
- (void)handleUrl: (NSURL * __nullable)url {
    NSString *urlStr = url.absoluteString;
    NSString *urlStrLower = [[urlStr lowercaseString] stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    
    NSMutableArray <NSString *> *keyList = [NSMutableArray array];
    
    for (NSString *key in self.callbackDict.allKeys) {
        NSArray *keySepList = [[key lowercaseString] componentsSeparatedByString:OCSIMOCManager.urlSeperator];
        NSString *uniqueIdStr = keySepList.firstObject;
        NSString *redirectUriStr = keySepList.lastObject;
        // urlStr: xxx://xxx?xxx=xxx
        NSString *ustr = [NSString stringWithFormat:@"=%@", uniqueIdStr];
        if ([urlStrLower hasPrefix: redirectUriStr] && [urlStrLower containsString: ustr]){
            [keyList addObject:key];
        }
    }
    
    if (keyList.count > 0) {
        // 解析url上的参数
        NSMutableDictionary<NSString *, NSString *> *urlParams = [urlStr urlParams];
        urlParams[@"_originUrl"] = urlStr;
        for (NSString *key in keyList) {
            // 执行回调
            JumpAuthBlock handler = self.callbackDict[key];
            if (handler != nil) {
                handler(urlParams);
            }
            // 删除相关回调处理
            [self.callbackDict removeObjectForKey:key];
        }
    }
    
}

- (void)handleUrls: (NSArray<NSURL *> * __nullable)urls {
    if (urls != nil || urls.count > 0) {
        for (NSURL *url in urls) {
            [self handleUrl: url];
        }
    }
}
#pragma mark - 处理跳转
- (void)jumpAuthWithClientId:(NSString *)clientId
              code_challenge:(NSString *)code_challenge
        coce_challengeMethod:(NSString *)coce_challengeMethod
                    uniqueId:(NSString *)uniqueId
                 redirectUri:(NSString *)redirectUri
                     handler:(JumpAuthBlock)handler{
    [self jumpAuthWithAppType:app68
                      envType:pro
                     clientId:clientId
               code_challenge:code_challenge
         coce_challengeMethod:coce_challengeMethod
                     uniqueId:uniqueId
                  redirectUri:redirectUri
                      handler:handler];
}

- (void)jumpAuthWithAppType:(OCSIMOCAPPType)appType
                    envType:(OCSIMOCENVType)envType
                   clientId:(NSString *)clientId
              code_challenge:(NSString *)code_challenge
        coce_challengeMethod:(NSString *)coce_challengeMethod
                    uniqueId:(NSString *)uniqueId
                redirectUri:(NSString *)redirectUri
                    handler:(JumpAuthBlock)handler {
    NSString *pagePath = [self pathWithAppType:appType envType: envType page:auth];
    NSDictionary<NSString *, NSString *> *params = @{
        @"clientId": clientId,
        @"code_challenge": code_challenge,
        @"coce_challengeMethod": coce_challengeMethod,
        @"unique_id": uniqueId,
        @"redirectUri": redirectUri,
    };
    pagePath = [pagePath appendParamWithParams:params];
    // handler
    if (handler != nil) {
        NSString *handlerKey = [NSString stringWithFormat:@"%@%@%@", uniqueId, OCSIMOCManager.urlSeperator, redirectUri];
        self.callbackDict[handlerKey] = handler;
    }
    // 跳转
    NSURL *url = [NSURL URLWithString:pagePath];
    if (url != nil) {
        __weak __typeof(self)weakSelf = self;
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler: ^(BOOL result){
            NSLog(@"%d", result);
            if (result == YES) {
                // 跳转成功
                
            } else {
                // 跳转官网
                [weakSelf jumpToWebSiteWithAppType:appType envType:envType];
            }
        }];
    } else {
        NSLog(@"url 为空");
    }
}

- (void)jumpToWebSiteWithAppType:(OCSIMOCAPPType)appType envType:(OCSIMOCENVType)envType {
    NSURL *webUrl = [NSURL URLWithString:[self officialSite:appType]];
    if (webUrl != nil) {
        [UIApplication.sharedApplication openURL:webUrl options:@{} completionHandler: ^(BOOL result){
            NSLog(@"%d", result);
        }];
    } else {
        NSLog(@"webUrl 为空");
    }
}

#pragma mark - Utils
- (NSString *)pathWithAppType:(OCSIMOCAPPType)appType envType:(OCSIMOCENVType)envType page:(OCSIMOCPageType)page {
    NSString *scheme = @"";
    if (page == auth) {
        scheme = [self authScheme:appType];
    } else {
        scheme = [self normalScheme:appType];
    }
    NSString *envPath = [self envPath:envType];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", scheme, envPath];
    return [fullPath appendPath:[self pagePath:page]];
}
- (NSString *)normalScheme:(OCSIMOCAPPType)appType {
    if (appType == app4e) {
        return @"4echatim";
    } else {
        return @"octopusim";
    }
}
- (NSString *)authScheme:(OCSIMOCAPPType)appType {
    if (appType == app4e) {
        return @"Custom4ECHATAuth";
    } else {
        return @"CustomOctopusAuth";
    }
}

- (NSString *)envPath:(OCSIMOCENVType)envType {
    NSString *path = @"";
    if (envType == uat) {
        path = @"uat";
    } else if (envType == test) {
        path = @"test";
    } else {
        path = @"";
    }
    return [NSString stringWithFormat:@"%@://", path];
}

- (NSString *)pagePath:(OCSIMOCPageType)page {
    if (page == identify) {
        return @"page/oneToOneMessage";
    } else if (page == groupShareLink) {
        return @"page/groupMessage";
    } else if (page == groupAlianName) {
        return @"page/atLink";
    } else if (page == auth) {
        return @"page/auth";
    } else if (page == otc) {
        return @"page/otc";
    } else {
        return @"";
    }
}

- (NSString *)officialSite:(OCSIMOCAPPType)appType {
    if (appType == app4e) {
        return @"https://4E.IM";
    } else {
        return @"https://68chat.com";
    }
}
+ (NSString *)urlSeperator {
    return @"_#@#_";
}
@end


@implementation NSString (UrlPath)
- (nonnull NSString *)appendPath:(nullable NSString *)path {
    if (path == nil || path.length == 0 ) {
        return self;
    }
    if ([self hasSuffix:@"/"] && [path hasPrefix:@"/"]) {
        // 重重复的/
        return [NSString stringWithFormat:@"%@%@", self, [path substringFromIndex:1]];
    } else if ([self hasSuffix:@"/"] == false && [path hasPrefix:@"/"] == false) {
        // 都没有/
        return [NSString stringWithFormat:@"%@/%@", self, path];
    } else {
        // 只有1个有/
        return [NSString stringWithFormat:@"%@%@", self, path];
    }
}
- (nonnull NSString *)appendParamWithKey:(nullable NSString *)key val:(nullable NSString *)val {
    if (key == nil || key.length <= 0) {
        return self;
    }
    if ([self containsString:@"?"]) {
        // 已经包含？,追加参数
        return [NSString stringWithFormat:@"%@&%@=%@", self, key, val];
    } else {
        // 没有包含参数，设置参数
        return [NSString stringWithFormat:@"%@?%@=%@", self, key, val];
    }
}
- (nonnull NSString *)appendParamWithParams:(nullable NSDictionary<NSString *, NSString*> *)params {
    if (params == nil || params.count <= 0) {
        return self;
    }
    NSString *path = self;
    for (NSString *key in params.allKeys) {
        NSString *val = params[key];
        path = [self appendParamWithKey:key val: val];
    }
    return path;
}
- (nonnull NSMutableDictionary<NSString *, NSString *> *)urlParams {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    // "http://www.appleX.com/info?name=balana&age=18" // 简单的标准url
    // "http://www.appleX.com/info?name=balana&age=18&callback=http://www.googleY.com&type=friend" // 子url在中间
    // "http://xx/aa?year=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=fly://aa/b?d=dd&d2=ddd" // 子url在后面，且子url也自带自己的参数
    // "http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&xx=wechat://a&x=1&y=2&q2=sky://aa/b?d=dd&d2=ddd" // 子url与父参数混杂
    
    
    return dictM;
}
// MARK: - 找出子URL的列表
- (NSArray *)subUrlList {
    // http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=okt://aa/b?d=dd&d2=ddd
    NSArray<NSString *> *urlStrList = [self componentsSeparatedByString:@"://"];
    NSMutableDictionary<NSString *, NSString *> *pramsDict = [NSMutableDictionary dictionary];
    NSString *paramStr = self;
    if (urlStrList.count > 2) {
        // 存在多个字url
    }
    return @[paramStr, pramsDict];
}
@end
