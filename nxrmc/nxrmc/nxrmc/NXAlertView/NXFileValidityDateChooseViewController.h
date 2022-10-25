//
//  NXFileValidityDateChooseViewController.h
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 06/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXLFileValidateDateModel.h"

typedef void(^dateChooseCompletionBlock)(NXLFileValidateDateModel *dateModel);

@interface NXFileValidityDateChooseViewController : UIViewController
@property (nonatomic, copy) dateChooseCompletionBlock chooseCompBlock;

- (void)show;
- (instancetype)initWithDateModel:(NXLFileValidateDateModel *)dateModel;
@end

@interface NXFileValidityWindow : UIWindow
- (void)dismiss;

@end
