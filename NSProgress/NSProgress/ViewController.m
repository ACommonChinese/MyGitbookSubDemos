//
//  ViewController.m
//  NSProgress
//
//  Created by liuweizhen on 2018/12/4.
//  Copyright © 2018 banma. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSProgress *progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self test1]; // 概念理解
    // [self test2]; // 子一旦完成，即完成即影响到父，并且不可再置于未完成状态无效
    // [self test3]; // 通过KVO创建简单的进度报告操作
    // [self test4]; // 添加2个子节点
    [self test5]; // 注册为当前线程根节点和取消注册, 其后的progress为它的子节点，不推荐使用
}

////////////////////////////////////////////////////////////////////////////////////////////////

// 概念理解
- (void)test1 {
    // NSProgress *progress = [NSProgress progressWithTotalUnitCount:(int64_t) parent:(nonnull NSProgress *) pendingUnitCount:(int64_t)];
    // progress.totalUnitCount // 需要完成的任务总量
    // progress.completedUnitCount // 已经完成的任务量（含子的pending数量）
    // progress.fractionCompleted // 某个任务已完成单元量占总单元量的比例（自己已完成+已完成的子的pending）/ totalUnitCount
    // progress.localizedDescription // 通过字符串的形式描述当前任务完成度, 比如：100% completed， ?% completed, 其中?为已经完成的任务量（含子的pending数量）/ totalUnitCount
    // progress.localizedAdditionalDescription // localizedAdditionalDescription: 同localizedDescription一样, 用来描述当前任务的完成度, 比如：9 of 10 (总任务量为10, 已完成任务量为9, 即 完成量/总量) x of y ==> 其中x是已经完成的任务量（含子的pending数量），y是totalUnitCount
    
    NSProgress *p1 = [NSProgress progressWithTotalUnitCount:10];
    NSProgress *p2 = [NSProgress progressWithTotalUnitCount:5 parent:p1 pendingUnitCount:20];
    NSLog(@"1--> %d", (int)p1.totalUnitCount); // 10
    NSLog(@"2--> %d", (int)p2.totalUnitCount); // 5
    NSLog(@"3--> %d", (int)p1.completedUnitCount); // 0
    p1.completedUnitCount = 5;
    NSLog(@"4--> %lf", p1.fractionCompleted); // 0.5
    NSLog(@"5--> %@", p1.localizedDescription); // 50% completed
    NSLog(@"6--> %@", p1.localizedAdditionalDescription); // 5 of 10
    NSLog(@"7--> %@", p2.localizedAdditionalDescription); // 0 of 5
    p2.completedUnitCount = 5; // 由于p2的parent是p1, 因此p2完成后，p1被加了20
    NSLog(@"8--> %lf", p2.fractionCompleted); // 1.0
    NSLog(@"9--> %lf", p1.fractionCompleted); // 2.5 ==> [5(自己已完成) + 20(子完成后添加的20)] / 10 = 2.5
    NSLog(@"10--> %d", (int)p1.totalUnitCount); // 10 ==> p1虽然有子，但totalUnitCount未发生变化
    NSLog(@"11--> %d", (int)p1.completedUnitCount); // 25 ==> 虽然p1.totalUnitCount = 10, 但已完成的+子完成的，为25
    NSLog(@"12--> %lf", p1.fractionCompleted); // 2.5
    NSLog(@"13--> %@", p1.localizedDescription); // 250% completed
    NSLog(@"14--> %@", p1.localizedAdditionalDescription); // 25 of 10
}

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)test2 {
    NSProgress *p1 = [NSProgress progressWithTotalUnitCount:10];
    NSProgress *p2 = [NSProgress progressWithTotalUnitCount:5 parent:p1 pendingUnitCount:20];
    p2.completedUnitCount = 1;
    NSLog(@"1--> %d", (int)p1.completedUnitCount); // 0
    NSLog(@"2--> %d", (int)p2.completedUnitCount); // 1
    p2.completedUnitCount = 25;
    NSLog(@"3--> %d", (int)p1.completedUnitCount); // 20
    NSLog(@"4--> %d", (int)p2.completedUnitCount); // 25
    NSLog(@"==> %@", p2.localizedDescription); // 500% completed
    p2.completedUnitCount = 1;
    NSLog(@"5--> %d", (int)p1.completedUnitCount); // 20
    NSLog(@"6--> %d", (int)p2.completedUnitCount); // 1
}

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)test3 {
    self.progress = [NSProgress progressWithTotalUnitCount:10];
    [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(task:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)task:(NSTimer *)timer {
    if (self.progress.completedUnitCount >= self.progress.totalUnitCount) {
        [timer invalidate];
        return;
    }
    self.progress.completedUnitCount += 1;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
    NSLog(@"localizedDescription --- %@", self.progress.localizedDescription);
}

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)test4 {
    // 初始化进度对象, 并设置进度总量
    self.progress = [NSProgress progressWithTotalUnitCount:20];
    
    // OK: NSProgress *sub1 = [NSProgress progressWithTotalUnitCount:10 parent:self.progress pendingUnitCount:10];
    // OK: NSProgress *sub2 = [NSProgress progressWithTotalUnitCount:10 parent:self.progress pendingUnitCount:10];
    NSProgress *sub1 = [NSProgress progressWithTotalUnitCount:10];
    NSProgress *sub2 = [NSProgress progressWithTotalUnitCount:10];
    [self.progress addChild:sub1 withPendingUnitCount:10];
    [self.progress addChild:sub2 withPendingUnitCount:10];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(task2:) userInfo:@{@"sub1" : sub1, @"sub2" : sub2} repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)task2:(NSTimer *)timer {
    NSLog(@"%@", self.progress.localizedDescription);
    
    NSDictionary *userInfo = timer.userInfo;
    NSProgress *sub1 = userInfo[@"sub1"];
    NSProgress *sub2 = userInfo[@"sub2"];
    
    if (sub1.completedUnitCount >= sub1.totalUnitCount && sub2.completedUnitCount >= sub2.totalUnitCount) {
        [timer invalidate];
    }
    
    // 当完成量达到总量时停止任务
    if (sub1.completedUnitCount < sub1.totalUnitCount) {
        sub1.completedUnitCount += 2;
    }
    if (sub2.completedUnitCount < sub2.totalUnitCount) {
        sub2.completedUnitCount += 1;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////

- (void)test5 {
    self.progress = [NSProgress progressWithTotalUnitCount:10];
    [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    [self.progress becomeCurrentWithPendingUnitCount:5];
    [self subTaskOne]; // 当一个NSProgress对象被注册为当前线程的根节点时，后面使用类方法 progressWithTotalUnitCount:创建的NSProgress对象都默认作为子节点添加
    [self.progress resignCurrent];
    [self.progress becomeCurrentWithPendingUnitCount:5];
    [self subTaskOne];
    [self.progress resignCurrent];
}

- (void)subTaskOne {
    NSProgress *sub = [NSProgress progressWithTotalUnitCount:10];
    int i=0;
    while (i<10) {
        i++;
        sub.completedUnitCount++;
    }
}

//
//NSProgress对象的用户字典中可以设置一些特定的键值来进行显示模式的设置，示例如下:
////设置剩余时间 会影响localizedAdditionalDescription的值
///*
// 例如：0 of 10 — About 10 seconds remaining
// */
//[progress setUserInfoObject:@10 forKey:NSProgressEstimatedTimeRemainingKey];
////设置完成速度信息 会影响localizedAdditionalDescription的值
///*
// 例如：Zero KB of 10 bytes (15 bytes/sec)
// */
//[progress setUserInfoObject:@15 forKey:NSProgressThroughputKey];
///*
// 下面这些键值的生效 必须将NSProgress对象的kind属性设置为 NSProgressKindFile
// NSProgressFileOperationKindKey键对应的是提示文字类型 会影响localizedDescription的值
// NSProgressFileOperationKindKey可选的对应值如下：
// NSProgressFileOperationKindDownloading： 显示Downloading files…
// NSProgressFileOperationKindDecompressingAfterDownloading： 显示Decompressing files…
// NSProgressFileOperationKindReceiving： 显示Receiving files…
// NSProgressFileOperationKindCopying： 显示Copying files…
// */
//[progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
///*
// NSProgressFileTotalCountKey键设置显示的文件总数
// 例如：Copying 100 files…
// */
//[progress setUserInfoObject:@100 forKey:NSProgressFileTotalCountKey];
////设置已完成的数量
//[progress setUserInfoObject:@1 forKey:NSProgressFileCompletedCountKey];

@end
