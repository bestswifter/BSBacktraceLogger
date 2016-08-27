//
//  ViewController.m
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/26.
//  Copyright © 2016年 bestswifter. All rights reserved.
//



#import "ViewController.h"
#import "KtBackTraceLogger.h"

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
    [[NSThread currentThread] setName:@"main thread"];
    
//    mach_port_t mach_thread = pthread_mach_thread_np(pthread_self());
//    uint64_t tid1, tid2;
//    pthread_threadid_np(NULL, &tid1);
//    pthread_threadid_np(pthread_self(), &tid2);
//    NSLog(@"dic = %@, %llu, %llu", [NSThread currentThread], tid1, tid2);
//    NSLog(@"thread_id = %u pthread_id = %u thread = %@, %d",mach_thread_self(), mach_thread, [NSThread currentThread], pthread_self());
//    dumpThreads();
//    
//    const thread_t main_thread = mach_thread_self();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        const thread_t this_thread = mach_thread_self();
//        backtraceThread(main_thread);
//        backtraceThread(this_thread);
        [KtBackTraceLogger printBackTraceOfAllThread];
    });
    [self foo];
}

@end
