//
//  CHLocalDataHandle.m
//  LocalDataBase
//
//  Created by Wu on 17/3/17.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "CHLocalDataHandle.h"


@interface CHLocalDataHandle()<CHLocalDBConfigurationDelegate>

@end

@implementation CHLocalDataHandle



- (CHLocalDataBase *) db {
    if (!_db) {
//        _db = [[CHLocalDataBase alloc]init]; // 默认配置
        CHLocalDBConfiguration *config = [CHLocalDBConfiguration new];
        config.delegate = self;
        _db = [[CHLocalDataBase alloc]initWithConfiguration:config];
    }
    return _db;
}



@end
