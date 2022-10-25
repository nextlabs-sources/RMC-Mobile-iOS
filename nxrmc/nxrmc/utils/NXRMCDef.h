//
//  Header.h
//  nxrmc
//
//  Created by Kevin on 15/5/12.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#ifndef nxrmc_def_h
#define nxrmc_def_h

#import "HexColor.h"

#if NXRMC_ENTERPRISE_FLAG == 1
#define buildFromSkyDRMEnterpriseTarget 1
#else
#define buildFromSkyDRMEnterpriseTarget 0
#endif

#define APPLICATION_NAME                @"RMC iOS"
#define APPLICATION_PUBLISHER           @"NextLabs"
#define APPLICATION_PATH                @"RMC iOS"

#define  CACHEOPENEDIN                  @"openedIn"
#define  CACHEMYVAULT                   @"myVault"
#define  CACHEMYVAULTROOTFOLDER         @"myVaultRootFolder"
#define  CACHEMYVAULTDOWNLOAD           @"myVaultDownload"
#define  CACHEDROPBOX                   @"dropbox_"
#define  CACHESHAREPOINT                @"sharepoint_"
#define  CACHESHAREPOINTONLINE          @"sharepointonline_"
#define  CACHEONEDRIVE                  @"onedrive_"
#define  CACHEGOOGLEDRIVE               @"googledrive_"
#define  CACHEICLOUDDRIVE               @"iCloudDrive"
#define  CACHESKYDRMBOX                 @"skydrmbox_"
#define  CACHEFILESYSFOLDER             @"FileSystemTreeCache"
#define  CACHEDIRECTORY                 @"directory.cache"
#define  CACHEROOTDIR                   @"root"

#define  RMS_REST_DEVICE_TYPE_ID        @"3"
#define  RMC_DEFAULT_SERVICE_ID_UNSET   @"SERVICE_ID_UNSET"

#define  KEYCHAIN_PROFILES_SERVICE      @"com.nextlabs.nxrmc.service.profiles"
#define  KEYCHAIN_DEVICE_ID             @"Nextlabs.iOS.DeviceID"
#define  KEYCHAIN_PROFILES              @"com.nextlabs.nxrmc.profiles"

#define  NXLFILEEXTENSION               @".nxl"
#define NXL                             @"nxl"

// table name
#define TABLE_CACHEFILE                 @"CacheFile"
#define TABLE_BOUNDSERVICE              @"BoundService"


#define SYNCDATA_INTERVAL               5  // second
#define NXLFILE_FIXED_TIMESTAMP_LENGTH  20


#define SKYDRM_HELP_URL                 @"https://help.skydrm.com/docs/ios/help/1.0/en-us/index.htm"
#define SKYDRM_START_URL                @"https://help.skydrm.com/docs/ios/start/1.0/en-us/index.htm"
// REST API

// NXL POLICY HEAD LENGTH
#define NXL_FILE_HEAD_LENGTH            0x4000

// test for debug
//#define DEFAULT_SKYDRM                 @"https://rmtest.nextlabs.solutions"
//#define DEFAULT_TENANT                  @"skydrm.com"

// test for release
//#define DEFAULT_SKYDRM                  @"https://testdrm.com"
//#define DEFAULT_TENANT                  @"testdrm.com"

// really env
#define DEFAULT_SKYDRM                 @"https://www.skydrm.com"
#define DEFAULT_TENANT                  @"skydrm.com"


// test for CDC Center Policy
//#define DEFAULT_SKYDRM                  @"https://rms-centos7308.qapf1.qalab01.nextlabs.com:8443"
//#define DEFAULT_TENANT                  @"3233042f-0308-479c-8484-a83d28053065"

#define RESTAPITAIL                     @"/service"
#define RESTAPIFLAGHEAD                 @"REST-FLAG"
#define RESTCLIENT_ID_HEAD              @"clientId"

#define SPECIFIC_TENANT                @"specific_tenant"


#define RESTMEMBERSHIP                  @"rs/membership"
#define RESTTOKEN                       @"rs/token"  //both encryption and decryptioin

#define RESTSUPERBASE                   @"RESTSUPERBASE"


