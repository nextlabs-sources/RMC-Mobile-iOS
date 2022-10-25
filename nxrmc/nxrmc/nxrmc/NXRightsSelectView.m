
//
//  NXRightsSelectView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXRightsSelectView.h"

#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXRightsSelectCell.h"
#import "NXRightsSelectReusableView.h"
#import "UIView+UIExt.h"
#import "HexColor.h"
#import "NXColllectionViewFlowLayoutout.h"

#import "NXRightsCellModel.h"
#import "NXRMCDef.h"
#import "NXLRights.h"
#import "NXRightsModel.h"
#import "NXFileValidityDateChooseViewController.h"
#import "NXLoginUser.h"
#import "NXEditWatermarkView.h"
#import "NXWatermarkWord.h"
#import "YYLabel.h"
#import "NXLFileValidateDateModel.h"
#import "NXShareView.h"
#define kHeaderHeight       90

#define kAnimationInterval  0.2 //second

#define kCellIdentifier     @"CellIdentifier"
#define kReusableView       @"ReuseableView"
#define kMoreOptionView     @"MoreOptionView"


@interface NXRightsSelectView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak, readonly) UILabel *promptLabel;
@property(nonatomic, weak, readonly) UILabel *protectDigitalTitleLabel;
@property(nonatomic, weak, readonly) UICollectionView *collectionView;
@property(nonatomic, weak, readonly) UILabel *noRightsLabel;
@property(nonatomic, strong) NXRightsModel *rightsModel;
@property(nonatomic, assign) BOOL selectWatermark;
@property(nonatomic, strong) NSArray *moreOptionArray;
@end

@implementation NXRightsSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.enabled = YES;
        _rights = [[NXLRights alloc]init];
        if (!self.isToProject) {
            self.currentWatermarks = [[NXLoginUser sharedInstance].userPreferenceManager userPreference].preferenceWatermark;
            self.currentValidModel = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate;
        }
        [_rights setRight:NXLRIGHTVIEW value:YES];
        
        _rightsModel = [[NXRightsModel alloc]initWithRights:_rights];
        [self commonInit];
    }
    return self;
}


- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}
- (void)setIsToProject:(BOOL)isToProject {
    _isToProject = isToProject;
    
}
- (void)setIsShowMoreOptions:(BOOL)isShowMoreOptions {
    _isShowMoreOptions = isShowMoreOptions;
}
#pragma mark -setter/getter
- (void)setNoRightsMessage:(NSString *)noRightsMessage {
    if (!noRightsMessage.length) {
        return;
    }
    if (self.rights && ![self.rights getRight:NXLRIGHTVIEW]) {
        _noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    } else {
        _noRightsMessage = noRightsMessage;
    }
    self.noRightsLabel.text = _noRightsMessage;
}

- (void)setRights:(NXLRights *)rights {
    _rights = rights;
    if (rights.getVaildateDateModel) {
          [_rights setFileValidateDate:rights.getVaildateDateModel];
    }else{
         [_rights setFileValidateDate:self.currentValidModel];
    }
   
    _rightsModel = [[NXRightsModel alloc] initWithRights:rights];
   
    [self.collectionView reloadData];
    
    if (rights && ![rights getRight:NXLRIGHTVIEW]) {
        self.noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    }
    
    if (![rights getRight:NXLRIGHTVIEW]) {
        //Have No Access Right;
        self.noRightsLabel.hidden = NO;
        [self bringSubviewToFront:self.noRightsLabel];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@80);
        }];
    } else {
        self.noRightsLabel.hidden = YES;
        [self sendSubviewToBack:self.noRightsLabel];
        float newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(newHeight));
        }];
    }
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(rightsSelectView:didHeightChanged:))) {
        [self.delegate rightsSelectView:self didHeightChanged:0.1];
    }
}
- (void)setRights:(NXLRights *)rights withFileSorceType:(NXFileBaseSorceType)fileSorceType{
    _rights = rights;
    if (rights.getVaildateDateModel) {
          [_rights setFileValidateDate:rights.getVaildateDateModel];
    }else{
         [_rights setFileValidateDate:self.currentValidModel];
    }
   
    _rightsModel = [[NXRightsModel alloc] initWithRights:rights fileSorceType:fileSorceType];
   
    [self.collectionView reloadData];
    
    if (rights && ![rights getRight:NXLRIGHTVIEW]) {
        self.noRightsMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    }
    
    if (![rights getRight:NXLRIGHTVIEW]) {
        //Have No Access Right;
        self.noRightsLabel.hidden = NO;
        [self bringSubviewToFront:self.noRightsLabel];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@80);
        }];
    } else {
        self.noRightsLabel.hidden = YES;
        [self sendSubviewToBack:self.noRightsLabel];
        float newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(newHeight));
        }];
    }
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(rightsSelectView:didHeightChanged:))) {
        [self.delegate rightsSelectView:self didHeightChanged:0.1];
    }
    
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.collectionView.userInteractionEnabled = enabled;
}

