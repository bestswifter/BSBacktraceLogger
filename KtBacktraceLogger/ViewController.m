//
//  ViewController.m
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/26.
//  Copyright © 2016年 bestswifter. All rights reserved.
//



#import "ViewController.h"
#import "KtBackTraceLogger.h"

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
        NSLog(@"all = %@",[KtBackTraceLogger backtraceOfAllThread]);
        NSLog(@"current = %@",[KtBackTraceLogger backtraceOfCurrentThread]);
        NSLog(@"main = %@",[KtBackTraceLogger backtraceOfNSThread:[NSThread mainThread]]);
    });
    [self foo];
}

@end
