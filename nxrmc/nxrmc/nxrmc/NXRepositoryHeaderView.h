//
//  NXRepositoryHeaderView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXRMCDef.h"

@interface NXRepositoryHeaderView : UIView

@property(nonatomic, strong) NSString *title;

@property(nonatomic, strong) ClickActionBlock clickBlock;

@end
