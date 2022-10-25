//
//  NXFileItemCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXFileItemCell.h"

//#import "NXFileOperationToolBar.h"

#import "NXFile.h"
#import "NXFolder.h"
#import "NXSharePointFolder.h"
#import "NXSharePointFile.h"
#import "NXWebFileManager.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "NXSharedWorkspaceFile.h"
#import "UIButton+Extensions.h"
#import "Masonry.h"

@interface NXFileItemCell()<MGSwipeTableCellDelegate /*NXFileOperationToolBarDelegate*/>

@property(nonatomic, weak) UIImageView *mainImageView;
//@property(nonatomic, weak) UIImageView *bottomImageView;

@property(nonatomic, weak) UILabel *mainTitleLabel;
@property(nonatomic, weak) UILabel *subTypeLabel;
@property(nonatomic, weak) UILabel *subSizeLabel;
@property(nonatomic, weak) UILabel *subDateLabel;
@property(nonatomic, weak) UILabel *fileStateTipsLabel;
@property(nonatomic, weak) UIImageView *fileStateImageView;

//@property(nonatomic, weak, readonly) MGSwipeButton *favButton;
//@property(nonatomic, weak, readonly) MGSwipeButton *offButton;

@end

@implementation NXFileItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
        self.allowsOppositeSwipe = NO;
        self.shouldShowSwipe = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        self.allowsOppositeSwipe = NO;
        self.shouldShowSwipe = YES;
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

- (void)dealloc {
//    [self.model removeObserver:self forKeyPath:@"isFavorite"];
//    [self.model removeObserver:self forKeyPath:@"isOffline"];
}
#pragma mark 

- (void)accessViewClicked:(id)sender {
    if (self.accessBlock) {
        self.accessBlock(sender);
    }
}

#pragma mark - setter

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (CGColorEqualToColor(backgroundColor.CGColor, [UIColor colorWithHexString:@"#45a150"].CGColor)) {
        self.mainTitleLabel.textColor = [UIColor whiteColor];
        self.subDateLabel.textColor = [UIColor whiteColor];
        self.subSizeLabel.textColor = [UIColor whiteColor];
        self.subTypeLabel.textColor = [UIColor whiteColor];
    } else {
        self.mainTitleLabel.textColor = [UIColor blackColor];
        self.subDateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.subSizeLabel.textColor = [UIColor colorWithHexString:@"#9c9999"];
        self.subTypeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    }
}

- (void)setModel:(NXFileBase *)model {
//    // break the observer of old model, in case APP crash for modal dealloc but still registered model's KVO
//    [self.model removeObserver:self forKeyPath:@"isFavorite"];
//    [self.model removeObserver:self forKeyPath:@"isOffline"];
    _model = model;
    if ([model isKindOfClass:[NXFolder class]] ||
        [model isKindOfClass:[NXSharePointFolder class]] || [model isKindOfClass:[NXSharedWorkspaceFolder class]]) {
        self.mainImageView.image = [UIImage imageNamed:@"folder - black"];
    } else  {
        NSString *imageName = [NXCommonUtils getImagebyExtension:model.fullPath ? model.fullPath : model.name];
        self.mainImageView.image = [UIImage imageNamed:imageName];
        self.bottomImageView.image = model.isOffline ? [UIImage imageNamed:@"offline file"] : nil;
    }
    self.accessoryView = self.accessButton;
    if ((model.serviceType.integerValue == kServiceSkyDrmBox) ||
        [model isKindOfClass:[NXFile class]]||
        [model isKindOfClass:[NXSharePointFile class]] ||
        [model isKindOfClass:[NXProjectFolder class]]) {
        self.accessButton.hidden = NO;
    } else {
        self.accessButton.hidden = YES;
    }
    
//    [model addObserver:self forKeyPath:@"isOffline" options:NSKeyValueObservingOptionNew context:nil];
//    [model addObserver:self forKeyPath:@"isFavorite" options:NSKeyValueObservingOptionNew context:nil];
    
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateStyle:NSDateFormatterShortStyle];
    [dateFormtter setTimeStyle:NSDateFormatterFullStyle];

    NSDate * modifyDate = nil;
    
//    if ([model isKindOfClass:[NXProjectFile class]]|| [model isKindOfClass:[NXProjectFolder class]]) {
//        [self.subTypeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(kMargin);
//            make.bottom.equalTo(self.contentView).offset(-kMargin);
//            make.width.equalTo(@2);
//            make.left.equalTo(self.mainTitleLabel);
//        }];
//    }
    modifyDate = model.lastModifiedDate;
    NSString* modifyDateString = nil;
    if (modifyDate) {
        [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        modifyDateString = [dateFormtter stringFromDate:modifyDate];
    }
    
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    
    self.mainTitleLabel.text = model.name;
    if (![model isKindOfClass:[NXFolder class]] && ![model isKindOfClass:[NXSharePointFolder class]]) {
         self.subSizeLabel.text = model.size ? strSize :@"N/A";
        
        NSString *fileExtension = model.name.pathExtension;
        if ((!fileExtension || fileExtension.length == 0) && model.serviceType.integerValue == kServiceSkyDrmBox) {
           self.subSizeLabel.text = @"N/A";
        }
    }else {
        self.subSizeLabel.text = @"";
    }
    self.subDateLabel.text = modifyDateString ? modifyDateString : @" ";
//    self.subTypeLabel.text = model.serviceAlias;
    self.topImageView.image = model.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
    
//    [self setSwipeButtons];
}

