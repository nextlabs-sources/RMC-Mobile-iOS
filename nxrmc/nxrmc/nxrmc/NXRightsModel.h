//
//  NXRightsModel.h
//  nxrmc
//
//  Created by nextlabs on 11/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

@class NXLRights;
@class NXRightsCellModel;

@interface NXRightsModel : NSObject

@property(nonatomic, strong, readonly) NSArray<NXRightsCellModel *> *contentsArray;
@property(nonatomic, strong, readonly) NSArray<NXRightsCellModel *> *collaborationArray;
@property(nonatomic, strong, readonly) NSArray<NXRightsCellModel *> *obsArray; //for now, it only have one element.for watermark/overlay.
@property(nonatomic, strong) NSArray<NXRightsCellModel *> *validityArray; //nxl file validity.
@property(nonatomic, strong) NSArray<NXRightsCellModel *> *moreOptionArray;//screen capture,extract
- (instancetype)initWithRights:(NXLRights *)rights;
- (instancetype)initWithRights:(NXLRights *)rights fileSorceType:(NXFileBaseSorceType)fileSorceType;

+ (NXLRights *)convertModelToRights:(NXRightsModel *)rightsModel;

@end
