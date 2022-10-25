//
//  NXRightsCellModel.h
//  nxrmc
//
//  Created by nextlabs on 11/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS  (long, MODELTYPE) {
    MODELTYPERIGHTS = 0,
    MODELTYPEOBS,
    MODELTYPEValidity,
};

@interface NXRightsCellModel : NSObject<NSCopying>

@property(nonatomic, strong) NSString *title;

@property(nonatomic, assign) MODELTYPE modelType;
@property(nonatomic, assign) long value;
@property(nonatomic, assign) BOOL active;

@property(nonatomic, readonly) NSDictionary *extDic;

- (instancetype)initWithTitle:(NSString *)title value:(long)value modelType:(MODELTYPE)type actived:(BOOL)active;

- (instancetype)initWithTitle:(NSString *)title value:(long)value modelType:(MODELTYPE)type actived:(BOOL)active extDic:(NSDictionary *)extDic;

@end
