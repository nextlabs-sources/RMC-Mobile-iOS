//
//  NXRightsDisplayView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXLRights;
@class NXLFileValidateDateModel;
@interface NXRightsDisplayView : UIView

@property(nonatomic, strong) NSString *noRightsMessage;
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NXLFileValidateDateModel *fileValidityModel;
@property(nonatomic, assign) BOOL isNeedTitle;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, assign) BOOL showLocalWatermarkStr;
- (void)showSteward:(BOOL)show;

@end
