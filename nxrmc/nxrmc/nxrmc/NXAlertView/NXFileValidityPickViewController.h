//
//  NXFileValidityPickViewController.h
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 07/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileValidityNavigationViewController.h"

@class NXLFileValidateDateModel;
typedef void(^pickViewDidSelectItemEvent)(NSString *selectedItem);
typedef void(^pickViewDidSelectItemBlock)(NXLFileValidateDateModel *dateModel);

@interface NXFileValidityPickViewController : UIViewController

@property (nonatomic, strong) NXFileValidityNavigationViewController *navc;
@property (nonatomic, assign) CGFloat navHeight;
@property (nonatomic, copy) pickViewDidSelectItemEvent selectBlock;
@property (nonatomic, copy) pickViewDidSelectItemBlock selectItemCompBlock;
@property (nonatomic, strong) NXLFileValidateDateModel *dateModel;

-(instancetype)initWithDateModel:(NXLFileValidateDateModel *)dateModel;

@end
