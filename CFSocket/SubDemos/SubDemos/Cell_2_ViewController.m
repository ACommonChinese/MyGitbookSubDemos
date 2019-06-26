//
//  Cell_2_ViewController.m
//  SubDemos
//
//  Created by liuweizhen on 2019/5/31.
//  Copyright © 2019 BanMa. All rights reserved.
//  参考：https://blog.csdn.net/qiuyinthree/article/details/51991533

#import "Cell_2_ViewController.h"

@interface Cell_2_ViewController () <NSStreamDelegate>

@property (nonatomic, copy) NSString *filePath;
/// 输入流
@property (nonatomic, strong) NSInputStream *inputStream;
/// 输出流
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation Cell_2_ViewController

/**
 NSInputStream 输入流 - 比如把文件读入内存(buffer)
 NSOutputStream 输出流 - 比如把内存(buffer)里的数据写入文件
 NSInputStream 和 NSOutputStream其实是对 CoreFoundation 层对应的CFReadStreamRef 和 CFWriteStreamRef 的高层抽象。在使用CFNetwork时，常常会使用到CFReadStreamRef 与 CFWriteStreamRef。
 
 输入流和输出流是相对而言的, 比如：
 [[NSOutputStream alloc] initToMemory] // Returns an initialized output stream that will write to memory.
 这就代表建立输出流，从外部输出到内存
 */

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // 在Documents中创建一个测试文件，以便测试输入流和输出流
    [self createTestFile];
}

- (void)createTestFile {
    self.filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test_data.txt"];
    NSLog(@"filePath: %@", self.filePath);
    NSError *error = nil;
    NSString *msg = @"This is 测试数据";
    if ([msg writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"write text to %@ success", self.filePath);
    }
    else {
        if (error) {
            NSLog(@"write text to %@ fail: %@", self.filePath, error.localizedDescription);
        }
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    [handle seekToEndOfFile];
    NSString *newMsg = @", And again 测试数据";
    [handle writeData:[newMsg dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

- (IBAction)inputStream:(id)sender {
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:self.filePath];
    inputStream.delegate = self;
    self.inputStream = inputStream;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
}

- (IBAction)outputStream:(id)sender {
    // 输出流，输出到文件
    NSString *outPath = @"/Users/banma-623/Desktop/test.txt";
    
//    NSError *error = nil;
//    if ([@"iOS Android" writeToFile:outPath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
//        NSLog(@"create file success: %@", outPath);
//    }
//    else {
//        if (error) {
//            NSLog(@"create file to %@ fail: %@", outPath, error.localizedDescription);
//        }
//    }
    
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:outPath append:YES];
    outStream.delegate = self;
    self.outputStream = outStream;
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outStream open];
}

#pragma mark - <NSStreamDelegate>

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: { // 写
            /**
             * NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:outPath append:YES];
             * outStream和file关联，则从外面读出东西给file，hasSpaceAvailable代表文件file中有空间可写入
             */
            NSError *error = nil;
            NSString *content = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error];
            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSOutputStream *outStream = (NSOutputStream *)aStream;
            [outStream write:data.bytes maxLength:data.length];
            [outStream close];
            break;
        }
        case NSStreamEventHasBytesAvailable: { // 读
            /**
             * NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:self.filePath];
             * inputStream和file关联，则从file中读出东西给外面，HasBytesAvailable代表文件file中还有内容可读
             */
            uint8_t buffer[1024];
            NSInputStream *inputStream = (NSInputStream *)aStream;
            NSInteger bitLength = [inputStream read:buffer maxLength:sizeof(buffer)];
            if (bitLength != 0) {
                NSData *data = [NSData dataWithBytes:(const void *)buffer length:bitLength];
                NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"did read msg：%@", msg);
            }
            else {
                [aStream close];
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream event error occurred.");
            break;
        }
        case NSStreamEventEndEncountered: {
            [aStream close];
            NSLog(@"The end of the stream has been reached.");
            break;
        }
        case NSStreamEventNone: {
            NSLog(@"No event has occurred.");
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"The open has completed successfully.");
            if (aStream == self.inputStream) {
                NSLog(@"Input stream");
            }
            else {
                NSLog(@"Output stream");
            }
            break;
        }
        default:
            break;
    }
}

@end
