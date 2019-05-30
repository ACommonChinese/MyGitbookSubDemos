//
//  ViewController.m
//  LastModified_ETag
//
//  Created by liuweizhen on 2019/5/30.
//  Copyright © 2019 DaLiu. All rights reserved.
//

#import "ViewController.h"

#define kLastModifiedImageURL @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1559197432643&di=d99c5caa027c418d1995d1646e6f2c2e&imgtype=0&src=http%3A%2F%2Fpic15.nipic.com%2F20110628%2F1369025_192645024000_2.jpg"

typedef void (^GetDataCompletion)(NSData *data);

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

// 响应的 LastModified
@property (nonatomic, copy) NSString *localLastModified;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)lastModified:(id)sender {
    [self getData:^(NSData *data) {
        if (data) {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
}

- (void)getData:(GetDataCompletion)completion {
    NSURL *url = [NSURL URLWithString:kLastModifiedImageURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
    // NSURLRequestReloadIgnoringLocalCacheData: This policy specifies that no existing cache data should be used to satisfy a URL load request. 试验结果：运行中点击两次走缓存（再次运行，第一次不走缓存）
    // NSURLRequestReturnCacheDataElseLoad: Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data. 试验结果：每次都是statusCode == 200
    // NSURLRequestReturnCacheDataDontLoad: Use existing cache data, regardless or age or expiration date, and fail if no cached data is available. 试验结果：每次都是statusCode == 200
    
    // 发送 LastModified
    if (self.localLastModified.length > 0) {
        [request setValue:self.localLastModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"statusCode == %@", @(httpResponse.statusCode));
        // 判断响应的状态码是否是 304 Not Modified （更多状态码含义解释： https://github.com/ChenYilong/iOSDevelopmentTips）
        if (httpResponse.statusCode == 304) {
            NSLog(@"加载本地缓存图片");
            // 如果是，使用本地缓存
            // 根据请求获取到`被缓存的响应`！
            NSCachedURLResponse *cacheResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            // 拿到缓存的数据
            data = cacheResponse.data;
        }
        // 获取并且纪录 LastModified
        self.localLastModified = httpResponse.allHeaderFields[@"Last-Modified"];
        NSLog(@"localLastModified: %@", self.localLastModified);
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(data);
        });
    }];
    [task resume];
}

@end
