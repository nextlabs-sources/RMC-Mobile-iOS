//
//  NXPhotoSelecter.m
//  xiblayout
//
//  Created by nextlabs on 10/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXPhotoSelector.h"

#import <MobileCoreServices/UTCoreTypes.h>

#import "NXPhotoTool.h"
#import "NXPhotoNavigationController.h"
#import "NXAlbumViewController.h"
#import "NXCommonUtils.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Cutting.h"
#import "MBProgressHUD.h"
#import "NXMBManager.h"
#define kFolderName  @"SelectedFiles"

typedef void (^selectBlock)(NSArray *selectedItems, BOOL authen);

@interface NXPhotoSelector()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, strong) selectBlock complete;
@property(nonatomic, strong) NSString *locationFolder;
@property(nonatomic, assign, readwrite) NXPhotoSelectorType selectType;
@property(nonatomic, weak) UIViewController *currentVC;
@end

@implementation NXPhotoSelector

- (instancetype)init {
    NSAssert(NO, @"Pls use initWithSelectedType:");
    return nil;
}

- (instancetype)initWithSelectedType:(NXPhotoSelectorType)selectType
{
    if (self = [super init]) {
        self.type = NXPhotoSelectRetunTypeFilePath;
        self.selectType = selectType;
        if (selectType == NXPhotoSelectorTypeSingleSelect) {
            [NXPhotoTool sharedInstance].workType = NXPhotoToolWorkTypeSingleSelected;
        }
        
        if (selectType == NXPhotoSelectorTypeMultiSelect) {
            [NXPhotoTool sharedInstance].workType = NXPhotoToolWorkTypeMultiSelected;
        }
    }
    return self;
}

- (void)dealloc {
    DLog();
}

#pragma mark public method

- (void)showPhotoPicker:(NXPhotoSelectType)type complete:(selectedblock)completion {
    self.complete = completion;
    self.currentVC = [self getTopVC];
    if (type == NXPhotoSelectTypePhotoLibrary || type == NXPhotoSelectTypePhotoLibraryPhotoOnly || type == NXPhotoSelectTypePhotoLibraryVideoOnly) {
        switch ([NXPhotoTool authorizationStatus]) {
            case PHAuthorizationStatusRestricted:
                break;
            case PHAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(nil, NO);
                }
                [self showDenyAlertView:NSLocalizedString(@"MSG_ALLOW_ACCESS_PHOTO", NULL)];
            }
                break;
            case PHAuthorizationStatusAuthorized:
            {
                [self showPhotoPickerView:type];
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                             [self showPhotoPickerView: type];
                        });
                    }
                }];
            }
            default:
                break;
        }
    }
    if (type == NXPhotoSelectTypeCamera || type == NXPhotoSelectTypeCameraPhotoOnly ||type == NXPhotoSelectTypeCameraVideoOnly) {
        switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
            {
                [self showDenyAlertView:NSLocalizedString(@"MSG_ALLOW_ACCESS_CAMERA", NULL)];
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                [self showCamaraView:type];
            }
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showCamaraView:type];
                        });
                        
                    } else {
                        
                    }
                }];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark private method

- (void)showPhotoPickerView:(NXPhotoSelectType)type {
    // only use custom photo picker
    NXAlbumViewControllerSelectedType albumType = NXAlbumViewControllerSelectedTypeSingleSelected;
    if (self.selectType == NXPhotoSelectorTypeSingleSelect) {
        albumType = NXAlbumViewControllerSelectedTypeSingleSelected;
    }else if(self.selectType == NXPhotoSelectorTypeMultiSelect){
        albumType = NXAlbumViewControllerSelectedTypeMultiSelected;
    }
    NXAlbumViewController *vc = [[NXAlbumViewController  alloc]initWithSelectedType:albumType];
    switch (type) {
        case NXPhotoSelectTypePhotoLibraryVideoOnly:
        case NXPhotoSelectTypePhotoLibrary:
        {
            vc.sourceType = NXAlbumSourceTypePhotoLibrary;
        }
            break;
        case NXPhotoSelectTypePhotoLibraryPhotoOnly:
        {
            vc.sourceType = NXAlbumSourceTypePhotos;
        }
            break;
        default:
            break;
    }
    NXPhotoNavigationController *nav = [[NXPhotoNavigationController alloc]initWithRootViewController:vc];
    nav.completionblock = ^(BOOL isCanceled){
        if (!isCanceled) {
            [self dealCompleteSelection];
        } else {
            [[NXPhotoTool sharedInstance] removeAllSelectedItems];
        }
    };
    [[self getTopVC] presentViewController:nav animated:YES completion:nil];
}

- (void)showCamaraView:(NXPhotoSelectType)type {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //available for camera
    } else {
        //can not using camera
        [NXCommonUtils showAlertViewInViewController:[self getTopVC] title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"Some Reason can not access camera", NULL)];
        return;
    }
    vc.videoQuality = UIImagePickerControllerQualityTypeIFrame960x540;
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    vc.allowsEditing = NO;
    vc.delegate = self;
    vc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    switch (type) {
        case NXPhotoSelectTypeCameraPhotoOnly:
        {
            vc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            vc.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
        }
            break;
        case NXPhotoSelectTypeCameraVideoOnly:
        {
            vc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            vc.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie,(NSString *)kUTTypeMovie, nil];
        }
            break;
        case NXPhotoSelectTypeCamera:
        {
            vc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        default:
            break;
    }
    [[self getTopVC] presentViewController:vc animated:YES completion:nil];
}

