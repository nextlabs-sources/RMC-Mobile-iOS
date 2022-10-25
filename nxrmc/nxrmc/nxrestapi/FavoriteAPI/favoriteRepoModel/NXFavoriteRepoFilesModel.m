//
//  NXFavoriteRepoFilesModel.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteRepoFilesModel.h"

@implementation NXFavoriteRepoFilesModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _repoModel = [[NXRepositoryModel alloc] init];
        _markedFavoriteFiles = [NSMutableArray new];
        _unmarkedFavoriteFiles = [NSMutableArray new];
    }
    return self;
}

@end
