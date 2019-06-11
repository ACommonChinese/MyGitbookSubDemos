//
//  main.cpp
//  client_cpp
//
//  Created by liuweizhen on 2019/6/6.
//  Copyright © 2019 DaLiu. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

int main(int argc, const char * argv[]) {
    // 创建套接字
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    
    // 向服务器（特定的IP和端口）发起请求
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));  // 每个字节都用0填充
    serv_addr.sin_family = AF_INET;  // 使用IPv4地址
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.56");  // 具体的IP地址
    serv_addr.sin_port = htons(1234);  // 端口
    int flag = connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    if (0 == flag) {
        printf("连接Server成功");
    }
    else {
        printf("连接Server失败");
        return 0;
    }
    // 读取服务器传回的数据
    char buffer[180];
    read(sock, buffer, 300); // read 方法：http://www.man7.org/linux/man-pages/man2/read.2.html

    printf("%s\n", buffer);
    
    int input_num;
    printf("please input number:");
    scanf("%d", &input_num);
    // printf("get input number: %d - %lu", input_num, sizeof(input_num));
    write(sock, (const void *)&input_num, sizeof(input_num)); // write to server
    char buffer2[200];
    read(sock, buffer2, sizeof(buffer2));
    printf("\nserver响应: %s\n", buffer2);
    
    // 关闭套接字
    close(sock);
    
    return 0;
}
