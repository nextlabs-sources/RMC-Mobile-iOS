//
//  NXHomeMySpaceStateView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeMySpaceStateView.h"
#import "NXHomeSpaceCollectionViewCell.h"
#import "Masonry.h"
#import "NXHomeSpaceItemModel.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
@interface NXHomeMySpaceStateView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) UICollectionView *stateCollectionView;
@end
@implementation NXHomeMySpaceStateView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//         self.backgroundColor = RMC_MAIN_COLOR;
        self.backgroundColor = [UIColor clearColor];
        [self commonInit];
    }
    return self;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)commonInit {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
   UICollectionView *stateCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    stateCollectionView.showsHorizontalScrollIndicator = NO;
    [stateCollectionView registerClass:[NXHomeSpaceCollectionViewCell class] forCellWithReuseIdentifier:@"spaceCell"];
    [stateCollectionView registerClass:[NXHomeMySpaceViewCell class] forCellWithReuseIdentifier:@"mySpaceCell"];
    stateCollectionView.delegate = self;
    stateCollectionView.dataSource = self;
    [self addSubview:stateCollectionView];
    stateCollectionView.backgroundColor = [UIColor clearColor];
    self.stateCollectionView = stateCollectionView;
    [stateCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.top.bottom.equalTo(self);
    }];
}

- (void)updateMySpaceItemFilesCount:(NSUInteger)filesCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NXHomeSpaceItemModel *model in self.dataArray) {
            if ([model.name isEqualToString:@"MySpace"]) {
                model.fileCount = filesCount;
                [self.stateCollectionView reloadData];
                return;
            }
        }
    });
}


- (void)updateOneItems:(NSInteger)index withDict:(NSDictionary *)dic{
    NXHomeSpaceItemModel *item = self.dataArray[index];
    if([dic.allKeys.firstObject isEqualToString:@"workSpace"]){
        NSNumber *fileCount = dic[@"workSpace"][@"totalFiles"];
        NSNumber *usageNumber = dic[@"workSpace"][@"usage"];
        long usage = [usageNumber longValue];
         item.fileCount = [fileCount longValue];
        if (usage == 0) {
            item.usageStr = @"0 KB";
        }else{
            item.usageStr = [NSByteCountFormatter stringFromByteCount:usage countStyle:NSByteCountFormatterCountStyleBinary];
        }
    }else{
        long long myDriveUsageSize = [(NSNumber *)dic[@"usage"] longLongValue] - [(NSNumber *)dic[@"myVaultUsage"] longLongValue];
        long long mySpaceUsageSize = [(NSNumber *)dic[@"usage"] longLongValue];

        if (myDriveUsageSize == 0) {
            item.usageStr = @"0 KB";
        }else {
            item.usageStr = [NSByteCountFormatter stringFromByteCount:mySpaceUsageSize countStyle:NSByteCountFormatterCountStyleBinary];
        }

    }
    
     [self.stateCollectionView reloadData];
}
- (void) makeUIBaseWithItemInfo:(NSDictionary *)dic {
        NXHomeSpaceItemModel *workSpaceItem = [[NXHomeSpaceItemModel alloc]init];
        workSpaceItem.name = @"WorkSpace";
        workSpaceItem.showFileNumber = YES;
        workSpaceItem.leftImage = [UIImage imageNamed:@"WorkSpace"];
        workSpaceItem.bgColor = [UIColor colorWithRed:47/256.0 green:128/256.0 blue:237/256.0 alpha:1];
    
          NXHomeSpaceItemModel *mySpaceItem = [[NXHomeSpaceItemModel alloc]init];
          mySpaceItem.name = @"MySpace";
          mySpaceItem.showFileNumber = YES;
          mySpaceItem.leftImage = [UIImage imageNamed:@"MySpace"];
          mySpaceItem.bgColor = [UIColor colorWithRed:153/256.0 green:206/256.0 blue:101/256.0 alpha:1];
    
        if (dic == nil) {
            workSpaceItem.usageStr = @"0 KB";
            workSpaceItem.fileCount = 0;
            mySpaceItem.usageStr = @"0 KB";
            mySpaceItem.fileCount = 0;
        }
        [self.dataArray removeAllObjects];
        [self.dataArray addObject:mySpaceItem];
    
    if ([NXCommonUtils isSupportWorkspace]){
          [self.dataArray addObject:workSpaceItem];
        }
        [self.stateCollectionView reloadData];
        
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(190, 80);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    NXHomeSpaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spaceCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickSpaceItemFinishedBlock) {
        self.clickSpaceItemFinishedBlock(indexPath.row);
    }
}
@end
