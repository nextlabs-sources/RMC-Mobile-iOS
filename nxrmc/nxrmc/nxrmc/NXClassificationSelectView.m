//
//  NXClassificationSelectView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXClassificationSelectView.h"
#import "HexColor.h"
#import "NXColllectionViewFlowLayoutout.h"
#import "NXClassificationLabCell.h"
#import "NXClassificationHeaderView.h"
#import "NXClassificationCategory.h"
#import "Masonry.h"
#import "NXRMCDef.h"

#define NXClassificationCell  @"ClassificationCell"
#define NXReusableView        @"ReusableView"
@interface NXClassificationSelectView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UILabel *CentralLabel;
@end
@implementation NXClassificationSelectView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (BOOL)isMandatoryEmpty {
    for (NXClassificationCategory *category in self.classificationCategoryArray) {
        if (category.mandatory && category.selectedLabs.count == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNotSelected {
    for (NXClassificationCategory *category in self.classificationCategoryArray) {
        if (category.selectedLabs.count > 0) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)isNotShouldMultipleCategory {
    NSMutableArray *notShouldMultipleArray = [NSMutableArray array];
    for (NXClassificationCategory *category in self.classificationCategoryArray) {
        if (!category.multiSelect && category.selectedLabs.count > 1) {
            [notShouldMultipleArray addObject:category.name];
        }
    }
    return notShouldMultipleArray;
}

- (void)setClassificationCategoryArray:(NSArray<NXClassificationCategory *> *)classificationCategoryArray {
    _classificationCategoryArray = classificationCategoryArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)commonInit {
    self.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    UILabel *centralLabel = [[UILabel alloc]init];
    [self addSubview:centralLabel];
    centralLabel.text = NSLocalizedString(@"UI_COMPANY_DEFINED_RIGHTS_MARK", NULL);
    centralLabel.textColor = [UIColor colorWithRed:100/256.0 green:100/256.0 blue:100/256.0 alpha:1];
    centralLabel.font = [UIFont systemFontOfSize:16];
    centralLabel.numberOfLines = 0;
    self.CentralLabel = centralLabel;
    NXColllectionViewFlowLayoutout *layout = [[NXColllectionViewFlowLayoutout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.maximumInteritemSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.sectionInset = UIEdgeInsetsMake(kMargin/2,kMargin,kMargin,kMargin/2);
    layout.estimatedItemSize = CGSizeMake(80,40);
    layout.headerReferenceSize = CGSizeMake(80,30);
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    collectionView.allowsMultipleSelection = YES;
    collectionView.backgroundColor = self.backgroundColor;
    [collectionView registerClass:[NXClassificationLabCell class] forCellWithReuseIdentifier:NXClassificationCell];
    [collectionView registerClass:[NXClassificationHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NXReusableView];
    self.collectionView = collectionView;
    [collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    [centralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin * 2);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.height.equalTo(@80);
    }];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centralLabel.mas_bottom).offset(kMargin * 2).priorityHigh();
        make.left.equalTo(self).offset(kMargin * 2);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.bottom.equalTo(self).offset(-kMargin).priorityLow();
    }];

    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NXClassificationCategory *category = self.classificationCategoryArray[section];
    return category.labs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.classificationCategoryArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXClassificationLabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NXClassificationCell forIndexPath:indexPath];
    NXClassificationCategory *category = self.classificationCategoryArray[indexPath.section];
    NXClassificationLab *lab = category.labs[indexPath.row];
    if (lab.defaultLab) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [category.selectedLabs addObject:lab];
        [category.selectedItemPostions addObject:indexPath];
    }
    cell.model = lab;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NXClassificationCategory *category = self.classificationCategoryArray[indexPath.section];
    NXClassificationLab *lab = category.labs[indexPath.row];
    if (!category.isMultiSelect) {
        if (category.selectedItemPostions.count>1) {
            for (int i = 0; i<category.selectedItemPostions.count; i++) {
                 [collectionView deselectItemAtIndexPath:category.selectedItemPostions[i] animated:NO];
            }
        }else{
          [collectionView deselectItemAtIndexPath:category.selectedItemPostions.firstObject animated:NO];
        }
        
        [category.selectedItemPostions removeAllObjects];
        [category.selectedItemPostions addObject:indexPath];
        [category.selectedLabs removeAllObjects];
        [category.selectedLabs addObject:lab];
    }else {
        if (![category.selectedLabs containsObject:lab]) {
          [category.selectedLabs addObject:lab];
        }
    }
    if (category.mandatory) {
        NXClassificationHeaderView *view = (NXClassificationHeaderView *)[collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
        view.category = category;
    }
    if ([self.delegate respondsToSelector:@selector(afterChangeCurrentSelectClassifationSelectView:)]) {
        [self.delegate afterChangeCurrentSelectClassifationSelectView:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NXClassificationCategory *category = self.classificationCategoryArray[indexPath.section];
    NXClassificationLab *lab = category.labs[indexPath.row];
    if ([category.selectedItemPostions containsObject:indexPath]) {
        [category.selectedItemPostions removeObject:indexPath];
    }
    if ([category.selectedLabs containsObject:lab]) {
        [category.selectedLabs removeObject:lab];
    }
    if (category.mandatory) {
        NXClassificationHeaderView *view = (NXClassificationHeaderView *)[collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
         view.category = category;
    }
    if ([self.delegate respondsToSelector:@selector(afterChangeCurrentSelectClassifationSelectView:)]) {
           [self.delegate afterChangeCurrentSelectClassifationSelectView:self];
       }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NXClassificationHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NXReusableView forIndexPath:indexPath];
        NXClassificationCategory *category = self.classificationCategoryArray[indexPath.section];
        view.category = category;
        return view;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NXClassificationCategory *category = self.classificationCategoryArray[indexPath.section];
    NXClassificationLab *lab = category.labs[indexPath.row];
    CGSize size = [self sizeOfLabelWithCustomMaxWidth:1000 systemFontSize:16 andFilledTextString:lab.name];
    CGFloat itemWidth = size.width + 10;
    if (itemWidth < 60) {
        itemWidth = 60;
    }
    CGFloat shortScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
    if (itemWidth > shortScreen * 0.85) {
        itemWidth = shortScreen - 50;
    }
    return CGSizeMake(itemWidth,40);
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context {
    //Whatever you do here when the reloadData finished
    float newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
}

#pragma mark ---->return size from title size
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 60)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}

- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
}

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}
@end
