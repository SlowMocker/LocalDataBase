//
//  CHLStudentDataHandle.m
//  CHDBTest
//
//  Created by Wu on 17/3/20.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "CHLStudentDataHandle.h"

static NSString *const primaryKey = @"sid";

@interface CHLStudentDataHandle()<CHLocalDBConfigurationDelegate>

@end

@implementation CHLStudentDataHandle

/**
 *  添加学生
 */
+ (void) addStudents:(NSArray<CHStudent *> *)students {
    [[[self alloc] db] localAddObjs:students primaryKey:primaryKey toFilePath:[self studentFilePath]];
}
/**
 *  删除学生
 *
 *  @param idNums 学号集合
 */
+ (void) deleteStudentsWithSids:(NSArray<NSString *> *)idNums {
    [[[self alloc] db] localDeleteObjsWithPrimaryKey:primaryKey primaryValues:idNums filePath:[self studentFilePath]];
}
/**
 *  所有学生
 */
+ (NSArray<CHStudent *> *) allStudents {
    return [[[self alloc] db] localAllObjsWithFilePath:[self studentFilePath]];
}
/**
 *  指定学号的学生信息
 */
+ (NSArray<CHStudent *> *) studentsWithSids:(NSArray<NSString *> *)sids {
    return [[[self alloc] db] localSearchObjWithFilePath:[self studentFilePath] primaryKey:primaryKey primaryValues:sids];
}
/**
 *  通过 students 信息，重置学生文件信息
 */
+ (void) resetStudentsFileWithStudents:(NSArray<CHStudent *> *)students {
    [[[self alloc] db] localResetFile:students primaryKey:primaryKey filePath:[self studentFilePath]];
}
/**
 *  本地存储学生信息文件路径
 */
+ (NSString *) studentFilePath {
    return [NSString stringWithFormat:@"%@%@",CH_DOCUMENT_PATH,@"students.archive"];
}

#pragma mark
#pragma mark CHLocalDBConfigurationDelegate

- (NSArray *) mergeRepeatItemWithOldObj:(NSObject *)oldObj newObj:(NSObject *)newObj {
    // 覆盖
    // return @[newObj];
    // 保留老数据
    // return @[oldObj];
    // 合并
    CHStudent *student = (CHStudent *)newObj;
    student.sid = [NSString stringWithFormat:@"%@_%f",student.sid,[[NSDate date] timeIntervalSince1970]];
    return @[oldObj , student];
}

- (NSData *) encryptionData:(NSData *)data {
    // 没有额外加密
    return data;
}

- (NSData *) decryptionData:(NSData *)data {
    // 没有额外加密
    return data;
}

@end