// Auth repo error
#define AUTH_ERROR_ALREADY_AUTHED               [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_SERVICE_ALREADY_AUTHED userInfo:nil]
#define AUTH_ERROR_AUTH_FAILED                  [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_AUTHFAILED userInfo:nil]
#define AUTH_ERROR_ACCOUNT_DIFF_FROM_RMS        [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_AUTH_ACCOUNT_NOT_SAME userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_AUTH_REPOSITORY_NOT_SAME_WITH_RMS", nil)}]
#define AUTH_ERROR_NO_NETWORK                   [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:nil]
#define AUTH_ERROR_AUTH_CANCELED                [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil]

// Remove repo error
#define REMOVE_REPO_ERROR                       [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_REMOVE_REPOSITORY_ERROR userInfo:nil]

// helper define
#define DELEGATE_HAS_METHOD(delegate, method) delegate && [delegate respondsToSelector:method]

//weak-strong.
#define WeakObj(obj) __weak typeof(obj) obj##Weak = obj;
#define StrongObj(obj) __strong typeof(obj) obj = obj##Weak;

//NSLog define
#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"Debug log:%s" fmt), __FUNCTION__, ##__VA_ARGS__);
#else
    #define DLog(...);
#endif

//
#define OFFLINE_ON      YES //YES means offline fuction open. NO means offline function close.
#define FAVORITE_ON     YES //YES means offline fuction open. NO means offline function close.

typedef NS_ENUM(NSInteger, ActivityOperation)
{
    kProtectOperation = 1,
    kShareOperation = 2,
    kRemoveUserOperation = 3,
    kViewOperation = 4,
    kPrintOpeartion = 5,
    kDownloadOperation = 6,
    kEditSaveOperation = 7,
    kRevokeOperation = 8,
    kDecryptOperation = 9,
    kCopyContentOpeartion = 10,
    kCaptureScreenOpeartion = 11,
    kClassifyOperation = 12,
    kReshareOperation = 13,
    kDeleteOperation = 14,
};

typedef enum{
    kAccountRMS = 0
}LogInAccountType;

typedef NS_ENUM(NSInteger, ServiceType) {
    kServiceUnset = -1,
    kServiceDropbox = 0,
    kServiceGoogleDrive = 1,
    kServiceOneDrive = 2,
    kServiceBOX = 3,
    kServiceSkyDrmBox = 4,
    kServiceSharepointOnline = 5,
    kServiceSharepoint = 6,
    kServiceICloudDrive = 7,
    kServiceOneDriveApplication = 8,
    KServiceSharepointOnlineApplication = 9
};

typedef NS_ENUM(NSInteger, NXManagedObjectContextType) {
    NXManagedObjectContextTypeLocal = -1,
    NXManagedObjectContextTypeFavoriteFileItem = 1,
    NXManagedObjectContextTypeMyVaultFileItem,
    NXManagedObjectContextTypeRepoFileItem,
    NXManagedObjectContextTypeCacheFile,
    NXManagedObjectContextTypeBackground
};

typedef NS_ENUM(NSInteger, NXRemoteViewRenderType) {
    NXRemoteViewRenderTypeUnknow = 0,
    NXRemoteViewRenderTypeCanvas = 1,
    NXRemoteViewRenderTypeImage = 2
};

typedef NS_ENUM(NSInteger, NXUserLoginStatusType) {
    NXUserLoginStatusTypePersonal = 0,
    NXUserLoginStatusTypeCompany = 1,
};

typedef NS_ENUM(NSInteger, NXFileState) {
    NXFileStateNormal = 1,
    NXFileStateConvertingOffline = 2,
    NXFileStateOfflineFailed = 3,
    NXFileStateOfflined
};

typedef NS_ENUM(NSInteger, NXOfflineFileOperateType) {
    NXOfflineFileOperateTypeView = 1,
    NXOfflineFileOperateTypePrint = 2
};

typedef NS_ENUM(NSInteger, NXExternalNXLFileSourceType) {
    NXExternalNXLFileSourceTypeProject = 1,
    NXExternalNXLFileSourceTypeSystemDefaultProject = 2,
    NXExternalNXLFileSourceTypeMyVault = 3,
    NXExternalNXLFileSourceTypeOther = 4
};

typedef NS_OPTIONS(long, NXLUSERROLE) {
    NXL_USER_ROLE_NORMAL      = 0x00000001,
    NXL_USER_ROLE_TENANT_ADMIN     = 0x00000002,
    NXL_USER_ROLE_PROJECT_ADMIN    = 0x00000004,
};

