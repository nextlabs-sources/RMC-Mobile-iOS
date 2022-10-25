//
//  NXEmailContactCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXEmailContact;
typedef void(^emailBtnClicked)(NSString *emailStr);
@interface NXEmailBtnsView : UIView
@property(nonatomic, strong)emailBtnClicked emailBtnClicked;
- (instancetype)initWithTitlesArray:(NSArray *)titles;
@end
@protocol NXEmailContactCellDelegate <NSObject>
- (void)emailBtnWhichTitle:(NSString *)title ClickedFromEmailBtnView:(NXEmailBtnsView*)emailBtnsView;
@end
@interface NXEmailContactCell : UITableViewCell
@property(nonatomic, weak)NXEmailContact *contactModel;
@property(nonatomic, assign)id<NXEmailContactCellDelegate> delegate;
@end

