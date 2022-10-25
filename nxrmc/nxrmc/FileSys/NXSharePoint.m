//
//  NXSharePoint.m
//  nxrmc
//
//  Created by ShiTeng on 15/5/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXSharePoint.h"
#import "NXSharePointFolder.h"
#import "NXCacheManager.h"
#import "NXKeyChain.h"
#import "NXSharePointFile.h"
#import "NXFileBase+SharePointFileSys.h"
#import "NXCommonUtils.h"
@interface NXSharePoint()
@property(nonatomic, strong) NXFileBase* curDownloadFile;
@end
@implementation NXSharePoint {
    NXFileBase *_parentFolderNew;
    NSString   *_newFolderName;
}

#pragma mark INIT and INSTANCE

-(NSString *) getServiceAlias
{
    return self.boundService.service_alias;
}

-(void) setAlias:(NSString *) alias
{
    _alias = alias;
}



- (instancetype) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel
{
    // for sharepoint, we need siteURL, userName, psw to init
    
    //step1. get psw from keychain by userId(siteURL^userEmail)
    NSString* psw = [NXKeyChain load:userId];
    
    //step2. The format of userId:  siteURL^userName  (^ is illegal character in URL, so use ^ to sperate)
    NSArray* array = [userId componentsSeparatedByString:@"^"];
    NSString* siteURL = array[0];
    NSString* userName = array[1];
    _boundService = [repoModel copy];
    
    return [self initWithSiteURL:siteURL userName:userName passWord:psw];
}
-(instancetype) initWithSiteURL:(NSString*) siteURL userName:(NSString *)userName passWord:(NSString *)psw
{
    if (self = [super init]) {
        _spMgr = [[NXSharePointManager alloc] initWithSiteURL:siteURL userName:userName passWord:psw Type:kSPMgrSharePoint];
        _spMgr.delegate = self;
        _userId = [NSString stringWithFormat:@"%@^%@", siteURL, userName];
        
        
    }
    
    return self;
}
-(void) setSharePointSite:(NSString*) siteURL
{
    if (_spMgr) {
        _spMgr.siteURL = siteURL;
    }
}

#pragma mark ----------NXFileInfo Delegate-----------
-(void) setDelegate: (id<NXServiceOperationDelegate>) delegate
{
    _delegate = delegate;
}
- (BOOL) isProgressSupported
{
    return YES;
}

- (BOOL) getUserInfo
{
    [_spMgr getCurrentUserInfo];
    return YES;
}

- (BOOL) cancelGetUserInfo
{
    [_spMgr cancelAllQuery];
    return YES;
}
-(BOOL) getAllFilesInFolder:(NXFileBase *)folder {
    return NO;
}
-(BOOL) getFiles:(NXFileBase *)folder
{
    //36
    if (!folder) {
        return NO;
    }
    self.curFolder = folder;
    // Check folder type: 1.root(The init site) 2.site 3.list 4.spfolder
    if (folder.isRoot) {
        [_spMgr allChildItemsOnSite];
        return YES;
    }
    
    if ([folder isKindOfClass:[NXSharePointFolder class]]) {
        
        NXSharePointFolder* spSharePointFolder = (NXSharePointFolder*) folder;
        
        if (spSharePointFolder.folderType == kSPDocList) {
            // FIRST, we need change spMgr siteURL according to folder ownerSite
            _spMgr.siteURL = spSharePointFolder.ownerSiteURL;
            [_spMgr checkListExistForGetFiles:spSharePointFolder.fullServicePath];
            
           // [_spMgr allChildenItemsInRootFolderInList:spSharePointFolder.fullServicePath];
        }else if(spSharePointFolder.folderType == kSPSite)
        {
            _spMgr.siteURL = spSharePointFolder.fullServicePath;
            [_spMgr checkSiteExistForGetFiles:spSharePointFolder.fullServicePath];
            //[_spMgr allChildItemsOnSite];

        }else if(spSharePointFolder.folderType == kSPNormalFolder)
        {
            _spMgr.siteURL = spSharePointFolder.ownerSiteURL;
            
            [_spMgr checkFolderExistForGetFiles:spSharePointFolder.fullServicePath];
           // [_spMgr allChildItemsInFolder:spSharePointFolder.fullServicePath];
        }
        return YES;
    }
    // will never have folder type, except root folder
//    if ([folder isMemberOfClass:[NXFolder class]]) {
//        NSLog(@"getFiles can not have foler type!Something is wrong");
//        return NO;
//    }
    return NO;
}

