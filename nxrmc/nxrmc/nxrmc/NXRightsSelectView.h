//
//  NXRightsSelectView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXFileBase.h"
@class NXLRights;
@class NXLFileValidateDateModel;
@class NXRightsSelectView;

@protocol NXRightsSelectViewDelegate <NSObject>
@optional
- (void)rightsSelectView:(NXRightsSelectView *)selectView didHeightChanged:(CGFloat)height;
- (void)rightsSelectView:(NXRightsSelectView *)selectView didRightsSelected:(NXLRights *)rights;
- (void)moreOperationsClicledFromRightsSelectView:(NXRightsSelectView *)selectView;
@end

typedef void(^RightsSelected)(NXLRights *rights);
typedef void(^ValidityChangeLabelClicked)(NXLFileValidateDateModel *model);

@interface NXRightsSelectView : UIView

@property(nonatomic, assign) BOOL isToProject;
@property(nonatomic, assign) BOOL isShowMoreOptions;
@property(nonatomic, strong) NSString *noRightsMessage;
@property(nonatomic, strong) RightsSelected rightsSelectedBlock;
@property(nonatomic, copy) ValidityChangeLabelClicked fileValidityChagedBlock;
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NSArray *currentWatermarks;
@property(nonatomic, strong) NXLFileValidateDateModel *currentValidModel;
@property(nonatomic, assign, getter=isEnabled) BOOL enabled; //default YES, if yes, user can select, if not ,can not change rights
@property(nonatomic, weak) id<NXRightsSelectViewDelegate> delegate;
- (void)setRights:(NXLRights *)rights withFileSorceType:(NXFileBaseSorceType)fileSorceType;

@end
