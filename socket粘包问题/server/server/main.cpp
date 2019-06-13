//
//  main.cpp
//  server
//
//  Created by liuweizhen on 2019/6/13.
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
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.105");
    serv_addr.sin_port = htons(1234);
    
    int serv_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    bind(serv_sock, (const struct sockaddr *)&serv_addr, sizeof(serv_addr));
    
    listen(serv_sock, 20);
    
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size = sizeof(clnt_addr);
    int clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
    
    sleep(10); // 暂停10秒

    // 接收客户端发来的数据，并原样返回
    char buffer[BUF_SIZE] = {0};
    ssize_t recv_len = recv(clnt_sock, buffer, BUF_SIZE, 0);
    printf("Get from 👤: %s\n", buffer);
    send(clnt_sock, buffer, recv_len, 0);
    
    close(clnt_sock);
    close(serv_sock);
    
    return 0;
}
