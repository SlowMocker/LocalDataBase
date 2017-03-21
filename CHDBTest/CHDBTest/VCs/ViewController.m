//
//  ViewController.m
//  LocalDataBase
//
//  Created by Wu on 17/3/17.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "ViewController.h"
#import "CHLStudentDataHandle.h"
#import "CHStudent.h"
#import "CHTeacher.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testDataBase];
}

- (void) testDataBase {
    // 清空本地学生信息
    [CHLStudentDataHandle resetStudentsFileWithStudents:nil];
    
    CHStudent *s1 = [CHStudent new];
    s1.sid = @"123";
    
    CHStudent *s2 = [CHStudent new];
    s2.sid = @"1234";
    s2.name = @"lilei";
    
    CHTeacher *teacher = [CHTeacher new];
    teacher.name = @"missgao";
    
    CHStudent *s3 = [CHStudent new];
    s3.sid = @"12345";
    s3.name = @"hanmei";
    s3.teacher = teacher;
    
    // 添加学生
    [CHLStudentDataHandle addStudents:@[s1,s2,s3]];
    // 获取学生 打印
    [self logStudents:[CHLStudentDataHandle allStudents]];
    
    CHStudent *s4 = [CHStudent new];
    s4.sid = @"12345";
    s4.name = @"hanmeimei";
    // 添加重复学生
    [CHLStudentDataHandle addStudents:@[s4]];
    NSLog(@"添加重复学生：");
    [self logStudents:[CHLStudentDataHandle allStudents]];
    
    NSLog(@"删除学生：");
    // 删除学生 打印
    [CHLStudentDataHandle deleteStudentsWithSids:@[@"123"]];
    [self logStudents:[CHLStudentDataHandle allStudents]];
    
    
}

- (void) logStudents:(NSArray<CHStudent *> *)students {
    [students enumerateObjectsUsingBlock:^(CHStudent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"student%d: %@",idx,[(CHStudent *)obj toDictionary]);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
