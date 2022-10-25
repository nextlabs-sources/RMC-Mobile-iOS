//
//  NXActionSheetSpecialTableViewCell.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 10/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXActionSheetItem.h"

@interface NXActionSheetSpecialTableViewCell : UITableViewCell

- (void)configureCellWithActionSheetItem:(NXActionSheetItem *)item;

@end
