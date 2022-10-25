//
//  NXMyVaultCell.m
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultCell.h"

#import "Masonry.h"
#import "HexColor.h"
#import "NXCommonUtils.h"
#import "NXSharePointFolder.h"
#import "AppDelegate.h"

@interface NXMyVaultCell ()<MGSwipeTableCellDelegate>
@end

@implementation NXMyVaultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
        self.allowsOppositeSwipe = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (CGColorEqualToColor(backgroundColor.CGColor, [UIColor colorWithHexString:@"#45a150"].CGColor)) {
//        self.mainTitleLabel.textColor = [UIColor whiteColor];
        self.subDateLabel.textColor = [UIColor whiteColor];
        self.subSizeLabel.textColor = [UIColor whiteColor];
        self.subSharedOnLabel.textColor = [UIColor whiteColor];
        self.subDrivePathLabel.textColor = [UIColor whiteColor];
    } else {
//        self.mainTitleLabel.textColor = [UIColor blackColor];
        self.subSizeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.subDateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.subSharedOnLabel.textColor = [UIColor colorWithHexString:@"#9c9999"];
        self.subDrivePathLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    }
}

- (void)setModel:(NXFileBase *)model {
    _model = model;
    if (![model isKindOfClass:[NXMyVaultFile class]]) {
        return;
    }
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:model];
    switch (state) {
        case NXFileStateNormal:
            [self updateCurrentLayoutForNormal];
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = nil;
            break;
        case NXFileStateOfflined:
        {
            [self updateCurrentLayoutForNormal];
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
        }
            break;
        case NXFileStateConvertingOffline:
        {
            [self updateCurrentLayoutForOffline];
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Updating..."];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:113.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"Updating..."]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
        }
            break;
        case NXFileStateOfflineFailed:
        {
            [self updateCurrentLayoutForOffline];
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Error in downloading file"];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"fa-exclamation-triangle"]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
        }
            break;
        default:
            break;
    }
    
    NXMyVaultFile *fileItem = (NXMyVaultFile *)model;
    _model = fileItem;
    
    if ([fileItem isKindOfClass:[NXFolder class]] ||
        [fileItem isKindOfClass:[NXSharePointFolder class]]) {
        self.mainImageView.image = [UIImage imageNamed:@"folder - black"];
        self.accessoryView = nil;
    } else  {
        NSString *imageName = [NXCommonUtils getImagebyExtension:fileItem.fullPath];
        self.mainImageView.image = [UIImage imageNamed:imageName];
    }
    NSDate *sharededDate = fileItem.lastModifiedDate;
    if (!sharededDate) {
      sharededDate = [NSDate dateWithTimeIntervalSince1970:fileItem.sharedOn.longLongValue];
    }
   
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString* sharedDateString = [dateFormtter stringFromDate:sharededDate];
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:fileItem.size countStyle:NSByteCountFormatterCountStyleBinary];
    [self.topImageView setHidden:NO];
    if (fileItem.isDeleted) {
        NSDictionary *attribtues = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),NSBaselineOffsetAttributeName:@(NSUnderlineStyleNone),
                                    NSForegroundColorAttributeName:[UIColor lightGrayColor]};
        self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:fileItem.name attributes:attribtues];
        self.mainImageView.image = [UIImage imageNamed:@"FileDeleted"];
        self.mainImageView.tintColor = [UIColor grayColor];
        [self.topImageView setHidden:YES];
        
        // if current file was deleted, unmark it
        NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:fileItem];
        if (state != NXFileStateNormal)
        {
            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:fileItem withCompletion:^(NXFileBase *fileItem, NSError *error) {
            }];
        }
    } else if (fileItem.isRevoked) {
        NSDictionary *attribtues = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};
        self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:fileItem.name attributes:attribtues];
        self.mainImageView.image = [UIImage imageNamed:@"FileDeleted"];
        self.mainImageView.tintColor = [UIColor grayColor];
    } else {
        NSDictionary *attribtues = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:fileItem.name attributes:attribtues];
    }
    
    self.mainTitleLabel.accessibilityValue = @"MY_VAULT_FILE_CELL";
    if (self.accessoryView) {
        self.accessoryView.accessibilityValue = @"MY_VAULT_FILE_CELL_ACCESSORY";
        self.accessoryView.accessibilityLabel = @"MY_VAULT_FILE_CELL_ACCESSORY";
    }
    
    
    self.subSizeLabel.text = fileItem.size ? strSize :@"N/A";
    self.subDateLabel.text = sharedDateString;
    
    self.subDrivePathLabel.text = [NSString stringWithFormat:@"%@:%@", fileItem.metaData.sourceRepoName, fileItem.metaData.sourceFilePathDisplay];
    if ([fileItem.metaData.sourceRepoName isEqualToString:@"local"]) {
        self.subDrivePathLabel.text = @"local";
    }

    if (fileItem.metaData == nil) {
         self.subDrivePathLabel.text = [NSString stringWithFormat:@"%@:%@", model.serviceAlias, model.fullPath];
    }
    NSString *sharedWithText;
    if (fileItem.sharedWith.count < 3) {
        sharedWithText = [fileItem.sharedWith componentsJoinedByString:@","];
    } else {
        NSString *userdText = [NSString stringWithFormat:@"%@ , %@",fileItem.sharedWith[0],fileItem.sharedWith[1]];
        sharedWithText = [NSString stringWithFormat:@"%@ and %ld others",userdText,fileItem.sharedWith.count - 2];
    }
    self.subSharedOnLabel.text = sharedWithText;
    self.topImageView.image = model.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
