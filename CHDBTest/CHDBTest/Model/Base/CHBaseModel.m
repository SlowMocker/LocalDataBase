//
//  CHSBaseModel.m
//  IPPSmartManager
//
//  Created by Wu on 16/9/2.
//  Copyright © 2016年  electric Co.,Ltd. All rights reserved.
//


#import "CHBaseModel.h"

#import <objc/runtime.h>


@implementation CHBaseModel

- (id)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        if (dic) {
            [self setValuesForKeysWithDictionary:dic];
        }
    }
    return self;
}
// 实现这个方法，防止动态设置属性时，因为找不到对应的变量而崩溃。
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // to do ...
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

// 对象转字典
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    NSArray *propertyNames = [self getAllProperties:[self class]];
    for (NSString *propertyName in propertyNames) {
        id property = [self valueForKey:propertyName];
        if ([property isKindOfClass:[NSArray class]] || [property isKindOfClass:[NSSet class]]) {// 如果获取到的属性是个数组，需要进一步获取
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:property];
            for (id object in property) {
                if ([object isKindOfClass:([CHBaseModel class])]) {
                    NSDictionary *dic = [object toDictionary];
                    [arrM removeObject:object];
                    [arrM addObject:dic];
                }
            }
            [dic setValue:[arrM copy] forKey:propertyName];
        }
        else if ([property isKindOfClass:[CHBaseModel class]]) {// 如果是该类型，继续获取
            [dic setValue:[property toDictionary] forKey:propertyName];
        }
        else {
            [dic setValue:property forKey:propertyName];
        }
    }
    return [dic copy];
}

- (NSString *)toJson {
    NSString *json;
    NSDictionary *dic = [self toDictionary];
    if (dic != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    return json;
}

- (NSArray<NSString *> *)getAllProperties:(Class)class {
    NSMutableArray *properties = [NSMutableArray new];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList(class, &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t propertyName = propertyList[i];
        const char *cName = property_getName(propertyName);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [properties addObject:name];
    }
    return [properties copy];
}

#pragma mark
#pragma mark NSCodingProtocol
- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *properties = [self getAllProperties:[self class]];
    for (NSString *name in properties) {
        [aCoder encodeObject:[self valueForKey:name] forKey:[NSString stringWithFormat:@"c_%@_%@",NSStringFromClass([self class]),name]];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSArray *properties = [self getAllProperties:[self class]];
        for (NSString *name in properties) {
            [self setValue:[aDecoder decodeObjectForKey:[NSString stringWithFormat:@"c_%@_%@",NSStringFromClass([self class]),name]] forKey:name];
        }
    }
    return self;
}
#pragma mark
#pragma mark NSCopyingProtocol
- (instancetype)copyWithZone:(NSZone *)zone {
    CHBaseModel *new = [[[self class] allocWithZone:zone] init];
    if (new) {
        NSArray *arr = [self getAllProperties:[self class]];
        if ([arr count] != 0) {
            for (NSString *name in arr) {
                [new setValue:[self valueForKey:name] forKey:name];
            }
        }
    }
    return new;
}

@end
