//
//  NXWaterMarkView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 10/11/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXWatermarkWord;
@interface NXWaterMarkView : UIView
@property (nonatomic, strong)NSArray <NXWatermarkWord *> *origialWaterMarks;
@property (nonatomic, weak)id delegate;
- (NSArray <NXWatermarkWord *>*)getTheWaterMarkValuesFromTextViewUI;
- (void)closeTheKeyBoardIfNeed;
@end
@protocol NXWaterMarkViewDelegate <NSObject>
@optional
- (void)watermarkViewTextDidChange:(BOOL)isValid;
@end
