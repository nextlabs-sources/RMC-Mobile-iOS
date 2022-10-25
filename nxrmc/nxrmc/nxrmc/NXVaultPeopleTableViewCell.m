//
//  NXVaultPeopleTableViewCell.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXVaultPeopleTableViewCell.h"

@implementation NXVaultPeopleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
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

- (void)setModel:(NSString *)model {
    _model = model;
    self.textLabel.text = model;
    self.textLabel.accessibilityValue = @"SHARED_WITH_PEOPLE_NAME";
}

- (void)click:(id)sender {
    if (self.clickActionBlock) {
        self.clickActionBlock(sender);
    }
}

#pragma mark
- (void)commonInit {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [button setTitle:NSLocalizedString(@"UI_COM_REMOVE", NULL) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.cornerRadius = 2;
    self.accessoryView = button;
    self.accessoryView.accessibilityValue = @"NXFILE_SHARED_PEOPLE_REMOVE";
    
    _accessoryButton = button;
    
    self.textLabel.textColor = RMC_MAIN_COLOR;
    
}

@end
