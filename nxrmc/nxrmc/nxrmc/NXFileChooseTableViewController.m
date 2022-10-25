//
//  NXFileChooseTableViewController.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileChooseTableViewController.h"
#import "NXLoginUser.h"
#import "NXFileSort.h"
#import "NXFileChooseTableViewCell.h"
#import "NXEmptyView.h"
#import "Masonry.h"
#import "NXMBManager.h"
#import "NXCustomTitleView.h"
#import "NXProjectModel.h"
@implementation NXMutableArray
- (instancetype)init{
    self = [super init];
    if (self) {
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count{
    return self.array.count;
}

- (void)addObject:(id)anObject
{
    [self.array addObject:anObject];
    self.nxNumCount = [NSNumber numberWithUnsignedInteger:self.count];
}

- (void)removeObject:(id)anObject
{
    [self.array removeObject:anObject];
    self.nxNumCount = [NSNumber numberWithUnsignedInteger:self.count];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self.array insertObject:anObject atIndex:index];
    self.nxNumCount = [NSNumber numberWithUnsignedInteger:self.count];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.array removeObjectAtIndex:index];
    self.nxNumCount = [NSNumber numberWithUnsignedInteger:self.count];
}

- (void)removeAllObjects
{
    [self.array removeAllObjects];
    self.nxNumCount = [NSNumber numberWithUnsignedInteger:self.count];
}

- (id)firstObject
{
    return [self.array firstObject];
}

- (id)lastObject
{
    return [self.array lastObject];
}
@end

@interface NXFileChooseTableViewController ()<UITextFieldDelegate>
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray*> *> *fileListData;
@property(nonatomic, strong) NSArray *originalFileArray;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UILabel *hintLabel;
@end

@implementation NXFileChooseTableViewController
- (instancetype)initWithSelectedFolder:(NXFileBase *)selectedFolder type:(NXFileChooseTableViewControllerType)type
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _currentFolder = selectedFolder;
        _fileListData = [[NSArray alloc] init];
        _type = type;
    }
    return self;
}

