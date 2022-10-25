//
//  NXProjectHeaderView.m
//  nxrmcUITest
//
//  Created by nextlabs on 2/13/17.
//  Copyright © 2017 zhuimengfuyun. All rights reserved.
//

#import "NXProjectHeaderView.h"

#import "NXProjectHeaderImageCell.h"
#import "NXProjectHeaderLabelCell.h"
#import "NXProjectHeaderViewFlowLayout.h"
#import "Masonry.h"
#import "UIImage+Cutting.h"

#define kMaxCount 7

@interface NXProjectHeaderView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UICollectionView *collectionView;

@end

@implementation NXProjectHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setDataArray:(NSArray<NXProjectMemberModel *> *)dataArray {
    if (_dataArray == dataArray) {
        return;
    }
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (NSInteger)numberofCells {
    if (self.dataArray.count > [self maxNumberOfCells]) {
        return [self maxNumberOfCells];
    } else {
        return self.dataArray.count;
    }
}

- (NSInteger)maxNumberOfCells {
    CGSize size = self.collectionView.bounds.size;
    
    return size.width/size.height;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberofCells];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NXProjectMemberModel *model = self.dataArray[indexPath.row];
    
    NXProjectHeaderBaseCell *cell = nil;
    if (model.avatarBase64) {
        NXProjectHeaderImageCell *imageCell = (NXProjectHeaderImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kImageCellIdentifier" forIndexPath:indexPath];
        imageCell.image = [UIImage imageWithBase64Str:model.avatarBase64];
        cell = imageCell;
    } else {
        NXProjectHeaderLabelCell *labelCell = (NXProjectHeaderLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kLabelCellIdentifier" forIndexPath:indexPath];
        if (model.displayName.length) {
            labelCell.title = [[model.displayName substringToIndex:1]uppercaseString];
        };
        cell = labelCell;
    }
    if (self.dataArray.count > [self maxNumberOfCells] && (indexPath.row == [self maxNumberOfCells] - 1)) {
        NXProjectHeaderLabelCell *cell = (NXProjectHeaderLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kLabelCellIdentifier" forIndexPath:indexPath];
        cell.title = [NSString stringWithFormat:@"+%ld", self.dataArray.count - [self maxNumberOfCells]];
        return cell;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NXProjectHeaderViewFlowLayout *layout = (NXProjectHeaderViewFlowLayout *)collectionViewLayout;
    CGFloat height = collectionView.bounds.size.height - layout.sectionInset.bottom - layout.sectionInset.top;
    return CGSizeMake(height, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NXProjectHeaderViewFlowLayout *layout = (NXProjectHeaderViewFlowLayout *)collectionViewLayout;
    NSInteger viewWidth = collectionView.bounds.size.width;
    CGFloat cellWidth = collectionView.bounds.size.height;;
    NSInteger totalCellWidth = cellWidth * [self numberofCells];
    NSInteger totalSpacingWidth = layout.maximumInteritemSpacing * ([self numberofCells] - 1);
    
    NSInteger leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
    NSInteger rightInset = leftInset;
    
    UIEdgeInsets sectionInsets = layout.sectionInset;
    sectionInsets.left = leftInset;
    sectionInsets.right = rightInset;
    layout.sectionInset = sectionInsets;
    
    return sectionInsets;
}

#pragma mrk
- (void)commonInit {
    NXProjectHeaderViewFlowLayout *layout = [[NXProjectHeaderViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 4;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.maximumInteritemSpacing = -1;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kMargin * 4, kMargin, self.bounds.size.width - kMargin * 8, self.bounds.size.height - kMargin * 2) collectionViewLayout:layout];
    [self addSubview:collectionView];
    
    collectionView.backgroundColor = self.backgroundColor;
    collectionView.scrollEnabled = NO;
    
    collectionView.delegate = self;
    collectionView.dataSource = self;

    [collectionView registerClass:[NXProjectHeaderLabelCell class] forCellWithReuseIdentifier:@"kLabelCellIdentifier"];
    [collectionView registerClass:[NXProjectHeaderImageCell class] forCellWithReuseIdentifier:@"kImageCellIdentifier"];
    self.collectionView = collectionView;
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin/2);
        make.left.equalTo(self).offset(kMargin * 4);
        make.right.equalTo(self).offset(-kMargin * 4);
        make.bottom.equalTo(self).offset(-kMargin * 2);
    }];
}
@end