typedef NS_ENUM(NSInteger, NXAddNXLFileUploadType) {
    NXAddNXLFileUploadTypeToProject = 1,
    NXAddNXLFileUploadTypeToWorkspace = 2,
    NXAddNXLFileUploadTypeToSharedWorkspace = 3
};

// RMS Repository Type
#define RMS_REPO_TYPE_SHAREPOINT        @"SHAREPOINT_ONPREMISE"
#define RMS_REPO_TYPE_SHAREPOINTONLINE  @"SHAREPOINT_ONLINE"
#define RMS_REPO_TYPE_DROPBOX           @"DROPBOX"
#define RMS_REPO_TYPE_GOOGLEDRIVE       @"GOOGLE_DRIVE"
#define RMS_REPO_TYPE_ONEDRIVE          @"ONE_DRIVE"
#define RMS_REPO_TYPE_SKYDRMBOX         @"MY_DRIVE"
#define RMS_REPO_TYPE_BOX               @"BOX"
#define RMS_REPO_TYPE_ONE_DRIVE_APPLICATION  @"ONE_DRIVE_APPLICATION"
#define RMS_REPO_TYPE_SHAREPOINTONLINE_APPLICATION @"SHAREPOINTONLINE_APPLICATION"
// NXErrorDomain
#define NXHTTPSTATUSERROR                   @"NXHttpStatusError"
#define NXHTTPAUTOREDIRECTERROR             @"NXHttpAutoRedirectError"
#define NX_ERROR_SERVICEDOMAIN              @"NXRMCServicesErrorDomain"
#define NX_ERROR_NETWORK_DOMAIN             @"NXNetworkErrorDomain"
#define NX_ERROR_REST_DOMAIN                @"NXRESTErrorDomain"
#define NX_ERROR_NXLFILE_DOMAIN             @"NXNXFILEDOMAIN"
#define NX_ERROR_RENDER_FILE                @"NXFileRenderDomain"
#define NX_ERROR_REPO_FILE_SYSTEM_DOMAIN    @"NXRepoFileSystemDomain"
#define NX_ERROR_MY_VAULT_DOMAIN            @"NXMyVaultDomain"
#define NX_ERROR_WORKSPACE_DOMAIN           @"NXWorkSpaceDomin"
#define NX_ERROR_NXOPERATION_DOMAIN         @"NXOperationDomain"
#define NX_ERROR_WEBFILEMANAGER_DOMAIN      @"NXWebFileManagerDomain"
#define NX_ERROR_PROJECT_DOMAIN             @"NXProjectDomain"
#define NX_ERROR_REPO_STORAGE_DOMAIN        @"NXRepoStorageDomain"
#define NX_ERROR_SHAREDFILE_DOMAIN          @"NXSharedFileDomain"
#define NX_ERROR_USER_PERFERENCE_DOMAIN     @"NXUserPerferenceDomain"
#define NX_ERROR_NXOFFLINEFILE_DOMAIN       @"NXOfflineFileDomain"
#define NX_ERROR_FILE_SYSTEM_DOMAIN         @"NXFileSystemDomain"

