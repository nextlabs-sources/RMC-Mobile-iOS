//
//  NXRightsModel.m
//  nxrmc
//
//  Created by nextlabs on 11/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRightsModel.h"

#import "NXRightsCellModel.h"

#import "NXLRights.h"
#import "NXLFileValidateDateModel.h"
#import "NXLoginUser.h"

@interface NXRightsModel ()

@property(nonatomic, strong)NXLRights *rights;

@end

@implementation NXRightsModel

- (instancetype) initWithRights:(NXLRights *)rights {
    if (self = [super init]) {
        _rights = rights;
        [self initializeWithFileSorceType:NXFileBaseSorceTypeUnknown];
    }
    return self;
}

- (instancetype)initWithRights:(NXLRights *)rights fileSorceType:(NXFileBaseSorceType)fileSorceType
{
    if (self = [super init]) {
        _rights = rights;
        [self initializeWithFileSorceType:fileSorceType];
    }
    return self;
}

- (void)initializeWithFileSorceType:(NXFileBaseSorceType)fileSorceType {
    //contentRights
    NSMutableArray *contentArray = [NSMutableArray array];
    [[NXLRights getSupportedContentRights] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
            NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:key value:obj.longValue modelType:MODELTYPERIGHTS actived:[_rights getRight:obj.longValue] extDic:nil];
            if (fileSorceType != NXFileBaseSorceTypeProject && obj.longValue == NXLRIGHTDECRYPT) {
                return ;
            }else{
                [contentArray addObject:model];
            }
            
        }];
    }];
    
    //collaborationRights
    NSMutableArray *collaborationArray = [NSMutableArray array];
    [[NXLRights getSupportedCollaborationRights] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
//            if (fileSorceType == NXFileBaseSorceTypeProject && obj.integerValue == NXLRIGHTSHARING) { // special for project
//                return;
//            }
            NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:key value:obj.longValue modelType:MODELTYPERIGHTS actived:[_rights getRight:obj.longValue] extDic:nil];
            [collaborationArray addObject:model];
        }];
    }];
    
    //obsRights
    NSMutableArray *obsArray = [NSMutableArray array];
    [[NXLRights getSupportedObs] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
            NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:key value:obj.longValue modelType:MODELTYPEOBS actived:[_rights getObligation:obj.longValue] extDic:nil];
            [obsArray addObject:model];
        }];
    }];
    
    // nxl file validity
    NSMutableArray *validityArray = [NSMutableArray array];
    NXLFileValidateDateModel *datemodel = nil;
    if ([_rights getVaildateDateModel]) {
        datemodel = [_rights getVaildateDateModel];
    }else{
        datemodel  = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate;
    }
  
    NSDictionary *validityDic = @{@"VALIDITY_MODEL":datemodel};
    NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:@"Validity" value:0 modelType:MODELTYPEValidity actived:YES extDic:validityDic];
    [validityArray addObject:model];
    // moreOptions rights
    NSMutableArray *moreoptionsArray = [NSMutableArray array];
    [[NXLRights getSuppotedMoreOptionsRights] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSNumber *obj, BOOL * _Nonnull stop) {
            NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:key value:obj.longValue modelType:MODELTYPERIGHTS actived:[_rights getRight:obj.longValue] extDic:nil];
            if ( obj.longValue == NXLRIGHTDECRYPT) {
                if (fileSorceType == NXFileBaseSorceTypeProject || fileSorceType == NXFileBaseSorceTypeWorkSpace) {
                    [moreoptionsArray addObject:model];
                }else{
                    return;
                }
              
            }else{
                [moreoptionsArray addObject:model];
            }
        }];
    }];
    
    _contentsArray = [NSArray arrayWithArray:contentArray];
    _collaborationArray = [NSArray arrayWithArray:collaborationArray];
    _obsArray = [NSArray arrayWithArray:obsArray];
    _validityArray = [NSArray arrayWithArray:validityArray];
    _moreOptionArray = [NSArray arrayWithArray:moreoptionsArray];
}

#pragma mark -
+ (NXLRights *)convertModelToRights:(NXRightsModel *)rightsModel {
    NXLRights *rights = [[NXLRights alloc] init];
    
    [rightsModel.contentsArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rights setRight:obj.value value:obj.active];
    }];
    
    [rightsModel.collaborationArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rights setRight:obj.value value:obj.active];
    }];
    
    [rightsModel.obsArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rights setObligation:obj.value value:obj.active];
    }];
    [rightsModel.moreOptionArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rights setRight:obj.value value:obj.active];
    }];
    return rights;
}

@end
