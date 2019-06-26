//
//  Cell_1_ViewController.m
//  SubDemos
//
//  Created by liuweizhen on 2019/5/20.
//  Copyright © 2019 BanMa. All rights reserved.
//

#import "Cell_1_ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface Cell_1_ViewController ()

@end

@implementation Cell_1_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     SSID: Service Set Identifier, 服务集标识
     SSID技术可以将一个无线局域网分为几个需要不同身份验证的子网络，每一个子网络都需要独立的身份验证，只有通过身份验证的用户才可以进入相应的子网络，防止未被授权的用户进入本网络。
     SSID（Service Set Identifier），许多人认为可以将SSID写成ESSID，其实不然，SSID是个笼统的概念，包含了ESSID和BSSID，用来区分不同的网络，最多可以有32个字符
     SSID就是一个局域网的名称，只有设置为名称相同SSID的值的电脑才能互相通信
     
     通常，手机WLAN中，bssid其实就是无线路由的MAC地址. ESSID 也可认为是SSID, WIFI 网络名
     */
    [self fetchSSIDInfo];
}

- (id)fetchSSIDInfo {
    // CFArrayRef CNCopySupportedInterfaces(void);
    // Returns the names of all network interfaces Captive Network Support is monitoring.
    //  an array of CFStringRef objects
    id value = @"";
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    /** po ifs
     <__NSCFArray 0x2827a77c0>(
     en0
     )
     */
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam); // iOS12之后需在Capabilities中打开Access WiFi Information
        NSLog(@"SSID: %@", [info objectForKey:@"SSID"]); // WIFI的名字，比如：alibaba-inc
        NSLog(@"BSSID: %@", [info objectForKey:@"BSSID"]); // 无线路由的MAC地址：14:1d:ba:72:bb:b8
        
        if (info[@"SSID"]) {
            value = info[@"SSID"];
        }
    }
    if (!value || [value length] == 0) {
        NSLog(@"get WiFi SSID Error!!");
    }
    return value;
}

@end
