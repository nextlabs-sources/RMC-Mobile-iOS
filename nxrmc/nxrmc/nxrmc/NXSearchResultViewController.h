//
//  NXSearchResultViewController.h
//  nxrmc
//
//  Created by nextlabs on 12/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NXSearchVCResignActiveDelegate <NSObject>
- (void)searchVCShouldResignActive;
@end

@interface NXSearchResultViewController : UIViewController

@property(nonatomic, strong) NSArray *dataArray;
@property (nonatomic,assign) BOOL searchFromFavoritePage;

@property (nonatomic,weak) id<NXSearchVCResignActiveDelegate> resignActiveDelegate;

- (void)updateData;

@end
