//
//  NXSharepointOnline.m
//  nxrmc
//
//  Created by nextlabs on 6/1/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXSharepointOnline.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"
#import "NXCacheManager.h"
#import "NXCommonUtils.h"

#import "NXFileBase.h"
#import "NXFolder.h"
#import "NXFile.h"

#import "NXLoginUser.h"
#import "NXCenterTokenManager.h"

@interface NXSharepointOnline()
@property(nonatomic, strong) NSString *token;
@property(nonatomic, strong) NSString *repoId;

@end


@implementation NXSharepointOnline


- (instancetype) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel
{
    self.userId = userId;
    self.repoId = repoModel.service_id;
    NSString *siteUrl = repoModel.service_account;
    return [self initWithUrl:siteUrl cookies:nil];
}

- (NSMutableArray*) changeFormatwithsiteurl:(NSString*)siteurl token:(NSString*)token{
    NSArray *array = [token componentsSeparatedByString:@"^"];
    NSString *fedauth = array[0];
    NSString *rtfa = array[1];
    
    NSDictionary *fedAuthCookie = [NSDictionary dictionaryWithObjectsAndKeys:
                                   siteurl, NSHTTPCookieOriginURL,
                                   @"FedAuth", NSHTTPCookieName,
                                   @"/", NSHTTPCookiePath,
                                   fedauth, NSHTTPCookieValue,
                                   nil];
    
    NSDictionary *rtFaCookie = [NSDictionary dictionaryWithObjectsAndKeys:
                                siteurl, NSHTTPCookieOriginURL,
                                @"rtFa", NSHTTPCookieName,
                                @"/", NSHTTPCookiePath,
                                rtfa, NSHTTPCookieValue,
                                nil];
    
    
    NSHTTPCookie *fedAuthCookieObj = [NSHTTPCookie cookieWithProperties:fedAuthCookie];
    NSHTTPCookie *rtFaCookieObj = [NSHTTPCookie cookieWithProperties:rtFaCookie];
    
    NSMutableArray *cookies = [NSMutableArray arrayWithObjects: fedAuthCookieObj, nil];
    
    if(rtFaCookieObj != nil){
        [cookies addObject:rtFaCookieObj];
    }
    return cookies;
}

- (instancetype) initWithUrl:(NSString*)siteurl cookies:(NSArray*) cookies{
    if (self = [super init]) {
        self.spMgr = [[NXSharePointManager alloc] initWithURL:siteurl cookies:cookies Type:kSPMgrSharePointOnline];
        self.spMgr.delegate = self;
        self.spMgr.repoId = self.repoId;
    }
    return self;
}

- (BOOL) downloadFile:(NXFileBase *)file
{
    // url is like
    // Cache/rms_userToken/SharePointOnline_sid/root/SPserver/sites/site/list/folder/file.txt
    
    if (![file isKindOfClass:[NXSharePointFile class]]) {
        NSLog(@"Not a SPFile, ERROR");
        return NO;
    }
    //// FIRST, we need change spMgr siteURL according to file ownerSite
    NXSharePointFile* spFile = (NXSharePointFile*)file;
    self.spMgr.siteURL = spFile.ownerSiteURL;
    NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file];
    NSURL* url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
    url = [url URLByAppendingPathComponent:CACHEROOTDIR isDirectory:NO];
    url = [url URLByAppendingPathComponent:file.fullServicePath];
    
    NSString* dest = url.path;
    NSRange range = [dest rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString* dir = [dest substringToIndex:range.location];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil] ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    [self.spMgr downloadFile:spFile fileRelativeURL:file.fullServicePath destPath:dest];
    
    return YES;
}

- (BOOL)cacheNewUploadFile:(NXFileBase *) uploadFile sourcePath:(NSString *)srcpath {
     NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.repoId];
    
    NSURL *url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
    
    NSString *localPath = [[[url path] stringByAppendingPathComponent:CACHEROOTDIR] stringByAppendingPathComponent:uploadFile.fullPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    if ([manager fileExistsAtPath:localPath]) {
        [manager removeItemAtPath:localPath error:&error];
    }
    
    BOOL ret = [manager moveItemAtPath:srcpath toPath:localPath error:&error];
    if (ret) {
        [NXCacheFileStorage storeCacheFileIntoCoreData:uploadFile cachePath:localPath];
        [NXCommonUtils setLocalFileLastModifiedDate:localPath date:uploadFile.lastModifiedDate];
    } else {
        NSLog(@"SharepointOnline service cache file %@ failed", localPath);
    }
    
    return YES;
}

@end