-(BOOL) cancelGetFiles:(NXFileBase*)folder
{
    if (folder && _curFolder == folder) {
        [_spMgr cancelAllQuery];
    }
    return YES;
}

- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    // url is like
    // Cache/rms_userToken/SharePoint_sid/root/SPserver/sites/site/list/folder/file.txt
    
    if (![file isKindOfClass:[NXSharePointFile class]]) {
        NSLog(@"Not a SPFile, ERROR");
        return NO;
    }
    //// FIRST, we need change spMgr siteURL according to file ownerSite
    NXSharePointFile* spFile = (NXSharePointFile*)file;
    _spMgr.siteURL = spFile.ownerSiteURL;
    NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file];
    NSURL* url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
    url = [url URLByAppendingPathComponent:CACHEROOTDIR isDirectory:NO];
    //url = [url URLByAppendingPathComponent:_spMgr.serverName isDirectory:NO];
    url = [url URLByAppendingPathComponent:file.fullServicePath];
    
    NSString* dest = url.path;
    NSRange range = [dest rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString* dir = [dest substringToIndex:range.location];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil] ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    self.curFolder = spFile;
    [self.spMgr downloadFile:spFile fileRelativeURL:file.fullServicePath destPath:dest];
    
    return YES;
}

- (BOOL) downloadFile:(NXFileBase *)file
{
    // url is like
    // Cache/rms_userToken/SharePoint_sid/root/SPserver/sites/site/list/folder/file.txt
    
    if (![file isKindOfClass:[NXSharePointFile class]]) {
        NSLog(@"Not a SPFile, ERROR");
        return NO;
    }
    //// FIRST, we need change spMgr siteURL according to file ownerSite
    NXSharePointFile* spFile = (NXSharePointFile*)file;
    _spMgr.siteURL = spFile.ownerSiteURL;
     NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file];
    NSURL* url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
    url = [url URLByAppendingPathComponent:CACHEROOTDIR isDirectory:NO];
    //url = [url URLByAppendingPathComponent:_spMgr.serverName isDirectory:NO];
    url = [url URLByAppendingPathComponent:file.fullServicePath];
    
    NSString* dest = url.path;
    NSRange range = [dest rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString* dir = [dest substringToIndex:range.location];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil] ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    self.curFolder = spFile;
    [self.spMgr downloadFile:spFile fileRelativeURL:file.fullServicePath destPath:dest];

    return YES;
}
- (BOOL)addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder {
    [_spMgr createFolderName:folderName withParent:parentFolder];
    _parentFolderNew=parentFolder;
    _newFolderName=folderName;
     return YES;
}
- (BOOL)deleteFileItem:(NXFileBase *)file {
    [_spMgr deleteFileOrFolder:file];
    return YES;
}

- (BOOL) cancelDownloadFile:(NXFileBase *)file
{
    if (![file isKindOfClass:[NXSharePointFile class]]) {
        NSLog(@"Not a SPFile, ERROR");
        return NO;
    }
    //// FIRST, we need change spMgr siteURL according to file ownerSite
    NXSharePointFile* spFile = (NXSharePointFile*)file;
    _spMgr.siteURL = spFile.ownerSiteURL;

    [self.spMgr cancelDownloadFile:spFile];
    return YES;
}
-(BOOL) uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile
{
    _curFolder = folder;
     NXSharePointFolder* spSharePointFolder = (NXSharePointFolder*) folder;
    if (spSharePointFolder.folderType == kSPDocList) {
        
        _spMgr.siteURL = spSharePointFolder.ownerSiteURL;
        [self.spMgr uploadFile:filename destFolderRelativeURL:spSharePointFolder.fullServicePath fromPath:srcPath isRootFolder:YES uploadType:type];
        
    }else if(spSharePointFolder.folderType == kSPNormalFolder)
    {
         _spMgr.siteURL = spSharePointFolder.ownerSiteURL;
        [self.spMgr uploadFile:filename destFolderRelativeURL:spSharePointFolder.fullServicePath fromPath:srcPath isRootFolder:NO uploadType:type];
    
    }else
    {
        return NO;
    }
    
    return YES;
}
-(BOOL) cancelUploadFile:(NSString*)filename toPath:(NXFileBase*)folder
{
     [_spMgr cancelAllQuery];
    return YES;
}

