//
//  CHLocalHandle.m
//  CH_IPP_SH_SDK
//
//  Created by Wu on 17/3/14.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "CHLocalDataBase.h"

@interface CHLocalDataBase()

@property (nonatomic , strong) CHLocalDBConfiguration *config;

@end

@implementation CHLocalDataBase
// sync
- (id) initWithConfiguration:(CHLocalDBConfiguration *)config {
    self = [super init];
    if (self) {
        if (config) {
            self.config = config;
        }
    }
    return self;
}
// 增
- (void) localAddObjs:(NSArray<NSCopying , NSCoding> *)objs primaryKey:(NSString *)key toFilePath:(NSString *)path {
    NSMutableArray *dataArrM = [NSMutableArray new];
    
    NSMutableArray *objArrM = [NSMutableArray new];
    // 取出原数据转成数据模型数组
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        for (NSData *data in [NSArray arrayWithContentsOfFile:path]) {
            NSData *encryptionData;
            // 自定义解密
            if (self.config.delegate && [self.config.delegate respondsToSelector:@selector(decryptionData:)]) {
                encryptionData = [self.config.delegate decryptionData:data];
            }
            else {
                encryptionData = data;
            }
            // 解密 base64
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedData:encryptionData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSKeyedUnarchiver *unArchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:base64Data];
            id obj = [unArchive decodeObjectForKey:@"data"];
            [unArchive finishDecoding];
            [objArrM addObject:obj];
        }
    }
    // 添加数据（添加之前会进行自检，去除添加数据中主键重复的多余数据）
    NSArray *allObjs = [objArrM addObjs:objs mergeRepeatItemWithPrimaryKey:key mergeBlock:^NSArray * _Nonnull(NSObject * _Nonnull oldObj, NSObject * _Nonnull addObj) {
        // 自定义合并准则
        if (self.config.delegate && [self.config.delegate respondsToSelector:@selector(mergeRepeatItemWithOldObj:newObj:)]) {
            return [self.config.delegate mergeRepeatItemWithOldObj:oldObj newObj:addObj];
        }
        else {
            return @[addObj];
        }
    }];
    // 再次自检
    allObjs = [allObjs removeRepeatItemsWithPrimaryKey:key];
    // 转 NSData 归档
    for (id<NSCopying , NSCoding> obj in allObjs) {
        // 序列化
        NSMutableData *dataM = [NSMutableData new];
        NSKeyedArchiver *archive = [[NSKeyedArchiver alloc]initForWritingWithMutableData:dataM];
        [archive encodeObject:obj forKey:@"data"];
        [archive finishEncoding];
        // 使用 base64 加密
        NSData *dataBase64 = [dataM base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSData *encryptionData;
        // 自定义加密
        if (self.config.delegate && [self.config.delegate respondsToSelector:@selector(decryptionData:)]) {
            encryptionData = [self.config.delegate encryptionData:dataBase64];
        }
        else {
            encryptionData = dataBase64;
        }
        
        [dataArrM addObject:dataBase64];
        
    }
    // 写入数据
    BOOL isTure = [dataArrM writeToFile:path atomically:YES];
    CHLog(@"本地数据写入:%d",isTure);
}
// 清空
- (void) localClearObjsWithFilePath:(NSString *)path {
    NSArray *dataArr = [NSArray new];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [dataArr writeToFile:path atomically:YES];
    }
}
// 重置
- (void) localResetFile:(NSArray<NSCoding , NSCopying> *)objs primaryKey:(NSString *)key filePath:(NSString *)path {
    [self localClearObjsWithFilePath:path];
    [self localAddObjs:objs primaryKey:key toFilePath:path];
}
// 查找所有本地存储数据模型数组
- (NSArray<NSCoding , NSCopying> *) localAllObjsWithFilePath:(NSString *)path {
    NSMutableArray *arrM = [NSMutableArray new];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        for (NSData *data in [NSArray arrayWithContentsOfFile:path]) {
            
            NSData *encryptionData;
            // 自定义解密
            if (self.config.delegate && [self.config.delegate respondsToSelector:@selector(decryptionData:)]) {
                encryptionData = [self.config.delegate decryptionData:data];
            }
            else {
                encryptionData = data;
            }
            
            // base64
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedData:encryptionData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSKeyedUnarchiver *unArchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:base64Data];
            id obj = [unArchive decodeObjectForKey:@"data"];
            [unArchive finishDecoding];
            [arrM addObject:obj];
        }
    }
    return [arrM copy];
}
// 查找
- (NSArray *) localSearchObjWithFilePath:(NSString *)path primaryKey:(NSString *)key primaryValues:(NSArray *)values {
    NSMutableArray *returnObjs = [NSMutableArray new];
    NSArray *objs = [self localAllObjsWithFilePath:path];
    for (NSObject *value in values) {
        for (NSObject *obj in objs) {
            if ([[obj valueForKey:key] isEqual:value]) {
                [returnObjs addObject:obj];
                break;
            }
        }
    }
    return [returnObjs copy];
}
// 删除
- (void) localDeleteObjsWithPrimaryKey:(NSString *)key primaryValues:(NSArray *)values filePath:(NSString *)path {
    NSMutableArray *objs = [[self localAllObjsWithFilePath:path] mutableCopy];
    for (id value in values) {
        for (id obj in [objs copy]) {
            if ([[(NSObject *)obj valueForKey:key] isEqual:value]) {
                [objs removeObject:obj];
                break;
            }
        }
    }
    [self localResetFile:objs primaryKey:key filePath:path];
}

