//
//  NXAddFileSavePathView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/20.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXAddFileSavePathView : UIView
- (instancetype)initWithSavePathText:(NSString *)text;
- (void)setHintMessage:(NSString * _Nonnull)hintMessage andSavePath:(NSString *)savePath;
@end

NS_ASSUME_NONNULL_END
