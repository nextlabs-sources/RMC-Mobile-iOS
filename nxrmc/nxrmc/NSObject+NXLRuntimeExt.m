//
//  NSObject+NXLRuntimeExt.m
//  nxrmc
//
//  Created by Eren on 2019/3/14.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NSObject+NXLRuntimeExt.h"
#import <objc/runtime.h>


@implementation NSObject (NXLRuntimeExt)
#pragma mark - Object runtime Debug
- (void)objectAddress {
    NSLog(@"Object address is %p", self);
}

- (void)objectPointerAddress {
    NSLog(@"Object pointer address is %p", &self);
}

- (void)objectISAContent {
    NSLog(@"Object isa content is %p", *(void **)(__bridge void *)self);
}


+ (NSArray<NSString *> *)instanceMethodList {
    Class class = [self class];
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(class, &methodCount);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:methodCount];
    for (int i = 0; i < methodCount; ++i) {
        NSString *methodName = NSStringFromSelector(method_getName(methodList[i]));
        [methodArray addObject:methodName];
    }
    free(methodList);
    return methodArray;
}

- (NSArray<NSString *> *)instanceMethodList {
    Class class = [self class];
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(class, &methodCount);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:methodCount];
    for (int i = 0; i < methodCount; ++i) {
        NSString *methodName = NSStringFromSelector(method_getName(methodList[i]));
        [methodArray addObject:methodName];
    }
    free(methodList);
    return methodArray;
}

+ (NSArray<NSString *> *)classMethodList {
    Class metaClass = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(metaClass, &methodCount);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:methodCount];
    for (int i = 0; i < methodCount; ++i) {
        NSString *methodName = NSStringFromSelector(method_getName(methodList[i]));
        [methodArray addObject:methodName];
    }
    free(methodList);
    return methodArray;
}

- (NSArray<NSString *> *)classMethodList {
    Class class = [self class];
    Class metaClass = object_getClass(class);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(metaClass, &methodCount);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:methodCount];
    for (int i = 0; i < methodCount; ++i) {
        NSString *methodName = NSStringFromSelector(method_getName(methodList[i]));
        [methodArray addObject:methodName];
    }
    free(methodList);
    return methodArray;
}

+ (NSArray<NSString *> *)objectPropertyList {
    Class class = [self class];
    NSMutableArray *retArray = [NSMutableArray new];
    unsigned int ivarCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(class, &ivarCount);
    for (int i = 0; i < ivarCount; ++i) {
        objc_property_t property = propertyList[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getAttributes(property)];
        [retArray addObject:propertyName];
    }
    free(propertyList);
    return retArray;
}

#pragma mark - Swizzle method
+ (void)swizzleInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    [self swizzleMethod:originalSelector withMethod:swizzledSelector isClassMethod:NO];
}
+ (void)swizzleClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    [self swizzleMethod:originalSelector withMethod:swizzledSelector isClassMethod:YES];
}

+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector isClassMethod:(BOOL)isClassMethod {
    Class class = isClassMethod ? object_getClass(self) : [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    // 考虑 originalSelector 在class中可能并没有实现的情况，我们先调用class_addMethod 来为class 尝试添加originalSelector。如果class已经对应的实现，则会返回失败
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {  // class中并没有originalSelector。
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        
    }else { // class中已经有originalSelector。则交换original 和 swizzledMethod的实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Encode/Decode
- (void)nxlEncode:(NSCoder *)aCoder {
    // from class to super class, encode every class ivar
    Class class = [self class];
    while (class && class != [NSObject class]) {
        unsigned int ivarCount = 0;
        Ivar *ivarList = class_copyIvarList(class, &ivarCount);
        for (int i = 0; i < ivarCount; ++i) {
            Ivar ivar = ivarList[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [self valueForKey:key];
            [aCoder encodeObject:value forKey:key];
        }
        free(ivarList);
        class = [class superclass];
    }
}

- (void)nxlDecode:(NSCoder *)aCode {
    Class class = [self class];
    while (class && class != [NSObject class]) {
        unsigned int ivarCount = 0;
        Ivar *ivarList = class_copyIvarList(class, &ivarCount);
        for (int i = 0; i < ivarCount; ++i) {
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivarList[i])];
            id value = [aCode decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivarList);
    }
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
