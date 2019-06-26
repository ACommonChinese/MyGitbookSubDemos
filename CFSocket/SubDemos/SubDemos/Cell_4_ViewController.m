//
//  Cell_4_ViewController.m
//  SubDemos
//
//  Created by liuweizhen on 2019/6/26.
//  Copyright © 2019 BanMa. All rights reserved.
//

#import "Cell_4_ViewController.h"

static int32_t const kStreamBufferSize = 2048;

@interface Cell_4_ViewController () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation Cell_4_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)sendToServer:(id)sender {
    int inputNum = [self.textField.text intValue];
    if ([self.outputStream hasSpaceAvailable]) {
        [self.outputStream write:(const uint8_t *)&inputNum maxLength:sizeof(inputNum)];
    }
}

- (IBAction)connectToHost:(id)sender {
    NSString *host = @"30.16.108.149";
    UInt32 port = 1234;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (__bridge CFStringRef)host,
                                       port,
                                       &readStream,
                                       &writeStream);
    _inputStream = (__bridge NSInputStream *)(readStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

#pragma mark - <NSStreamDelegate>

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    /**
     typedef NS_OPTIONS(NSUInteger, NSStreamEvent) {
         NSStreamEventNone = 0, // 无事件
         NSStreamEventOpenCompleted = 1UL << 0, // 打开成功
         NSStreamEventHasBytesAvailable = 1UL << 1, // 有字节可读（输入流）
         NSStreamEventHasSpaceAvailable = 1UL << 2, // 有空间，可以发放字节 （输出流）
         NSStreamEventErrorOccurred = 1UL << 3, // 连接出现错误
         NSStreamEventEndEncountered = 1UL << 4 // 连接结束
     };
     */
    NSMutableData *receivedData = nil;
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream && self.inputStream.streamStatus == NSStreamStatusOpen) {
                NSLog(@"输入流打开成功");
            }
            else if (self.outputStream.streamStatus == NSStreamStatusOpen) {
                // connectionStatusDidChange:NSStreamEventOpenCompleted
                NSLog(@"输出流打开成功");
            }
            break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"inputStream 有字节可读");
            if (receivedData == nil) {
                receivedData = [[NSMutableData alloc] init];
            }
            uint8_t streamBuffer[kStreamBufferSize] = {0};
            NSInteger numBytesRead = [(NSInputStream *)aStream read:streamBuffer maxLength:kStreamBufferSize];
            if (numBytesRead == 0) {
                NSLog(@"inputStream读取完毕");
                [self clear];
                return;
            }
            else if (numBytesRead < 0) {
                NSLog(@"inputStream读取出现错误");
                return;
            }
            
            [receivedData appendBytes:streamBuffer length:numBytesRead];
            NSLog(@"inputStream读取数据%d字节", (int)numBytesRead);
            
            while ([(NSInputStream *)aStream hasBytesAvailable]) {
                numBytesRead = [(NSInputStream *)aStream read:streamBuffer maxLength:kStreamBufferSize];
                NSLog(@"inputStream读取数据%d字节", (int)numBytesRead);
                [receivedData appendBytes:streamBuffer length:numBytesRead];
            }
            NSString *str = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            self.label.text = [NSString stringWithFormat:@"%@", str];
        
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"outputStream 有空间，可以发送字节");
            
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSLog(@"连接出现错误");
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog(@"连接结束");
            break;
        }
        default:
            break;
    }
}

- (void)clear {
    [self.inputStream close];
    [self.outputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

@end
