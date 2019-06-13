//
//  main.cpp
//  client
//
//  Created by liuweizhen on 2019/6/13.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define BUF_SIZE 100

int main(int argc, const char * argv[]) {
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.105");
    serv_addr.sin_port = htons(1234);
    
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    int flag = connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    if (flag == 0) {
        printf("success connect to server\n");
    }
    else {
        printf("fail connect to server\n");
        return 0;
    }
    
    char bufSend[BUF_SIZE] = {0};
    printf("Input a string:");
    // gets(bufSend);
    scanf("%s", bufSend);
    for (int i = 0; i < 3; i++) {
        printf("👤 ----> 🌎: %s\n", bufSend);
        send(sock, bufSend, strlen(bufSend), 0);
    }

    char bufRecv[BUF_SIZE] = {0};
    recv(sock, bufRecv, BUF_SIZE, 0);
    printf("🌎 ----> 👤: %s\n", bufRecv);
    
    close(sock);
    
    return 0;
}
