//
//  BTLogReport.m
//  Track_Example
//
//  Created by Brooks on 2020/7/20.
//  Copyright © 2020 BrooksWon. All rights reserved.
//

#import "BTLogReport.h"
#import "BTLogStorage.h"

@implementation BTLogReport

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __block id observer = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                              object:nil
                                                                               queue:nil
                                                                          usingBlock:^(NSNotification * _Nonnull note) {

            [[BTLogStorage shraed] popLog:^BOOL(NSData * _Nonnull log) {
                //网络上报
//                if (WIFI) {
//                    BOOL report = [NetEngin post:data];
//
//                }
                NSString *result = [[NSString alloc] initWithData:log encoding:NSUTF8StringEncoding];
                NSLog(@"log: %@", result);
                return YES;
            }];
            
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }];
    });
}

@end
