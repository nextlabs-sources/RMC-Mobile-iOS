//
//  NXRightsDisplayView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXRightsDisplayView.h"

#import "Masonry.h"
#import "NXRightsDisplayCell.h"
#import "NXRightsDisplayHorizCell.h"
#import "NXColllectionViewFlowLayoutout.h"

#import "NXRMCDef.h"
#import "NXLRights.h"
#import "NXRightsModel.h"
#import "NXLoginUser.h"
#import "NXLFileValidateDateModel.h"

@interface NXRightsDisplayView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, weak) UILabel *stewardPromptLabel;
@property(nonatomic, weak) UILabel *noRightsLabel;
@property(nonatomic, weak) UILabel *digitalLabel;
@property(nonatomic, weak) UIView *contentView;
@property(nonatomic, strong) NSMutableArray *rightsArray;
@property(nonatomic, strong) NSString *watermarkStr;
@property(nonatomic, strong) NSString *validityStr;
@property(nonatomic, strong) UIView *watermarkInfoView;
@property(nonatomic, strong) UILabel *documentLabel;
@end

@implementation NXRightsDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        self.rightsArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 4;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)setNoRightsMessage:(NSString *)noRightsMessage {
    _noRightsMessage = noRightsMessage;
    if (noRightsMessage) {
        self.noRightsLabel.text = noRightsMessage;
        return;
    }
    if (self.rights && ![self.rights getRight:NXLRIGHTVIEW]) {
        _noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    } else {
        _noRightsMessage = noRightsMessage;
    }
    self.noRightsLabel.text = _noRightsMessage;
}
- (void)setIsNeedTitle:(BOOL)isNeedTitle {
    _isNeedTitle = isNeedTitle;
    if (!isNeedTitle) {
        self.digitalLabel.hidden = YES;
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin);
            make.bottom.equalTo(self).offset(-kMargin);
        }];
    }else{
        self.digitalLabel.hidden = NO;
    }
}
- (void)setRights:(NXLRights *)rights {
    _rights = rights;
    NXRightsModel *rightsModel;
    if ([rights DecryptRight]) {
        // only project file have decrypt rights
        rightsModel = [[NXRightsModel alloc] initWithRights:rights fileSorceType:NXFileBaseSorceTypeProject];
    }else{
        rightsModel = [[NXRightsModel alloc] initWithRights:rights];
    }
    
    [self.rightsArray removeAllObjects];
    
//    if (rights && ![rights getRight:NXLRIGHTVIEW]) {
//        self.noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
//    }
    if ([rights getRights] == 0) {
        self.noRightsLabel.hidden = NO;
        [self bringSubviewToFront:self.noRightsLabel];
        if (!self.noRightsMessage) {
            self.noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
        }
    } else {
        self.noRightsLabel.hidden = YES;
        [self sendSubviewToBack:self.noRightsLabel];
        [self bringSubviewToFront:self.stewardPromptLabel];
    }

    
    [rightsModel.contentsArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.active) {
            [self.rightsArray addObject:obj];
        }
    }];

    [rightsModel.collaborationArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.active) {
            [self.rightsArray addObject:obj];
        }
    }];

    [rightsModel.obsArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.active) {
            [self.rightsArray addObject:obj];
        }
    }];
    
    // show watermark value
    
    if ([rights getWatermarkString] != nil) {
        NSArray *watermarkContent = [[rights getWatermarkString] parseWatermarkWords];
        NSMutableString *watermarkString = [[NSMutableString alloc] init];
        for (NXWatermarkWord *watermarkWord in watermarkContent) {
            if (self.showLocalWatermarkStr) {
                [watermarkString appendString:[watermarkWord watermarkLocalizedString]];
            }else{
                [watermarkString appendString:[watermarkWord watermarkPolicyString]];
            }
        }
        self.watermarkStr = watermarkString;
    }
    _fileValidityModel = [rights getVaildateDateModel];
    
    if (_fileValidityModel) {
        self.validityStr = [_fileValidityModel getValidateDateDescriptionString];
        NSDictionary *validityDic = @{@"VALIDITY_MODEL":_fileValidityModel};
        NXRightsCellModel *model = [[NXRightsCellModel alloc] initWithTitle:@"Validity" value:0 modelType:MODELTYPEValidity actived:YES extDic:validityDic];
         [self.rightsArray addObject:model];
    }
    [self setWaterMarkAndValidityViewWithWatermarkStr:self.watermarkStr validityStr:self.validityStr];
    
    [rightsModel.moreOptionArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.active) {
            [self.rightsArray addObject:obj];
        }
    }];
    
    [self.collectionView reloadData];
}
- (void)setIsOwner:(BOOL)isOwner{
    _isOwner = isOwner;
    if (isOwner) {
        self.documentLabel.hidden = NO;
    }else{
        self.documentLabel.hidden = YES;
    }
    
}
- (void)setWaterMarkAndValidityViewWithWatermarkStr:(NSString *)waterStr validityStr:(NSString *)validityStr {
    NSMutableArray *viewArray = [NSMutableArray array];
    if (waterStr) {
      UILabel * watermarkLabel = [[UILabel alloc]init];
        watermarkLabel.numberOfLines = 0;
        watermarkLabel.attributedText = [self createAttributeString:@"Watermark: " subTitle1:waterStr];
        [viewArray addObject:watermarkLabel];
    }
    if (validityStr) {
       UILabel *validityLabel = [[UILabel alloc]init];
        validityLabel.numberOfLines = 0;
        validityLabel.attributedText = [self createAttributeString:@"Validity: " subTitle1:validityStr];
        [viewArray addObject:validityLabel];
    }
    if (viewArray.count > 0) {
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithRed:100/256.0 green:100/256.0 blue:100/256.0 alpha:1];
        [self.watermarkInfoView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.watermarkInfoView);
            make.right.left.equalTo(self.collectionView);
            make.height.equalTo(@1);
        }];
        if (viewArray.count < 2) {
            UILabel *label = viewArray[0];
            [self.watermarkInfoView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lineView.mas_bottom).offset(kMargin);
                make.left.right.equalTo(lineView);
                make.bottom.equalTo(self.watermarkInfoView).offset(-kMargin * 1.5);
            }];
        } else {
            UILabel *label1 = viewArray[0];
            [self.watermarkInfoView addSubview:label1];
            UILabel *label2 = viewArray[1];
            [self.watermarkInfoView addSubview:label2];
            [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lineView.mas_bottom).offset(kMargin);
                make.left.right.equalTo(lineView);
            }];
            [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(label1.mas_bottom).offset(kMargin/2);
                make.left.right.equalTo(label1);
                make.bottom.equalTo(self.watermarkInfoView).offset(-kMargin * 1.5);
            }];
        }
    }
}

