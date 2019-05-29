//
//  ViewController.m
//  NSCache
//
//  Created by liuweizhen on 2018/12/5.
//  Copyright © 2018 banma. All rights reserved.
//
// 参考链接：https://www.jianshu.com/p/e850f8d120b0
// https://www.jianshu.com/p/04ec045151c0

/**
 NSCache是一个类似NSDictionary一个可变的集合。
 提供了可设置缓存的数目与内存大小限制的方式。
 保证了处理的数据的线程安全性。
 NSCache的Key只是对对象进行了Strong引用，而非拷贝，因此缓存使用的key不需要是实现NSCopying的类。
 当内存警告时内部自动清理部分缓存数据。
 SDWebImage和AFNetworking都有使用它

An NSCache object is a mutable collection that stores key-value pairs, similar to an NSDictionary object. The NSCache class provides a programmatic interface to adding and removing objects and setting eviction policies （清除策略） based on the total cost and number of objects in the cache.

The NSCache class incorporates various auto-eviction policies, which ensure that a cache doesn’t use too much of the system’s memory. If memory is needed by other applications, these policies remove some items from the cache, minimizing its memory footprint.
You can add, remove, and query items in the cache from different threads without having to lock the cache yourself.
Unlike an NSMutableDictionary object, a cache does not copy the key objects that are put into it.
 */

#import "ViewController.h"

@interface ViewController () <NSCacheDelegate>

@property (nonatomic, strong) NSCache *cache;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonClick_1:(id)sender {
    _cache = [[NSCache alloc] init];
    _cache.delegate = self;
    [_cache setObject:@"cache_object" forKey:@"cache_key"];
    NSString *object = [_cache objectForKey:@"cache_key"];
    NSLog(@"%@", object);
    [_cache removeObjectForKey:@"cache_key"];
}

// NSCache的两个属性
// @property NSUInteger totalCostLimit; // limits are imprecise（不精确）/not strict
// @property NSUInteger countLimit;     // limits are imprecise/not strict
// [_cache setObject:(nonnull id) forKey:(nonnull id) cost:(NSUInteger)]
// 比如缓存一条条视频流，如果简单的实现就是用countLimit等于50来限制视频缓存的总数量不超过50条
// 即：countLimit = 50，则cache set的object <= 50
// 合理的方法是把每一条视频的大小作为cost，把最大内存100MB作为totalCostLimit
// 先看countLimit
- (IBAction)buttonClick_2:(id)sender {
    _cache = [[NSCache alloc] init];
    _cache.countLimit = 5;
    _cache.delegate = self;
    [_cache setObject:@"object_1" forKey:@"key_1" cost:1];
    [_cache setObject:@"object_2" forKey:@"key_2" cost:2];
    [_cache setObject:@"object_3" forKey:@"key_3" cost:3];
    [_cache setObject:@"object_4" forKey:@"key_4" cost:4];
    [_cache setObject:@"object_5" forKey:@"key_5" cost:5];
    [_cache setObject:@"object_6" forKey:@"key_6" cost:6]; // 删除缓存数据：object_1
    [_cache setObject:@"object_7" forKey:@"key_7" cost:7]; // 删除缓存数据：object_2
    // 注：countLimit的值代表cache setObject:forKey:cost:的调用次数，和每次set时传入的cost的值无关，因此设置countLimit=5时，当再次set时就会今次删除最先添加的object
}

// totalCostLimit代表最多允许的cost的数目，和每次setObject的cost相关
// 当加入一个新的缓存(即setObject..)之后总的cost大于totalCostLimit时，NSCache会按照加入缓存的先后顺序一个一个移除已有的缓存，直到能够放下新的缓存数据
- (IBAction)buttonClick_3:(id)sender {
    _cache = [[NSCache alloc] init];
    _cache.totalCostLimit = 5;
    _cache.delegate = self;
    [_cache setObject:@"object_1" forKey:@"key_1" cost:1];
    [_cache setObject:@"object_2" forKey:@"key_2" cost:2];
    [_cache setObject:@"object_3" forKey:@"key_3" cost:3]; // 删除缓存数据：object_1
    [_cache setObject:@"object_4" forKey:@"key_4" cost:1]; // 删除缓存数据：object_2
    [_cache setObject:@"object_5" forKey:@"key_5" cost:2]; // 删除缓存数据：object_3
    [_cache setObject:@"object_6" forKey:@"key_6" cost:3]; // 删除缓存数据：object_4
    [_cache setObject:@"object_7" forKey:@"key_7" cost:7]; // 删除缓存数据：object_5，6，7
}

#pragma mark - <NSCacheDelegate>

// 调用removeObjectForKey或内存吃紧时会调用
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"删除缓存数据：%@", obj);
}

@end