- (void)showDenyAlertView:(NSString *)message {
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    } cancelActionHandle:nil inViewController:[self getTopVC] position:nil];
}


#pragma mark

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString: @"public.image"]) {
        UIImage *image;
        if ([picker allowsEditing]) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        // correctly the orientation of image UIImagePickerController taked
        image = [image fixOrientation];
        
        
        if (self.type == NXPhotoSelectRetunTypeFilePath) {
            NSString *fileName = [[info objectForKey:UIImagePickerControllerReferenceURL] lastPathComponent];
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
            NSString *fileTempName = [[NSString alloc] initWithFormat:@"%@.JPG", dateStr];
            NSString *path = [[self getLocationFolder] stringByAppendingPathComponent:fileName ? fileName :fileTempName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            NSData *data =  UIImageJPEGRepresentation(image, 0.9);
          
            
            BOOL ret = [data writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
            if (!ret) {
                DLog(@"error when write image to local cache");
            }
            if (self.complete) {
                self.complete(@[path], YES);
            }
        } else {
            if (self.complete) {
                self.complete(@[image], YES);
            }
        }
    }
    
    if ([type isEqualToString:@"public.movie"]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *filePath = [[self getLocationFolder] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:filePath] error:&error];
        if (error) {
            DLog(@"usering camera to video error %@", error.localizedDescription);
            if (self.complete) {
                self.complete(@[], NO);
            }
        } else {
            if (self.complete) {
                self.complete(@[filePath], YES);
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.complete(nil, YES);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    //
}

#pragma mark

- (void)dealCompleteSelection {
    [self showWaitingView];
    NSMutableArray *selectedArray = [NSMutableArray array];
    NSString *folder = [self getLocationFolder];
    NSLog(@"%@", folder);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[NXPhotoTool sharedInstance] getAllSelectedItems] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NXAssetItem *obj, BOOL * _Nonnull stop) {
            switch (obj.asset.mediaType) {
                case PHAssetMediaTypeImage:
                {
                    dispatch_semaphore_t t = dispatch_semaphore_create(0);
                    [[NXPhotoTool sharedInstance] requestImageFromPhoto:obj scale:1 resizeMode:PHImageRequestOptionsResizeModeExact synchronous:NO completion:^(UIImage *image, NSString *photoName) {
                        if (self.type == NXPhotoSelectRetunTypeDefault) {
                            [selectedArray addObject:image];
                        } else {
                            NSString *filePath = [folder stringByAppendingPathComponent:photoName];
                            NSData *data = UIImageJPEGRepresentation(image, 1);
                            NSError *error;
                            BOOL ret = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
                            if (!ret) {
                                DLog(@"error when copy file :%@", error.localizedDescription);
                                dispatch_semaphore_signal(t);
                                return;
                            }
                            [selectedArray addObject:filePath];
                        }
                        dispatch_semaphore_signal(t);
                    }];
                    dispatch_semaphore_wait(t, DISPATCH_TIME_FOREVER);
                }
                    break;
                case PHAssetMediaTypeVideo:
                {
                    dispatch_semaphore_t t = dispatch_semaphore_create(0);
                    [[NXPhotoTool sharedInstance] requestExportSessionForVideo:obj resultHandler:^(AVURLAsset *exportSession, NSURL *url, NSDictionary *info) {
                        DLog(@"starting loading %@", url.absoluteString);
                        NSString *filePath = [folder stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
                        NSError *error;
                        BOOL ret = [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:filePath] error:&error];
                        if (!ret) {
                            DLog(@"error when copy file :%@", error.localizedDescription);
                        }
                        [selectedArray addObject:filePath];
                        dispatch_semaphore_signal(t);
                    }];
                    dispatch_semaphore_wait(t, DISPATCH_TIME_FOREVER);
                }
                    break;
                case PHAssetMediaTypeUnknown:
                case PHAssetMediaTypeAudio:
                {
                    DLog(@"error when get file type");
                }
                    break;
                default:
                    break;
            }
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NXPhotoTool sharedInstance] removeAllSelectedItems];
            [self hiddenWaitingView:nil];
            NSLog(@"finished");
            if (self.complete) {
                self.complete(selectedArray, YES);
            }
        });
    });
}

#pragma mark
- (MBProgressHUD *)showWaitingView {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.currentVC.view animated:YES];
    hud.contentColor = RMC_MAIN_COLOR;
    hud.bezelView.backgroundColor = [UIColor lightGrayColor];
    hud.animationType = MBProgressHUDAnimationFade;
    hud.userInteractionEnabled = YES;
    hud.graceTime = 0.2;
    hud.margin = 20;
    hud.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8];
    hud.tag =23234;
    
//    hud.label.text = NSLocalizedString(@"    Exporting...   ", NULL);
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud removeFromSuperViewOnHide];
    return hud;
}

- (void)hiddenWaitingView:(MBProgressHUD *)hud {
    [hud hideAnimated:YES];
    [MBProgressHUD hideHUDForView:self.currentVC.view animated:YES];
}

#pragma mark
- (UIViewController *)getTopVC {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (NSString *)getLocationFolder {
    NSString *folder;
    if (self.selectedFileLocationFolder) {
        folder = [self.selectedFileLocationFolder stringByAppendingPathComponent:kFolderName];
    } else {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        folder = [path stringByAppendingPathComponent:kFolderName];
    }
    
    NSError *error;
    BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (ret == NO) {
        NSLog(@"create file folder error:%@", error.localizedDescription);
    }
    
    return folder;
}

@end
