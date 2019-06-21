//
//  main.cpp
//  client_udp
//
//  Created by liuweizhen on 2019/6/21.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#define BUF_SIZE 1024

int main(int argc, const char * argv[]) {
    // 服务器地址信息
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));  //每个字节都用0填充
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.120");
    serv_addr.sin_port = htons(1234);
    
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    
    // 不断获取用户输入并发送给服务器，然后接受服务器数据
    struct sockaddr_in fromaddr;
    size_t fromaddr_len = sizeof(fromaddr);
    
    while (1) {
        char buffer[BUF_SIZE] = {0};
        printf("Input a string:");
        gets(buffer);
        sendto(sock, buffer, strlen(buffer), 0, (const struct sockaddr *)&serv_addr, sizeof(serv_addr)); // 发送给server，带上server地址
        ssize_t rec_len = recvfrom(sock, buffer, BUF_SIZE, 0, (struct sockaddr *)&fromaddr, (socklen_t *)&fromaddr_len);
        
        // buffer[rec_len] = {0};
        printf("Message form server: %s - length: %ld字节\n", buffer, rec_len);
    }
    
    close(sock);
    
    return 0;
}
