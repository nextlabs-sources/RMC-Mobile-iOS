//
//  NXFavoriteRepoFilesModel.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepositoryModel.h"

@interface NXFavoriteRepoFilesModel : NSObject

@property (nonatomic,strong,nullable) NXRepositoryModel *repoModel;
@property (nonatomic,strong,nullable) NSMutableArray *markedFavoriteFiles;
@property (nonatomic,strong,nullable) NSMutableArray *unmarkedFavoriteFiles;

@end
