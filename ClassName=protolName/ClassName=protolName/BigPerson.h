//
//  BigPerson.h
//  ClassName=protolName
//
//  Created by liuweizhen on 2019/5/29.
//  Copyright © 2019 DaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BigPerson : NSObject

@end

@interface BigPerson (Person) <Person>

@end

NS_ASSUME_NONNULL_END
