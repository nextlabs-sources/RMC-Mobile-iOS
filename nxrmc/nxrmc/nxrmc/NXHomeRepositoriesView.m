//
//  NXHomeRepositoriesView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 28/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeRepositoriesView.h"
#import "Masonry.h"
#import "NXhomeReposCollectionViewCell.h"
#import "NXRepositoryModel.h"
#import "NXCommonUtils.h"

@interface NXHomeRepositoriesView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)UICollectionView *repoCollectionView;
@property(nonatomic, strong)UILabel *repoLabel;
@end
@implementation NXHomeRepositoriesView
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)commonInit {
    UILabel *repoCountLabel = [[UILabel alloc]init];
    [self addSubview:repoCountLabel];
    repoCountLabel.font = [UIFont systemFontOfSize:16];
    self.repoLabel = repoCountLabel;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//    layout.minimumInteritemSpacing = 10;
//    layout.minimumLineSpacing = 20;
//    layout.sectionInset = UIEdgeInsetsMake(10, 30, 10, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *repoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    repoCollectionView.showsHorizontalScrollIndicator = NO;
        repoCollectionView.delegate = self;
    repoCollectionView.dataSource = self;
    [repoCollectionView registerClass:[NXhomeReposCollectionViewCell class] forCellWithReuseIdentifier:@"repoCell"];
    [self addSubview:repoCollectionView];
    self.repoCollectionView = repoCollectionView;
    repoCollectionView.backgroundColor = [UIColor clearColor];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [repoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(10);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(30);
                make.width.equalTo(@300);
                make.height.equalTo(@30);
            }];
            
            [repoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(repoCountLabel.mas_bottom).offset(10);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }
    else
    {
        [repoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(30);
            make.width.equalTo(@300);
            make.height.equalTo(@30);
        }];
        [repoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(repoCountLabel.mas_bottom).offset(10);
            make.left.right.bottom.equalTo(self);
        }];
    }
}
- (void)upDateNewInfoWith:(NSArray *)infos {
    [self.dataArray removeAllObjects];
    for (NXRepositoryModel *repoModel in infos) {
        if (!(repoModel.service_type.integerValue == kServiceSkyDrmBox)) {
            [self.dataArray addObject:repoModel];
        }
    }
    NXRepositoryModel *addModel = [[NXRepositoryModel alloc]init];
    addModel.isAddItem = YES;
    [self.dataArray insertObject:addModel atIndex:0];
   
    self.repoLabel.text = NSLocalizedString(@"UI_ADDITIONAL_DOCUMENT_SOURCES", NULL);
    [self.repoCollectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, 85);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 30, 10, 30);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXhomeReposCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"repoCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    if (indexPath.row<self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
        if (cell.model.isAddItem) {
            cell.accessibilityValue = @"HOME_PAGE_ADD_REPO_BTN";
        }
    }
  
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NXRepositoryModel *model = self.dataArray[indexPath.row];
    if (self.clickRepoItemFinishedBlock) {
        self.clickRepoItemFinishedBlock(model);
    }
}

@end
