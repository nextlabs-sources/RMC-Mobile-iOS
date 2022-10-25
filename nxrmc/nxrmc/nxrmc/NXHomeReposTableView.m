//
//  NXHomeReposTableView.m
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXHomeReposTableView.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXCommonUtils.h"

@interface NXHomeReposTableView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSDictionary *repoIconDict;

@end

@implementation NXHomeReposTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self commonInit];
        _dataArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
#pragma mark
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self reloadData];
}

#pragma mark
- (NSDictionary *)repoIconDict {
    if (!_repoIconDict) {
        _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                          [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                          [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                          [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                          [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - black"],
                          
        };
    }
    return _repoIconDict;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.tintColor = [UIColor blueColor];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NXRepositoryModel *service = self.dataArray[indexPath.row];
    cell.textLabel.text = service.service_account;
    cell.imageView.image = self.repoIconDict[service.service_type];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = self.dataArray[indexPath.row];
    if (self.selectBlock) {
        self.selectBlock(object);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeMake(15, 15);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark
- (void)commonInit {
    self.dataSource = self;
    self.delegate = self;
    self.scrollEnabled = NO;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cellLayoutMarginsFollowReadableWidth = NO;
}
@end
