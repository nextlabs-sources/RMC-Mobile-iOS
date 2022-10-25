//
//  NXFileChooseFlowViewController.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileChooseFlowViewController.h"
#import "NXFileChooseTableViewController.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
@interface NXFileChooseFlowViewController ()<UINavigationControllerDelegate>
@property(nonatomic, strong) NXMutableArray *selectedFilesArray;
@property(nonatomic, strong)NSString *headerTitle;
@property(nonatomic, strong)UIButton *rightButton;
@end

@implementation NXFileChooseFlowViewController
- (instancetype) initWithAnchorFolder:(NXFileBase *)anchorFolder fromPath:(NSString *)fromPath type:(NXFileChooseFlowViewControllerType)type {
    if (self = [super init]) {
        self.type = type;
        _selectedFilesArray = [[NXMutableArray alloc] init];
        id<NXFileChooseFlowDataSorceDelegate> dataSource = nil;
        switch (anchorFolder.sorceType) {
            case NXFileBaseSorceTypeRepoFile:
            {
                dataSource = [NXLoginUser sharedInstance].myRepoSystem;
            }
                break;
            case NXFileBaseSorceTypeProject:
            {
                dataSource = [NXLoginUser sharedInstance].myProject;
            }
                break;
            case NXFileBaseSorceTypeWorkSpace:
            {
                dataSource = [NXLoginUser sharedInstance].workSpaceManager;
            }
                break;
            case NXFileBaseSorceTypeMyVaultFile:
                dataSource = [NXLoginUser sharedInstance].myVault;
                break;
            default:
            {
                NSAssert(NO, @"File Choose should for repo/project/workspace model");
            }
                break;
        }
        NXFileChooseTableViewControllerType tbViewType;
        switch (type) {
            case NXFileChooseFlowViewControllerTypeChooseFile:
            {
                tbViewType = NXFileChooseTableViewControllerChooseFile;
            }
                break;
            case NXFileChooseFlowViewControllerTypeChooseDestFolder:
            {
                tbViewType = NXFileChooseTableViewControllerChooseDestFolder;
            }
                break;
            case NXFileChooseFlowViewControllerTypeNormalFile:
            {
                tbViewType = NXFileChooseTableViewControllerNormalFile;
            }
                break;
            case NXFileChooseFlowViewControllerTypeNxlFile:
            {
                tbViewType = NXFileChooseFlowViewControllerNxlFile;
            }
            default:
                break;
        }
        NSMutableArray *folderVCArray =[NSMutableArray array];
        NSMutableArray *retArray = [NSMutableArray array];
        [self parentFolderForFolder:anchorFolder withDataSource:dataSource retArray:retArray startPath:fromPath shouldRecord:NO];
        
        for (NXFileBase *parentFolder in retArray) {
            [folderVCArray addObject:[[NXFileChooseTableViewController alloc] initWithSelectedFolder:parentFolder type:tbViewType]];
        }
        
        if (fromPath == nil) {
            NXFileChooseTableViewController *vc = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:anchorFolder type:tbViewType];
            [folderVCArray addObject:vc];
        }
        
        [self setViewControllers:folderVCArray];
        NXFileChooseTableViewController *vc = (NXFileChooseTableViewController *)self.topViewController;
        if (fromPath == nil) {
            [_selectedFilesArray addObject:anchorFolder];
        }
        vc.selectedFileArray = _selectedFilesArray;
        [self.selectedFilesArray addObserver:self forKeyPath:@"nxNumCount" options:NSKeyValueObservingOptionNew context:nil];
        self.delegate = self;
    }
    return self;
}


- (void)parentFolderForFolder:(NXFileBase *)folder withDataSource:(id<NXFileChooseFlowDataSorceDelegate>) dataSource retArray:(NSMutableArray *)retArray startPath:(NSString *)startPath shouldRecord:(BOOL)shouldRecord{
    if (folder.isRoot) { // root have no parent
        return;
    }
    NXFileBase *parentFolder = [dataSource queryParentFolderForFolder:folder];
    if (startPath) {
        if ([parentFolder.fullPath isEqualToString:startPath]) {
            [self.selectedFilesArray addObject:parentFolder];
            shouldRecord = YES;
        }
    }else {
        shouldRecord = YES;
    }
    
    if (parentFolder.isRoot) {
        if (shouldRecord) {
            [retArray addObject:parentFolder];
        }
    }else {
        [self parentFolderForFolder:parentFolder withDataSource:dataSource retArray:retArray startPath:startPath shouldRecord:shouldRecord];
        if (shouldRecord) {
            [retArray addObject:parentFolder];
        }
    }
}

