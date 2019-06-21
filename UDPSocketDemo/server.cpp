//
//  main.cpp
//  server_udp
//
//  Created by liuweizhen on 2019/6/21.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define BUF_SIZE 1024

int main(int argc, const char * argv[]) {
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET; // 使用IPv4
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); // 如果是TCP, 形如：inet_addr("30.16.104.94");
    serv_addr.sin_port = htons(1234);  //端口
    
    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP); // 最后一个参数可写为0
    bind(sock, (const struct sockaddr *)&serv_addr, sizeof(serv_addr));
    
    // listen(serv_sock, 20) UDP不需要监听
    // int clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size) UDP无连接
    
    // 接收客户端请求
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size = sizeof(clnt_addr);
    char buffer[BUF_SIZE];
    while (1) {
        /**
         ssize_t
         recvfrom(int socket,
                  void *restrict buffer,
                  size_t length,
                  int flags,
                  struct sockaddr *restrict address,
                  socklen_t *restrict address_len);
         */

        ssize_t recv_len = recvfrom(sock, buffer, BUF_SIZE, 0, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
    
        sendto(sock, buffer, recv_len, 0, (const struct sockaddr *)&clnt_addr, clnt_addr_size);
    }
    close(sock);
    
    return 0;
}
