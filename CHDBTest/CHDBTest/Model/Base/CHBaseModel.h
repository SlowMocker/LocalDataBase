//
//  CHSBaseModel.h
//  IPPSmartManager
//
//  Created by Wu on 16/9/2.
//  Copyright © 2016年 Changhong electric Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CHBaseModel : NSObject<NSCoding , NSCopying>
/**
 *  动态初始化对象
 *
 *  @param dic 属性字典
 *
 *  @return 对象
 */
- (id)initWithDic:(NSDictionary *)dic;
/**
 *  对象转字典
 *
 *  注意点：
 *  如果属性中包含了非BaseModel的自定义对象需要在调用者Model中重写该方法，对该对象进行处理
 *
 */
- (NSDictionary *)toDictionary;
/**
 *  对象转JSON字符串
 *
 *  @return JSON字符串
 */
- (NSString *)toJson;
/**
 *  获取所有的属性
 *
 *  @param class 目标类
 *
 *  @return 属性名称数组
 */
- (NSArray<NSString *> *)getAllProperties:(Class)class;


@end
