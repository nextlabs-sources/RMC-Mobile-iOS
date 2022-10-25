//
//  NXProjectSearchResultVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/12/4.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXProjectSearchResultVC.h"
#import "Masonry.h"
#import "NXInviteMessageCell.h"
#import "NXAllProjectDetailCell.h"
#import "NXRMCDef.h"
#import "NXProjectModel.h"
#import "NXPendingProjectInvitationModel.h"

@interface NXProjectSearchResultVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *noSerchResultsTipsView;
@property (nonatomic, strong) NSMutableArray *byMeArray;
@property (nonatomic, strong) NSMutableArray *byOtherArray;
@property (nonatomic, strong) NSMutableArray *byPendingArray;
@property (nonatomic, strong) NSMutableArray *projectDicArray;
@end

@implementation NXProjectSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    
    
}
- (void)updateData {
    if (self.dataArray.count == 0) {
        [self.noSerchResultsTipsView setHidden:NO];
        return;
    }
    else
    {
        [self.noSerchResultsTipsView setHidden:YES];
    }
    self.byMeArray = [NSMutableArray array];
    self.byOtherArray = [NSMutableArray array];
    self.byPendingArray = [NSMutableArray array];
    
    for (id item in self.dataArray) {
        if ([item isKindOfClass:[NXPendingProjectInvitationModel class]]) {
            [self.byPendingArray addObject:item];
        }else if ([item isKindOfClass:[NXProjectModel class]]) {
            NXProjectModel *model = (NXProjectModel *)item;
            if (model.isOwnedByMe) {
                [self.byMeArray  addObject:model];
            } else {
                [self.byOtherArray addObject:model];
            }
        }
    }
    NSMutableArray *projectDicArray = [NSMutableArray array];
    if (self.byPendingArray.count > 0) {
        NSDictionary *dic = @{@"pending":self.byPendingArray}.copy;
        [projectDicArray addObject:dic];
    }
    if (self.byMeArray.count > 0) {
        NSDictionary *dic = @{@"byMe":self.byMeArray}.copy;
        [projectDicArray addObject:dic];
    }
        
    if (self.byOtherArray.count > 0) {
        NSDictionary *dic = @{@"byOther":self.byOtherArray}.copy;
        [projectDicArray addObject:dic];
    }
    self.projectDicArray = projectDicArray;
    [self.collectionView reloadData];
}
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(20,0,20,0);
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[NXInviteMessageCell class] forCellWithReuseIdentifier:@"PendingCell"];
    [collectionView registerClass:[NXAllProjectDetailCell class] forCellWithReuseIdentifier:@"ProjectCell"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    
    UIView *noSearchResultView = [[UIView alloc] initWithFrame:self.view.bounds];
    noSearchResultView.backgroundColor = [UIColor whiteColor];
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, 55.0)];
    tipsLabel.text = @"No search results";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:20];
    tipsLabel.textColor = [UIColor grayColor];
    [noSearchResultView addSubview:tipsLabel];
    [self.view addSubview:noSearchResultView];
    
    self.noSerchResultsTipsView = noSearchResultView;
    [self.noSerchResultsTipsView setHidden:YES];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.self.view.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else {
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    [self.noSerchResultsTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@55);
        make.center.equalTo(self.view);
    }];
}
#pragma mark ---- > collectionView delegate and dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.projectDicArray.count;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *dic = self.projectDicArray[section];
    NSString *key = [dic allKeys].firstObject;
    NSArray *projectArray = dic[key];
    return projectArray.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(5, 0, 300, 30);
    label.backgroundColor = self.view.backgroundColor;
    [header addSubview:label];
    if ([key isEqualToString:@"pending"]) {
        label.frame = CGRectZero;
    }else if ([key isEqualToString:@"byMe"]) {
        NSString *meStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_ME", NULL);
        label.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_CREATED", NULL) subTitle1:[NSString stringWithFormat:@" %@",meStr] subTitle2:[NSString stringWithFormat:@" (%ld)", self.byMeArray.count]];
    }else if ([key isEqualToString:@"byOther"]) {
        NSString *otherStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_OTHER", NULL);
        label.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_INVITED", NULL) subTitle1:[NSString stringWithFormat:@" %@",otherStr] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byOtherArray.count]];
    }
    return header;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        NXInviteMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PendingCell" forIndexPath:indexPath];
        NXPendingProjectInvitationModel *invitation = self.byPendingArray[indexPath.row];
        cell.model = invitation;
        cell.clickAcceptFinishedBlock = ^(NSError *err) {
            if (_delegate && [_delegate respondsToSelector:@selector(projectListResultVC:didClickPendingAcceptButton:)]) {
                [self.delegate projectListResultVC:self didClickPendingAcceptButton:invitation];
            }
            if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
                [self.resignActiveDelegate searchVCShouldResignActive];
            }
          
        };
        cell.clickIgnoreFinishedBlock = ^(NSError *err) {
            if (_delegate && [_delegate respondsToSelector:@selector(projectListResultVC:didClickPendingDeclineAccessButton:)]) {
                [self.delegate projectListResultVC:self didClickPendingDeclineAccessButton:invitation];
            }
            if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
                [self.resignActiveDelegate searchVCShouldResignActive];
            }
        };
        return cell;
    }

    NXAllProjectDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectCell" forIndexPath:indexPath];
    if ([key isEqualToString:@"byMe"]) {
        cell.model = self.byMeArray[indexPath.row];
    }else {
        cell.model = self.byOtherArray[indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.projectDicArray[section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        return CGSizeZero;
    }else {
        return CGSizeMake(collectionView.bounds.size.width, 30);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        return CGSizeMake(collectionView.bounds.size.width, 100);
    }else {
        return CGSizeMake(collectionView.bounds.size.width, 80);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        return;
    }else {
        NSArray *projectArray = dic[key];
        NXProjectModel *model = projectArray[indexPath.row];
        if (_delegate && [_delegate respondsToSelector:@selector(projectListResultVC:didSelectItem:)]) {
            [self.delegate projectListResultVC:self didSelectItem:model];
        }
        if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
            [self.resignActiveDelegate searchVCShouldResignActive];
        }
    }
    
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 subTitle2:(NSString *)subTitle2 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    NSAttributedString *sub2 ;
    if (subTitle2) {
        sub2 = [[NSMutableAttributedString alloc] initWithString:subTitle2 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    }
    
    [myprojects appendAttributedString:sub1];
    [myprojects appendAttributedString:sub2];
    return myprojects;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
