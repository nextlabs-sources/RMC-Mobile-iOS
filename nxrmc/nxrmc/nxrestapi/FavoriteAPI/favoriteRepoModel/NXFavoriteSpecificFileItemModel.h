//
//  NXFavoriteSpecificFileItemModel.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepositoryModel.h"
#import "NXFile.h"

@interface NXFavoriteSpecificFileItemModel : NSObject

@property (nonatomic,strong,nullable) NXRepositoryModel *repoModel;
@property (nonatomic,strong,nullable) NXFile *fileItem;
@end
