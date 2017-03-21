//
//  CHLStudentDataHandle.h
//  CHDBTest
//
//  Created by Wu on 17/3/20.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "CHLocalDataHandle.h"
#import "CHStudent.h"
#import "CHTeacher.h"

@interface CHLStudentDataHandle : CHLocalDataHandle

/**
 *  添加学生
 */
+ (void) addStudents:(NSArray<CHStudent *> *)students;
/**
 *  删除学生
 *
 *  @param idNums 学号集合
 */
+ (void) deleteStudentsWithSids:(NSArray<NSString *> *)idNums;
/**
 *  所有学生
 */
+ (NSArray<CHStudent *> *) allStudents;
/**
 *  指定学号的学生信息
 */
+ (NSArray<CHStudent *> *) studentsWithSids:(NSArray<NSString *> *)sids;
/**
 *  通过 students 信息，重置学生文件信息
 */
+ (void) resetStudentsFileWithStudents:(NSArray<CHStudent *> *)students;

@end
