//
//  NXSetRightsPageView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 16/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,NXSetRightsType) {
    NXSetRightsTypeDigital,
    NXSetRightsTypeClassification
};
@class NXLRights;
@class NXClassificationCategory;
@interface NXSetRightsPageView : UIView
@property (nonatomic, assign)NXSetRightsType currentType;
@property(nonatomic, strong) NXLRights *digitalSelectRights;
@property(nonatomic, strong)NSArray <NXClassificationCategory *>*classificationCategoryArray;
@property(nonatomic, assign) id delegate;
@end
@protocol NXSetRightsPageViewDelegate <NSObject>
- (void)nxsetRightspageView:(NXSetRightsPageView *)pageView didChangeType:(NXSetRightsType)type;
@end
