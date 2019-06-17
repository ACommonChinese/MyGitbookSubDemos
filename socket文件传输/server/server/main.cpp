//
//  main.cpp
//  server
//
//  Created by liuweizhen on 2019/6/17.
//  Copyright © 2019 liuxing8807@126.com. All rights reserved.
//  client 从 server 下载一个文件并保存到本地

/**
 ==== fread ====
 size_t fread(void *restrict ptr, size_t size, size_t nitems, FILE *restrict stream);
 
 The function fread() reads nitems objects, each size bytes long, from the
 stream pointed to by stream, storing them at the location given by ptr.
 
 示例：
 int nCount;
 while( (nCount = fread(buffer, 1, BUF_SIZE, fp)) > 0 ){ // 当读取到文件末尾，fread() 会返回 0
    send(sock, buffer, nCount, 0);
 }
 
 ==== fwrite ====
 size_t fwrite(const void *restrict ptr, size_t size, size_t nitems, FILE *restrict stream);
 The function fwrite() writes nitems objects, each size bytes long, to the
 stream pointed to by stream, obtaining them from the location given by
 ptr.
 
 示例：
 int nCount;
 while( (nCount = recv(clntSock, buffer, BUF_SIZE, 0)) > 0 ){
    fwrite(buffer, nCount, 1, fp);
 }
 注意：读取完缓冲区中的数据 recv() 并不会返回 0，而是被阻塞，直到缓冲区中再次有数据，因此我们需要在文件传输完毕后让 recv() 返回 0，结束 while 循环
 recv() 返回 0 的唯一时机就是收到FIN包时，我们调用 shutdown() 来发送FIN包：server 端直接调用 close()/closesocket() 会使输出缓冲区中的数据失效，文件内容很有可能没有传输完毕连接就断开了，而调用 shutdown() 会等待输出缓冲区中的数据传输完毕
 */

#include <iostream>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define BUF_SIZE 1024

int main(int argc, const char * argv[]) {
    char *filename = "/Users/banma-623/Desktop/wxy.jpeg";
    FILE *fp = fopen(filename, "rb"); // 以二进制方式打开文件
    if (fp == NULL) {
        printf(" 🌎: cannot open file, press any key to exit!\n");
        system("pause");
        exit(0);
    }
    
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr("30.16.104.94");
    serv_addr.sin_port = htons(1234);
    
    int serv_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    bind(serv_sock, (const struct sockaddr *)&serv_addr, sizeof(serv_addr));
    
    listen(serv_sock, 20);
    
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size = sizeof(clnt_addr);
    int clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
    
    // 循环发送数据，直到文件结尾
    char buffer[BUF_SIZE] = {0};
    size_t nCount;
    // size_t fread(void *restrict ptr, size_t size, size_t nitems, FILE *restrict stream);
    // 从stream中读取nitems个objects, 每个object占size个byte，存入ptr
    while ((nCount = fread(buffer, 1, BUF_SIZE, fp)) > 0) {
        send(clnt_sock, buffer, nCount, 0);
    }
    shutdown(clnt_sock, SHUT_WR); // 文件读取完毕，断开输出流，如果输出缓冲区尚有内容，则先输出完内容，然后向客户端发送FIN包
    recv(clnt_sock, buffer, BUF_SIZE, 0); // 阻塞，等待客户端接收完毕, 当 client 端调用 closesocket() 后，server 端会收到FIN包，recv() 就会返回，后面的代码继续执行
    
    fclose(fp);
    close(clnt_sock);
    close(serv_sock);
    
    return 0;
}