-(BOOL)getMetaData:(NXFileBase *)file
{
    if (![file isKindOfClass:[NXSharePointFile class]] && ![file isKindOfClass:[NXSharePointFolder class]]) {
        NSLog(@"Error! getMetaData is not a sharepoint file or Folder!");
        return NO;
    }
    
    self.spMgr.siteURL = ((NXSharePointFile*)file).ownerSiteURL;
    
    if ([file isKindOfClass:[NXSharePointFile class]]) {
        [self.spMgr queryFileMetaData:file.fullServicePath];
    }else if([file isKindOfClass:[NXSharePointFolder class]]){
        
        SPFolderType folderType = ((NXSharePointFolder*) file).folderType;
        switch (folderType) {
            case kSPNormalFolder:
                [self.spMgr queryFolderMetaData:file.fullServicePath];
                break;
            case kSPDocList:
                [self.spMgr queryListMetaData:file.fullServicePath];
                break;
            case kSPSite:
                [self.spMgr querySiteMetaData:file.fullServicePath];
                break;
        }
    }
    
    return YES;
}

-(BOOL) cancelGetMetaData:(NXFileBase*)file
{
    if (file) {
        [_spMgr cancelAllQuery];
    }
    return YES;
}

#pragma mark NXSharePointManagerDelegate
-(void) didFinishSPQuery:(NSArray*) result forQuery:(SPQueryIdentify) type
{
    if (type < kSPQueryGetFilesEnd) {
        NSMutableArray* nxFileArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary* dicNode in result) {
            NXFileBase* spFile = nil;
           
            // step1. check node type
            NSString* nodeType = dicNode[SP_NODE_TYPE];
            
            if ([nodeType isEqualToString:SP_NODE_SITE] || [nodeType isEqualToString:SP_NODE_DOC_LIST] || [nodeType isEqualToString:SP_NODE_FOLDER]) {
                spFile = [[NXSharePointFolder alloc] init];
                
            }else if([nodeType isEqualToString:SP_NODE_FILE])
            {
                spFile = [[NXSharePointFile alloc]init];
            }
            
            [self fetchFile:spFile InfoFrom:dicNode];

            
            if(spFile){
                [nxFileArray addObject:spFile];
            }
            spFile.parent = self.curFolder;
            ///[self.curFolder addChild:spFile];
        }

        NSMutableArray* mutablrChildren = (NSMutableArray*)nxFileArray;
        [mutablrChildren sortUsingSelector:@selector(compareItemType:)];
        [self.delegate getFilesFinished:nxFileArray error:nil];
        
        if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
            [_delegate serviceOpt:self getFilesFinished:nxFileArray error:nil];
        }

    }
    
    if (type == kSPQueryCheckFolderExistForGetFiles) {
        [_spMgr allChildItemsInFolder:self.curFolder.fullServicePath];
    }
    
    if (type == kSPQueryCheckListExistForGetFiles) {
        [_spMgr allChildenItemsInRootFolderInList:self.curFolder.fullServicePath];
    }
    
    if (type == kSPQueryCheckSiteExistForGetFiles) {
        [_spMgr allChildItemsOnSite];
    }
}

-(void) didFinishSPQueryWithError:(NSError*) error forQuery:(SPQueryIdentify) type
{
    if (type < kSPQueryGetFilesEnd) {
        [self.delegate getFilesFinished:nil error:error];
        
        if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
            [_delegate serviceOpt:self getFilesFinished:nil error:error];
        }
        
    }else if(type == kSPQueryDownloadFile)
    {
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
            [self.delegate downloadFileFinished:self.curDownloadFile fileData:nil error:error];
        }
        
    }else if(type == kSPQueryCheckListExistForGetFiles || type == kSPQueryCheckFolderExistForGetFiles || type == kSPQueryCheckSiteExistForGetFiles)
    {
        [self.delegate getFilesFinished:nil error:error];
        
        if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
            [_delegate serviceOpt:self getFilesFinished:nil error:error];
        }
        
    }else if(type == kSPQueryUploadFile || type == kSPQueryGetContextInfo)
    {
        if ([self.delegate respondsToSelector:@selector(uploadFileFinished:fromPath:error:)]) {
            [self.delegate uploadFileFinished:nil fromPath:nil error:error];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadFileFinished:fromLocalPath:error:)]) {
            [self.delegate uploadFileFinished:nil fromLocalPath:nil error:error];
        }
        
    }else if(type ==  kSPQueryGetCurrentUserInfo || type == kSPQueryGetCurrentUserDetailInfo)
    {
        if ([self.delegate respondsToSelector:@selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:)]) {
            [self.delegate getUserInfoFinished:nil userEmail:nil totalQuota:nil usedQuota:nil error:error];
        }
    }
}

