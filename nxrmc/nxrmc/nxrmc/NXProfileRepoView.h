//
//  NXProfileRepoView.h
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapClickBlock)(id sender);

@interface NXProfileRepoView : UIView

@property(nonatomic, strong) TapClickBlock tapclickBlock;
@end
