//
//  NXAccountInputCell.h
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXAccountInputTextField.h"

#import "NXAccountInputCellModel.h"

@interface NXAccountInputCell : UITableViewCell

@property(nonatomic, weak, readonly) NXAccountInputTextField *textField;

@property(nonatomic, strong) NXAccountInputCellModel *model;

@end
#import "NXAccountInputTextField.h"