- (void)setSwipeButtons {

    if (!self.shouldShowSwipe) {
        return;
    }

    if ([self.model isKindOfClass:[NXFolder class]] ||
        [self.model isKindOfClass:[NXSharePointFolder class]]) {
        return;
    }
    
    NSString *extension = [self.model.name pathExtension];
    NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
    
    WeakObj(self);
    MGSwipeButton *shareButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_COM_SHARE", NULL) icon:nil backgroundColor:RMC_MAIN_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeShare);
        return YES;
    }];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    BOOL isNXL = [markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame;
    BOOL isMyDrive = self.model.serviceType.integerValue == kServiceSkyDrmBox;
    if (isNXL && isMyDrive) {
        MGSwipeButton *logButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_LOG", NULL) icon:nil backgroundColor:RMC_SUB_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            self.swipeButtonBlock(SwipeButtonTypeActiveLog);
            return YES;
        }];
        logButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.rightButtons = @[logButton, shareButton];
    } else if (isNXL && !isMyDrive) {
        self.rightButtons = @[shareButton];
    } else {
        MGSwipeButton *protectButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) icon:nil backgroundColor:RMC_SUB_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            self.swipeButtonBlock(SwipeButtonTypeProtect);
            return YES;
        }];
        protectButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.rightButtons = @[protectButton, shareButton];
    }
}

//#pragma mark
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id> *)change context:(void *)context {
//    NXFileBase *item = (NXFileBase *)object;
//    
//    if ([keyPath isEqualToString:@"isFavorite"]) {
//        self.topImageView.image = item.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
//    }
//    if ([keyPath isEqualToString:@"isOffline"]) {
//        if (item.isOffline) {
//            if ([[NXWebFileManager sharedInstance] isFileCached:self.model]) {
//                self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
//                
//            }else{
//                self.bottomImageView.image = [UIImage imageNamed:@"Loading"];
//                // dirty code, should not call download file here, but I can't find any other way to start
//                if (![[NXWebFileManager sharedInstance] isFileDownloading:item]) {
//                    WeakObj(self);
//                    [[NXWebFileManager sharedInstance] downloadFile:item withProgress:nil isOffline:YES completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
//                        StrongObj(self);
//                        if (self) {
//                            if ([item isEqual:file] && fileData) {
//                               // dispatch_main_async_safe(^{
//                                    self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
//                              //  });
//                            }
//                        }
//                    }];
//                }
//            }
//        }else{
//            self.bottomImageView.image =nil;
//            // dity code
//            [[NXWebFileManager sharedInstance] unmarkFileAsOffine:item];
//        }
//    }
//}

#pragma mark - MGSwipeTableCellDelegate
-(BOOL)swipeTableCell:(nonnull MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction fromPoint:(CGPoint) point {
    if (direction == MGSwipeDirectionLeftToRight) {
        return NO;
    }
    
    if (direction == MGSwipeDirectionRightToLeft) {
        if ([self.model isKindOfClass:[NXFolder class]] ||
            [self.model isKindOfClass:[NXSharePointFolder class]]) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

-(BOOL)swipeTableCell:(nonnull MGSwipeTableCell *)cell shouldHideSwipeOnTap:(CGPoint) point {
    return YES;
}

- (void)swipeTableCellWillEndSwiping:(MGSwipeTableCell *)cell {
    cell.allowsOppositeSwipe = NO;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (DELEGATE_HAS_METHOD(self.swipeDelegate, @selector(nxfileItemWillEndSwiping:))) {
        [self.swipeDelegate nxfileItemWillEndSwiping:(NXFileItemCell *)cell];
    }
}

- (void)swipeTableCellWillBeginSwiping:(MGSwipeTableCell *)cell {
    cell.allowsOppositeSwipe = NO;
    if (cell.swipeOffset > 0) {
        cell.backgroundColor = [UIColor colorWithHexString:@"#45a150"];
    }
    if (cell.swipeOffset < 0) {
//        cell.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
          cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (DELEGATE_HAS_METHOD(self.swipeDelegate, @selector(nxfileItemWillBeginSwiping:))) {
        [self.swipeDelegate nxfileItemWillBeginSwiping:(NXFileItemCell *)cell];
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
    mainLabel.accessibilityValue = @"FILE_CELL_TITLE";
   
    UILabel *subTypeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subTypeLabel];
    
    
    UILabel *subSizeLabel = [[UILabel alloc] init];
    [self.contentView addSubview: subSizeLabel];
    
    UILabel *subDateLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subDateLabel];
    
    UIButton *accessButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.accessoryView = accessButton;
    accessButton.accessibilityValue = @"FILE_CELL_ACCESS_BTN";
    //  file state icon
    UIImageView *fileStateImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:fileStateImageView];
    
    UILabel *fileStateTipsLabel = [[UILabel alloc] init];
    [self.contentView addSubview:fileStateTipsLabel];
    
    [accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    accessButton.contentMode = UIViewContentModeScaleAspectFit;
    [accessButton addTarget:self action:@selector(accessViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [accessButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    fileStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    fileStateImageView.backgroundColor = [UIColor clearColor];
    
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    topImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.font = [UIFont systemFontOfSize:16];
    mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainLabel.numberOfLines = 1;
    
    subTypeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    subTypeLabel.font = [UIFont systemFontOfSize:12];
    subTypeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    subSizeLabel.textColor = [UIColor colorWithHexString:@"#9c9999"];
    subSizeLabel.font = [UIFont boldSystemFontOfSize:12];
    
    subDateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    subDateLabel.font = [UIFont systemFontOfSize:12];
    
    fileStateTipsLabel.textColor = [UIColor colorWithHexString:@"999999"];
    fileStateTipsLabel.font = [UIFont systemFontOfSize:8];
    fileStateTipsLabel.numberOfLines = 0;
    
    self.mainImageView = mainImageView;
    self.topImageView = topImageView;
    self.bottomImageView = bottomImageView;
    self.mainTitleLabel = mainLabel;
    self.fileStateImageView = fileStateImageView;
    self.fileStateTipsLabel = fileStateTipsLabel;
    
    self.subTypeLabel = subTypeLabel;
    self.subSizeLabel = subSizeLabel;
    self.subDateLabel = subDateLabel;
    
    self.accessButton  = accessButton;
    
    //
    self.delegate = self;
    self.allowsOppositeSwipe = NO;
    
    [mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(kFileIconWidth));
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
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(mainImageView.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-8);
    }];

    [subTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLabel.mas_bottom).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.width.equalTo(@0);
        make.left.equalTo(mainLabel);
    }];

    [subSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subTypeLabel);
        make.left.equalTo(subTypeLabel.mas_right).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);

    }];

    [subDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLabel.mas_bottom).offset(kMargin);
        make.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(subSizeLabel);

    }];
}