-(void) didDownloadFile:(NSString*) fileName fileData:(NSData*) fileData
{
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
        [self.delegate downloadFileFinished:self.curDownloadFile fileData:fileData error:nil];
    }
}

-(void) didUploadFileFinished:(NSString *)servicePath fromPath:(NSString *)localCachePath fileInfo:(NSDictionary *)uploadedFileInfo error:(NSError *)err {
    NXFileBase *overWriteFile = nil;
    NXSharePointFile *uploadedFile = nil;
    if (!err) {
        
       
        //for sharepoint online and sharepoint, uploadfile will overwrite if same file(it mean same name) exist. so we should delete old file.
        for (NXFileBase * child in [_curFolder getChildren] ) {
            if ([servicePath isEqualToString: child.fullServicePath]) {
//                [_curFolder removeChild:child];
                overWriteFile = child;
                break;
            }
        }
        if (overWriteFile) {
            [self fetchFile:overWriteFile InfoFrom:uploadedFileInfo];
            [self cacheNewUploadFile:overWriteFile sourcePath:localCachePath];
        } else {
            uploadedFile = [[NXSharePointFile alloc] init];
            [self fetchFile:uploadedFile InfoFrom:uploadedFileInfo];
            uploadedFile.parent = _curFolder;
            [_curFolder addChild:uploadedFile];
            [self cacheNewUploadFile:uploadedFile sourcePath:localCachePath];
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(uploadFileFinished:fromLocalPath:error:)]) {
        [self.delegate uploadFileFinished:overWriteFile?:uploadedFile fromLocalPath:localCachePath error:err];
    }
}

-(void) didAuthenticationFail:(NSError*) error forQuery:(SPQueryIdentify) type
{
    if (type < kSPQueryGetFilesEnd) {
        [self.delegate getFilesFinished:nil error:error];
        if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
            [_delegate serviceOpt:self getFilesFinished:nil error:error];
        }
        
    }else if(type == kSPQueryDownloadFile)
    {
//        [self.delegate downloadFileFinished:nil intoPath:nil error:error];
        [self.delegate downloadFileFinished:nil fileData:nil error:error];
    }

}
-(void) didFinishSPQueryFileMetaData:(NSDictionary*) result error:(NSError*) error forQuery:(SPQueryIdentify) type
{
    
    if (error) {
        
        [self.delegate getMetaDataFinished:nil error:error];
        
    }else
    {
        if (type == kSPQueryListMetaData || type == kSPQuerySiteMetaData || type == kSPQueryFolderMetaData) {
            NXSharePointFolder* spFolder = [[NXSharePointFolder alloc] init];
            [self fetchFile:spFolder InfoFrom:result];
            [self.delegate getMetaDataFinished:(NXFileBase *)spFolder error:nil];

        }else if(type == kSPQueryFileMetaData)
        {
            NXSharePointFile* spFile = [[NXSharePointFile alloc] init];
            [self fetchFile:spFile InfoFrom:result];
            [self.delegate getMetaDataFinished:(NXFileBase *)spFile error:nil];
        }else
        {
            NSLog(@"Error!!!! Sharepoint getmetadata from error query type");
        }
        
    }
}
-(void) updataDownloadProcess:(CGFloat)progress forFile:(NSString*) filePath
{
    if ([self.delegate respondsToSelector:@selector(downloadFileProgress:forFile:)]) {
        [self.delegate downloadFileProgress:progress forFile:filePath];
    }
}
-(void) didAuthenticationSuccess
{
}

