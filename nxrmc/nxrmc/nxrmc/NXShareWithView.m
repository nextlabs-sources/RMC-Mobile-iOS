//
//  NXEmailAndOthersView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/1/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXShareWithView.h"
#import "NXColllectionViewFlowLayoutout.h"
#import "Masonry.h"
#import "NXShareWithCell.h"
#import "NXRMCDef.h"
#import "NXProjectModel.h"
@interface NXShareWithView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)NXColllectionViewFlowLayoutout *layout;
@property(nonatomic,strong)UICollectionView *collectionView;
@end

@implementation NXShareWithView
- (NSMutableArray *)deleteProjectArray {
    if (!_deleteProjectArray) {
        _deleteProjectArray = [NSMutableArray array];
    }
    return _deleteProjectArray;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionViewMaxHeight = 300;
        self.collectionViewMinHeight = 40;
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    NXColllectionViewFlowLayoutout *layout = [[NXColllectionViewFlowLayoutout alloc] init];
    self.layout = layout;
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(kMargin, 0, kMargin, 0);
    layout.maximumInteritemSpacing = kMargin;
   
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self addSubview:collectionView];
    collectionView.backgroundColor = self.backgroundColor;
    [collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[NXShareWithCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView = collectionView;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(self.collectionViewMinHeight));
        make.bottom.equalTo(self).offset(-10);
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context {
    //Whatever you do here when the reloadData finished
    
    CGFloat collectionViewContentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    CGFloat newHeight = collectionViewContentHeight < self.collectionViewMaxHeight ? collectionViewContentHeight : self.collectionViewMaxHeight;
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
    
}
#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)(self.dataArray[section].allValues.firstObject)).count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NXShareWithCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"cell" forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSString *key = dict.allKeys.firstObject;
    NSMutableArray *itmeArray = dict.allValues.firstObject;
    cell.item = itmeArray[indexPath.row];
    cell.shareWithType = [key integerValue];
    
    WeakObj(self);
    cell.deleteBlock = ^(id sender) {
        StrongObj(self);
        if (cell.shareWithType == NXShareWithTypeProject) {
            [self.deleteProjectArray addObject:itmeArray[indexPath.row]];
        }
        [itmeArray removeObjectAtIndex:indexPath.row];
        [self.collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(theShareWithViewHasChanged)]) {
            [self.delegate theShareWithViewHasChanged];
        }
    };
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        NSDictionary *dict = self.dataArray[indexPath.section];
        NSArray *itmeArray = dict.allValues.firstObject;
        id item = itmeArray[indexPath.row];
        NSString *itemName;
    if ([item isKindOfClass:[NXProjectModel class]]) {
        itemName = ((NXProjectModel *)item).name;
    }else if ([item isKindOfClass:[NSString class]]){
        itemName = item;
    }
    
    CGSize size = [NXShareWithCell sizeForTitle:itemName];
    if ([dict.allKeys.firstObject integerValue]) {
        return CGSizeMake(size.width+40, 40);
    }
    return size;
}
- (void)setDataArray:(NSArray<NSDictionary *> *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