//    [self setSwipeButtons];
}

- (void)setSwipeButtons {
    WeakObj(self);
    MGSwipeButton *logButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_LOG",NULL) backgroundColor:RMC_SUB_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeActiveLog);
        return YES;
    }];
    logButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [logButton setButtonWidth:80.0];
    MGSwipeButton *manageButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) backgroundColor:RMC_MAIN_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeManage);
        return YES;
    }];
    manageButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [manageButton setButtonWidth:80.0];

    MGSwipeButton *shareButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_COM_SHARE", NULL) backgroundColor:RMC_MAIN_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeShare);
        return YES;
    }];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [shareButton setButtonWidth:80.0];
    
    if ([self.model isKindOfClass:[NXMyVaultFile class]]) {
        NXMyVaultFile *fileItem = (NXMyVaultFile *)self.model;
        if (fileItem.isDeleted) {
            if(fileItem.isShared){
                //            self.leftButtons = @[];
                self.rightButtons = @[logButton, manageButton];
            }else{
                self.rightButtons = @[logButton];
            }
        }else {
            if (fileItem.isShared) {
                self.rightButtons = @[logButton, manageButton];
                
            }else{
                self.rightButtons = @[logButton, shareButton];
                
            }
        }
    }
}

#pragma mark - MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    if (direction == MGSwipeDirectionLeftToRight) {
        return  NO;
    } else {
        return YES;
    }
}

-(BOOL)swipeTableCell:(nonnull MGSwipeTableCell *)cell shouldHideSwipeOnTap:(CGPoint) point {
    return YES;
}

- (void)swipeTableCellWillEndSwiping:(MGSwipeTableCell *)cell {
    cell.allowsOppositeSwipe = NO;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (DELEGATE_HAS_METHOD(self.swipeDelegate, @selector(nxfileItemWillEndSwiping:))) {
        [self.swipeDelegate nxfileItemWillEndSwiping:(NXMyVaultCell *)cell];
    }
}

