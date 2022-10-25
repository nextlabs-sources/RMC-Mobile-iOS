//
//  NXFileChooseTableViewCell.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileChooseTableViewCell.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "HexColor.h"
#import "Masonry.h"
#import "NXRMCUIDef.h"
#import "NXCommonUtils.h"
#import "NXWebFileManager.h"

@interface NXFileChooseTableViewCell()
@property(nonatomic, weak) UIImageView *mainImageView;
@property(nonatomic, weak) UIImageView *topImageView;
@property(nonatomic, weak) UIImageView *bottomImageView;

@property(nonatomic, weak) UILabel *mainTitleLabel;
@property(nonatomic, weak) UILabel *subTypeLabel;
@property(nonatomic, weak) UILabel *subSizeLabel;
@property(nonatomic, weak) UILabel *subDateLabel;


@end

@implementation NXFileChooseTableViewCell
#pragma mark - INIT
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
        _cellType = NXFileChooseTableViewCellTypeChooseFile;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChooseChanged:) name:NOTIFICATION_FILE_CHOOSE_CHANGED object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        _cellType = NXFileChooseTableViewCellTypeChooseFile;
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChooseChanged:) name:NOTIFICATION_FILE_CHOOSE_CHANGED object:nil];
    }
    return self;
}

