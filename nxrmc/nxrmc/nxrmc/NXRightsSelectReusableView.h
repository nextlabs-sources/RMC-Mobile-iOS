//
//  NXRightsSelectReusableView.h
//  nxrmc
//
//  Created by nextlabs on 11/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXRightsSelectReusableView : UICollectionReusableView

@property(nonatomic, copy) NSString *model;

@end
typedef void(^moreOptionsButtonClicked)(void);
@interface NXRightsMoreOptionSelectReusableView : UICollectionReusableView

@property(nonatomic, copy) NSString *model;
@property(nonatomic, copy) moreOptionsButtonClicked moreOptionsButtonClicked;
- (void)setShowMoreOptions:(BOOL)moreOption;
@end
