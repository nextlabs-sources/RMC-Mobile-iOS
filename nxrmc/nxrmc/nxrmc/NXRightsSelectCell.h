//
//  NXRightsSelectCell.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NXLFileValidateDateModel;
@class NXRightsCellModel;
@class NXRightsSelectCell;
@class YYLabel;
typedef void(^SwitchActionBlock)(BOOL active);
typedef void(^OnClickChangeLabelActionBlock)(id model,NXRightsSelectCell *cell);

@interface NXRightsSelectCell : UICollectionViewCell

@property(nonatomic, strong) NXRightsCellModel *model;
@property(nonatomic, strong) NXLFileValidateDateModel *fileValidityModel;

@property(nonatomic, strong) UISwitch *switchButton;
@property(nonatomic, strong) UIButton *checkBoxButton;
@property(nonatomic, strong) SwitchActionBlock actionBlock;
@property(nonatomic, copy) OnClickChangeLabelActionBlock tapChangeBlock;

@property(nonatomic, weak) YYLabel *descriptionLabel;
@property(nonatomic, weak) UILabel *changeLabel;


@end