- (void)swipeTableCellWillBeginSwiping:(MGSwipeTableCell *)cell {
    cell.allowsOppositeSwipe = NO;
    if (cell.swipeOffset > 0) {
        cell.backgroundColor = [UIColor colorWithHexString:@"#45a150"];
    }
    if (cell.swipeOffset < 0) {
        cell.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    }
    
    if (DELEGATE_HAS_METHOD(self.swipeDelegate, @selector(nxfileItemWillBeginSwiping:))) {
        [self.swipeDelegate nxfileItemWillBeginSwiping:(NXMyVaultCell *)cell];
    }
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    //file icon
    UIImageView *mainImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mainImageView];
    
    //favorite icon
    UIImageView *topImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:topImageView];
    
    //offline icon
    UIImageView *bottomImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:bottomImageView];
    
    UILabel *mainLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainLabel];
    
    UILabel *subDateLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subDateLabel];
    
    UILabel *subSizeLabel = [[UILabel alloc] init];
    [self.contentView addSubview: subSizeLabel];
    
    UILabel *drivePathLabel = [[UILabel alloc] init];
    [self.contentView addSubview:drivePathLabel];
    
    UILabel *sharedonLabel = [[UILabel alloc] init];
    [self.contentView addSubview:sharedonLabel];
    
    //  file state icon
    UIImageView *fileStateImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:fileStateImageView];
    
    UILabel *fileStateTipsLabel = [[UILabel alloc] init];
    [self.contentView addSubview:fileStateTipsLabel];
    
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    fileStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    fileStateImageView.backgroundColor = [UIColor clearColor];
    topImageView.translatesAutoresizingMaskIntoConstraints = NO;

    mainLabel.font = [UIFont systemFontOfSize:18];
    mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainLabel.numberOfLines = 1;
    
    sharedonLabel.numberOfLines = 0;
    mainLabel.attributedText = nil;
    
    subSizeLabel.textColor = [UIColor colorWithHexString:@"#9c9999"];
    subSizeLabel.font = [UIFont boldSystemFontOfSize:12];
    
    subDateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    subDateLabel.font = [UIFont systemFontOfSize:12];
    
    sharedonLabel.textColor = [UIColor colorWithHexString:@"999999"];
    sharedonLabel.font = [UIFont systemFontOfSize:12];
    sharedonLabel.numberOfLines = 0;
    
    drivePathLabel.textColor = [UIColor colorWithHexString:@"999999"];
    drivePathLabel.font = [UIFont systemFontOfSize:12];
    drivePathLabel.numberOfLines = 0;
    
//  fileStateTipsLabel.textColor = [UIColor colorWithHexString:@"999999"];
    fileStateTipsLabel.font = [UIFont systemFontOfSize:8];
    fileStateTipsLabel.numberOfLines = 0;
    
    _mainImageView = mainImageView;
    _mainTitleLabel = mainLabel;
    _topImageView = topImageView;
    _bottomImageView = bottomImageView;
    _fileStateImageView = fileStateImageView;
    _fileStateTipsLabel = fileStateTipsLabel;
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    // UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    moreButton.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.backgroundColor = [UIColor clearColor];
    [moreButton setImage:[UIImage imageNamed:@"ellipsis - gray"] forState:UIControlStateNormal];
    moreButton.accessibilityValue = @"FILE_CELL_ELLIPSIS_BTN";
     moreButton.accessibilityLabel = @"FILE_CELL_ELLIPSIS_BTN";
    [moreButton addTarget:self action:@selector(singleTapAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.userInteractionEnabled = YES;
    _moreButton = moreButton;
    self.accessoryView = self.moreButton;
    
    //[self.accessoryView setBackgroundColor:[UIColor redColor]];
    
    _subDrivePathLabel = drivePathLabel;
    _subSharedOnLabel = sharedonLabel;
    
    _subSizeLabel = subSizeLabel;
    _subDateLabel = subDateLabel;
    
    self.delegate = self;
    self.allowsOppositeSwipe = NO;
    
    [mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(mainImageView.mas_height);
    }];
    
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainImageView).offset(-4);
        make.right.equalTo(mainImageView).offset(4);
        make.width.equalTo(mainImageView).multipliedBy(0.5);
        make.height.equalTo(topImageView.mas_width);
    }];
    
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(mainImageView).offset(4);
        make.right.equalTo(mainImageView).offset(4);
        make.width.equalTo(mainImageView).multipliedBy(0.5);
        make.height.equalTo(bottomImageView.mas_width);
    }];
    
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mainImageView.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(4);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [subSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLabel.mas_bottom).offset(4);
        make.left.equalTo(mainLabel);
    }];
    
    [subDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subSizeLabel);