@end



@implementation CHLocalDBConfiguration
@end



@implementation NSArray (ChEx_DB)

/**
 *  像一个数组中添加新元素，如果新元素和老元素有重复的，用新元素覆盖老元素
 *
 *  @param newObjs 新数组
 *  @param key     主键
 */
- (NSArray *) addObjs:(NSArray *)newObjs coverRepeatItemWithPrimaryKey:(NSString *)key {
    return [self addObjs:newObjs mergeRepeatItemWithPrimaryKey:key mergeBlock:^NSArray * _Nonnull(NSObject * _Nonnull oldObj, NSObject * _Nonnull addObj) {
        return @[addObj];
    }];
}

/**
 *  移除一个数组中重复的元素
 *
 *  @param objs 检测数组
 *  @param key  主键
 */
- (NSArray *) removeRepeatItemsWithPrimaryKey:(NSString *)key {
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:[self copy]];
    NSMutableArray *arrM2 = [NSMutableArray arrayWithArray:[self copy]];
    for (NSObject *obj in [self copy]) {
        [arrM2 removeObject:obj];
        for (NSObject *obj2 in [arrM2 copy]) {
            if ([[obj valueForKey:key] isEqual:[obj2 valueForKey:key]]) {
                [arrM2 removeObject:obj2];
                [arrM removeObject:obj2];
            }
        }
    }
    return [arrM copy];
}

/**
 *  像一个数组中添加新元素，如果新元素和老元素有重复的，使用 block 处理
 *
 *  @param newObjs 新数组
 *  @param key     主键
 *  @param block   重复数据处理
 */
- (NSArray *) addObjs:(NSArray *)newObjs mergeRepeatItemWithPrimaryKey:(NSString *)key mergeBlock:(NSArray/* 这里使用数组是考虑到了并存的情况*/ *(^)(NSObject *oldObj , NSObject *addObj))block {
    
    NSMutableArray *originalObjs = [NSMutableArray arrayWithArray:self];
    // 对添加的数据做一次自检
    NSMutableArray *addObjs = [[[NSMutableArray arrayWithArray:newObjs] removeRepeatItemsWithPrimaryKey:key] mutableCopy];
    // 找到原数据中和待添加的数据重复的 并删除
    for (NSObject *addObj in [addObjs copy]) {
        for (NSObject *oObj in [originalObjs copy]) {
            if ([[oObj valueForKey:key] isEqual:[addObj valueForKey:key]]) {
                [originalObjs removeObject:oObj];
                [addObjs removeObject:addObj];
                NSArray *mergeObjs;
                mergeObjs = block(oObj , addObj);
                // 确保同步
                while (!mergeObjs) {}
                [originalObjs addObjectsFromArray:mergeObjs];
            }
        }
    }
    [originalObjs addObjectsFromArray:addObjs];
    return originalObjs;
}

@end