// NXError code
typedef NS_ENUM(NSInteger, NXRMC_ERROR_CODE) {
    // NX_ERROR_RENDER_FILE
    NXRMC_ERROR_CODE_RENDER_FILE_NOT_SUPPORT = 900,
    NXRMC_ERROR_CODE_RENDER_FAILED = 901,
    
    NXRMC_ERROR_CODE_NOSUCHFILE = 1000,
    NXRMC_ERROR_CODE_AUTHFAILED,
    NXRMC_ERROR_CODE_CANCEL,
    NXRMC_ERROR_CODE_CONVERTFILEFAILED,
    NXRMC_ERROR_CODE_CONVERTFILEFAILED_NOSUPPORTED,
    NXRMC_ERROR_CODE_CONVERTFILE_CHECKSUM_NOTMATCHED,
    NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED,
    NXRMC_ERROR_NO_NETWORK,
    NXRMC_ERROR_BAD_REQUEST,
    NXRMC_ERROR_GET_USER_ACCOUNT_INFO_FAILED,
    NXRMC_ERROR_CODE_GET_NO_KEY_BLOB,
    NXRMC_ERROR_CODE_NOT_NXL_FILE,
    NXRMC_ERROR_CODE_TRANS_BYTES_FAILED,
    
    //nxl file related error, such as encrypt/decrypt
    NXRMC_ERROR_CODE_NXFILE_ISNXL = 2000,
    NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY,
    NXRMC_ERROR_CODE_NXFILE_ISNOTNXL,
    NXRMC_ERROR_CODE_NXFILE_NO_TOKEN, // can not get token from keychain, memory cache.
    NXRMC_ERROR_CODE_NXFILE_ENCRYPT,
    NXRMC_ERROR_CODE_NXFILE_DECRYPT,
    NXRMC_ERROR_CODE_NXFILE_GETFILETYPE,
    NXRMC_ERROR_CODE_NXFILE_ADDPOLICY,
    NXRMC_ERROR_CODE_NXFILE_GETPOLICY,
    NXRMC_ERROR_CODE_NXFILE_UNKNOWN,
    NXRMC_ERROR_CODE_NXFILE_TOKENINFO,
    NXRMC_ERROR_CODE_NXFILE_OWNER,
    NXRMC_ERROR_CODE_NXFILE_SHARE,
    NXRMC_ERROR_CODE_NXFILE_UPDATE_RECIPIENTS,
    NXRMC_ERROR_CODE_NXFILE_REVOKE,
    NXRMC_ERROR_CODE_NXFILE_INVALID,
    NXRMC_ERROR_CODE_NXFILE_GET_RIGHT,
    
    
    //repo file system related error
    NXRMC_ERROR_CODE_NO_SUCH_REPO = 3000,
    NXRMC_ERROR_CODE_GET_ROOT_FOLDERS_CHILDREN_FAILED = 3001,
    NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR = 3002,
    NXRMC_ERROR_CODE_DELETE_FILE_ERROR = 3003,
    NXRMC_ERROR_CODE_ADD_FOLDER_ERROR = 3004,
    NXRMC_ERROR_CODE_DOWNLOAD_ERROR = 3005,
    NXRMC_ERROR_CODE_UPLOAD_ERROR = 3006,
    NXRMC_ERROR_CODE_GET_USER_INFO_ERROR = 3007,
    NXRMC_ERROR_CODE_GET_FILE_META_ERROR = 3008,
    NXRMC_ERROR_CODE_UPLOAD_TO_MAX = 3009,
    
    // my vault file system related error
    NXRMC_ERROR_CODE_MY_VAULT_OPT_CANCELED = 4000,
    NXRMC_ERROR_CODE_MY_VAULT_DOWNLOAD_FILE_FAILED,
    NXRMC_ERROR_CODE_MY_VAULT_UPLOAD_FILE_EXISTED,
    NXRMC_ERROR_CODE_WORKSPACE_OPT_CANCELED,
    // rms rest error
    NXRMC_ERROR_CODE_REST_UPLOAD_FAILED = 5000,
    NXRMC_ERROR_CODE_REST_MEMBERSHIP_FAILED,
    NXRMC_ERROR_CODE_REST_MEMBERSHIP_CERTIFICATES_NOTENOUGH,
    NXRMC_ERROR_CODE_SERVICE_ALREADY_AUTHED,
    NXRMC_ERROR_CODE_AUTH_ACCOUNT_NOT_SAME,
    NXRMC_ERROR_CODE_RENDER_FILE_FAILED,
    NXRMC_ERROR_CODE_RMS_REST_FAILED,
    NXRMC_ERROR_CODE_RMS_REST_ADD_REPO_ALREADY_EXIST,
    NXRMC_ERROR_CODE_RMS_REST_ADD_ALREADY_HAVE_THIS_ACCOUNT,
    NXRMC_ERROR_CODE_RMS_REST_ADD_REPO_OTHER_ERRORS,
    NXRMC_ERROR_CODE_REMOVE_REPOSITORY_ERROR,
    NXRMC_ERROR_CODE_UPDATE_REPOSITORY_INFO_ERROR,
    NXRMC_ERROR_CODE_REPOSITORY_NOT_EXIST,
    NXRMC_ERROR_CODE_GET_MYDRIVE_USAGE_INFO_ERROR,
    NXRMC_ERROR_CODE_PROJECT_KICKED,
    NXRMC_ERROR_CODE_EMPTY_CONTENT,
    NXRMC_ERROR_CODE_RMS_SHAREDFILE_REVOKED_OR_DELETED,
    NXRMC_ERROR_CODE_GET_REPO_ACCESS_TOKEN_FAILED,
    
    // NXRepoFileSystemDomain error
    NXRMC_ERROR_CODE_REPO_FILE_SYS_MANAGER_CANCELLED = 6000,
    NXRMC_ERROR_CODE_REPO_FILE_SYS_MANAGER_GET_FILE_ERROR,
    NXRMC_ERROR_CODE_VAULT_FILE_SYS_MANAGER_VAULT_EXCEEDED_ERROR,
    NXRMC_ERROR_CODE_REPO_STORAGE_MANAGER_EXCEEDED_ERROR,
    NXRMC_ERROR_CODE_ADD_REPO_ERROR,
    // NX_ERROR_NXOPERATION_DOMAIN error
    NXRMC_ERROR_CODE_NXOPERATION_CANCELLED = 7000,
    
    // NX_ERROR_WEBFILEMANAGER_DOMAIN
    NXRMC_ERROR_CODE_NXWEBFILEMANAGER_GET_METADATA_FILE_TYPE_ERROR = 8000,
    NXRMC_ERROR_CODE_NXWEBFILEMANAGER_WRONG_PARAMETER = 8001,
    NXRMC_ERROR_CODE_NXWEBFILEMANAGER_CACHE_FILE_FAILED = 8002,
    
    
    // PROJECT ERROR
    NXRMC_ERROR_CODE_PROJECT_NOT_EXISTED = 9000,
    NXRMC_ERROR_CODE_PROJECT_INVITATION_MISMATCH = 9001,
    NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_FAILED = 9002,
    NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_EXPIRED = 9003,
    NXRMC_ERROR_DECLINE_PROJECT_INVITATION_FAILED = 9004,
    NXRMC_ERROR_INVALIDE_PROJECT_NAME = 9005,
    
    // User perference Error
    NXRMC_ERROR_CODE_UPDATE_USER_PERFERENCE_FAILED = 10000,
    NXRMC_ERROR_CODE_GET_USER_PERFERENCE_FAILED = 10001,
    
    // OFFLINE  ERROR
    NXRMC_ERROR_CODE_OFFLINE_FILE_EXPIRED_ERROR = 11000,
    NXRMC_ERROR_CODE_OFFLINE_FILE_FORMAT_NOT_SUPPORT_ERROR = 11001,
    
    // FILE SYSTEM
    NXRMC_ERROR_CODE_FILE_SYSTEM_QUERY_LASTMODIFIED_DATE_ERROR = 12000,
    
    // WorkSpace
    NXRMC_ERROR_CODE_WORK_SPACE_DOWNLOAD_FAILED = 13000,
};

