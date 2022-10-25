//
//  NXSearchContactResultVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/26.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NXSearchContactResultVCDelegate <NSObject>
- (void)theEmailBtnBeClickedOnSearchResultPageWithTitle:(NSString *)title;
@end
@interface NXSearchContactResultVC : UIViewController<UISearchResultsUpdating>
@property(nonatomic, strong)NSArray *allContactsArray;
@property(nonatomic, assign)id<NXSearchContactResultVCDelegate> delegate;
@end

