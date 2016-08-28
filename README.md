# BSBacktraceLogger —— 轻量级调用栈分析器

这是一个强大且轻量的线程调用栈分析器，只有一个类，四百行代码。它支持现有所有模拟器、真机的 CPU 架构，可以获取任意线程的调用栈，因此可以在检测到 runloop 检测到卡顿时获取卡顿处的代码执行情况。

## 用法

```objc
#import "BSBacktraceLogger.h"

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BSLOG  // 打印当前线程的调用栈
        BSLOG_ALL  // 打印所有线程的调用栈
        BSLOG_MAIN  // 打印主线程调用栈
    });
    [self foo];
}

- (void)foo {
    [self bar];
}

- (void)bar {
    while (true) {
        ;
    }
}
```

定义了三个宏用于快速输出，或者调用 `[BSBacktraceLogger bs_backtraceOfCurrentThread]` 等函数获取字符串格式的调用栈。

## 样例

上述代码中，`BSLOG_MAIN` 这个宏的输出结果如下:

```objc
2016-08-27 18:33:20.017 BSBacktraceLogger[25215:862569] Backtrace of Thread 1803:
KtBacktraceLogger               0x10b831f4c -[ViewController bar] + 12
KtBacktraceLogger               0x10b831f2b -[ViewController foo] + 43
KtBacktraceLogger               0x10b831fe0 -[ViewController viewDidLoad] + 128
UIKit                           0x10c813984 -[UIViewController loadViewIfRequired] + 1198
UIKit                           0x10c813cd3 -[UIViewController view] + 27
UIKit                           0x10c6e9fb4 -[UIWindow addRootViewControllerViewIfPossible] + 61
UIKit                           0x10c6ea69d -[UIWindow _setHidden:forced:] + 282
UIKit                           0x10c6fc180 -[UIWindow makeKeyAndVisible] + 42
UIKit                           0x10c670ed9 -[UIApplication _callInitializationDelegatesForMainScene:transitionContext:] + 4131
UIKit                           0x10c677568 -[UIApplication _runWithMainScene:transitionContext:completion:] + 1769
UIKit                           0x10c674714 -[UIApplication workspaceDidEndTransaction:] + 188
FrontBoardServices              0x10f0e18c8 __FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 24
FrontBoardServices              0x10f0e1741 -[FBSSerialQueue _performNext] + 178
FrontBoardServices              0x10f0e1aca -[FBSSerialQueue _performNextFromRunLoopSource] + 45
CoreFoundation                  0x10c1e8301 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
CoreFoundation                  0x10c1de22c __CFRunLoopDoSources0 + 556
CoreFoundation                  0x10c1dd6e3 __CFRunLoopRun + 867
CoreFoundation                  0x10c1dd0f8 CFRunLoopRunSpecific + 488
UIKit                           0x10c673f21 -[UIApplication _run] + 402
UIKit                           0x10c678f09 UIApplicationMain + 171
KtBacktraceLogger               0x10b8338ff main + 111
libdyld.dylib                   0x10ea9c92d start + 1
```

## 说明

Xcode 的调试输出不稳定，有时候存在调用 `NSLog()` 但没有输出结果的情况，建议前往 **控制台** 中根据设备的 UUID 查看完整输出。

真机调试和使用 Release 模式时，为了优化，某些符号表并不在内存中，而是存储在磁盘上的 dSYM 文件中，无法在运行时解析，因此符号名称显示为 `<redacted>`。