-(void) didFinishGetUserInfoQUery:(NSDictionary *) result error:(NSError *) error
{
    if ([self.delegate respondsToSelector:@selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:)]) {
         [self.delegate getUserInfoFinished:result[SP_TITLE_TAG] userEmail:result[SP_EMAIL_TAG] totalQuota:result[SP_STORAGE_TAG] usedQuota:result[SP_STORAGE_USED_TAG] error:error];
    }
}
-(void)didDeleteItemFinishedFormPath:(NSString *)path {
    if ([self.delegate respondsToSelector:@selector(deleteItemFinished:)]) {
        [self.delegate deleteItemFinished:nil];
    }
}
-(void)didDeleteItemFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(deleteItemFinished:)]) {
        [self.delegate deleteItemFinished:error];
    }
}
-(void)didCreateFolderFinishedTopath:(NSString *)path {
    if ([self.delegate respondsToSelector:@selector(addFolderFinished:error:)]) {
    NXSharePointFolder *pointFolder =(NXSharePointFolder*)_parentFolderNew;
    NXSharePointFolder *fileBase =[[NXSharePointFolder alloc]init];
    fileBase.SPSiteId=path;
    fileBase.name=_newFolderName;
        NSTimeInterval tempMilli = [[NSDate date]timeIntervalSince1970];
        NSUInteger seconds = tempMilli*1000;
    fileBase.lastModifiedTime=[NSString stringWithFormat:@"%ld",seconds];
    
    if ([_parentFolderNew.fullPath isEqualToString:@"/"]) {
      //  NSString *pathStr=@"/ProjectNova";
        fileBase.fullPath=[fileBase.fullPath stringByAppendingPathComponent:_newFolderName];
        fileBase.fullServicePath=[self bringUpfullServicePathGuidForCreateFolderFromString:path];
        fileBase.folderType=kSPDocList;
    }else{
        if (pointFolder.folderType==kSPSite) {
            fileBase.fullPath=[_parentFolderNew.fullPath stringByAppendingPathComponent:_newFolderName];
            fileBase.fullServicePath=[self bringUpfullServicePathGuidForCreateFolderFromString:path];
            fileBase.folderType=kSPDocList;
        }else {
            fileBase.fullPath=[_parentFolderNew.fullPath stringByAppendingPathComponent:_newFolderName];
            fileBase.fullServicePath=[self bringUpfullServicePathStrForCreateFolderFromString:path];
            fileBase.folderType= kSPNormalFolder;
        }
    }
        fileBase.ownerSiteURL = [self.spMgr.siteURL copy];
        // [self.delegate add:nil];
        [self.delegate addFolderFinished:fileBase error:nil];
    }
}
-(void)didCreateFolderFailwithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(addFolderFinished:error:)]) {
      //  [self.delegate addFloderFinished:error];
        [self.delegate addFolderFinished:nil error:error];
    }
}
#pragma mark Fetch SPQuery Resutl
-(void) fetchFile:(NXFileBase*) file InfoFrom:(NSDictionary*) dicNode
{
    NSString* nodeType = dicNode[SP_NODE_TYPE];
    
    if ([nodeType isEqualToString:SP_NODE_SITE]) {
        file.name = dicNode[SP_TITLE_TAG];
        file.fullServicePath = dicNode[SP_URL_TAG];
        file.SPSiteId = dicNode[SP_id_TAG];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate* lastModifydate = [dateFormatter dateFromString:dicNode[SP_CREATED_TAG]];
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterFullStyle];
        file.lastModifiedDate = lastModifydate;
        file.lastModifiedTime = lastModifydateString;
        ((NXSharePointFolder*)file).ownerSiteURL = _spMgr.siteURL;
        ((NXSharePointFolder*)file).folderType = kSPSite;
        
    }else if([nodeType isEqualToString:SP_NODE_DOC_LIST]){
        
        file.name = dicNode[SP_TITLE_TAG];
        file.fullServicePath = dicNode[SP_ID_TAG];
        file.SPSiteId = dicNode[SP_id_TAG];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate* lastModifydate = [dateFormatter dateFromString:dicNode[SP_CREATED_TAG]];
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterFullStyle];
        file.lastModifiedDate = lastModifydate;
        file.lastModifiedTime = lastModifydateString;
        ((NXSharePointFolder*)file).folderType =kSPDocList;
        ((NXSharePointFolder*)file).ownerSiteURL = _spMgr.siteURL;
        
    }else if ([nodeType isEqualToString:SP_NODE_FOLDER]){
        file.name = dicNode[SP_NAME_TAG];
        file.fullServicePath = dicNode[SP_SERV_RELT_URL_TAG];
        file.SPSiteId = dicNode[SP_id_TAG];
        ((NXSharePointFolder*)file).folderType = kSPNormalFolder;
        ((NXSharePointFolder*)file).ownerSiteURL = _spMgr.siteURL;
        
    }else if([nodeType isEqualToString:SP_NODE_FILE])
    {
        file.name = dicNode[SP_NAME_TAG];
        file.fullServicePath = dicNode[SP_SERV_RELT_URL_TAG];
        file.SPSiteId = dicNode[SP_id_TAG];
        file.size = [dicNode[SP_FILE_SIZE_TAG] longLongValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate* lastModifydate = [dateFormatter dateFromString:dicNode[SP_TIME_LAST_MODIFY]];
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterFullStyle];
        file.lastModifiedDate = lastModifydate;
        ((NXSharePointFolder*)file).lastModifiedTime = lastModifydateString;
        ((NXSharePointFolder*)file).ownerSiteURL = _spMgr.siteURL;
        NSString *serverFilePathId =  dicNode[SP_CONTENT_VERSION_TAG];
        if (serverFilePathId.length > 0) {
            NSArray *array = [serverFilePathId componentsSeparatedByString:@","];
            if (array.count > 0) {
                NSString *serfilePathId = [array firstObject];
                NSString *serverfilePathID = [serfilePathId substringWithRange:NSMakeRange(1, serfilePathId.length - 2)];
                if (serverfilePathID.length > 0) {
                        ((NXSharePointFolder*)file).fullServicePath = serverfilePathID;
                }
            }
        }
        
        if (_spMgr.spMgrType == kSPMgrSharePoint) {
              ((NXSharePointFolder*)file).fullServicePath = dicNode[SP_SERV_RELT_URL_TAG];
        }
    }
    file.serviceAccountId = _userId;
    if ([self isKindOfClass:[NXSharePoint class]]) {
        
        file.serviceType = [NSNumber numberWithInteger:kServiceSharepoint];
        
    }else
    {
        file.serviceType = [NSNumber numberWithInteger:kServiceSharepointOnline];
    }
    
    file.serviceAlias = [self getServiceAlias];
    
    if (self.curFolder.isRoot) {
        file.fullPath = [NSString stringWithFormat:@"%@%@", self.curFolder.fullPath, file.name];
    }else {
        file.fullPath = [NSString stringWithFormat:@"%@/%@", self.curFolder.fullPath, file.name];
    }
    file.sorceType = NXFileBaseSorceTypeRepoFile;
}

