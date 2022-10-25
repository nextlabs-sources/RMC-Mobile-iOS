//
//  NXProjectFolder.m
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFolder.h"
#import "NXProjectFileOwnerModel.h"
@implementation NXProjectFolder {
    NSString *_fromType;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeProject;
    }
    return self;
}

-(instancetype)initFileFromResultProjectFileListDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _fromType=@"projectFileList";
        self.sorceType = NXFileBaseSorceTypeProject;
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"lastModified"]) {
        self.lastModifiedTime = [NSString stringWithFormat:@"%f", ((NSNumber *)value).doubleValue/1000];
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:self.lastModifiedTime.longLongValue];
    }else if ([key isEqualToString:@"creationTime"]) {
        self.creationTime = [NSString stringWithFormat:@"%f", ((NSNumber *)value).doubleValue/1000];
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // projectFileListModel
    if ([_fromType isEqual:@"projectFileList"]) {
//        if ([key isEqualToString:@"fileName"]) {
//            self.name=value;
//        }
        if ([key isEqualToString:@"pathDisplay"]) {
            self.fullPath=value;
        }
        if ([key isEqualToString:@"pathId"]) {
            self.fullServicePath=value;
        }
        if ([key isEqualToString:@"id"]) {
            self.Id=value;
        }
//        if ([key isEqualToString:@"fileSize"]) {
//            self.size=[value longLongValue];
//        }
        if ([key isEqualToString:@"owner"]) {
            NSDictionary*ownerDic=(NSDictionary*)value;
            NXProjectFileOwnerModel *owner=[[NXProjectFileOwnerModel alloc]init];
            [owner setValuesForKeysWithDictionary:ownerDic];
            self.projectFileOwner=owner;
        }
        
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXProjectFolder class]]) {
        return NO;
    }
    
    NXProjectFolder *otherObj = (NXProjectFolder *)object;
    if ([otherObj.fullServicePath isEqualToString:self.fullServicePath]) {
        return YES;
    }else {
        return NO;
    }
}


@end