typedef void(^ClickActionBlock)(id sender);

// http error code
#define HTTP_ERROR_CODE_ACCESS_FORBIDDEN  403
#define SHARE_POINT_HTTP_ERROR_CODE_NO_SUCH_FILE  500

// define 3d file format,like hsf
#define FILEEXTENSION_JT        @"jt"
#define FILEEXTENSION_PRT       @"prt"
#define FILEEXTENSION_HSF       @"hsf"
#define FILEEXTENSION_VDS       @"vds"
#define FILEEXTENSION_RH        @"rh"
#define FILEEXTENSION_PDF       @"pdf"
#define FILEEXTENSION_VSD       @"vsd"
#define FILEEXTENSION_STL       @"stl"

//file type supported to open
#define FILESUPPORTOPEN         @".key.numbers.pages.rtf.jt.prt.hsf.vds.pdf.jpg.jpeg.png.bmp.gif.txt.h.c.js.htm.html.mp4.mp3.xlsx.xls.ppt.pptx.doc.docx.log.tiff.tif.mov.vb.m.swift.py.md.dotx.docm.potm.xltm.xlsm.xltx.json.properties.stl.obj.prc.u3d.igs.iges.stp.step.ifc.ifczip.x_b.x_t.x_mt.xmt_txt.HEIC.ptx.pts.xyz.potx.pot.pps.ppsm.ppsx."
#define FILE_HOOPS_SUPPORT @".hsf.stl.obj.prc.u3d.jt.igs.iges.stp.step.ifc.ifczip.x_b.x_t.x_mt.xmt_txt.ptx.pts.xyz."
#define FILEREMOTEVIEWSUPPORTOPEN  @".vsd.vsdx.dxf.xml.java.cpp.sql.csv.xlsb.xlt.err.model.dwg."

