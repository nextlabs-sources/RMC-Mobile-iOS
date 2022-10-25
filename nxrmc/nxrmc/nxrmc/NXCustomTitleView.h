//
//  NXCustomTitleView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXCustomTitleView : UILabel

@end
@interface NXCustomNavTitleView : UIView
@property(nonatomic, strong)NSString *mainTitle;
@property(nonatomic, strong)NSString *subTitle;
@end