- (BOOL)cacheNewUploadFile:(NXFileBase *) uploadFile sourcePath:(NSString *)srcpath {
    
    return YES;
//     NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:uploadFile];
//    NSURL *url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
//    
//    NSString *localPath = [[[url path] stringByAppendingPathComponent:CACHEROOTDIR] stringByAppendingPathComponent:uploadFile.fullPath];
//    
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSError *error;
//    if ([manager fileExistsAtPath:localPath]) {
//        [manager removeItemAtPath:localPath error:&error];
//    }
//    
//    BOOL ret = [manager moveItemAtPath:srcpath toPath:localPath error:&error];
//    if (ret) {
//        [NXCommonUtils storeCacheFileIntoCoreData:uploadFile cachePath:localPath];
//        [NXCommonUtils setLocalFileLastModifiedDate:localPath date:uploadFile.lastModifiedDate];
//    } else {
//        NSLog(@"Sharepoint service cache file %@ failed", localPath);
//    }
//    
//    return YES;
}
#pragma mark ------>bring up url
-(NSString*)bringUpfullServicePathStrForCreateFolderFromString:(NSString*)string{
    NSMutableString *muStr =[NSMutableString stringWithString:string];
    NSRange range1 = [muStr rangeOfString:@"('"];
    NSRange range2 = [muStr rangeOfString:@"')"];
    NSString *guidStr =[muStr substringWithRange:NSMakeRange(range1.location+2, range2.location-range1.location-2)];
    return guidStr;
    
}
- (NSString*)bringUpfullServicePathGuidForCreateFolderFromString:(NSString*)string{
    NSMutableString *muStr =[NSMutableString stringWithString:string];
    NSRange range1 = [muStr rangeOfString:@"id'"];
    NSRange range2 = [muStr rangeOfString:@"')"];
    NSString *guidStr =[muStr substringWithRange:NSMakeRange(range1.location+3, range2.location-range1.location-3)];
    return guidStr;
}
@end
