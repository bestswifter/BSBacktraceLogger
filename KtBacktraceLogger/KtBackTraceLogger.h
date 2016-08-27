//
//  KtBackTraceLogger.h
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KTLOG NSLog(@"%@",[KtBackTraceLogger backtraceOfCurrentThread]);
#define KTLOG_MAIN NSLog(@"%@",[KtBackTraceLogger backtraceOfMainThread]);
#define KTLOG_ALL NSLog(@"%@",[KtBackTraceLogger backtraceOfAllThread]);

@interface KtBackTraceLogger : NSObject

+ (NSString *)backtraceOfAllThread;
+ (NSString *)backtraceOfCurrentThread;
+ (NSString *)backtraceOfMainThread;
+ (NSString *)backtraceOfNSThread:(NSThread *)thread;

@end
