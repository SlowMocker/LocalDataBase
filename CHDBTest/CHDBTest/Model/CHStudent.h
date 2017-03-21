//
//  CHStudent.h
//  CHDBTest
//
//  Created by Wu on 17/3/20.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "CHBaseModel.h"
#import "CHTeacher.h"

@interface CHStudent : CHBaseModel

@property (nonatomic , copy) NSString *sid;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , strong) NSArray *books;
@property (nonatomic , strong) CHTeacher *teacher;

@end
