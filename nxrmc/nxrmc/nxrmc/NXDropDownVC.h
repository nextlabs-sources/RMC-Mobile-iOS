//
//  NXDropDownVC.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/14.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXDropDownVC;
@protocol NXDropDownVCDelegate <NSObject>
- (void)cancelButtonTapped:(NXDropDownVC *)dropDownVc;
- (void)needUpdateSelectState:(NXDropDownVC *)dropDownVc;
@end

@interface NXDropDownVC : UIViewController
@property (nonatomic,assign) id<NXDropDownVCDelegate> delegate;
-(void)reloadData;
@end
