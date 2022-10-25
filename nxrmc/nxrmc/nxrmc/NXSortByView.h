//
//  NXSortByView.h
//  nxrmc
//
//  Created by EShi on 11/9/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRoundButtonView.h"

@interface NXSortByButtonView : NXRoundButtonView
- (void)setCurrentSortButtomImage:(NSString *)imageType;
@property(nonatomic, strong)NSString *currentImageType;
@end

@class NXSortByView;
@protocol NXSortByViewDelegate <NSObject>
- (void)nxsortByView:(NXSortByView *) sortByView didSelectedSortTitle:(NSString *) sortTitle;
@end

@interface NXSortByView : UIView
@property(nonatomic, strong) NXSortByButtonView *sortByBtnView;
@property(nonatomic, weak) id<NXSortByViewDelegate> delegate;
- (instancetype)initWithSortButtonView:(NXSortByButtonView *) sortByBtnView;
- (void)setHidenSortByRepoView:(BOOL) hidden;
- (void)showSortByItems;
- (void)hideSortByItems;

- (void)commonInit;
@end
