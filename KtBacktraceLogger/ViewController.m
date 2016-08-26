//
//  ViewController.m
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/26.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import "ViewController.h"
#import <mach/mach.h>

@interface ViewController ()

@end

@implementation ViewController

static int getThreadsCount(){
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;
    
    const task_t this_task     = mach_task_self();
    const thread_t this_thread = mach_thread_self();
    
    
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);
    
    if(kr != KERN_SUCCESS) {
        // printf("error getting threads: %s", mach_error_string(kr));
        return NO;
    }
    
    for(int i = 0; i < thread_count; i++) {
        backtraceThread(threads[i]);
    }
    
    NSLog(@"开始打印主线程");
    backtraceThread(this_thread);
    NSLog(@"%@", [NSThread callStackSymbols]);
    NSLog(@"%@", [NSThread currentThread]);
    
    return thread_count;
}

bool  fillThreadStateIntoMachineContext(thread_t thread, _STRUCT_MCONTEXT *machineContext) {
    mach_msg_type_number_t state_count = ARM_THREAD_STATE64_COUNT;
    kern_return_t kr = thread_get_state(thread, ARM_THREAD_STATE64, (thread_state_t)&machineContext->__ss, &state_count);
    return (kr == KERN_SUCCESS);
}

uintptr_t  mach_framePointer(mcontext_t const machineContext){
    return machineContext->__ss.__fp;
}

uintptr_t  mach_stackPointer(mcontext_t const machineContext){
    return machineContext->__ss.__sp;
}

uintptr_t  mach_instructionAddress(mcontext_t const machineContext){
    return machineContext->__ss.__pc;
}

uintptr_t  mach_linkRegister(mcontext_t const machineContext){
    return machineContext->__ss.__lr;
}

typedef struct KtStackFrameEntry
{
    const struct SunFrameEntry *const previous;
    
    const uintptr_t return_address;
} KtStackFrameEntry;



kern_return_t  mach_copyMem(const void *const src,
                            void *const       dst,
                            const size_t      numBytes){
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(),
                             (vm_address_t)src,
                             (vm_size_t)numBytes,
                             (vm_address_t)dst,
                             &bytesCopied);
}

int  backtraceThread(thread_t thread) {
    
    
    _STRUCT_MCONTEXT machineContext;
    if(!fillThreadStateIntoMachineContext(thread, &machineContext)) {
        return 0;
    }
    
    const uintptr_t instructionAddress = mach_instructionAddress(&machineContext);
    
    if(instructionAddress == 0) {
        return 0;
    }
    
    KtStackFrameEntry frame      = {0};
    const uintptr_t framePtr = mach_framePointer(&machineContext);
    if(framePtr == 0 ||
       mach_copyMem((void *)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS) {
        return 1;
    }
    
    
    for(int i = 1; i < INT_MAX; i++)
    {
        //printf("%lx\n", frame.return_address);
        if(frame.previous == 0 ||
           mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
            NSLog(@"i = %d", i);
            return i;
        }
    }
    
    return INT_MAX;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    getThreadsCount();
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //        getThreadsCount();
    //    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
