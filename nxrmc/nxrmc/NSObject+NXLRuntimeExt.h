//
//  NSObject+NXLRuntimeExt.h
//  nxrmc
//
//  Created by Eren on 2019/3/14.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NXLRuntimeExt)
#pragma mark - Object runtime Debug
- (void)objectAddress;
- (void)objectPointerAddress;
- (void)objectISAContent;

#pragma mark - Object information
+ (NSArray<NSString *> *)instanceMethodList;
- (NSArray<NSString *> *)instanceMethodList;
+ (NSArray<NSString *> *)classMethodList;
- (NSArray<NSString *> *)classMethodList;
+ (NSArray<NSString *> *)objectPropertyList;


#pragma mark - Swizzle method

// use this method in +load method
// when call swizzle method funciton, should use them in dispatch_once block, in case multi call
+ (void)swizzleInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;
+ (void)swizzleClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;

#pragma mark - Encode/Decode
- (void)nxlEncode:(NSCoder *)aCode;
- (void)nxlDecode:(NSCoder *)aCode;

#pragma mark - Init with dictionary
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
