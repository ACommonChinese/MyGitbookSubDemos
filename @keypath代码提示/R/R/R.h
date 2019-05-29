//
//  R.h
//  R
//
//  Created by liuweizhen on 2018/12/10.
//  Copyright © 2018 daliu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Computer : NSObject

@property (nonatomic) float price;

@end

@interface RoundedButton : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) Computer *computer;

@end

@interface R : NSObject

@property (nonatomic, strong) RoundedButton *button;
@property (nonatomic, strong) NSString *price;

- (void)test;

@end

NS_ASSUME_NONNULL_END
