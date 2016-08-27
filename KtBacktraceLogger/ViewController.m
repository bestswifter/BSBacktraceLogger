//
//  ViewController.m
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/26.
//  Copyright © 2016年 bestswifter. All rights reserved.
//



#import "ViewController.h"
#import "BsBacktraceLogger.h"

#import <pthread.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)foo {
    [self bar];
}

- (void)bar {
    while (true) {
        ;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // You can use class method begun with `backtraceof` if you need to get the NSString result.
        // Or just you macros begun with `KTLOG` for convenience to print the callstack.
//        NSLog(@"all = %@",[KtBackTraceLogger backtraceOfAllThread]);
//        NSLog(@"current = %@",[KtBackTraceLogger backtraceOfCurrentThread]);
//        NSLog(@"main1 = %@",[KtBackTraceLogger backtraceOfMainThread]);
//        NSLog(@"main2 = %@",[KtBackTraceLogger backtraceOfNSThread:[NSThread mainThread]]);
        BSLOG
        BSLOG_ALL
        BSLOG_MAIN
    });
    [self foo];
}

@end
