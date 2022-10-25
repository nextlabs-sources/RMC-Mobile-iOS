//
//  NXPageMenuView.h
//  nxrmc
//
//  Created by helpdesk on 14/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KMENUBTNTAG 10086
#define  KGREENCOLOR [UIColor colorWithRed:109/256.0 green:180/256.0 blue:90/256.0 alpha:1]
@interface NXPageMenuView : UIView
@property(nonatomic, strong)UIView *slideView;
@property(nonatomic, strong)UIImageView *selectImageView;
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, assign)id delegate;
-(instancetype)initWithsubViewsPictures:(NSMutableArray*)iconArray andButtonTitles:(NSMutableArray*)titlearray;
@end
@protocol NXpageMenuViewDelegate <NSObject>

-(void)NXPageMenuView:(NXPageMenuView*)pageView selectMenuButtonClicked:(UIButton*)sender;

@end
