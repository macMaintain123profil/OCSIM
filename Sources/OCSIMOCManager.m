//
//  OCSIMOCManager.m
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSIMOCManager.h"

@implementation OCSIMOCManager
static OCSIMOCManager *_instance;
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

- (void)handleUrl: (NSURL * __nullable)url {
    
}

- (void)handleUrls: (NSArray<NSURL *> * __nullable)urls {
    
}
@end
