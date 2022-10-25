//
//  NXProtectedFIileTableViewCell.m
//  nxrmc
//
//  Created by Sznag on 2020/12/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectedFIileTableViewCell.h"
#import "HexColor.h"
#import "Masonry.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"
#import "HexColor.h"
@interface NXProtectedFIileTableViewCell ()
@property(nonatomic, strong)UIImageView *mainImageView;
@property(nonatomic, strong)UILabel *mainTitleLabel;
@property(nonatomic, strong)UILabel *subSizeLabel;
@property(nonatomic, strong)UILabel *subDateLabel;
@end
@implementation NXProtectedFIileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
       
    }
    return self;
}

- (void)commonInit{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [HXColor colorWithHexString:@"#F5F5F3"];
    UIImageView *mainImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mainImageView];
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImageView = mainImageView;

    
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainTitleLabel];
    mainTitleLabel.textColor = [UIColor blackColor];
    mainTitleLabel.font = [UIFont systemFontOfSize:16];
    mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainTitleLabel.numberOfLines = 1;
    self.mainTitleLabel = mainTitleLabel;

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
    
  
    // make up constraints
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(kFileIconWidth));
        make.width.equalTo(mainImageView.mas_height);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(mainImageView.mas_right).offset(kMargin);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [self.subSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainTitleLabel.mas_bottom).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.width.equalTo(@60);
        make.left.equalTo(mainTitleLabel);
    }];
    
    [self.subDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subSizeLabel);
        make.left.equalTo(subSizeLabel.mas_right).offset(kMargin/2);
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
    
}
- (void)setModel:(NXFileBase *)model {
    self.mainImageView.image = nil;
    self.mainTitleLabel.text = @"";
    self.subSizeLabel.text = @"";
    self.subDateLabel.text = @"";
    if (model.sorceType == NXFileBaseSorceTypeLocal) {
        model.fullPath = model.localPath;
    }
    NSString *imageName = [NXCommonUtils getImagebyExtension:model.fullPath?:model.name];
    self.mainImageView.image = [UIImage imageNamed:imageName];
  
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
    self.subSizeLabel.text = model.size ? strSize : @" ";
 
}
@end
