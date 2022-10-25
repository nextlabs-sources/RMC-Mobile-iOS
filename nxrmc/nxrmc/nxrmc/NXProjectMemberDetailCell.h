//
//  NXProjectMemberDetailCell.h
//  nxrmc
//
//  Created by xx-huang on 07/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectMemberModel.h"

@interface dataModel : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;

- (instancetype)initWithTittle:(NSString *)tittle content:(NSString *)content;

@end

@interface NXProjectMemberDetailCell : UITableViewCell

- (void)configureCellWithDataModel:(dataModel *)model;

- (void)configureCellWithMemberModel:(NXProjectMemberModel *)memberModel;

@end
