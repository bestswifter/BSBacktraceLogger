//
//  BsBackTraceLogger.h
//  BsBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BSLOG NSLog(@"%@",[BsBacktraceLogger backtraceOfCurrentThread]);
#define BSLOG_MAIN NSLog(@"%@",[BsBacktraceLogger backtraceOfMainThread]);
#define BSLOG_ALL NSLog(@"%@",[BsBacktraceLogger backtraceOfAllThread]);

@interface BsBacktraceLogger : NSObject

+ (NSString *)backtraceOfAllThread;
+ (NSString *)backtraceOfCurrentThread;
+ (NSString *)backtraceOfMainThread;
+ (NSString *)backtraceOfNSThread:(NSThread *)thread;

@end
