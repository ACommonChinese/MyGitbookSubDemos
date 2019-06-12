//
//  main.cpp
//  server
//
//  Created by liuweizhen on 2019/6/12.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define BUF_SIZE 100

int main(int argc, const char * argv[]) {
    // 创建套接字
    int serv_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    // 绑定IP, 端口
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.105");
    serv_addr.sin_port = htons(1234);
    bind(serv_sock, (const struct sockaddr *)&serv_addr, sizeof(serv_addr));
    
    // 进入监听状态
    listen(serv_sock, 20);
    
    // 接收客户端请求
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size = sizeof(clnt_addr);
    char buffer[BUF_SIZE] = {0}; // 缓冲区
    while (1) {
        int clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size); // 对应client的connect
        size_t length = BUF_SIZE;
        ssize_t strLen = recv(clnt_sock, buffer, length, 0);  //接收客户端发来的数据
        send(clnt_sock, buffer, strLen, 0); // 将数据原样返回
        close(clnt_sock);
        memset(buffer, 0, BUF_SIZE);
    }
    close(serv_sock); // Code will never be executed
    
    return 0;
}
