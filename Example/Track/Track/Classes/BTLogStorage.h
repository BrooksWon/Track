//
//  BTLogStorage.h
//  Track_Example
//
//  Created by Brooks on 2020/7/20.
//  Copyright © 2020 BrooksWon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTLogStorage : NSObject
+ (instancetype)shraed ;
//遍历文件夹获得文件夹大小，返回多少M
+ (float)logFolderSize;
- (void)pushLog:(NSString *)log;
- (void)popLog:(BOOL(^)(NSData *))block;
//test case
-  (void)eventAction ;
@end

NS_ASSUME_NONNULL_END
