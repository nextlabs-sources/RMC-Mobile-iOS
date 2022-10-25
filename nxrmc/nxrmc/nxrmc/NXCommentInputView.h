//
//  NXCommentInputView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXTextView.h"

@interface NXCommentInputView : UIView

@property(nonatomic, strong, readonly) UILabel *promptLabel;
@property(nonatomic, strong, readonly) NXTextView *textView;
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) NSInteger maxCharacters;

@end
@protocol NXCommnetInputViewDelegate <NSObject>

- (void)commentInputViewDidEndEditing:(NXCommentInputView *)inputView;
- (void)commentInputView:(NXCommentInputView *)inputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
