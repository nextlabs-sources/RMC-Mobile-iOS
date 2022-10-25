//
//  NXEmailView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXEmailView;
@protocol NXEmailViewDelegate <NSObject>
@optional
- (void)emailViewDidBeginEditing:(NXEmailView *)emailView;
- (void)emailViewDidEndingEditing:(NXEmailView *)emailView;
- (void)emailViewDidReturn:(NXEmailView *)emailView;
- (void)emailView:(NXEmailView *)emailView didChangeHeightTo:(CGFloat)height;
- (void)emailView:(NXEmailView *)emailView didInputEmail:(NSString *)email;
//- (BOOL)emailViewShouldReturn:(NXEmailView *)emailView;
@end
typedef void(^rightBtnClicked)(void);
@interface NXEmailView : UIView

@property(nonatomic, readonly, strong) UITextField *textField;

@property(nonatomic, strong, readonly) NSArray<NSString *> *vaildEmails;
@property(nonatomic, strong) NSMutableArray<NSString *> *emailsArray;
@property(nonatomic, strong) NSString *promptMessage;

@property(nonatomic, assign) BOOL editable;
@property(nonatomic, weak) id<NXEmailViewDelegate> delegate;
@property(nonatomic, copy) rightBtnClicked rightBtnClicked;
- (BOOL)isExistInvalidEmail;
- (void)addAEmail:(NSString *)str;
@end