- (NSArray *)fileListData
{
    @synchronized (self) {
        return _fileListData;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[NXFileChooseTableViewCell class] forCellReuseIdentifier:@"FILE_ITEM_CELL"];
    self.tableView.estimatedRowHeight = 45.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(50, 0,0, 0);
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
     
    if (self.type == NXFileChooseTableViewControllerNormalFile) {
        self.tableView.allowsMultipleSelection = YES;
        
    }else{
        self.tableView.allowsMultipleSelection = NO;
    }
    if (self.type == NXFileChooseTableViewControllerChooseDestFolder) {
        self.tableView.contentInset = UIEdgeInsetsMake(50, 0,0, 0);
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.text = @"Select a folder";
        hintLabel.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor colorWithRed:(246.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:1.0];
        hintLabel.textColor = RMC_MAIN_COLOR;
        [self.view addSubview:hintLabel];
        self.hintLabel = hintLabel;
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kMargin);
            } else {
                make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin);
            }
            make.left.equalTo(self.view).offset(kMargin);
            make.width.equalTo(self.view).multipliedBy(0.95);
            make.height.equalTo(@30);
        }];
        
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(80,0,0,0);
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @"Search";
        textField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        textField.delegate = self;
        textField.clearsOnBeginEditing = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.view addSubview:textField];
        self.textField = textField;
        UILabel *selectFileLabel = [[UILabel alloc] init];
        selectFileLabel.backgroundColor = [UIColor whiteColor];
        if(self.type == NXFileChooseFlowViewControllerNxlFile){
            selectFileLabel.text = @"Select a protected file";
        }else{
            selectFileLabel.text = @"Select file(s)";
        }
       
        selectFileLabel.textColor = RMC_MAIN_COLOR;
        [self.view addSubview:selectFileLabel];
        self.hintLabel = selectFileLabel;
        if (@available(iOS 11.0,*)) {
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.view).offset(kMargin);
                make.width.equalTo(self.view).multipliedBy(0.95);
                make.height.equalTo(@35);
            }];

        }else{
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuideBottom);
                make.left.equalTo(self.view).offset(kMargin);
                make.width.equalTo(self.view).multipliedBy(0.95);
                make.height.equalTo(@30);
            }];

        }
        [selectFileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textField.mas_bottom);
            make.left.right.equalTo(textField);
            make.height.equalTo(@30);
        }];
       
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NXMBManager showLoadingToView:self.view];
    [self fileListUnderCurrentFolder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.type == NXFileChooseTableViewControllerChooseDestFolder) {
        switch (self.currentFolder.sorceType) {
            case NXFileBaseSorceTypeWorkSpace:
            {
                if (!self.currentFolder.isRoot) {
                    NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
                    titleView.mainTitle = self.currentFolder.name;
                    titleView.subTitle = [NSString stringWithFormat:@"/%@%@%@",@"/",@"WorkSpace",self.currentFolder.fullServicePath];
                    self.navigationItem.titleView = titleView;
                }else{
                    self.navigationItem.title = @"WorkSpace";
                }
            }
                break;
            case NXFileBaseSorceTypeRepoFile:
                if (!self.currentFolder.isRoot) {
                    NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
                    titleView.mainTitle = self.currentFolder.name;
                    NSString *subStr = [NSString stringWithFormat:@"%@%@%@",@"//",self.currentFolder.serviceAlias,self.currentFolder.fullPath];;
                    titleView.subTitle = subStr;
                    self.navigationItem.titleView = titleView;
                }else{
                    self.navigationItem.title = self.currentFolder.serviceAlias;
                }
                break;
            case NXFileBaseSorceTypeProject:{
               NXProjectModel *model = [[NXLoginUser sharedInstance].myProject getProjectModelForFolder:(NXProjectFolder *)self.currentFolder];
                if (!self.currentFolder.isRoot) {
                    NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
                    titleView.mainTitle = self.currentFolder.name;
                    titleView.subTitle = [NSString stringWithFormat:@"%@%@%@",@"//",model.name,self.currentFolder.fullServicePath];
                    self.navigationItem.titleView = titleView;
                }else{
                    self.navigationItem.title = model.name;
                }
            }
                break;
            case NXFileBaseSorceTypeMyVaultFile:{
                self.navigationItem.title = @"MyVault";
            
            }
                break;
            default:
                break;
        }
        
    }else{
        if (!self.currentFolder.isRoot) {
    //        self.navigationItem.title = self.currentFolder.name;
            NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
            titleView.text = self.currentFolder.name;
            self.navigationItem.titleView = titleView;
        }
        
    }
    
