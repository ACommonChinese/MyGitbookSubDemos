//
//  R.m
//  R
//
//  Created by liuweizhen on 2018/12/10.
//  Copyright © 2018 daliu. All rights reserved.
//

#import "R.h"

@implementation Computer

@end

@implementation RoundedButton

@end

@implementation R

#define keypath2(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

#define keypath3(OBJ, PATH_1, PATH_2) \
(((void)(NO && ((void)OBJ.PATH_1, (void)OBJ.PATH_2, NO)), # PATH_1))

- (void)test {
    // Student s;
    // keypath2(s, age)
    NSLog(@"%@", @keypath2(NSObject, version));
    R *r = [[R alloc] init];
    NSLog(@"%@", @keypath2(r, button.computer.price));
    keypath3(r, button, price);
}

@end