-(void)updateUIForNormal
{
    [self.subTypeLabel setHidden:NO];
    [self.fileStateTipsLabel setHidden:YES];
    [self.fileStateImageView setHidden:YES];
    
    [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(kFileIconWidth));
        make.width.equalTo(self.mainImageView.mas_height);
    }];
    
    [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainImageView).offset(-4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.mainImageView.mas_width);
    }];
    
    [self.bottomImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainImageView).offset(4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.bottomImageView.mas_width);
    }];
    
    [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(self.mainImageView.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subTypeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.width.equalTo(@2);
        make.left.equalTo(self.mainTitleLabel);
    }];
    
    [self.subSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTypeLabel);
        make.left.equalTo(self.subTypeLabel.mas_right).offset(kMargin);
        make.height.equalTo(self.subTypeLabel);
    }];
    
    [self.subDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTypeLabel);
        make.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(self.subTypeLabel);
        
    }];
    
    [self.fileStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTypeLabel.mas_bottom);
        make.left.and.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(@(1));
    }];
    
    [self.fileStateTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTypeLabel.mas_bottom);
        make.left.and.right.equalTo(self.mainTitleLabel);
        make.height.equalTo(@(1));
    }];
}

- (void)updateUIForOffline
{
    [self.subTypeLabel setHidden:YES];
    [self.fileStateTipsLabel setHidden:NO];
    [self.fileStateImageView setHidden:NO];
    
    [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(kFileIconWidth));
        make.width.equalTo(self.mainImageView.mas_height);
    }];
    
    [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainImageView).offset(-4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.mainImageView.mas_width);
    }];
    
    [self.bottomImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainImageView).offset(4);
        make.right.equalTo(self.mainImageView).offset(4);
        make.width.equalTo(self.mainImageView).multipliedBy(0.5);
        make.height.equalTo(self.bottomImageView.mas_width);
    }];
    
    [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(self.mainImageView.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(kMargin/4);
        make.left.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.fileStateImageView.mas_top);
    }];
    
    [self.subDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel);
        make.right.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.fileStateImageView.mas_top);
    }];
    
    [self.fileStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel.mas_bottom);
        make.left.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
        make.width.height.equalTo(@(9));
    }];
    
    [self.fileStateTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subSizeLabel.mas_bottom);
        make.left.equalTo(self.fileStateImageView).offset(14);
        make.right.equalTo(self.mainTitleLabel);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
}
@end
