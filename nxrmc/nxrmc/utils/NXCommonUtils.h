//
//  NXCommonUtils.h
//  nxrmc
//
//  Created by Kevin on 15/5/12.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXRMCDef.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXCacheFile+CoreDataClass.h"
#import "NXServiceOperation.h"
#import "NXLoginUser.h"
#import "NXRepository.h"
#import "NXSyncDateModel.h"
#import "NXCacheFileStorage.h"
#import "NXRepositoryStorage.h"
#define NXDIVKEY @"NX_DIV_KEY" // use for connect service_type and sservice_account to gen rootFoler service dict key
@class NXLProfile;
@class NXLMetaData;
@interface NXCommonUtils : NSObject

//+ (UIView*) createWaitingView;
//+ (UIView*) createWaitingView:(CGFloat)sidelength;
//+ (UIView*) createWaitingViewWithCancel: (id) target selector: (SEL)selector inView:(UIView*)view;

+(NSString *) currentRMSAddress;
+(NSString *) currentTenant;
+(NSString *) currentSkyDrm;
+(NSString *) currentBundleDisplayName;
+(void) updateRMSAddress:(NSString *) rmsAddress;
+(void) updateRMSTenant:(NSString *) tenant;
+(void) updateSkyDrm:(NSString *) skyDrmAddress;

+ (void)forceUserLogout;

+ (NSRegularExpression *)getSortRegularExpression;
+ (BOOL)IsEnglishLetterInitalCapitalAndLowercaseLetter:(NSString*)string;
+ (NXFolder *)createRootFolderByRepoType:(ServiceType) type;
/**
 *  create waitting view and add to view(support auto layout)
 *
 *  @param view the parent view that want to add waiting view
 *
 *  @return the waiting view
 */
//+ (UIView*)createWaitingViewInView:(UIView*)view;
//+ (void) removeWaitingViewInView:(UIView *) view;
//+(BOOL) waitingViewExistInView:(UIView *)view;

+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
        OKActionTitle:(NSString *)okTitle
    cancelActionTitle:(NSString *)cancelTitle
       OKActionHandle:(void (^)(UIAlertAction *action))OKActionHandler
   cancelActionHandle:(void (^)(UIAlertAction *action))cancelActionHandler inViewController:(UIViewController *)controller
             position:(id)sourceView;

+ (void)showAlertView:(NSString *)title
           message:(NSString *)message
             style:(UIAlertControllerStyle)style
     OKActionTitle:(NSString *)okTitle
 cancelActionTitle:(NSString*)cancelTitle
        otherTitle:(NSString *)otherTitle
    OKActionHandle:(void (^)(UIAlertAction *action))OKActionHandler
cancelActionHandle:(void (^)(UIAlertAction *action))cancelActionHandler
 otherActionHandle:(void (^)(UIAlertAction *action))otherActionHandler
  inViewController:(UIViewController *)controller
          position:(id)sourceView;

+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
    cancelActionTitle:(NSString *)cancelTitle
   otherActionTitles:(NSArray *)otherTitles
     inViewController:(UIViewController *)controller
             position:(id)sourceView
             tapBlock:(void (^)(UIAlertAction *action, NSInteger index))tapBlock;

+ (NSString *)addIndexForFile:(NSUInteger)index fileName:(NSString *)fileName;
+ (NSUInteger)getMaxIndexForFile:(NSString *)fileName fileNameArray:(NSArray *)fileNameArr;

+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidateURL:(NSString *)URL;
+ (void) cleanUpTable:(NSString *) tableName;

+ (void) deleteCachedFilesOnDisk;
+ (void) deleteFilesAtPath:(NSString *)directory;
+ (NSNumber *) calculateCachedFileSize;
+ (NSNumber *) calculateCachedFileSizeAtPath:(NSString *)folderPath;

+ (NSArray*) getStoredProfiles;
+ (void) storeProfile: (NXLProfile*) profile;
+ (void) deleteProfile:(NXLProfile*) profile;


+ (id<NXServiceOperation>)getServiceOperation:(NXFileBase *)item;
+ (id<NXServiceOperation>)getServiceOperationFromRepoItem:(NXRepositoryModel *)repo;

+ (NXFileBase*) storeThirdPartyFileAndGetNXFile:(NSURL*)fileURL;

