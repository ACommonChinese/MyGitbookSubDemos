//
//  Cell_0_ViewController.m
//  SubDemos
//
//  Created by liuweizhen on 2019/5/15.
//  Copyright © 2019 BanMa. All rights reserved.
//

#import "Cell_0_ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface Cell_0_ViewController ()

@end

@implementation Cell_0_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (IBAction)getWifiC:(id)sender {
    NSString *localIPAddress = [self getLocalIPAddressByC];
    NSLog(@"localIPAddress：==========%@", localIPAddress);
}

// https://stackoverflow.com/questions/32104279/will-en0-always-be-wi-fi-on-an-ios-device
- (IBAction)getWifiOC:(id)sender {
    [self getWifiInfo];
}

// https://stackoverflow.com/questions/32104279/will-en0-always-be-wi-fi-on-an-ios-device
// Failed
- (NSDictionary *)getWifiInfo {
    // CFArrayRef CNCopySupportedInterfaces(void);
    // Returns the names of all network interfaces Captive（捕捉，俘虏） Network Support is monitoring(监控).
    // Return value: The network interface names, as an array of CFStringRef objects. Ownership follows the The Create Rule.
    
    NSDictionary *ret = nil;
    
    // Get the supported interfaces.
    /**
     NS_INLINE id _Nullable CFBridgingRelease(CFTypeRef CF_CONSUMED _Nullable X) {
        return (__bridge_transfer id)X;
     }
     */
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    
    // Find one with a BSSID and return that. This should be the wifi.
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"Network device found = %@", info.description);
        if (info[(__bridge NSString *)kCNNetworkInfoKeyBSSID]) {
            // Return this as it should be the right one given it has a MAC address for the station
            ret=info;
        }
    }
    
    NSLog(@"Exit: returning wifi info = %@", ret.description);
    return ret;
}

/**
 struct ifaddrs {
    struct ifaddrs  *ifa_next;
    char        *ifa_name;
    unsigned int     ifa_flags;
    struct sockaddr    *ifa_addr;
    struct sockaddr    *ifa_netmask;
    struct sockaddr    *ifa_dstaddr;
    void        *ifa_data;
 };

 struct ifaddrs {
    struct ifaddrs *ifa_next;     // Next item in list, 指向链表的下一个成员
    char *ifa_name;               // Name of interface ， 接口名称，以0结尾的字符串，比如eth0
    unsigned int ifa_flags;       // Flags from SIOCGIFFLAGS, 接口的标识位（比如当IFF_BROADCAST或IFF_POINTOPOINT设置到此标识位时，影响联合体变量ifu_broadaddr存储广播地址或ifu_dstaddr记录点对点地址）
    struct sockaddr *ifa_addr;    // Address of interface，
    struct sockaddr *ifa_netmask; // Netmask of interface， 存储该接口的子网掩码
    struct sockaddr *ifa_dstaddr; //
    void *ifa_data; // Address-specific data, 存储了该接口协议族的特殊信息，它通常是NULL（一般不关注他）
 };
 
 函数getifaddrs（int getifaddrs (struct ifaddrs **__ifap)）获取本地网络接口信息，将之存储于链表中，链表头结点指针存储于__ifap中带回，函数执行成功返回0，失败返回-1，且为errno赋值。
 很显然，函数getifaddrs用于获取本机接口信息，比如最典型的获取本机IP地址
 */

- (NSString*)getLocalIPAddressByC {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    //address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    char IPdotdec[16];
                    const char* pAddr = inet_ntop(AF_INET, &((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr, IPdotdec, 16);
                    if (pAddr!=NULL && strlen(pAddr)>0) {
                        address = [NSString stringWithCString:pAddr encoding:NSUTF8StringEncoding];
                    }
                    NSLog(@"ipv4:%s",pAddr==NULL?"":pAddr);
                }
            } else if (temp_addr->ifa_addr->sa_family == AF_INET6){
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    char IPdotdec[24];
                    struct sockaddr_in6 *addr6 = (struct sockaddr_in6*)temp_addr->ifa_addr;
                    const char* pAddr = inet_ntop(AF_INET6, &addr6->sin6_addr, IPdotdec, 24);
                    if (pAddr!=NULL && strlen(pAddr)>0) {
                        address = [NSString stringWithCString:pAddr encoding:NSUTF8StringEncoding];
                    }
                    NSLog(@"ipv6:%s",pAddr==NULL?"":pAddr);
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}

@end
