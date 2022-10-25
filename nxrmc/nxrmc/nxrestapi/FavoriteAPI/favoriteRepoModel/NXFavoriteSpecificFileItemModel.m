//
//  NXFavoriteSpecificFileItemModel.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteSpecificFileItemModel.h"

@implementation NXFavoriteSpecificFileItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _repoModel = [NXRepositoryModel new];
        _fileItem = [NXFile new];
    }
    return self;
}
@end
