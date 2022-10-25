//
//  NXActionSheetTableViewCell.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 05/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXActionSheetItem.h"

@interface NXActionSheetTableViewCell : UITableViewCell

- (void)configureCellWithActionSheetItem:(NXActionSheetItem *)item;

@end
