 //
//  NXItemDisplayViewController.m
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXItemDisplayViewController.h"

#import "NXImageItemDisplayCell.h"
#import "NXVideoItemDisplayCell.h"
#import "NXRMCDef.h"
#import "Masonry.h"

#define kItemMargin 20

@interface NXItemDisplayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, weak) UIButton *leftButtonItem;

@end

@implementation NXItemDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoSelectorStateChanged:) name:NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE object:nil];
}

- (void)photoSelectorStateChanged:(NSNotification *)notification
{
    if ([[NXPhotoTool sharedInstance] getAllSelectedItems].count) {
        self.toolbarItems.lastObject.enabled = YES;
    }else{
        self.toolbarItems.lastObject.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView setContentOffset:CGPointMake((self.currentPage - 1) * (self.view.bounds.size.width + kItemMargin), 0)];
    [self photoSelectorStateChanged:nil];

}

- (void)dealloc {
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 

- (void)rightItemClicked:(id)sender {
    NXAssetItem *model = self.dataArray[self.currentPage - 1];
    [[NXPhotoTool sharedInstance] isItemSelected:model]?[[NXPhotoTool sharedInstance] unselectItem:model]:[[NXPhotoTool sharedInstance] selectItem:model];
    [self updateRightItemBarStatus];
}

- (void)updateRightItemBarStatus {
    NXAssetItem *model = self.dataArray[self.currentPage - 1];
    self.leftButtonItem.selected = [[NXPhotoTool sharedInstance] isItemSelected:model];
}

- (void)updateNavigationBars {
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", self.currentPage, self.dataArray.count];
}

- (void)updateBottomBars {
    NXAssetItem *model = self.dataArray[self.currentPage - 1];
    switch (model.asset.mediaType) {
        case PHAssetMediaTypeImage:
        {
            
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            
        }
        case PHAssetMediaTypeAudio:
        case PHAssetMediaTypeUnknown:
        {
            NSLog(@"");
        }
            break;
        default:
            break;
    }
}

- (void)hiddenOrShowNavigationBar {
    if (self.navigationController.navigationBar.isHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
        self.collectionView.backgroundColor = [UIColor whiteColor];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        self.collectionView.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark - UIScrollViewDelegate UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXAssetItem *item = self.dataArray[indexPath.row];
    UICollectionViewCell *baseCell = nil;
    switch (item.asset.mediaType) {
        case PHAssetMediaTypeImage:
        {
            NXImageItemDisplayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NXImageItemDisplayCell" forIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            cell.singleTapCallBack = ^() {
                typeof(self) self = weakSelf;
                [self hiddenOrShowNavigationBar];
            };
            cell.model = item;
            
            baseCell = cell;
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            NXVideoItemDisplayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NXVideoItemDisplayCell" forIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            cell.singleTapCallBack = ^() {
                typeof(self) self = weakSelf;
                [self hiddenOrShowNavigationBar];
            };
            
            cell.model = item;
            baseCell = cell;
        }
            break;
        case PHAssetMediaTypeAudio:
        case PHAssetMediaTypeUnknown:
        {
            
        }
            break;
        default:
            break;
    }
    if(baseCell == nil){
        baseCell = [[UICollectionViewCell alloc] init];
    }
    return baseCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[NXVideoItemDisplayCell class]]) {
        NXVideoItemDisplayCell *videoCell = (NXVideoItemDisplayCell *)cell;
        [videoCell stopPlay];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == (UIScrollView *)_collectionView) {
        CGFloat page = scrollView.contentOffset.x/(self.view.bounds.size.width + kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        self.currentPage = str.integerValue + 1;
        [self updateRightItemBarStatus];
        [self updateNavigationBars];
    }
}

#pragma mark
- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"originalIcon"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"selectedIcon"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(rightItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.leftButtonItem = button;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    [rightItem setCustomView:button];

    self.navigationItem.rightBarButtonItem = rightItem;
    rightItem.tintColor = [UIColor clearColor];
    
    [self updateRightItemBarStatus];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layout.itemSize = self.view.bounds.size;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kItemMargin/2, 0, self.view.bounds.size.width + kItemMargin, self.view.bounds.size.height) collectionViewLayout:layout];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    collectionView.pagingEnabled = YES;
    
    [collectionView registerClass:[NXImageItemDisplayCell class] forCellWithReuseIdentifier:@"NXImageItemDisplayCell"];
    [collectionView registerClass:[NXVideoItemDisplayCell class] forCellWithReuseIdentifier:@"NXVideoItemDisplayCell"];
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//        make.bottom.equalTo(self.mas_bottomLayoutGuide);
//        make.width.height.equalTo(self.view);
//    }];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self updateNavigationBars];
}

@end
