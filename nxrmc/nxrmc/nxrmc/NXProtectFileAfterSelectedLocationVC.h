//
//  NXProtectFileAfterSelectedLocationVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^clickChangeSaveLocationCompletion)(void);
@interface NXSaveLocationInfoView:UIView
//@property(nonatomic, strong)NSString *savePath;
//@property(nonatomic, strong)NSString *hintMessage;
@property(nonatomic, copy)clickChangeSaveLocationCompletion changeSaveLocationCompletion;
- (instancetype)initWithSavePathText:(NSString *)text;
- (void)hideChangeSaveLocationButton;
- (void)setHintMessage:(NSString * _Nonnull)hintMessage andSavePath:(NSString *)savePath;

@end
@class NXFileBase;
@class NXProjectModel;
typedef NS_ENUM(NSInteger,NXSelectProtectType) {
    NXSelectProtectTypeDigital,
    NXSelectProtectTypeClassification
};
typedef NS_ENUM(NSInteger,NXProtectSaveLoactionType) {
    NXProtectSaveLoactionTypeFileRepo,
    NXProtectSaveLoactionTypeMyVault,
    NXProtectSaveLoactionTypeProject,
    NXProtectSaveLoactionTypeLocalFiles,
    NXProtectSaveLoactionTypeWorkSpace,
    NXProjectSaveLocationTypeSharedWorkSpace,
};
@interface NXProtectFileAfterSelectedLocationVC : UIViewController
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong)NSArray *filesArray;
@property(nonatomic, strong)NXFileBase *saveFolder;
@property(nonatomic, strong)NXProjectModel *targetProject;
@property(nonatomic, assign)NXSelectProtectType protectType;
@property(nonatomic, assign)NXProtectSaveLoactionType locationType;
@end

NS_ASSUME_NONNULL_END