- (instancetype) initWithRepository:(NXRepositoryModel *)repoModel type:(NXFileChooseFlowViewControllerType)type isSupportMultipleSelect:(BOOL)supportMultiple
{
    NXFileBase *rootFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:repoModel];
    self.repoModel = repoModel;
    self.headerTitle = repoModel.service_alias;
    self.type = type;
    NXFileChooseTableViewController *fileChooseTableViewController = nil;
    if (type == NXFileChooseFlowViewControllerTypeChooseFile) {
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseFile];
    }else if(type == NXFileChooseFlowViewControllerTypeChooseDestFolder){
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseDestFolder];
    }else if(type == NXFileChooseFlowViewControllerTypeNormalFile) {
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerNormalFile];
    }else if(type == NXFileChooseFlowViewControllerTypeNxlFile){
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseFlowViewControllerNxlFile];
    }else{
        NSAssert(NO, @"Please use the correctly type");
    };
    fileChooseTableViewController.supportMultipleSelect = supportMultiple;
    fileChooseTableViewController.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    if(self = [super initWithRootViewController:fileChooseTableViewController]){
        _selectedFilesArray = [[NXMutableArray alloc] init];
        fileChooseTableViewController.selectedFileArray = _selectedFilesArray;
        [self.selectedFilesArray addObserver:self forKeyPath:@"nxNumCount" options:NSKeyValueObservingOptionNew context:nil];
        self.delegate = self;
        
    }
    return self;
}

