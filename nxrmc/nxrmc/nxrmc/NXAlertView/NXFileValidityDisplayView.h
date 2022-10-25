//
//  NXFileValidityDisplayView.h
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 06/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXLFileValidateDateModel;
@interface NXFileValidityDisplayDateView : UIView
- (instancetype)initWithDate:(NSDate *)date;
- (void)update:(NSDate *)date;
@end

@interface NXFileValidityDisplayView : UIView

@property (nonatomic,assign) NXLFileValidateDateModel *model;

- (instancetype)initWithFileValidityModel:(NXLFileValidateDateModel *)model;
- (void)update:(NXLFileValidateDateModel*)dateModel;

@end