//    if (!self.currentFolder.isRoot) {
////        self.navigationItem.title = self.currentFolder.name;
//        NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
//        titleView.mainTitle = self.currentFolder.name;
//        titleView.subTitle = self.currentFolder.fullServicePath;
//        self.navigationItem.titleView = titleView;
//    }else{
//        if (self.currentFolder.sorceType == NXFileBaseSorceTypeWorkSpace) {
//            self.navigationItem.title = @"WorkSpace";
//        }
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fileListData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sec = self.fileListData[section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXFileChooseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FILE_ITEM_CELL" forIndexPath:indexPath];
    if (self.type == NXFileChooseTableViewControllerChooseFile || self.type == NXFileChooseTableViewControllerNormalFile || self.type == NXFileChooseFlowViewControllerNxlFile) {
        cell.cellType = NXFileChooseTableViewCellTypeChooseFile;
    }else if(self.type == NXFileChooseTableViewControllerChooseDestFolder){
        cell.cellType = NXFileChooseTableViewCellTypeChooseFolder;
    }
    if (self.fileListData.count-1<indexPath.section) {
        return nil;
    }
    NSDictionary *sec = self.fileListData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    
    NXFileBase *fileItem = array[indexPath.row];

    
//    NXFileBase *selectedFileItem = self.selectedFileArray.firstObject;
//    if([selectedFileItem.fullServicePath isEqualToString:fileItem.fullServicePath]){
//        cell.isSelected = YES;
//    }else{
//        cell.isSelected = NO;
//    }
    cell.model = fileItem;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.textField && [self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    NSDictionary *sec = self.fileListData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileItem = array[indexPath.row];
    NXFileChooseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([fileItem isKindOfClass:[NXFile class]]){
        if (!self.supportMultipleSelect) {
            for (NXFileBase *selectFile in self.selectedFileArray.array) {
                selectFile.isSelected = NO;
            }
            [self.selectedFileArray removeAllObjects];
            [self.selectedFileArray addObject:fileItem];
            fileItem.isSelected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_CHOOSE_CHANGED object:self userInfo:@{@"model":[fileItem copy]}];
        }else if(self.type == NXFileChooseTableViewControllerNormalFile){
            if (![self.selectedFileArray.array containsObject:fileItem]) {
                fileItem.isSelected = YES;
                [self.selectedFileArray addObject:fileItem];
                [cell isShowSelectedRightImage:YES];
                cell.isSelected = YES;
                
            }else{
                if (fileItem.isSelected) {
                    [self.selectedFileArray removeObject:fileItem];
                    fileItem.isSelected = NO;
                    [cell isShowSelectedRightImage:NO];
                    cell.isSelected = NO;
                }
            }
            
        }
    }
    
    if ([fileItem isKindOfClass:[NXFolder class]]) {
        if(self.type == NXFileChooseTableViewControllerChooseDestFolder){
            [self.selectedFileArray removeAllObjects];
            [self.selectedFileArray addObject:fileItem];
        }
        NXFileChooseTableViewController *newVC = [[NXFileChooseTableViewController alloc] initWithSelectedFolder:fileItem type:self.type];
        newVC.selectedFileArray = self.selectedFileArray;
        newVC.supportMultipleSelect = self.supportMultipleSelect;
        [self.navigationController pushViewController:newVC animated:YES];
    }
//    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sec = self.fileListData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileItem = array[indexPath.row];
   
    NXFileChooseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.type == NXFileChooseTableViewControllerNormalFile) {
        if ([self.selectedFileArray.array containsObject:fileItem]) {
            [self.selectedFileArray removeObject:fileItem];
            fileItem.isSelected = NO;
            [cell isShowSelectedRightImage:NO];
            cell.isSelected = NO;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
       
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView= [[UIView alloc]init];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    titleLabel.frame = CGRectMake(10, 0, self.tableView.bounds.size.width, 25);
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSDictionary *sec = self.fileListData[section];
    titleLabel.text = [sec allKeys].firstObject;
    [bgView addSubview:titleLabel];
 
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(bgView.mas_safeAreaLayoutGuideLeft).offset(20);
                make.right.equalTo(bgView.mas_safeAreaLayoutGuideRight);
                make.top.equalTo(bgView.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(bgView.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }
   return bgView;
}

- (void)showEmptyView:(NSString *)title image:(UIImage *)image {
    if ([self.tableView viewWithTag:213]) {
        return;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0,0, 0);
    if (self.hintLabel) {
        self.hintLabel.hidden = YES;
    }
    NXEmptyView *emptyView = [[NXEmptyView alloc] init];
    emptyView.textLabel.text = NSLocalizedString(@"UI_NO_FILE_IN_FOLDER", NULL);
    emptyView.imageView.image = [UIImage imageNamed:@"emptyFolder"];
    emptyView.tag = 213;
    if (title) {
        emptyView.textLabel.text = title;
    }
    
    if (image) {
        emptyView.imageView.image = image;
    }
    
    [self.tableView addSubview:emptyView];
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tableView);
        make.width.and.height.equalTo(self.tableView);
    }];
}
- (void)hideEmptyView {
    if (self.hintLabel) {
        self.hintLabel.hidden = NO;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(80, 0,0, 0);
    if ([self.tableView viewWithTag:213]) {
        NXEmptyView *emptyView = [self.tableView viewWithTag:213];
        [emptyView removeFromSuperview];
    }else{
        return;
    }
}
- (void)fileListUnderCurrentFolder
{
    id<NXFileChooseFlowDataSorceDelegate> dataSorce = nil;
    if (self.currentFolder.sorceType == NXFileBaseSorceTypeProject) {
        dataSorce = [NXLoginUser sharedInstance].myProject;
    }else if(self.currentFolder.sorceType == NXFileBaseSorceTypeRepoFile || self.currentFolder.sorceType == NXFileBaseSorceTypeSharedWorkspaceFile){
        dataSorce = [NXLoginUser sharedInstance].myRepoSystem;
    }else if(self.currentFolder.sorceType == NXFileBaseSorceTypeWorkSpace){
        dataSorce = [NXLoginUser sharedInstance].workSpaceManager;
    }else if(self.currentFolder.sorceType == NXFileBaseSorceTypeMyVaultFile){
        dataSorce = [NXLoginUser sharedInstance].myVault;
    }

    [dataSorce fileListUnderFolder:(NXFolder *)self.currentFolder withCallBackDelegate:self];
}
#pragma mark - NXFileChooseFlowDataSorceDelegate
- (void)fileChooseFlowDidGetFileList:(NSArray *)fileList underParentFolder:(NXFolder *)parentFolder error:(NSError *)error
{
    dispatch_main_async_safe(^{
        [NXMBManager hideHUDForView:self.view];
    });
    if (!error) {
        if (fileList) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *normalFileItems = [[NSMutableArray alloc] initWithArray:fileList];
                if(self.type == NXFileChooseTableViewControllerNormalFile) {
                    for (NXFileBase *fileItem in fileList) {
                        if ([fileItem isKindOfClass:[NXFile class]] && [fileItem.name.pathExtension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            [normalFileItems removeObject:fileItem];
                        }
                    }
                }else if(self.type == NXFileChooseTableViewControllerChooseDestFolder) {
                    for (NXFileBase *fileItem in fileList) {
                        if ([fileItem isKindOfClass:[NXFile class]]) {
                            [normalFileItems removeObject:fileItem];
                        }
                    }
                }else if(self.type == NXFileChooseFlowViewControllerNxlFile){
                    for (NXFileBase *fileItem in fileList) {
                        if ([fileItem isKindOfClass:[NXFile class]] && !([fileItem.name.pathExtension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
                            [normalFileItems removeObject:fileItem];
                        }
                    }
                }
                self.originalFileArray = [normalFileItems copy];
                NSMutableArray<NSDictionary *> * result =  [NXFileSort keySortObjects:normalFileItems option:NXSortOptionNameAscending];
                if (result) {
                    self.fileListData = result;
                }
                
                dispatch_main_async_safe(^{
                    if(result.count){
                        [self.tableView reloadData];
                    }else{
                        [self showEmptyView:nil image:nil];
                    }
                });
            });
        }
    }else{
        NSString *errorMsg = error.localizedDescription?:NSLocalizedString(@"MSG_COM_GETFILE_FAIL", nil);
        dispatch_main_async_safe(^{
            [NXMBManager showMessage:errorMsg hideAnimated:YES afterDelay:kDelay];
        })
    }
 
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.tableView.scrollEnabled = YES;
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (![newStr isEqualToString:@""]) {
        
//        NSArray *data = [self.currentSelectVC getSearchDataSource];
        
        // filter ...a
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"self.name contains [cd] %@",newStr];
        NSMutableArray *searchArray = [[NSMutableArray alloc] initWithArray:[self.originalFileArray filteredArrayUsingPredicate:preicate]];
        NSMutableArray<NSDictionary *> * result =  [NXFileSort keySortObjects:searchArray option:NXSortOptionNameAscending];
        if (result) {
            self.fileListData = result;
        }
        
        dispatch_main_async_safe(^{
            if(result.count){
                [self hideEmptyView];
                [self.tableView reloadData];
            }else{
                [self showEmptyView:nil image:nil];
            }
        });
    }else{
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:self.originalFileArray];
        NSMutableArray<NSDictionary *> * result =  [NXFileSort keySortObjects:dataArray option:NXSortOptionNameAscending];
        if (result) {
            self.fileListData = result;
        }
        
        dispatch_main_async_safe(^{
            if(result.count){
                [self hideEmptyView];
                [self.tableView reloadData];
            }else{
                [self showEmptyView:nil image:nil];
            }
        });
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.tableView.scrollEnabled = YES;
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.tableView.scrollEnabled = NO;
    return YES;
}
@end
