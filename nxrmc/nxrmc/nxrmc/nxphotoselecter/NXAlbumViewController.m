//
//  NXAlbumViewController.m
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAlbumViewController.h"

#import "NXPhotoViewController.h"

#import "NXAlbumCell.h"
#import "NXEmptyView.h"

#import "NXPhotoTool.h"
#import "UIImage+Cutting.h"
#import "NXRMCDef.h"
#import "Masonry.h"


#define kCellIdentifier @"CellIdentifier"

@interface NXAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) NXEmptyView *emptyView;

@property(nonatomic, strong) NSArray<NXPhotoAlbum *> *dataArray;
@property(nonatomic, assign, readwrite) NXAlbumViewControllerSelectedType selectedType;

@end

@implementation NXAlbumViewController
- (instancetype)init{
    NSAssert(NO, @"Pls use initWithSelectedType");
    return nil;
}
- (instancetype)initWithSelectedType:(NXAlbumViewControllerSelectedType)selectedType
{
    if (self = [super init]) {
        _selectedType = selectedType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self createData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoSelectorStateChanged:) name:NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE object:nil];
}
- (void)photoSelectorStateChanged:(NSNotification *)notification
{
    if ([[NXPhotoTool sharedInstance] getAllSelectedItems].count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self photoSelectorStateChanged:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)createData {
    if (self.sourceType == NXPhotoToolSourceTypePhotos) {
        [NXPhotoTool sharedInstance].sourceType = NXPhotoToolSourceTypePhotos;
    } else {
        [NXPhotoTool sharedInstance].sourceType = NXPhotoToolSourceTypeLibrary;
    }
    self.dataArray = [[NXPhotoTool sharedInstance] getAllAlbums];
    if (self.dataArray.count) {
        [self hiddenEmpty];
    } else {
        [self showEmpty];
    }
}

#pragma mark
- (void)showEmpty {
    NXEmptyView *emptyView = [[NXEmptyView alloc] initWithFrame:self.view.bounds];
    emptyView.imageView.image = [UIImage imageNamed:@"Image"];
    emptyView.textLabel.text = NSLocalizedString(@"UI_NO_PHOTO_WAROING", NULL);
    emptyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:emptyView];
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    [self.view bringSubviewToFront:emptyView];
    self.emptyView = emptyView;
}

- (void)hiddenEmpty {
    [self.emptyView removeFromSuperview];
}

- (void)leftItemClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NXAlbumCell *cell = (NXAlbumCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    NXPhotoAlbum *item = self.dataArray[indexPath.row];
    
    cell.countLabel.text = [NSString stringWithFormat:@"(%ld)", item.count];
    cell.titleLabel.text = item.title;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(width * scale, width * scale * item.thumbAsset.asset.pixelHeight/item.thumbAsset.asset.pixelWidth);
    [[NXPhotoTool sharedInstance] requestImageFromPhoto:item.thumbAsset size:size resizeMode:PHImageRequestOptionsResizeModeExact synchronous:NO completion:^(UIImage *image, NSDictionary *info) {
        CGFloat width = image.size.width > image.size.height ? image.size.height : image.size.width;
        if (image) {
            cell.thumbImageView.image = [image imageCuttingToSize:CGSizeMake(width, width)];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXPhotoAlbum *item = self.dataArray[indexPath.row];
    if (item.count) {
        NXPhotoViewController *vc = [[NXPhotoViewController alloc] init];
        if(self.selectedType == NXAlbumViewControllerSelectedTypeMultiSelected){
            vc.multSelected = YES;
        }else{
            vc.multSelected = NO;
        }
        vc.album = item;
        vc.navigationItem.title = item.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 

- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"UI_ALBUMS", NULL);
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem.accessibilityValue = @"ALBUMS_CANCEL";
    self.navigationItem.rightBarButtonItem.accessibilityValue = @"ALBUMS_DONE";
    self.navigationController.toolbarHidden = YES;
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    //TBD autolayout
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[NXAlbumCell class] forCellReuseIdentifier:kCellIdentifier];
    tableView.estimatedRowHeight = 44;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    
    self.tableView = tableView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
}
- (void) cancel:(id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
