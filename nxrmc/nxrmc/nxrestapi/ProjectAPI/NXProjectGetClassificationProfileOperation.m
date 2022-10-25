//
//  NXProjectGetClassificationProfileOperation.m
//  nxrmc
//
//  Created by Eren on 23/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXProjectGetClassificationProfileOperation.h"
#import "NXGetClassificationProfileAPI.h"
#import "NXLProfile.h"
@interface NXProjectGetClassificationProfileOperation()
@property(nonatomic, strong) NXProjectModel *projectModel;
@property(nonatomic, strong) NXGetClassificationProfileAPIRequest *request;
@property(nonatomic, strong) NSArray *classifications;
@property(nonatomic, strong) NSString *tokenGroupName;
@end

@implementation NXProjectGetClassificationProfileOperation

- (instancetype)initWithProject:(NXProjectModel *)projectMode {
    if (self = [super init]) {
        _projectModel = projectMode;
    }
    return self;
}
- (instancetype)initWithDeflautTokenGroup:(id)tokenGroup {
    if (self = [super init]) {
        _tokenGroupName = tokenGroup;
    }
    return self;
}
- (void)executeTask:(NSError **)error
{
    self.request = [[NXGetClassificationProfileAPIRequest alloc] init];
    id object = nil;
    if (self.tokenGroupName) {
        object = self.tokenGroupName;
    }else{
        if (self.projectModel) {
            object = self.projectModel.tokenGroupName;
        }
    }
    WeakObj(self);
    [self.request requestWithObject:object Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            self.classifications = [((NXGetClassificationProfileAPIResponse *)response) returndCategoriesArray];
            [self finish:nil];
        }else{
            [self finish:error];
        }
    }];
}
- (void)workFinished:(NSError *)error
{
    if (self.optCompletion) {
        self.optCompletion(self.classifications, error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
    if (self.optCompletion) {
        self.optCompletion(nil, cancelError);
    }
}
@end