- (void)showSteward:(BOOL)show {
//    if (show) {
//        self.stewardPromptLabel.text = NSLocalizedString(@"UI_PERMISSIONS_APPLIED_TEXT", NULL);
//    } else {
//        self.stewardPromptLabel.text = nil;
//    }
//    [self bringSubviewToFront:self.stewardPromptLabel];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rightsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NXRightsCellModel *model = self.rightsArray[indexPath.row];
    if (model.modelType == MODELTYPEValidity) {
        NXRightsDisplayHorizCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"horizCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    } else {
        NXRightsDisplayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NXRightsCellModel *model = self.rightsArray[indexPath.row];
//    if (model.modelType == MODELTYPEValidity) {
//        return CGSizeMake(250, 70);
//    } else {
        return CGSizeMake(80, 70);
//    }
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context {
    //Whatever you do here when the reloadData finished
    float newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
}

#pragma mark

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
//    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
    UILabel *digitalLabel = [[UILabel alloc]init];
    digitalLabel.text = NSLocalizedString(@"UI_PREMISSIONS_APPLIED_TO_THE_FILE", NULL);
    digitalLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:digitalLabel];
    self.digitalLabel = digitalLabel;
    
    UIView *contentView =[[UIView alloc]init];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UILabel *noRightsLabel = [[UILabel alloc] init];
    noRightsLabel.backgroundColor = contentView.backgroundColor;
    [self addSubview:noRightsLabel];
    
    NXColllectionViewFlowLayoutout *layout = [[NXColllectionViewFlowLayoutout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 5;
    layout.maximumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.itemSize = CGSizeMake(90, 75);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [self.contentView addSubview:collectionView];

    collectionView.backgroundColor = self.backgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[NXRightsDisplayCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView registerClass:[NXRightsDisplayHorizCell class] forCellWithReuseIdentifier:@"horizCell"];
    [collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    collectionView.backgroundColor = contentView.backgroundColor;


    noRightsLabel.text = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    noRightsLabel.textAlignment = NSTextAlignmentCenter;
    noRightsLabel.numberOfLines = 0;
    UIView *watermarkInfoView = [[UIView alloc]init];
    [self.contentView addSubview:watermarkInfoView];
    self.watermarkInfoView = watermarkInfoView;
    self.collectionView = collectionView;
    self.noRightsLabel = noRightsLabel;
   
    if (@available(iOS 11.0, *)) {
        [digitalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin);
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
        }];

        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(digitalLabel.mas_bottom).mas_offset(10);
            make.left.right.equalTo(digitalLabel);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kMargin).with.priorityLow();
        }];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView).offset(kMargin);
            make.left.equalTo(contentView).offset(kMargin);
            make.right.equalTo(contentView).offset(-kMargin);
        }];
        [watermarkInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(collectionView.mas_bottom).offset(kMargin);
            make.bottom.equalTo(contentView.mas_safeAreaLayoutGuideBottom).offset(-kMargin);
            make.left.right.equalTo(contentView);
        }];
        [noRightsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.mas_safeAreaLayoutGuide);
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            make.height.greaterThanOrEqualTo(@(80)).with.priorityHigh();
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        }];
    }
    else
    {
        [digitalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin);
        }];

        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(digitalLabel.mas_bottom).mas_offset(10);
            make.left.right.equalTo(digitalLabel);
            make.bottom.equalTo(self).offset(-kMargin).with.priorityLow();
        }];
        
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView).offset(kMargin);
            make.left.equalTo(contentView).offset(kMargin);
            make.right.equalTo(contentView).offset(-kMargin);
        }];
        [watermarkInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(collectionView.mas_bottom).offset(kMargin);
            make.bottom.equalTo(contentView.mas_bottom).offset(-kMargin);
            make.left.right.equalTo(contentView);
        }];
        [noRightsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.left.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin);
            make.height.greaterThanOrEqualTo(@(80)).with.priorityHigh();
            make.bottom.equalTo(self);
            make.top.equalTo(self);
        }];
    }
    
#if 0
    self.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.backgroundColor = [UIColor orangeColor];
    stewardPromptLabel.backgroundColor = [UIColor blueColor];
#endif
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:80/256.0 green:80/256.0 blue:80/256.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:120/256.0 green:120/256.0 blue:120/256.0 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myprojects appendAttributedString:sub1];
    
    return myprojects;
}
@end