- (NSArray<NSString *> *)supplementaryTitles {
    return @[NSLocalizedString(@"UI_FILE_PERMISSIONS", NULL),@"",@"",@"    More options"];
////      if (self.isToProject) {
////             return @[NSLocalizedString(@"UI_CONTENT", NULL),NSLocalizedString(@"UI_COLLABORATION", NULL),NSLocalizedString(@"UI_EFFECT", NULL)];
////      }
////      else{
//             return @[NSLocalizedString(@"UI_CONTENT", NULL),NSLocalizedString(@"UI_COLLABORATION", NULL),NSLocalizedString(@"UI_EFFECT", NULL),NSLocalizedString(@"UI_EXPIRATION", NULL)];
////      }
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    if (self.isToProject) {
//        return 3;
//    }
//    else
//    {
         return 4;
//    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.rightsModel.contentsArray.count;
    }
    if (section == 1) {
        return self.rightsModel.obsArray.count;
    }
    if (section == 2) {
        return self.rightsModel.validityArray.count;
    }
    if (section == 3) {
        return self.moreOptionArray.count;
    }
    
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == 3) {
            NXRightsMoreOptionSelectReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMoreOptionView forIndexPath:indexPath];
            [view setShowMoreOptions:self.isShowMoreOptions];
            WeakObj(self);
            view.moreOptionsButtonClicked = ^{
                StrongObj(self);
                self.isShowMoreOptions = !self.isShowMoreOptions;
                [self setCurrentMoreOptions:self.isShowMoreOptions];
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            };
            return  view;
        }else{
            NXRightsSelectReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableView forIndexPath:indexPath];
            
            view.model = [self supplementaryTitles][indexPath.section];
            return view;
        }
       
    }
    
    return [[UICollectionReusableView alloc] init];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NXRightsSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NXRightsCellModel *model = nil;
    if (indexPath.section == 0 ) {
        model = self.rightsModel.contentsArray[indexPath.row];
        cell.descriptionLabel.hidden = YES;
        cell.changeLabel.hidden = YES;
    }
    
    if (indexPath.section == 1) {
        model = self.rightsModel.obsArray[indexPath.row];
        if (model.active) {
            cell.descriptionLabel.hidden = NO;
            if (self.currentWatermarks.count) {
                cell.descriptionLabel.text = [self.currentWatermarks translateIntoLocalizedString];
            }
        }else{
            cell.descriptionLabel.hidden = YES;
        }
       
        cell.changeLabel.hidden = YES;
    }
    if (indexPath.section == 2) {
        model = self.rightsModel.validityArray[indexPath.row];
        cell.descriptionLabel.hidden = NO;
        cell.changeLabel.hidden = NO;
    }
    if (indexPath.section == 3) {
        model = self.moreOptionArray[indexPath.row];
        cell.descriptionLabel.hidden = YES;
        cell.changeLabel.hidden = YES;
    }
    cell.model = model;
    if (indexPath.section == 0 && indexPath.row == 0) {
        //for View
        cell.userInteractionEnabled = NO;
//        cell.switchButton.onTintColor = [UIColor darkGrayColor];
    }else if(indexPath.section == 2 && indexPath.row == 0){
        //for file validity
        cell.userInteractionEnabled = YES;
//        cell.switchButton.userInteractionEnabled = NO;
//        cell.switchButton.onTintColor = [UIColor darkGrayColor];
    }
    else{
        cell.userInteractionEnabled = YES;
        cell.switchButton.onTintColor = RMC_MAIN_COLOR;
    }
    
    if (self.isToProject) {
        if (indexPath.row == 0 && indexPath.section == 1) {
            //for Share
            cell.userInteractionEnabled = YES;
//            cell.switchButton.tintColor = [UIColor lightGrayColor];
//            cell.switchButton.thumbTintColor = [UIColor lightGrayColor];
        }
    }
    
    WeakObj(self);
    WeakObj(cell);
    cell.actionBlock = ^(BOOL active){
        StrongObj(self);
        StrongObj(cell);
        if (indexPath.section == 1) {
//            if (!self.isToProject && active) {
//
//            }
            if (active) {
                cell.changeLabel.hidden = NO;
                cell.descriptionLabel.hidden = NO;
                cell.descriptionLabel.attributedText = [self.currentWatermarks translateInfoTextUIString];
                self.selectWatermark = YES;
            }else {
                cell.changeLabel.hidden = YES;
                cell.descriptionLabel.hidden = YES;
                self.selectWatermark = NO;
            }
        }
        model.active = active;
        if (self.rightsSelectedBlock) {
            self.rightsSelectedBlock([NXRightsModel convertModelToRights:_rightsModel]);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rightsSelectView:didHeightChanged:)]) {
            NXLRights *currentRights = [NXRightsModel convertModelToRights:_rightsModel];
            if (cell.fileValidityModel) {
                [currentRights setFileValidateDate:cell.fileValidityModel];
            }else{
                if ([_rights getVaildateDateModel]) {
                    [currentRights setFileValidateDate:[_rights getVaildateDateModel]];
                }else{
                    [currentRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
                }
            }
            if (self.selectWatermark) {
                [currentRights setWatermarkString:[self.currentWatermarks translateIntoPolicyString]];
            }
            [self.delegate rightsSelectView:self didRightsSelected:currentRights];
        }
    };
    
    cell.tapChangeBlock = ^(id model,NXRightsSelectCell *cell) {
          StrongObj(self);
        if (cell.model.modelType == MODELTYPEValidity) {
            NXLFileValidateDateModel *dateModel = model;
            NXFileValidityDateChooseViewController *vc = [[NXFileValidityDateChooseViewController alloc] initWithDateModel:dateModel];
            vc.chooseCompBlock = ^(NXLFileValidateDateModel *fileValidityDateModel) {
                cell.descriptionLabel.text = [fileValidityDateModel getValidateDateDescriptionString];
                cell.fileValidityModel = fileValidityDateModel;
                
                if (self.fileValidityChagedBlock) {
                    self.fileValidityChagedBlock(fileValidityDateModel);
                }
            };
            [vc show];
        }
        else if(cell.model.modelType == MODELTYPEOBS)
        {
            // watermark
            NXEditWatermarkView *waterView = [[NXEditWatermarkView alloc]initWithWatermarks:self.currentWatermarks InviteHander:^(NSArray *changedWatermarks) {
                self.currentWatermarks = changedWatermarks;
                cell.descriptionLabel.attributedText = [self.currentWatermarks translateInfoTextUIString];
                if (self.delegate && [self.delegate respondsToSelector:@selector(rightsSelectView:didHeightChanged:)]) {
                    NXLRights *currentRights = [NXRightsModel convertModelToRights:_rightsModel];
                    [currentRights setWatermarkString:[self.currentWatermarks translateIntoPolicyString]];
                    [currentRights setFileValidateDate:cell.fileValidityModel];
                    [self.delegate rightsSelectView:self didRightsSelected:currentRights];
                }
            }];
            [waterView show];
        }
    };
    if (!self.enabled) {
        cell.switchButton.onTintColor = [UIColor darkGrayColor];
        cell.changeLabel.hidden = YES;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return CGSizeMake(collectionView.frame.size.width - 20, 80); //for watermark just make sure it can show all text.
    }else if(indexPath.section == 2) {
         return CGSizeMake(collectionView.frame.size.width - 20, 80);
    }else {
        return CGSizeMake(140, 40);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(300, 45);
    }else if(section == 3){
        return CGSizeMake(collectionView.bounds.size.width, 45);
    }else{
        return CGSizeMake(300, 0);
    }
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context {
    CGFloat newHeight = 0;
    if ([self.rights getRight:NXLRIGHTVIEW]) {
        newHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    } else {
        newHeight = 80;
    }
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightsSelectView:didHeightChanged:)]) {
        [self.delegate rightsSelectView:self didHeightChanged:0.1];
    }
}
- (void)setCurrentMoreOptions:(BOOL)isShowMoreOptions {
    if (isShowMoreOptions) {
        self.moreOptionArray = self.rightsModel.moreOptionArray ;
    }else{
        self.moreOptionArray = [NSArray array];
    }
}
#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    
    NXColllectionViewFlowLayoutout *layout = [[NXColllectionViewFlowLayoutout alloc] init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.maximumInteritemSpacing = 30;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
//    layout.estimatedItemSize = CGSizeMake(80, 40);
//    layout.headerReferenceSize = CGSizeMake(80, 40);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:collectionView];
    
    collectionView.contentInset = UIEdgeInsetsMake(kMargin * 2, 0, 0, 0);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = self.backgroundColor;
    [collectionView registerClass:[NXRightsSelectCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [collectionView registerClass:[NXRightsSelectReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableView];
    [collectionView registerClass:[NXRightsMoreOptionSelectReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMoreOptionView];
    [collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    self.moreOptionArray = [NSArray array];
    UILabel *promptLabel = [[UILabel alloc] init];
    [self addSubview:promptLabel];
    
    promptLabel.text = NSLocalizedString(@"UI_SPECIFY_DIGITAL_RIGHTS", NULL);
    promptLabel.numberOfLines = 0;
    promptLabel.textColor = [UIColor colorWithRed:100/256.0 green:100/256.0 blue:100/256.0 alpha:1];
    promptLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin * 2);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin * 2);
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin);
                make.height.equalTo(@60);
            }];
            
            [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(promptLabel.mas_bottom).offset(kMargin);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin * 1.5);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin * 1.5);
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kMargin * 2);
            }];
           
        }
    }
    else
    {
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kMargin * 2);
            make.right.equalTo(self).offset(-kMargin * 2);
           make.top.equalTo(self).offset(kMargin);
            make.height.equalTo(@60);
        }];
        
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(promptLabel.mas_bottom).offset(kMargin);
            make.left.equalTo(self).offset(kMargin * 2);
            make.right.equalTo(self).offset(kMargin);
            make.bottom.equalTo(self).offset(-kMargin * 2);
        }];
    }
    
    UILabel *noRightsLabel = [[UILabel alloc] init];
    [self addSubview:noRightsLabel];
    
    noRightsLabel.text = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT", NULL);
    noRightsLabel.textAlignment = NSTextAlignmentCenter;
    noRightsLabel.backgroundColor = self.backgroundColor;
    noRightsLabel.hidden = YES;
    [self sendSubviewToBack:noRightsLabel];
    
    [noRightsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@(130));
    }];
    
    _noRightsLabel = noRightsLabel;
    _collectionView = collectionView;
    _promptLabel = promptLabel;
    
//    [_collectionView setBackgroundColor:[UIColor cyanColor]];
//    [promptLabel setBackgroundColor:[UIColor redColor]];
//    [protectUsingDigitalRightsLabel setBackgroundColor:[UIColor orangeColor]];
    
#if 0
    self.backgroundColor = [UIColor blueColor];
    noRightsLabel.backgroundColor = [UIColor redColor];
#endif
}
@end
