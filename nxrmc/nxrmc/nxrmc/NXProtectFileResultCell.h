//
//  NXProtectFileResultCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/3/4.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXFileBase;
@interface NXResultModel : NSObject
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, assign)BOOL isSuccess;
@end
@interface NXProtectFileResultCell : UITableViewCell
@property(nonatomic, strong)NXResultModel *model;
@end