+ (NSString*) getMiMeType:(NSString*)filepath;
+ (NSString *) getMimeTypeByFileName:(NSString *)fileName;
+ (NSString*) getUTIForFile:(NSString*) filepath;
+ (NSString*) getExtension:(NSString*) fullpath error:(NSError **)error;
+ (NSString *) arrayToJsonString:(NSArray *)array error:(NSError **)error;
+ (NSString *)getFileExtensionByFileName:(NXFileBase *)file;

+ (NSString *) convertToCCTimeFormat:(NSDate *) date;
+ (NSString *) convertRepoTypeToDisplayName:(NSNumber *) repoType;
+ (BOOL) is3DFileWithMimeType:(NSString*)mimeType;
+ (BOOL) is3DFileFormat:(NSString*)extension;
+ (BOOL) isHOOPSFileFormat:(NSString *)extension;
+ (BOOL) is3DFileNeedConvertFormat:(NSString*)extension;
+ (BOOL) isTheSupportedFormat:(NSString*)extension;
+ (BOOL) isRemoteViewSupportFormat:(NSString *)extension;
+ (BOOL) isOfflineViewSupportFormat:(NXFileBase *)file;

+ (float) iosVersion;
+ (BOOL) isiPad;
+ (NSString *) deviceID;
+ (NSNumber*) getPlatformId;

+ (void)showAlertViewInViewController:(UIViewController*)vc title:(NSString*)title message:(NSString*)message;


//get device screenbounds.
+ (CGRect) getScreenBounds;



/**
 *  protect normal file to nxl file
 *
 *  @param filePath    normal file full path.
 *  @param nxlFilePath nxl file path which to be saved to.
 *  @param nxlFiletags set to nxl file
 *
 *  @return true means generate nxl file success.
 */


//only used for dropbox.
+ (NSDictionary*)parseURLParams:(NSString *)query;

+ (NSString*) randomStringwithLength:(NSUInteger)length;

+ (NSString*) getConvertFileTempPath;

+ (void)cleanTempFile;

+ (NSString*) md5Data: (NSData*) data;

+ (NSString *) getRmServer;

+ (void) saveRmserver:(NSString *)rmserver;

+ (void)saveLoggerURL:(NSString *)loggerURL;
+ (NSString *)getLoggerURL;
+ (void)saveLoggerToken:(NSString *)loggerToken;
+ (NSString *)loadLoggerToken;

+ (BOOL) isFirstTimeLaunching;

+ (void) saveFirstTimeLaunchSymbol;

+ (void) unUnarchiverCacheDirectoryData:(NXFileBase *) rootFolder;

+ (NXFileBase*)fetchFileInfofromThirdParty:(NSURL*)fileURL;
+ (NXFileBase*)fetchFileInfofromUniversalLinksWithTransactionCode:(NSString *)transactionCode transactionId:(NSString *)transactionId;
+ (NSString *)createNewNxlTempFile:(NSString *)filename; // Get the filename-data-time.nxl format file path
+ (NSString *) getTempNXLFilePath:(NSString *) fileName;
+ (NSString *)getNXLFileOriginalName:(NSString *)fileName;
+ (NSString *)getMyVaultFilePathBy3rdOpenInFileLocalPath:(NSString *)localPath;

/**
 *  create service root folder key which is used in root folders directory
 *   to support multi-service get root folderview and add to view(support auto layout)
 *
 */

+(NSString *) getServiceFolderKeyForFolderDirectory:(NXBoundService *) boundService;

/**
 *  get NXError from nxrmc error code, which have localized description to let user
 *  make sence
 *
 */
+(NSError *) getNXErrorFromErrorCode:(NXRMC_ERROR_CODE) NXErrorCode error:(NSError *) error;

+ (NSString *)getImagebyExtension:(NSString *)extension;

+ (void)setLocalFileLastModifiedDate:(NSString *)localFilePath date:(NSDate *)date;

+ (NSDate *)getLocalFileLastModifiedDate:(NSString *)localFilePath;

+ (UIUserInterfaceIdiom) getUserInterfaceIdiom;

/**
 *  get Log index send to RMS server
 *
 */

+ (NSUInteger) getLogIndex;


/**
 *  RMS <-> RMC Repo sync
 *
 */
+ (NSString *) rmcToRMSRepoType:(NSNumber *) rmcRepoType;
+ (NSNumber *) rmsToRMCRepoType:(NSString *) rmsRepoType;