#define REMOTEVIEWPRINTCANVASTYPEARRAY [NSMutableArray arrayWithObjects:@"vds", nil]
#define REMOTEVIEWPRINTIMAGETYPEARRAY  [NSMutableArray arrayWithObjects:@"vsd",@"dxf",@"vsdx",@"dwg",nil]

#define GOOGLEDRIVEDOCUMENTTYPEARRAY  [NSMutableArray arrayWithObjects:@"application/vnd.google-apps.drawing",@"application/vnd.google-apps.spreadsheet",@"application/vnd.google-apps.document",@"application/vnd.google-apps.presentation",nil]

// define SkyDRM APP LOGIN URL KEY
#define SKYDRM_LOGINURL_KEY                     @"skyDRM_LoginURL_Key"
#define SKYDRM_USER_INPUT_SERVER_ADDRESS_KEY    @"skyDRM_User_Input_Server_Address_Key"
#define SKYDRM_AFTER_CHANGE_LOGIONURL_KEY       @"skyDRM_After_Change_LoginURL_Key"
#define SKYDRM_USER_LOGIN_STATUS_KEY            @"skyDRM_User_Login_Status_Key"
#define SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST   @"skyDRM_User_Remembered_LoginURL_List"

// define DropBox client ID
#define DROPBOXCLIENTID                 @"3y95f3gtd9hii68"
#define DROPBOXCLIENTSECRET             @"h9e95mu086nokfg"



// define One Drive client ID
#define ONEDRIVECLIENTID                @"8ea12ff6-4f3f-4f4d-a727-d02e2be5e15e"
// OneDrive local plist file key
#define LIVE_AUTH_CLIENTID              @"client_id"
#define LIVE_AUTH_REFRESH_TOKEN         @"refresh_token"

//define GoogleDrive client ID
#define GOOGLEDRIVECLIENTID             @"1021466473229-gfuljuu4spgkvs4vnk6hl48ah1rcpfre.apps.googleusercontent.com"
#define GOOGLEDRIVE_REDIRECT_URI        @"com.googleusercontent.apps.1021466473229-gfuljuu4spgkvs4vnk6hl48ah1rcpfre:/oauthredirect"
#define GOOGLEDRIVEKEYCHAINITEMLENGTH   20   //random string length

// notification RMS server address changed
#define NOTIFICATION_RMSSERVER_CHANGED  @"RMS_Server_Changed"
#define NOTIFICATION_NXRMC_LOG_OUT @"NXRMC_USER_LOG_OUT"

// notification client login success
#define NOTIFICATION_SKYDRM_LOGIN_SUCCESS @"SKYDRM_LOGIN_SUCCESS"

// notifcation User pressed sort button
#define NOTIFICATION_USER_PRESSED_SORT_BTN @"User_Pressed_Sort_Btn"

// notification User open new file
#define NOTIFICATION_USER_OPEN_FILE @"USER_OPEN_FILE_NOTIFICATION"

// notification Fav file list changed
#define NOTIFICATION_FAV_FILE_LIST_CHANGED @"NOTIFICATION_FAV_FILE_LIST_CHANGED"

#define NOTIFICATION_DROP_BOX_CANCEL @"Drop_Box_Cancel"

// project notify
#define NOTIFICATION_PROJECT_MEMBER_UPDATED @"NOTIFICATION_PROJECT_MEMBER_UPDATED"
#define NOTIFICATION_PROJECT_CURRENTPROJECT_UPDATED @"NOTIFICATION_PROJECT_CURRENTPROJECT_UPDATED"
#define NOTIFICATION_PROJECT_LIST_UPDATED @"NOTIFICATION_PROJECT_LIST_UPDATED"
#define NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE @"NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE"
#define NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE @"NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE"
#define NOTIFICATION_PROJECT_PENDING_INVITATION_CHANGED @"NOTIFICATION_PROJECT_PENDING_INVITATION_CHANGED"

