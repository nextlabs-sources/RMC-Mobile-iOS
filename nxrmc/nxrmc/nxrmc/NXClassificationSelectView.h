//
//  NXClassificationSelectView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXClassificationCategory;
@class NXClassificationSelectView;
@protocol NXClassificationSelectViewDelegate <NSObject>

- (void)afterChangeCurrentSelectClassifationSelectView:(NXClassificationSelectView *)selectView;

@end
@interface NXClassificationSelectView : UIView
@property(nonatomic, strong)NSArray <NXClassificationCategory *>*classificationCategoryArray;
@property(nonatomic, assign, readonly) BOOL isMandatoryEmpty;
@property(nonatomic, assign, readonly) BOOL isNotSelected;
@property(nonatomic, assign) id <NXClassificationSelectViewDelegate>delegate;
- (NSArray *)isNotShouldMultipleCategory;
@end