//      make.left.equalTo(subSizeLabel.mas_right).offset(4);
        make.right.equalTo(mainLabel);
        make.width.equalTo(subSizeLabel);
    }];
    
    [drivePathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subSizeLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(mainLabel);
    }];
    
    [sharedonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(drivePathLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(mainLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
    
//    [self.fileStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.subSharedOnLabel.mas_bottom);
//        make.left.and.right.equalTo(self.mainTitleLabel);
//        make.height.equalTo(@(1));
//    }];
//
//    [self.fileStateTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.subSharedOnLabel.mas_bottom);
//        make.left.and.right.equalTo(self.mainTitleLabel);
//        make.height.equalTo(@(1));
//    }];
}

- (void)updateCurrentLayoutForNormal
{
    [self.fileStateTipsLabel setHidden:YES];
    [self.fileStateImageView setHidden:YES];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(self.mainImageView.mas_height);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainImageView).offset(-4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.topImageView.mas_width);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainImageView).offset(4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.bottomImageView.mas_width);
    }];
    
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(4);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.mainTitleLabel);
    }];
    
    [self.subDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel);
        //      make.left.equalTo(subSizeLabel.mas_right).offset(4);
        make.right.equalTo(self.mainTitleLabel);
        make.width.equalTo(self.subSizeLabel);
    }];
    
    [self.subDrivePathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(self.mainTitleLabel);
    }];
    
    [self.subSharedOnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subDrivePathLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
    
    [self.fileStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSharedOnLabel.mas_bottom);
        make.left.and.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(@(1));
    }];
    
    [self.fileStateTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSharedOnLabel.mas_bottom);
        make.left.and.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(@(1));
    }];
}

- (void)updateCurrentLayoutForOffline
{
    [self.fileStateTipsLabel setHidden:NO];
    [self.fileStateImageView setHidden:NO];
    
    [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(self.mainImageView.mas_height);
    }];
    
    [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainImageView).offset(-4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.topImageView.mas_width);
    }];
    
    [self.bottomImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainImageView).offset(4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.bottomImageView.mas_width);
    }];
    
    [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(4);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.mainTitleLabel);
    }];
    
    [self.subDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel);
        //      make.left.equalTo(subSizeLabel.mas_right).offset(4);
        make.right.equalTo(self.mainTitleLabel);
        make.width.equalTo(self.subSizeLabel);
    }];
    
    [self.subDrivePathLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(self.mainTitleLabel);
    }];
    
    [self.subSharedOnLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subDrivePathLabel.mas_bottom).offset(4);
        make.left.and.right.equalTo(self.mainTitleLabel);
        //make.bottom.equalTo(self.contentView).offset(-4);
    }];
    
    [self.fileStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSharedOnLabel.mas_bottom).offset(2);
        make.left.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
        make.width.height.equalTo(@(9));
    }];
    
    [self.fileStateTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSharedOnLabel.mas_bottom).offset(2);
        make.left.equalTo(self.fileStateImageView).offset(14);
        make.right.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
}

-(void)singleTapAction:(id)sender
{
    if (DELEGATE_HAS_METHOD(self.myVaultCellDelegate, @selector(onClickMoreButton:))) {
       [self.myVaultCellDelegate onClickMoreButton:(NXMyVaultFile *)self.model];
    }
    if (self.accessBlock) {
        self.accessBlock(self.model);
    }
}

@end
