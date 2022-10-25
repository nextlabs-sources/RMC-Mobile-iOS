//
//  NXProjectFileItemCell.h
//  nxrmc
//
//  Created by EShi on 3/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileItemCell.h"
#import "NXProjectModel.h"

@interface NXProjectFileItemCell : NXFileItemCell

@property(nonatomic, strong) NXProjectModel *projectModel;

@end