- (instancetype) initWithProject:(NXProjectModel *)project type:(NXFileChooseFlowViewControllerType)type
{
    NXProjectFolder *rootFolder = [NXMyProjectManager rootFolderForProject:project];
    NXFileChooseTableViewController *fileChooseTableViewController = nil;
    self.type = type;
    self.projectModel = project;
    self.headerTitle = project.name;
    if (type == NXFileChooseFlowViewControllerTypeChooseFile  || self.type == NXFileChooseTableViewControllerNormalFile) {
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseFile];
    }else if(type == NXFileChooseFlowViewControllerTypeNxlFile) {
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseFlowViewControllerNxlFile];
    }else{
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseDestFolder];
    }
    if(self = [super initWithRootViewController:fileChooseTableViewController]){
        _selectedFilesArray = [[NXMutableArray alloc] init];
        fileChooseTableViewController.selectedFileArray = _selectedFilesArray;
        [self.selectedFilesArray addObserver:self forKeyPath:@"nxNumCount" options:NSKeyValueObservingOptionNew context:nil];
        self.delegate = self;
        
    }
    fileChooseTableViewController.supportMultipleSelect = self.supportMultipleSelect;
    return self;
}
- (instancetype) initWithWorkSpaceType:(NXFileChooseFlowViewControllerType)type
{
    self.headerTitle = @"WorkSpace";
    NXWorkSpaceFolder *rootFolder = [[NXLoginUser sharedInstance].workSpaceManager rootFolderForWorkSpace];
    NXFileChooseTableViewController *fileChooseTableViewController = nil;
    self.type = type;
    if (type == NXFileChooseFlowViewControllerTypeChooseFile  || self.type == NXFileChooseTableViewControllerNormalFile) {
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseFile];
    }else if(type == NXFileChooseFlowViewControllerTypeNxlFile){
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseFlowViewControllerNxlFile];
        
    }else{
        fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:rootFolder type:NXFileChooseTableViewControllerChooseDestFolder];
    }
    if(self = [super initWithRootViewController:fileChooseTableViewController]){
        _selectedFilesArray = [[NXMutableArray alloc] init];
        fileChooseTableViewController.selectedFileArray = _selectedFilesArray;
        [self.selectedFilesArray addObserver:self forKeyPath:@"nxNumCount" options:NSKeyValueObservingOptionNew context:nil];
        self.delegate = self;
        
    }
    fileChooseTableViewController.supportMultipleSelect = self.supportMultipleSelect;
    return self;
}
- (instancetype)initWithMyVaultType:(NXFileChooseFlowViewControllerType)type {
    NXFolder *myVaultFolder = [[NXFolder alloc]init];
    myVaultFolder.isRoot = YES;
    myVaultFolder.sorceType = NXFileBaseSorceTypeMyVaultFile;
    self.type = type;
    self.headerTitle = @"MySpace";
    NXFileChooseTableViewController *fileChooseTableViewController = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:myVaultFolder type:NXFileChooseFlowViewControllerNxlFile];
    if(self = [super initWithRootViewController:fileChooseTableViewController]){
        _selectedFilesArray = [[NXMutableArray alloc] init];
        fileChooseTableViewController.selectedFileArray = _selectedFilesArray;
        [self.selectedFilesArray addObserver:self forKeyPath:@"nxNumCount" options:NSKeyValueObservingOptionNew context:nil];
        self.delegate = self;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc
{
    [self.selectedFilesArray removeObserver:self forKeyPath:@"nxNumCount"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"nxNumCount"] && [object isEqual:self.selectedFilesArray]) {
        NXFileChooseTableViewController *topVC = (NXFileChooseTableViewController *)self.topViewController;
        if (topVC) {
            if ((self.type == NXFileChooseFlowViewControllerTypeChooseFile || self.type == NXFileChooseTableViewControllerNormalFile || self.type == NXFileChooseFlowViewControllerNxlFile)&& self.selectedFilesArray.count > 0) {
               [self.rightButton setTitleColor:RMC_MAIN_COLOR forState:UIControlStateNormal];
                self.rightButton.userInteractionEnabled = YES;
               
            }else{
                [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                self.rightButton.userInteractionEnabled = YES;
            }
            if (self.type == NXFileChooseFlowViewControllerTypeChooseFile || self.type == NXFileChooseTableViewControllerNormalFile) {
                topVC.navigationItem.title = [NSString stringWithFormat:@"%ld selected",self.selectedFilesArray.array.count];
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NXFileChooseTableViewController *vc = (NXFileChooseTableViewController *)viewController;
    vc.selectedFileArray = _selectedFilesArray;
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(fileChooseCancel:)];
    cancelBtn.accessibilityValue = @"CHOOSEFLOWVIEWVC_CANCEL";
    if (vc.currentFolder.isRoot) {
        viewController.navigationItem.leftBarButtonItem = cancelBtn;
    }else{
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(fileChooseBack:)];
        backBtn.accessibilityValue = @"CHOOSEFLOWVIEWVC_BACK";
        viewController.navigationItem.leftBarButtonItems = @[backBtn, cancelBtn];
    }
    UIButton *rightButton = nil;
    viewController.navigationItem.title = self.headerTitle;
    if (self.type == NXFileChooseTableViewControllerChooseDestFolder) {
//        viewController.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(fileChooseDone:)];
        viewController.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] init];
        rightButton = [[UIButton alloc] init];
        rightButton.bounds = CGRectMake(0, 0, 44, 44);
        [rightButton setTitleColor:RMC_MAIN_COLOR forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(fileChooseDone:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:@"Done" forState:UIControlStateNormal];
        viewController.navigationItem.rightBarButtonItem.customView = rightButton;
    }else{
//        viewController.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(fileChooseDone:)];
    
        viewController.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] init];
        rightButton = [[UIButton alloc] init];
        rightButton.bounds = CGRectMake(0, 0, 44, 44);
        [rightButton setTitleColor:RMC_MAIN_COLOR forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(fileChooseDone:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:@"Next" forState:UIControlStateNormal];
        viewController.navigationItem.rightBarButtonItem.customView = rightButton;
    }
    viewController.navigationItem.rightBarButtonItem.accessibilityValue = @"CHOOSEFLOWVIEWVC_DONE";
    if((self.type == NXFileChooseFlowViewControllerTypeChooseFile || self.type == NXFileChooseTableViewControllerNormalFile || self.type == NXFileChooseFlowViewControllerNxlFile)&& self.selectedFilesArray.count == 0){
        [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        rightButton.userInteractionEnabled = NO;
    }else if ((self.type == NXFileChooseFlowViewControllerTypeChooseDestFolder && vc.currentFolder.isRoot) && (vc.currentFolder.serviceType.intValue == kServiceSharepoint || vc.currentFolder.serviceType.intValue == kServiceSharepointOnline)) {
        [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        rightButton.userInteractionEnabled = NO;
    }else {
        [rightButton setTitleColor:RMC_MAIN_COLOR forState:UIControlStateNormal];
        rightButton.userInteractionEnabled = YES;
    }
    self.rightButton = rightButton;
}


- (void)fileChooseDone:(UIBarButtonItem *)barButtonItem
{
    for (NXFileBase *fileItem in self.selectedFilesArray.array) {
        if (self.type != NXFileChooseTableViewControllerChooseDestFolder) {
            if (!fileItem.size || fileItem.size == 0) {
                [NXMBManager showMessage:@"You can not operate on 0KB file.Please select a different file." toView:self.view hideAnimated:YES afterDelay:kDelay * 2];
               
            }
            if (fileItem.name.length >128) {
                [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_128",NULL) toView:self.view hideAnimated:YES afterDelay:kDelay * 2];
                return;
            }
        }
        
    }
    if (DELEGATE_HAS_METHOD(self.fileChooseVCDelegate, @selector(fileChooseFlowViewController:didChooseFile:))) {
        NXFileChooseTableViewController *topVC = (NXFileChooseTableViewController *)self.topViewController;
        if (self.type == NXFileChooseFlowViewControllerTypeChooseDestFolder) {
            [self.selectedFilesArray removeAllObjects];
            [self.selectedFilesArray addObject:topVC.currentFolder];
        }
        [self.fileChooseVCDelegate fileChooseFlowViewController:self didChooseFile:[self.selectedFilesArray.array copy]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fileChooseBack:(UIBarButtonItem *)barButtonItem
{
    [self popViewControllerAnimated:YES];
}

- (void)fileChooseCancel:(UIBarButtonItem *)barButtonItem
{
    if (DELEGATE_HAS_METHOD(self.fileChooseVCDelegate, @selector(fileChooseFlowViewControllerDidCancelled:))) {
        [self.fileChooseVCDelegate fileChooseFlowViewControllerDidCancelled:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
