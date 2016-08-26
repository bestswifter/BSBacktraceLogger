//
//  ViewController.m
//  KtBacktraceLogger
//
//  Created by 张星宇 on 16/8/26.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#if defined(__arm__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(1UL))
#elif defined(__arm64__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(3UL))
#else
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#endif

#define CALL_INSTRUCTION_FROM_RETURN_ADDRESS(A) (DETAG_INSTRUCTION_ADDRESS((A)) - 1)

#if defined(__LP64__)
#define TRACE_FMT         "%-4d%-31s 0x%016lx %s + %lu"
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#else
#define TRACE_FMT         "%-4d%-31s 0x%08lx %s + %lu"
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
#endif

#import "ViewController.h"

#import <mach/mach.h>
#include <dlfcn.h>
#include "KSDynamicLinker.h"
#include <pthread.h>
#include <sys/types.h>

@interface ViewController ()

@end

@implementation ViewController


const char* ksfu_lastPathEntry(const char* const path)
{
    if(path == NULL)
    {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}

void ksbt_symbolicate(const uintptr_t* const backtraceBuffer,
                      Dl_info* const symbolsBuffer,
                      const int numEntries,
                      const int skippedEntries)
{
    int i = 0;
    
    if(!skippedEntries && i < numEntries)
    {
        ksdl_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++)
    {
        ksdl_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolsBuffer[i]);
    }
}

void kscrw_i_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo)
{
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = ksfu_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL)
    {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL)
    {
        sprintf(saddrBuff, POINTER_SHORT_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    printf("%s\n", fname);
    printf("%lu\n", address);
    printf("name =%s\n", sname);
    printf("%lu\n\n", offset);
}

static int getThreadsCount(){
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;
    
    const task_t this_task     = mach_task_self();
    const thread_t this_thread = mach_thread_self();
    
    
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);
    pthread_t pt = pthread_from_mach_thread_np(threads[0]);
    if(kr != KERN_SUCCESS) {
        // printf("error getting threads: %s", mach_error_string(kr));
        return NO;
    }
    
    NSLog(@"%@", [NSThread callStackSymbols]);
    NSLog(@"%@", [NSThread currentThread]);
    for(int i = 0; i < thread_count; i++) {
        NSLog(@"打印线程 %u", threads[i]);
        backtraceThread(threads[i]);
    }
    
    NSLog(@"开始打印主线程 %u", this_thread);
    backtraceThread(this_thread);
    
    
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
    uintptr_t backtraceBuffer[40];
    int i = 0;
    
    _STRUCT_MCONTEXT machineContext;
    if(!fillThreadStateIntoMachineContext(thread, &machineContext)) {
        return 0;
    }
    
    const uintptr_t instructionAddress = mach_instructionAddress(&machineContext);
    backtraceBuffer[i] = instructionAddress;
    ++i;
    
    uintptr_t linkRegister = mach_linkRegister(&machineContext);
    if (linkRegister) {
        backtraceBuffer[i] = linkRegister;
        i++;
    }
    
    if(instructionAddress == 0) {
        return 0;
    }
    
    KtStackFrameEntry frame      = {0};
    const uintptr_t framePtr = mach_framePointer(&machineContext);
    if(framePtr == 0 ||
       mach_copyMem((void *)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS) {
        return 0;
    }
    
    
    for(; i < INT_MAX; i++)
    {
        printf("%p\n", frame.return_address);
        backtraceBuffer[i] = frame.return_address;
        if(backtraceBuffer[i] == 0 ||
           frame.previous == 0 ||
           mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
            break;
        }
    }
    
    NSLog(@"i = %d", i);
    
    int backtraceLength = i;
    Dl_info symbolicated[backtraceLength];
    ksbt_symbolicate(backtraceBuffer, symbolicated, backtraceLength, 0);
//    ksdl_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolicated[i]);
//    dladdr((void *)backtraceBuffer[i], &symbolicated[i]);
    for (int i = 0; i < backtraceLength; ++i) {
        kscrw_i_logBacktraceEntry(i, backtraceBuffer[i], &symbolicated[i]);
    }
    
    return i;
}

static void dumpThreads(void) {
    char name[256];
    mach_msg_type_number_t count;
    thread_act_array_t list;
    task_threads(mach_task_self(), &list, &count);
    for (int i = 0; i < count; ++i) {
        pthread_t pt = pthread_from_mach_thread_np(list[i]);
        if (pt) {
            name[0] = '\0';
            int rc = pthread_getname_np(pt, name, sizeof name);
            NSLog(@"mach thread %u: getname returned %d: %s", list[i], rc, name);
        } else {
            NSLog(@"mach thread %u: no pthread found", list[i]);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    getThreadsCount();
    [[NSThread currentThread] setName:@"main thread"];
    
    mach_port_t mach_thread = pthread_mach_thread_np(pthread_self());
    uint64_t tid1, tid2;
    pthread_threadid_np(NULL, &tid1);
    pthread_threadid_np(pthread_self(), &tid2);
    NSLog(@"dic = %@, %llu, %llu", [NSThread currentThread], tid1, tid2);
    NSLog(@"thread_id = %u pthread_id = %u thread = %@, %d",mach_thread_self(), mach_thread, [NSThread currentThread], pthread_self());
    dumpThreads();
    
    const thread_t main_thread = mach_thread_self();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        const thread_t this_thread = mach_thread_self();
        backtraceThread(main_thread);
        backtraceThread(this_thread);
    });
    [self foo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)foo {
    [self bar];
}

- (void)bar {
    while (true) {
        ;
    }
}

@end