+ (void)clearUpSDK:(ServiceType) serviceType appendData:(id) appendData;
+ (void)changeRMCServiceTokenToRMSServiceToken:(NXRMCRepoItem *)serviceItem;
+ (void)buildEnviromentForRepoSDK:(NXRepositoryModel *)repoItem;
+ (BOOL)cleanUpBoundRepoData:(NXRepositoryModel *)boundService;
+ (void)destoryEnviromentForRepoSDK:(NXRepositoryModel *)repoItem;


+ (NSString *) rmsToRMCDisplayName:(NSString *) rmsRepoType;

+ (NXSyncDateModel *)userSyncDateModel;
+ (void)storeSyncDateModel:(NXSyncDateModel *)model;
+ (NSString *)displaySyncDateString;

+ (NSString *) ISO8601Format:(NSDate *)date;
+ (NSString *)decodedURLString:(NSString *)encodedString;

+ (NSNumber *)converttoNumber:(NSString *)string;

+ (BOOL)ispdfFileContain3DModelFormat:(NSString *)pdfFilePath;

+ (BOOL)isStewardUser:(NSString *)userId forFile:(NXFileBase *)nxlFile;
+ (NXExternalNXLFileSourceType)getExternalNXLFileTypeByFileOwnerID:(NSString *)fileOwnerID;
/**
 *
 *  zip and unzip
 *
 */
+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray *)paths;
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;

+ (NSString *)sessionTimeOutString;
+ (NSString *)timeAgoFromDate:(NSDate *)date;
+ (NSString *)timeAgoShortFromDate:(NSDate *)date;

+ (NSString *)removeIllegalLettersForPath:(NSString *)path;

+ (BOOL)fileItemSupportDownloadProgress:(NXFileBase *)fileItem;
+ (BOOL)fileItemSupportUploadloadProgress:(NXFileBase *)fileItem;

+ (NSString *)timeStringFrom1970TimeInterval:(NSTimeInterval)interval orDate:(NSDate *)date;
+ (BOOL)JudgeTheillegalCharacter:(NSString *)content withRegexExpression:(NSString*)str;

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr;

/**
 *  file unique key used in cache or some where
 *
 *  @return NSMutableDictionary parameters
 */
+ (NSString *)fileKeyForFile:(NXFileBase *)file;

+ (void)addCustomCookies:(NSURL *)url withCooies:(NSArray *)cookies;
+ (NXRemoteViewRenderType)isRemoteViewUsingCanvasByFile:(NXFileBase *)fileBase;
+(UIImage *)screenShot:(CGRect)rect;

+(BOOL)checkNXLFileisValid:(NXLFileValidateDateModel *)dateModel;
+ (BOOL)checkIsLegalFileValidityDate:(NXLFileValidateDateModel *)dateModel;
+ (BOOL)checkNXLFileisExpired:(NXLFileValidateDateModel *)dateModel;

/**
 *  save/get user login url
 */
+ (void)setUserLoginStatus:(NXUserLoginStatusType)type;
+ (BOOL)isCompanyAccountLogin;
+ (NSString *)getDefaultPresonalLoginURL;
+ (NSArray *)getUserRememberedAndManagedLoginUrlList;
+ (NSString *)getUserCurrentSelectedLoginURL;
+ (void)updateUserLoginUrl:(NSString *)oldLoginUrl newLoginUrl:(NSString *)newLoginUrl isMakeDefault:(BOOL)makeDefault;
+ (void)removeUserRememberedLoginUrl:(NSString *)loginUrl;
+ (void)setUserRememberedAndSelectedLoginUrl:(NSString *)selectedLoginUrl;

+ (BOOL)checkStringContainMultiByte:(NSString *)checkedString;
+ (NSString *)MIMETypeFileName:(NSString *)path
               defaultMIMEType:(NSString *)defaultType;
+(UIImage *)getProviderIconByRepoProviderClass:(NSString *)providerClass;
+(UIImage *)getRepoIconByRepoType:(NSInteger)repoType;
+ (BOOL)isSkyDRMForcurrentServer:(NSString *)serverAddress;
+ (BOOL)isSupportWorkspace;
+ (NSString *)getCurretnHostName;
+ (NSString *)getCurrentIpAdress;
@end
