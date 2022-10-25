//
//  NXMySpaceHomePageRepoModel.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/23.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMySpaceHomePageRepoModelType)
{
    NXMySpaceHomePageRepoModelTypeMyDrive = 1,
    NXMySpaceHomePageRepoModelTypeMyVault = 2,
    NXMySpaceHomePageRepoModelTypeMySpace = 3,
    NXMySpaceHomePageRepoModelTypeSharedWithMe = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface NXMySpaceHomePageRepoModel : NSObject
@property (nonatomic,assign) NXMySpaceHomePageRepoModelType type;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *filesCount;
@property (nonatomic,copy) NSString *repoDescription;
@property (nonatomic,copy) NSString *spaceUsedDesStr;
@property (nonatomic,assign) double proportion;
@property (nonatomic,assign) double myDriveProportion;
@property (nonatomic,assign) double myVaultProportion;

- (instancetype)initWithType:(NXMySpaceHomePageRepoModelType)type title:(NSString *)title filesCount:(NSString *)filesCount Des:(NSString*)description proportion:(double)proportion spaceUsedDesStr:(NSString*)spaceUsedStr;
@end

NS_ASSUME_NONNULL_END