// remoteview notify
#define NOTIFICATION_DETAILVC_PRINT_ENABLED @"NOTIFICATION_DETAILVC_PRINT_ENABLED"

// photo picker notify
#define NOTIFICATION_PHOTO_SELECTED @"NOTIFICATION_PHOTO_SELECTED"


// notification Response Add
#define NOTIFICATION_REPO_ADDED @"notification_repo_added"
#define NOTIFICATION_REPO_ADDED_ERROR_KEY @"NOTIFICATION_REPO_ADDED_ERROR_KEY"
#define NOTIFICATION_REPO_AUTH_FINISHED @"NOTIFICATION_REPO_AUTH_FINISHED"
#define NOTIFICATION_WORKSPACE_STATE_UPDATE @"NOTIFICATION_WORKSPACE_STATE_UPDATE"

#define RMS_ADD_REPO_ERROR_NET_ERROR @"RMS_ADD_REPO_ERROR_NET_ERROR"
#define RMS_ADD_REPO_DUPLICATE_NAME @"RMS_ADD_REPO_DUPLICATE_NAME"
#define RMS_ADD_REPO_RMS_OTHER_ERROR @"RMS_ADD_REPO_RMS_OTHER_ERROR"
#define RMS_ADD_REPO_ALREADY_EXIST @"RMS_ADD_REPO_ALREADY_EXIST"

// notification Response Update
#define NOTIFICATION_REPO_UPDATED @"notification_repo_updated"
#define NOTIFICATION_REPO_UPDATED_ERROR_KEY @"NOTIFICATION_REPO_UPDATED_ERROR_KEY"

#define RMS_UPDATE_REPO_ERROR @"RMS_UPDATE_REPO_ERROR"

// notification Response Deleted
#define NOTIFICATION_REPO_DELETED @"notification_repo_deleted"
#define NOTIFICATION_REPO_DELETE_ERROR_KEY @"NOTIFICATION_REPO_DELETE_ERROR_KEY"
#define RMS_DELETE_REPO_FAILED @"RMS_DELETE_REPO_FAILED"

// notification Response Repository changed
#define NOTIFICATION_REPO_CHANGED @"notification_repo_changed"
// notification Detail View Change
#define NOTIFICATION_DETAILVIEW_CHANGED @"notification_detailView_changed"

// notification Repo update
#define NOTIFICATION_REPO_ALIAS_UPDATED @"notification_repo_alias_updated"

// notification user info update
#define NOTIFICATION_USER_INFO_UPDATED @"NOTIFICATION_USER_INFO_UPDATED"

// notification of photo selected
#define NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE @"NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE"

#define NOTIFICATION_FILE_CHOOSE_CHANGED @"NOTIFICATION_FILE_CHOOSE_CHANGED"

// notification of tableview should reload
#define NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE @"NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE"

// notification of master tabbar add button need hidden
#define NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN  @"NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN"
// notification of master tabbar add button need display
#define NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY  @"NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY"

// notification of project master tabbar add button need hidden
#define NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN  @"NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN"
// notification of project master tabbar add button need display
#define NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY  @"NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY"

//========The view's TAGs
#define SEARCH_COVER_VIEW_TAG 90001
#define SERVICETABLE_COVER_VIEW_TAG 90002
#define SERVICETABLE_COVER2_VIEW_TAG 90003
#define FILEDETAILINFO_VIEW_TAG 90004
#define NO_REPO_VIEW_TAG 90005
#define FILE_LIST_NAV_VIEW_TAG 90006
#define ALERT_VIEW_RENAME_FILE_TAG 90007
//===Home page TAGs
#define HOME_TOUCH_DISABLE_COVER_VIEW 90008
#define HOME_PAGE_FILE_DETAIL_VIEW_TAG 90009
#define HOME_PAGE_ADD_REPO_BTN_TAG 90010
#define HOME_PAGE_NX_ICON_TAG 90011
#define HOME_PAGE_NO_SEL_REPO_LAB_TAG 90012
//===Account page TAGs
#define ACCOUNT_PAGE_COVER_VIEW_TAG 70001
#define ACCOUNT_PAGGE_DATA_PICKER_TAG 70002
//===File Content TAGs
#define FILE_CONTENT_NO_CONTENT_VIEW_TAG 80001
#define AUTO_DISMISS_LABLE_TAG 80002

