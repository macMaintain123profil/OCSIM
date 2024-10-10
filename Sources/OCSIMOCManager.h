//
//  OCSIMOCManager.h
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCSIMOCManager : NSObject

+ (instancetype _Nonnull)sharedInstance;
- (void)handleUrl: (nullable NSURL *)url;
- (void)handleUrls: (nullable NSArray<NSURL *> *)urls;

@end
