//
//  NXSetSeverURLView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/4/24.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,NXSetSeverURLViewType) {
    NXSetSeverURLViewTypeCommanyEdit = 0,
    NXSetSeverURLViewTypeCommanySelect
};
typedef void(^urlViewPullDownBlock)(void);
typedef void(^urlViewManageUrlBlock)(void);
@interface NXSetSeverURLView : UIView
@property (nonatomic, assign, readonly) BOOL isRemberURL;
@property (nonatomic, strong) NSString *URLStr;
@property (nonatomic, assign) NXSetSeverURLViewType urlViewType;
@property (nonatomic, copy) urlViewPullDownBlock pullDownBlock;
@property (nonatomic, copy) urlViewManageUrlBlock manageUrlBlock;
- (void)showErrorMessage;
- (void)closeTheKeyBoard;
@end
