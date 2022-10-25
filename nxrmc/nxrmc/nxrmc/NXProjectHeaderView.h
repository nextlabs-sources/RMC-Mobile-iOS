//
//  NXProjectHeaderView.h
//  nxrmcUITest
//
//  Created by nextlabs on 2/13/17.
//  Copyright © 2017 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXProjectMemberModel.h"

@interface NXProjectHeaderView : UIView

@property(nonatomic, strong) NSArray<NXProjectMemberModel *> *dataArray;

- (void)reloadData;

@end
