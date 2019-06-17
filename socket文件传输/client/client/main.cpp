//
//  main.cpp
//  client
//
//  Created by liuweizhen on 2019/6/17.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//

#include <iostream>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define BUF_SIZE 1024

int main(int argc, const char * argv[]) {
    char filename[100] = {0};
    printf("Input filename to save: ");
    gets(filename);
    FILE *fp = fopen(filename, "wb"); //以二进制方式打开（创建）文件
    if (fp == NULL) {
        printf("👤: cannot open file, press any key to exit!\n");
        system("pause");
        exit(0);
    }
    
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.94");
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
    
    // 循环接收数据，直到文件传输完毕
    char buffer[BUF_SIZE] = {0};
    ssize_t nCount;
    while( (nCount = recv(sock, buffer, BUF_SIZE, 0)) > 0 ) { // 当收到server发来的FIN时，recv返回0
        fwrite(buffer, nCount, 1, fp);
    }
    puts("File transfer success!");
    
    fclose(fp);
    close(sock);
    system("puase");
    
    return 0;
}
