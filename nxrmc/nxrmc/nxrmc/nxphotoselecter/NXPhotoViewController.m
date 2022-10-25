//
//  NXPhotoViewController.m
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXPhotoViewController.h"
#import "NXItemDisplayViewController.h"

#import "NXPhotoCell.h"
#import "Masonry.h"
#import "NXRMCDef.h"

#define kCellIdentifier @"kCellIdentifier"
#define kRowCount 4

@interface NXPhotoViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *dataArray;
@end

@implementation NXPhotoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self createData];
    _multSelected = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRouted:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoSelectorStateChanged:) name:NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE object:nil];
}


- (void)photoSelectorStateChanged:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem.accessibilityValue = @"PHOTO_DONE";
    self.navigationItem.leftBarButtonItem.accessibilityValue = @"PHOTO_BACK";
    if ([[NXPhotoTool sharedInstance] getAllSelectedItems].count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%ld selected",[[NXPhotoTool sharedInstance] getAllSelectedItems].count];
    
}

- (void)deviceRouted:(NSNotification *)notification
{
    [self.collectionView invalidateIntrinsicContentSize];
    [self.collectionView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //TBD
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [self photoSelectorStateChanged:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createData {
    self.dataArray = [[NXPhotoTool sharedInstance] getItemsFromAlbum:self.album ascending:NO];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXPhotoCell *cell = (NXPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NXAssetItem *item = self.dataArray[indexPath.row];
    cell.model = item;
    cell.selectBlock = ^(UIButton *sender) {
        if (sender.selected) {
            [[NXPhotoTool sharedInstance] selectItem:item];
        } else {
            [[NXPhotoTool sharedInstance] unselectItem:item];
        }
    };
    cell.selectButton.selected = [[NXPhotoTool sharedInstance] isItemSelected:item];
    cell.backgroundColor = self.view.backgroundColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NXItemDisplayViewController *vc = [[NXItemDisplayViewController alloc]init];
    vc.currentPage = indexPath.row + 1;
    vc.dataArray = self.dataArray;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat totalWidth = collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right;
    NSInteger suggestedWidth = 120;
    NSInteger itemCount = totalWidth/suggestedWidth;
    
    if (itemCount < 4) {
        itemCount = 4; // at least 4 rows one line
    }
    
    totalWidth = totalWidth - itemCount * layout.minimumInteritemSpacing + layout.minimumInteritemSpacing;
    return CGSizeMake(totalWidth/itemCount - 1, totalWidth/itemCount - 1);
}

#pragma mark

- (void)commonInit {
//    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(2, 10, 2, 10);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.bounces = YES;
    collectionView.backgroundColor = [UIColor whiteColor];

    self.collectionView = collectionView;
    [collectionView registerClass:[NXPhotoCell class] forCellWithReuseIdentifier:kCellIdentifier];
}

@end
