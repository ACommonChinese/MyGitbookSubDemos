//
//  main.m
//  ClassName=protolName
//
//  Created by liuweizhen on 2019/5/29.
//  Copyright © 2019 DaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "BigPerson.h"

id<Person> getPerson() {
    return Person.new;
    // return BigPerson.new;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [getPerson() think];
    }
    return 0;
}


