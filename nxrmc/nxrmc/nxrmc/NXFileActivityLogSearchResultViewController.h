//
//  NXFileActivityLogSearchResultViewController.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSearchResultViewController.h"
@class NXFileActivityLogSearchResultViewController;
@class NXNXLFileLogModel;
@protocol NXFileActivityLogSearchResultDelegate <NSObject>
@required
- (void)fileActivityLogSearchResultVC:(NXFileActivityLogSearchResultViewController *)resultVC didSelectItem:(NXNXLFileLogModel *)item;
@end

@interface NXFileActivityLogSearchResultViewController : NXSearchResultViewController
@property(nonatomic, weak) id<NXFileActivityLogSearchResultDelegate> delegate;
@end