- (void)fileChooseChanged:(NSNotification *)notification
{
    NXFileBase *fileItem = notification.userInfo[@"model"];
    if ([fileItem.fullServicePath isEqualToString:self.model.fullServicePath] && self.cellType == NXFileChooseTableViewCellTypeChooseFile) {
        self.selectedImageView.image = [UIImage imageNamed:@"repo selected - green"];
    }else{
        self.selectedImageView.image = [UIImage imageNamed:@"repo selected - black"];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)isShowSelectedRightImage:(BOOL)isShow{
    if (isShow) {
        self.selectedImageView.image = [UIImage imageNamed:@"repo selected - green"];
    }else{
        self.selectedImageView.image = [UIImage imageNamed:@"repo selected - black"];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
  
//    if([self.model isKindOfClass:[NXFile class]] && self.cellType == NXFileChooseTableViewCellTypeChooseFile){
//        if (selected) {
//            self.selectedImageView.image = [UIImage imageNamed:@"repo selected - green"];
//        }else{
//            self.selectedImageView.image = [UIImage imageNamed:@"repo selected - black"];
//        }
//        self.accessoryView = self.selectedImageView;
//       
//    }
    
}
#pragma mark - Setter
- (void)setModel:(NXFileBase *)model
{
    self.isSelected = NO;
    [self isShowSelectedRightImage:NO];
    self.mainImageView.image = nil;
    self.topImageView.image = nil;
    self.mainTitleLabel.text = @"";
    self.subSizeLabel.text = @"";
    self.subTypeLabel.text = @"";
    self.subDateLabel.text = @"";
    
    _model = [model copy];
    if([model isKindOfClass:[NXFolder class]]){
        self.mainImageView.image = [UIImage imageNamed:@"folder - black"];
        self.accessoryView = nil;
    }else{
        if (self.cellType == NXFileChooseTableViewCellTypeChooseFile) {
            if (self.isSelected || model.isSelected) {
                self.selectedImageView.image = [UIImage imageNamed:@"repo selected - green"];
            }else{
                self.selectedImageView.image = [UIImage imageNamed:@"repo selected - black"];

            }
        }
        NSString *imageName = [NXCommonUtils getImagebyExtension:model.fullPath];
        self.mainImageView.image = [UIImage imageNamed:imageName];
        self.accessoryView = self.selectedImageView;
    }
    
    
    //favorite
    if (FAVORITE_ON) {
        if (model.isFavorite) {
            self.topImageView.image = [UIImage imageNamed:@"faved file"];
        } else {
            self.topImageView.image = nil;
        }
    }
    
    if (OFFLINE_ON) {
        //offline
        if (model.isOffline) {
            if ([[NXWebFileManager sharedInstance] isFileCached:model]) {
                self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
                
            }else{
                self.bottomImageView.image = [UIImage imageNamed:@"Loading"];
                // dirty code, should not call download file here, but I can't find any other way to start
                if (![[NXWebFileManager sharedInstance] isFileDownloading:model]) {
                    WeakObj(self);
                    [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)model withProgress:nil isOffline:YES forOffline:YES completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                        StrongObj(self);
                        if (self) {
                            if ([self.model isEqual:file] && fileData) {
                                self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
                            }
                        }
                    }];
                }
            }
            
        } else {
            self.bottomImageView.image = nil;
        }
    }
    
    // file detail
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateStyle:NSDateFormatterShortStyle];
    [dateFormtter setTimeStyle:NSDateFormatterFullStyle];
    
    NSDate * modifyDate = nil;
    modifyDate = [dateFormtter dateFromString:model.lastModifiedTime];
    
    NSString* modifyDateString = nil;
    if (modifyDate) {
        [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        modifyDateString = [dateFormtter stringFromDate:modifyDate];
    }
    
    NSArray *date = [modifyDateString componentsSeparatedByString:@","];
    if (date.count) {
        modifyDateString = [date objectAtIndex:0];
    }
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    
    self.mainTitleLabel.text = model.name;
    self.subDateLabel.text = modifyDateString ? modifyDateString : @" ";
    self.subTypeLabel.text = model.serviceAlias;
    
    if ([model isKindOfClass:[NXFolder class]]) {
         self.subSizeLabel.text = @"";
    }
    else
    {
         self.subSizeLabel.text = strSize;
    }
    
    if (self.cellType == NXFileChooseTableViewCellTypeChooseFolder) {
        if ([self.model isKindOfClass:[NXFile class]]) {
            self.mainTitleLabel.textColor = [UIColor groupTableViewBackgroundColor];
            self.subSizeLabel.textColor = [UIColor groupTableViewBackgroundColor];
            self.subDateLabel.textColor = [UIColor groupTableViewBackgroundColor];
            self.subTypeLabel.textColor = [UIColor groupTableViewBackgroundColor];
        }
        else
        {
            self.mainTitleLabel.textColor = [UIColor blackColor];
            self.subSizeLabel.textColor = [UIColor blackColor];
            self.subDateLabel.textColor = [UIColor blackColor];
            self.subTypeLabel.textColor = [UIColor blackColor];
        }
        self.selectedImageView.hidden = YES;
    }
}
#pragma mark - 
- (void)commonInit
{
//    @property(nonatomic, weak) UIImageView *mainImageView;
//    @property(nonatomic, weak) UIImageView *topImageView;
//    @property(nonatomic, weak) UIImageView *bottomImageView;
//    
//    @property(nonatomic, weak) UILabel *mainTitleLabel;
//    @property(nonatomic, weak) UILabel *subTypeLabel;
//    @property(nonatomic, weak) UILabel *subSizeLabel;
//    @property(nonatomic, weak) UILabel *subDateLabel;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *mainImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mainImageView];
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImageView = mainImageView;
    
    UIImageView *topImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:topImageView];
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.topImageView = topImageView;
    
    UIImageView *bottomImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:bottomImageView];
    bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bottomImageView = bottomImageView;
    
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainTitleLabel];
    mainTitleLabel.textColor = [UIColor blackColor];
    mainTitleLabel.font = [UIFont systemFontOfSize:16];
    mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainTitleLabel.numberOfLines = 1;
    self.mainTitleLabel = mainTitleLabel;
    
    UILabel *subTypeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subTypeLabel];
    subTypeLabel.font = [UIFont systemFontOfSize:12];
    subTypeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    subTypeLabel.numberOfLines = 1;
    subTypeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    self.subTypeLabel = subTypeLabel;
    
    UILabel *subSizeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subSizeLabel];
    subSizeLabel.font = [UIFont systemFontOfSize:12];
    subSizeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    subSizeLabel.numberOfLines = 1;
    subSizeLabel.textColor = [UIColor colorWithHexString:@"#9c9999"];
    self.subSizeLabel = subSizeLabel;
    
    UILabel *subDateLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subDateLabel];
    subDateLabel.font = [UIFont systemFontOfSize:12];
    subDateLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    subDateLabel.numberOfLines = 1;
    subDateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.subDateLabel = subDateLabel;
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    selectedImageView.image = [UIImage imageNamed:@"repo selected - black"];
    selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectedImageView = selectedImageView;
    self.accessoryView = selectedImageView;
    
    
    
    // make up constraints
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(kFileIconWidth));
        make.width.equalTo(mainImageView.mas_height);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainImageView).offset(-4);
        make.right.equalTo(mainImageView).offset(4);
        make.height.equalTo(mainImageView).multipliedBy(0.5);
        make.width.equalTo(self.topImageView.mas_height);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(mainImageView).offset(4);
        make.right.equalTo(mainImageView).offset(4);
        make.height.equalTo(mainImageView).multipliedBy(0.5);
        make.width.equalTo(self.bottomImageView.mas_height);
    }];
    
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(mainImageView.mas_right).offset(kMargin);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainTitleLabel.mas_bottom).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.width.equalTo(self.contentView).multipliedBy(0.2);
        make.left.equalTo(mainTitleLabel);
    }];
    
    [self.subSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subTypeLabel);
        make.left.equalTo(subTypeLabel.mas_right).offset(kMargin/2);
        make.width.equalTo(self.contentView).multipliedBy(0.2);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
    
    [self.subDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subTypeLabel);
        make.left.equalTo(subSizeLabel.mas_right).offset(kMargin/2);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.right.equalTo(self.contentView).offset(-kMargin/2);
    }];
    
#if 0
    self.topImageView.backgroundColor = [UIColor blueColor];
    self.bottomImageView.backgroundColor = [UIColor redColor];
    self.mainImageView.backgroundColor = [UIColor greenColor];
#endif
}

@end
