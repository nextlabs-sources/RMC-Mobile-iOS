//
//  NXCommonUtils.h
//  nxrmc
//
//  Created by Kevin on 15/5/12.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXLSDKDef.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"


#define NXDIVKEY @"NX_DIV_KEY" // use for connect service_type and sservice_account to gen rootFoler service dict key

@interface NXLCommonUtils : NSObject

+ (NSString *) getTempNXLFilePath:(NSString *) fileName;
+ (NSString *) getTempDecryptFilePath:(NSString *) srcPath clientProfile:(NXLProfile *) userProfile error:(NSError **) error;
+ (NSString *) getNXLTempFolderPath;
+ (void) cleanNXLTempFolder;





+ (UIView*) createWaitingView;
+ (UIView*) createWaitingView:(CGFloat)sidelength;
+ (UIView*) createWaitingViewWithCancel: (id) target selector: (SEL)selector inView:(UIView*)view;



+(void) updateRMSAddress:(NSString *) rmsAddress;
+(void) updateRMSTenant:(NSString *) tenant;
+(void) updateSkyDrm:(NSString *) skyDrmAddress;

/**
 *  create waitting view and add to view(support auto layout)
 *
 *  @param view the parent view that want to add waiting view
 *
 *  @return the waiting view
 */
+ (UIView*) createWaitingViewInView:(UIView*)view;
+ (void) removeWaitingViewInView:(UIView *) view;
+(BOOL) waitingViewExistInView:(UIView *)view;

+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
        OKActionTitle:(NSString *)okTitle
    cancelActionTitle:(NSString *)cancelTitle
       OKActionHandle:(void (^)(UIAlertAction *action))OKActionHandler
   cancelActionHandle:(void (^)(UIAlertAction *action))cancelActionHandler inViewController:(UIViewController *)controller
             position:(UIView *)sourceView;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (NSArray*) fetchData: (NSString*) table predicate: (NSPredicate*) pred;
+ (int) getIndex: (NSString*)table;
+ (void) updateIndex: (NSString*) table;


+ (void) deleteCachedFilesOnDisk;
+ (void) deleteFilesAtPath:(NSString *)directory;
+ (NSNumber *) calculateCachedFileSize;
+ (NSNumber *) calculateCachedFileSizeAtPath:(NSString *)folderPath;

+ (NSArray*) getStoredProfiles;
+ (void) storeProfile: (NXLProfile*) profile;
+ (void) deleteProfile:(NXLProfile*) profile;



+ (NSString*) getMiMeType:(NSString*)filepath;
+ (NSString*) getUTIForFile:(NSString*) filepath;
+ (NSString*) getExtension:(NSString*) fullpath error:(NSError **)error;

+ (NSString *) convertToCCTimeFormat:(NSDate *) date;


+ (float) iosVersion;
+ (BOOL) isiPad;
+ (NSString *) deviceID;
+ (NSNumber*) getPlatformId;

+ (void)showAlertViewInViewController:(UIViewController*)vc title:(NSString*)title message:(NSString*)message;



//get device screenbounds.
+ (CGRect) getScreenBounds;


//only used for dropbox.
+ (NSDictionary*)parseURLParams:(NSString *)query;

+ (NSString*) randomStringwithLength:(NSUInteger)length;



+ (NSString*) md5Data: (NSData*) data;

+ (NSString *) getRmServer;

+ (void) saveRmserver:(NSString *)rmserver;

+ (BOOL) isFirstTimeLaunching;

+ (void) saveFirstTimeLaunchSymbol;





/**
 *  get NXError from nxrmc error code, which have localized description to let user
 *  make sence
 *
 */
+(NSError *) getNXLErrorFromErrorCode:(NXLSDKErrorCode) NXLErrorCode error:(NSError *) error;

+ (NSString *)getImagebyExtension:(NSString *)extension;

+ (void)setLocalFileLastModifiedDate:(NSString *)localFilePath date:(NSDate *)date;

+ (NSDate *)getLocalFileLastModifiedDate:(NSString *)localFilePath;

+ (UIUserInterfaceIdiom) getUserInterfaceIdiom;

/**
 *  get Log index send to RMS server
 *
 */

+ (NSUInteger) getLogIndex;




+ (NSString *) ISO8601Format:(NSDate *)date;
+ (NSString *)decodedURLString:(NSString *)encodedString;

+ (NSNumber *)converttoNumber:(NSString *)string;

+ (BOOL)ispdfFileContain3DModelFormat:(NSString *)pdfFilePath;

+ (BOOL)isStewardUser:(NSString *)userId clientProfile:(NXLProfile *)profile;

@end
