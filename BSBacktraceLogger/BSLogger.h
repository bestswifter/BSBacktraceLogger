//
//  Logger.h
//  BsBacktraceLogger
//
//  Created by Ruswan Efendi on 29/03/22.
//  Copyright © 2022 Ruswan Efendi. All rights reserved.
//
#import <Foundation/Foundation.h>

#define BSLOG NSLog(@"%@",[Logger bs_backtraceOfCurrentThread]);
#define BSLOG_MAIN NSLog(@"%@",[Logger bs_backtraceOfMainThread]);
#define BSLOG_ALL NSLog(@"%@",[Logger bs_backtraceOfAllThread]);

@interface BSLogger : NSObject

+ (NSString *_Nullable)bs_backtraceOfAllThread;
+ (NSString *_Nullable)bs_backtraceOfCurrentThread;
+ (NSString *_Nullable)bs_backtraceOfMainThread;
+ (NSString *_Nullable)bs_backtraceOfNSThread:(NSThread *_Nonnull)thread;

@end
