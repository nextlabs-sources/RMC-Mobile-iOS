//
//  NXFileChooseTableViewController.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileBase.h"
#import "NXFileBaseViewController.h"
#import "NXFileChooseFlowDataSorceDelegate.h"


typedef NS_ENUM(NSInteger, NXFileChooseTableViewControllerType)
{
    NXFileChooseTableViewControllerChooseFile = 1,  // choose all files
    NXFileChooseTableViewControllerNormalFile = 2,  // choose all files except nxl
    NXFileChooseTableViewControllerChooseDestFolder = 3, // just choose folder
    NXFileChooseFlowViewControllerNxlFile
};

@interface NXMutableArray : NSObject
@property(nonatomic, strong) NSNumber *nxNumCount;
@property(nonatomic, strong) NSMutableArray *array;
- (NSUInteger)count;
- (void)addObject:(id)anObject;
- (void)removeObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;
- (id)firstObject;
@end

@interface NXFileChooseTableViewController : UITableViewController<NXFileChooseFlowDataSorceDelegate>
- (instancetype)initWithSelectedFolder:(NXFileBase *)selectedFolder type:(NXFileChooseTableViewControllerType) type;
@property(nonatomic, strong) NXMutableArray *selectedFileArray;
@property(nonatomic, assign) NXFileChooseTableViewControllerType type;
@property(nonatomic, strong) NXFileBase *currentFolder;
@property(nonatomic, assign) BOOL supportMultipleSelect;
@end
