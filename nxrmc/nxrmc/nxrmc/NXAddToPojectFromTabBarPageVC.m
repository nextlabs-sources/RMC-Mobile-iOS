//
//  NXAddToPojectFromTabBarPageVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/10/17.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToPojectFromTabBarPageVC.h"
#import "NXPreviewFileView.h"
#import "Masonry.h"
#import "NXAddToProjectCell.h"
#import "NXLoginUser.h"
#import "NXProjectUploadVC.h"

#define PREVIEWFOLDHEIGHT 98

@interface NXAddToPojectFromTabBarPageVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NXPreviewFileView *preview;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *byMeProjects;
@property (nonatomic, strong) NSArray *byOtherPtojects;
@property (nonatomic, assign) BOOL showedPreview;
@property (nonatomic, strong) UILabel *tintlabel;
@end

@implementation NXAddToPojectFromTabBarPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurationNavigation];
    [self commonInit];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getNewDataFromAPIandReload];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)configurationNavigation {
    self.dataArray = [NSMutableArray array];
    self.byMeProjects = [NSArray array];
    self.byOtherPtojects = [NSArray array];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"Add file to project";
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
   
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}
- (void)commonInit{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NXPreviewFileView *preview = [[NXPreviewFileView alloc]init];
    preview.fileItem = self.fileItem;
//    [preview showSmallPreImageView];
    preview.enabled = NO;
    preview.promptMessage = @"File source";
    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal ) {
        preview.savedPath = @"Local";
    }else if(self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile){
        preview.savedPath = self.fileItem.serviceAlias;
    }
    preview.showPreviewClick = ^(id sender) {
        [self changePreviewSize];
    };
    self.preview = preview;
    [self.view addSubview:preview];
    
    UILabel *tintLabel = [[UILabel alloc]init];
    tintLabel.backgroundColor = self.view.backgroundColor;
    tintLabel.text = @"     Choose save location";
    [self.view addSubview:tintLabel];
    self.tintlabel = tintLabel;
    
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    self.tableView = tableView;
    tableView.tableFooterView = [[UIView alloc]init];
    [tableView registerClass:[NXAddToProjectCell class] forCellReuseIdentifier:@"cell"];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [preview mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.height.equalTo(self.view).multipliedBy(0.6);
            }];
            
        }
    }else {
       [preview mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
             make.height.equalTo(self.view).multipliedBy(0.6);
        }];
    }
    [tintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(preview.mas_top).offset(100);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tintLabel.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
}

#pragma mark ----- getNewDataAndreload UI
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        StrongObj(self);
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray removeAllObjects];
                self.byMeProjects = projectsCreatedByMe;
                self.byOtherPtojects = projectsInvitedByOthers;
                if (self.byMeProjects.count>0) {
                    [self.dataArray addObject:self.byMeProjects];
                }
                if (self.byOtherPtojects.count>0) {
                    [self.dataArray addObject:self.byOtherPtojects];
                }
                [self.tableView reloadData];
            });
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return ((NSArray *)(self.dataArray[section])).count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc]init];
    sectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *sectionLabel = [[UILabel alloc]init];
    sectionLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionLabel.frame = CGRectMake(20, 10, 350, 20);
    if (self.dataArray.count > 1) {
        if (section == 0) {
            sectionLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_CREATED", NULL) subTitle1:[NSString stringWithFormat:@" %@",@"me"] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byMeProjects.count]];
        }else{
            sectionLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_INVITED", NULL) subTitle1:[NSString stringWithFormat:@" %@",@"others"] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byOtherPtojects.count]];
        }
    }else if (self.dataArray.count == 0){
        return nil;
    }else if (self.byMeProjects.count > 0){
        sectionLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_CREATED", NULL) subTitle1:[NSString stringWithFormat:@" %@",@"me"] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byMeProjects.count]];
    }else if (self.byOtherPtojects.count > 0){
         sectionLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_INVITED", NULL) subTitle1:[NSString stringWithFormat:@" %@",@"others"] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byOtherPtojects.count]];
    }
    [sectionView addSubview:sectionLabel];
    return sectionView;
    
    
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemArray = self.dataArray[indexPath.section];
    NXAddToProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = itemArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProjectUploadVC *vc = [[NXProjectUploadVC alloc] init];
    vc.fileItem = self.fileItem;
    vc.vcTitle = @"Add file to project";
    vc.btnTitle = @"Add file";
    NXProjectModel *model = self.dataArray[indexPath.section][indexPath.row];
    vc.folder = [NXMyProjectManager rootFolderForProject:model];
    vc.project = model;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)cancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)changePreviewSize {
    if (self.showedPreview) {
        [self.tintlabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
        }];
    }else{
        [self.tintlabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
        }];
        
    }
    self.showedPreview = !self.showedPreview;
    [UIView animateWithDuration:0.7 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
    
}

#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 subTitle2:(NSString *)subTitle2 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    NSAttributedString *sub2 ;
    if (subTitle2) {
         sub2 = [[NSMutableAttributedString alloc] initWithString:subTitle2 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    }
    
    [myprojects appendAttributedString:sub1];
    [myprojects appendAttributedString:sub2];
    return myprojects;
}
@end
