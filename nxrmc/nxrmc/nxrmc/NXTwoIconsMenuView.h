//
//  NXTwoIconsMenuView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^twoIconsMenuIsSelectedCompletion)(void);
@interface NXTwoIconsMenuView : UIView
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,copy)twoIconsMenuIsSelectedCompletion selectedCompletion;
//- (instancetype)initWithFirstIconName:(NSString *)firstIconName secondIconName:(NSString *)secondIconName title:(NSString *)title;
- (instancetype)initWithFirstNormalIconName:(NSString *)firstNormal firstSelectIconName:(NSString *)selectedName secondNormalIconName:(NSString *)secondNormal secondSelectIconName:(NSString *)secondSelectName title:(NSString *)title;
- (void)cancelSelect;
@end

NS_ASSUME_NONNULL_END
