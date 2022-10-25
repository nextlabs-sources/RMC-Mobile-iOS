//
//  NXProjectTotalNumView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 30/10/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, NXProjectTotalNumViewType) {
    NXProjectTotalNumViewTypeForPending,
    NXProjectTotalNumViewTypeForByMe,
    NXProjectTotalNumViewTypeForByOthers
};
@interface NXProjectTotalNumView : UIView

@property (nonatomic ,copy) void(^clickBgViewFinishedBlock) (NSError *error);
- (instancetype)initWithProjectNumber:(NSNumber *)number andProjectType:(NXProjectTotalNumViewType)type;
@end
