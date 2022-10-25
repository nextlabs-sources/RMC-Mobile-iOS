//
//  NXWorkSpaceItemCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceItemCell.h"
#import "NXWorkSpaceItem.h"
#import "NXCommonUtils.h"
#import "Masonry.h"
#import "NXOfflineFileManager.h"

@interface NXWorkSpaceItemCell ()
@property(nonatomic, strong)NXFileBase *workSpaceModel;
@property(nonatomic, strong)NSDateFormatter *dateFormtter;
@end
@implementation NXWorkSpaceItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self updateUIForNormal];
        [self.fileStateTipsLabel setHidden:YES];
        [self.fileStateImageView setHidden:YES];
        self.bottomImageView.image = nil;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self updateUIForNormal];
        [self.fileStateTipsLabel setHidden:YES];
        [self.fileStateImageView setHidden:YES];
        self.bottomImageView.image = nil;
    }
    return self;
}
- (NSDateFormatter *)dateFormtter{
    if (!_dateFormtter) {
        _dateFormtter = [[NSDateFormatter alloc]init];
        [_dateFormtter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormtter setTimeStyle:NSDateFormatterFullStyle];
    }
    return _dateFormtter;
}
- (void)setModel:(NXFileBase *)model{
    _workSpaceModel = model;
    if ([model isKindOfClass:[NXFolder class]] && (![[NXLoginUser sharedInstance] isTenantAdmin])) {
        [self.accessButton setHidden:YES];
    }
    else
    {
        [self.accessButton setHidden:NO];
    }
    if ([model isKindOfClass:[NXFolder class]]) {
        self.mainImageView.image = [UIImage imageNamed:@"folder - black"];
        [self updateUIForNormal];
        [self.fileStateTipsLabel setHidden:YES];
        [self.fileStateImageView setHidden:YES];
        self.bottomImageView.image = nil;
    } else  {
        NSString *imageName = [NXCommonUtils getImagebyExtension:model.fullServicePath];
        self.mainImageView.image = [UIImage imageNamed:imageName];
        NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:model];
        switch (state) {
            case NXFileStateNormal:
                [self updateUIForNormal];
                [self.fileStateTipsLabel setHidden:YES];
                [self.fileStateImageView setHidden:YES];
                self.bottomImageView.image = nil;
                break;
            case NXFileStateOfflined:
            {
                [self updateUIForNormal];
                [self.fileStateTipsLabel setHidden:YES];
                [self.fileStateImageView setHidden:YES];
                self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
            }
                break;
            case NXFileStateConvertingOffline:
            {
                [self updateUIForOffline];
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
                [self updateUIForOffline];
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
    }
    self.mainTitleLabel.text = model.name;
    self.accessoryView = self.accessButton;
   
    
    NSDate * modifyDate = model.lastModifiedDate;
    NSString* modifyDateString = nil;
    if (modifyDate) {
        [self.dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        modifyDateString = [self.dateFormtter stringFromDate:modifyDate];
    }
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    
    if (![model isKindOfClass:[NXFolder class]]) {
        self.subSizeLabel.text = model.size ? strSize :@"N/A";
        
        NSString *fileExtension = model.name.pathExtension;
        if ((!fileExtension || fileExtension.length == 0) && model.serviceType.integerValue == 4) {
            self.subSizeLabel.text = @"N/A";
        }
    }else {
        self.subSizeLabel.text = @"";
    }
    self.subDateLabel.text = modifyDateString ? modifyDateString : @" ";
    self.topImageView.image = model.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
