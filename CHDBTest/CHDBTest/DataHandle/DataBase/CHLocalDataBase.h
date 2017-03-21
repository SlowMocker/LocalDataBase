//
//  CHLocalHandle.h
//  CH_IPP_SH_SDK
//
//  Created by Wu on 17/3/14.
//  Copyright © 2017年 Wu. All rights reserved.
//


//  基于归档
//  基于对象（实现 NSCoding 和 NSCopying）的本地数据存储（数组）
//  对象拥有主键（唯一识别）,并且主键值为对象


#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

// note : 如果 oldObj 和 addObj 主键重复，又希望可以并存，那么你返回的数组中的元素的主键必须不相同并且也不能和已有的元素的主键相同。
// notice : 如果重复的主键是 123  那么你应该这样修改你的主键 123_repeat_1
// 原因 : 在每次添加数据之前会对待添加的数据做自检（移除待添加数据中主键重复的数据），在添加完之后会对整体数据再做一次自检。如果这时候还存在主键重复 会造成数据遗失

@class CHLocalDBConfiguration;
@interface CHLocalDataBase : NSObject

/**
 *  使用 DB 配置对象进行初始化
 *
 *  @param config 自定义配置
 *
 *  @return 自定义 DB
 */
- (id) initWithConfiguration:(CHLocalDBConfiguration *)config;

/**
 *  将一类相同类型的对象存储到文件中（增）
 *
 *  @param objs 对象数组
 *  @param key 主键
 *  @param path 路径
 */
- (void) localAddObjs:(NSArray<NSCopying , NSCoding> *)objs primaryKey:(NSString *)key toFilePath:(NSString *)path;

/**
 *  清空某个文件的内容（删）
 *
 *  @param path 路径
 */
- (void) localClearObjsWithFilePath:(NSString *)path;

/**
 *  重置某个文件的数据
 *
 *  @param devics 重新写入的数据
 *  @param key 主键
 *  @param path   文件路径
 */
- (void) localResetFile:(NSArray<NSCoding , NSCopying> *)objs primaryKey:(NSString *)key filePath:(NSString *)path;

/**
 *  获取到某个文件路径里的所有对象（查）
 *
 *  @param path 路径
 *
 *  @return 所有对象
 */
- (NSArray<NSCoding , NSCopying> *) localAllObjsWithFilePath:(NSString *)path;

/**
 *  在指定文件中查找特定的对象（查）
 *
 *  @param path  文件
 *  @param key   主键
 *  @param value 主键值数组
 *
 *  @return 对象数组
 */
- (NSArray *) localSearchObjWithFilePath:(NSString *)path primaryKey:(NSString *)key primaryValues:(NSArray *)values;

/**
 *  在指定文件中删除特定的对象（删）
 *
 *  @param key    主键
 *  @param values 主键值数组
 *  @param path   文件
 */
- (void) localDeleteObjsWithPrimaryKey:(NSString *)key primaryValues:(NSArray *)values filePath:(NSString *)path;

@end


@protocol CHLocalDBConfigurationDelegate <NSObject>
@optional

/**
 *  合并重复数据方式
 *
 *  @param oldPbj 已经存储的数据元素
 *  @param newObj 待存储的重复数据元素
 *
 *  @return 合并后的数据
 */
- (NSArray *) mergeRepeatItemWithOldObj:(NSObject *)oldObj newObj:(NSObject *)newObj;

/**
 *  自定义加密
 *
 *  @param data 已经经过 base64 加密的数据
 */
- (NSData *) encryptionData:(NSData *)data;

/**
 *  和自定义加密配套的解密
 *
 *  @param data base64 + 自定义加密后的数据
 *
 *  @return base64 加密的数据
 */
- (NSData *) decryptionData:(NSData *)data;
@end
@interface CHLocalDBConfiguration : NSObject

@property (nonatomic , weak) id<CHLocalDBConfigurationDelegate> delegate;

@end


@interface NSArray (ChEx_DB)

/**
 *  像一个数组中添加新元素，如果新元素和老元素有重复的，用新元素覆盖老元素
 *
 *  @param newObjs 新数组
 *  @param key     主键
 */
- (NSArray *) addObjs:(NSArray *)newObjs coverRepeatItemWithPrimaryKey:(NSString *)key;

/**
 *  移除一个数组中重复的元素
 *
 *  @param objs 检测数组
 *  @param key  主键
 */
- (NSArray *) removeRepeatItemsWithPrimaryKey:(NSString *)key;

/**
 *  像一个数组中添加新元素，如果新元素和老元素有重复的，使用 block 处理
 *
 *  @param newObjs 新数组
 *  @param key     主键
 *  @param block   重复数据处理
 */
- (NSArray *) addObjs:(NSArray *)newObjs mergeRepeatItemWithPrimaryKey:(NSString *)key mergeBlock:(NSArray *(^)(NSObject *oldObj , NSObject *addObj))block;

@end

NS_ASSUME_NONNULL_END
