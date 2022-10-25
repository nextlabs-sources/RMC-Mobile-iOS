//
//  NXMySpaceHomePageRepoModel.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/23.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXMySpaceHomePageRepoModel.h"

@implementation NXMySpaceHomePageRepoModel

- (instancetype)initWithType:(NXMySpaceHomePageRepoModelType)type title:(NSString *)title filesCount:(NSString *)filesCount Des:(NSString*)description proportion:(double)proportion spaceUsedDesStr:(NSString*)spaceUsedStr;
{
    self = [super init];
    if (self) {
        self.type = type;
        self.title = title;
        self.filesCount = filesCount;
        self.repoDescription = description;
        self.proportion = proportion;
        self.spaceUsedDesStr = spaceUsedStr;
    }
    return self;
}

@end