//=====iPad
//===File List Page TAGs
#define FILE_LIST_NO_REPO_BTN_TAG 60001
#define FILE_LIST_SERVICE_TABLE_VIEW_TAG 60002
#define FILE_LIST_COVER_VIEW_TAG 60003


// The side menu section tag
#define SERVICES_SECTION    0
#define PAGES_VIEWS_SECTION 1
#define SlideMenuMyOffline 0
#define SlideMenuMyFavorite 1
#define SlideMenuMyAccount 2
#define SlideMenuHelp 3

// The user guider
#define UserGuiderCachedName @"userGuider.archive"

// The REST Request NX_UUID
#define NXREST_UUID(boundService)   [NSString stringWithFormat:@"%@-%@", boundService.service_type, boundService.service_account_id]

// The extension of REST API cache file
#define NXREST_CACHE_EXTENSION @".nxrest"

// The keyword for sync repo date in NSUserDefaults
#define NXSYNC_REPO_DATE_USERDEFAULTS_KEY @"SYNC_REPO_DATE"

// The Sperate string for service token used in sync repo
#define NXSYNC_REPO_SPERATE_KEY @"NEXTLABS_SPERATE_KEY"

// The RMS config NSUserProfile Key
#define NXRMS_ADDRESS_KEY @"NXRMS_ADDRESS_KEY"
#define NXRMS_SKY_DRM_KEY @"NXRMS_SKY_DRM_KEY"
#define NXRMS_TENANT_KEY @"NXRMS_TENANT_KEY"

// RMS API Error Code
#define NXRMS_ERROR_CODE_SUCCESS 200
#define NXRMS_ERROR_CODE_SUCCESS_NO_NEED_REFRESH 204
#define NXRMS_ERROR_CODE_EMPTY_CONTENT 204
#define NXRMS_ERROR_CODE_REPO_EXISTS 304
#define NXRMS_ERROR_CODE_409 409
#define NXRMS_ERROR_CODE_UNAUTHENTICATED 403
#define NXRMS_ERROR_CODE_NOT_FOUND 404
#define NXRMS_MYVAULT_UPLOAD_FILL_EXISTED 4001
#define NXRMS_MYDRIVE_UPLOAD_DRIVE_EXCEEDED 6001
#define NXRMS_MYVAULT_UPLOAD_VAULT_EXCEEDED 6002
#define NXRMS_PROJECT_INVITATION_MISMATCH 4003
#define NXRMS_PROJECT_CLASSIFICATION_NOT_MATCH_RIGHTS 5002
// detect device type
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH > 811.0)

// REPO PROPERTY KEY
#define AUTH_RESULT_ACCOUNT          @"accountName"
#define AUTH_RESULT_ACCOUNT_ID       @"accountId"
#define AUTH_RESULT_ACCOUNT_TOKEN    @"AUTH_RESULT_ACCOUNT_TOKEN"
#define AUTH_RESULT_REPO_TYPE        @"type"
#define AUTH_RESULT_USER_ID          @"AUTH_RESULT_USER_ID"
#define AUTH_RESULT_ALIAS            @"name"
#define AUTH_RESULT_REPO_ID          @"repoId"
#define AUTH_RESULT_STATUS_CODE      @"statusCode"
#define AUTH_RESULT_STATUS_MESSAGE   @"message"

//
#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

#endif

#define RMS_MAX_UPLOAD_SIZE 150 * 1024 *1024  // 150MB
// for center token
#define RMS_CENTER_TOKEN_SCHEME @"com.skydrm.rmc"

// sync timer interval
#define REPO_FILE_SYNC_INTERVAL 30
#define WORKSPACE_FILE_SYNC_INTERVAL 30
#define PROJECT_PENDING_INVITATION_SYNC_INTERVAL 300
#define PROJECT_LIST_SYNC_INTERVAL 300
#define PROJECT_MEMBER_SYNC_INTERVAL 180
#define PROJECT_PENDING_MEMBER_SYNC_INTERVAL 180
#define FAVORITE_FILES_SYNC_INTERVAL 30

// Offline file download suffix
#define OFFLINE_DOWNLOAD_SUFFIX @"OFFLINE_DOWNLOAD_SUFFIX"
