//
//  NXMySpaceHomeInfoView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXMySpaceHomeInfoView : UIView
@property (nonatomic ,copy) void(^goToPorFilePageBlock) (id sender);
- (void)updateUserNameAndHeadImage;

@end
