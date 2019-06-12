//
//  main.cpp
//  client
//
//  Created by liuweizhen on 2019/6/12.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define BUF_SIZE 100

int main(int argc, const char * argv[]) {
    // 向服务器发起请求
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.105");
    serv_addr.sin_port = htons(1234);
    
    char bufSend[BUF_SIZE] = {0};
    char bufRecv[BUF_SIZE] = {0};
    
    while (1) {
        int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        int flag = connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)); // 对应server的accept
        if (flag == 0) {
            // printf("success connect to server\n");
        }
        else {
            printf("fail connect to server\n");
        }
        printf("Input a string:");
        // scanf("%s", bufSend);
        gets(bufSend); // 支持空格输入
        send(sock, bufSend, strlen(bufSend), 0);
        recv(sock, bufRecv, BUF_SIZE, 0); // 接收服务器传回的数据
        printf("Message from server: %s\n", bufRecv);
        memset(bufSend, 0, BUF_SIZE);  //重置缓冲区
        memset(bufRecv, 0, BUF_SIZE);  //重置缓冲区
        close(sock);
    }
    
    return 0;
}
