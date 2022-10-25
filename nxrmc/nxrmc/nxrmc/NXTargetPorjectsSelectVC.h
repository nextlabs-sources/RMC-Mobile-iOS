//
//  NXTargetPorjectsSelectVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NXFileBase;
@class NXProjectModel;
@interface NXTargetPorjectsSelectVC : UIViewController
@property(nonatomic,strong,nonnull)NXFileBase *currentFile;
@property(nonatomic,strong,nonnull)NSArray *fileArray;
@property(nonatomic,strong,nullable)NXProjectModel *fromProjectModel;
@property(nonatomic,strong,nullable)NSArray *sharedProjects;
@property(nonatomic,assign,nullable)id delegate;
@property(nonatomic, assign) BOOL isForProtect;
@end

@protocol NXTargetPorjectsSelectVCDelegate <NSObject>
- (void)successToShareProjects:(NSArray *_Nullable)projects;

@end
