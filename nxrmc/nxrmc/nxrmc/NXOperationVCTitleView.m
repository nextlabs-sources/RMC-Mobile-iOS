//
//  NXOperationVCTitleView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXOperationVCTitleView.h"

#import "Masonry.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"

@interface NXOperationVCTitleView()

@property(nonatomic, weak) UILabel *nameLabel;
@property(nonatomic, weak) UILabel *operationLabel;
@property(nonatomic, weak) UIImageView *thumbImageView;

@end

@implementation NXOperationVCTitleView

- (instancetype)initWithFrame:(CGRect)frame supportSortAndSearch:(BOOL) supportSortAndSearch{
    if (self = [super initWithFrame:frame]) {
        self.supportSortAndSearch = supportSortAndSearch;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark
- (void)setModel:(NXFileBase *)model {
    _model = model;
    NSString *fileExtension = model.name.pathExtension;
    if (!fileExtension || fileExtension.length == 0) {
        fileExtension = model.localPath.lastPathComponent;
         self.nameLabel.text = fileExtension;
        if (fileExtension.length == 0) {
             self.nameLabel.text = model.name;
        }
    }
    else
    {
         self.nameLabel.text = model.name;
    }
    self.nameLabel.accessibilityValue = @"FILE_PROPERTY_NAME_LAB";
    self.thumbImageView.image = [UIImage imageNamed:[NXCommonUtils getImagebyExtension:model.name]];
}

- (void)setOperationTitle:(NSString *)operationTitle {
    _operationTitle = operationTitle;
    self.operationLabel.text = operationTitle;
}

#pragma mark
- (void)back:(id)sender {
    if (self.backClickAction) {
        self.backClickAction(nil);
    }
}

#pragma mark
- (void)commonInit {
    UIButton *backButton = [[UIButton alloc]init];
    [self addSubview:backButton];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self addSubview:nameLabel];
    
    UILabel *operationLabel = [[UILabel alloc] init];
    [self addSubview:operationLabel];
    
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    imageView.image = [UIImage imageNamed:@"Document"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    nameLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.numberOfLines = 1;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.text = @" ";
    
    operationLabel.text = NSLocalizedString(@" ", NULL);
    operationLabel.font = [UIFont systemFontOfSize:12];
    operationLabel.textColor = RMC_MAIN_COLOR;
    operationLabel.numberOfLines = 1;
    operationLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    
    
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(kMargin);
        make.width.equalTo(@40);
        make.height.equalTo(backButton.mas_width).multipliedBy(0.8);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin+kMargin/2);
        make.left.equalTo(backButton.mas_right);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];
    
    if (self.supportSortAndSearch) {
        UIButton *sortButton = [[UIButton alloc] init];
        [self addSubview:sortButton];
        [sortButton setImage:[UIImage imageNamed:@"ellipsis - black"] forState:UIControlStateNormal];
        [sortButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sortButton];
        
        UIButton *searchButton = [[UIButton alloc] init];
        [self addSubview:searchButton];
        [searchButton setImage:[UIImage imageNamed:@"search - black"] forState:UIControlStateNormal];
        searchButton.accessibilityValue = @"SEARCH_OPERATOR";
        [searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(imageView.mas_right).offset(kMargin/4);
            make.right.equalTo(self).offset(-100);
        }];
        
        [sortButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(nameLabel.mas_right).offset(kMargin/4);
            make.width.height.equalTo(@40);
        }];
        
        [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(sortButton.mas_right).offset(kMargin/4);
            make.width.height.equalTo(@40);
        }];
        
    }else {
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(imageView.mas_right).offset(kMargin/4);
            make.right.equalTo(self).offset(-kMargin/2);
        }];
        
    }
   
    [operationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kMargin/2);
        make.left.equalTo(nameLabel);
        make.right.equalTo(nameLabel);
        make.bottom.equalTo(self).offset(-kMargin/4);
    }];
    
    _nameLabel = nameLabel;
    _operationLabel = operationLabel;
    _operationLabel.accessibilityValue = @"FILE_PROPERTY_LOCATION_LAB";
    _thumbImageView = imageView;

#if 0
    _nameLabel.backgroundColor = [UIColor blueColor];
    _operationLabel.backgroundColor = [UIColor redColor];
    _thumbImageView.backgroundColor = [UIColor greenColor];
    backButton.backgroundColor = [UIColor orangeColor];
#endif
}


- (void)sort:(UIButton *)sortButton {
    if (self.sortClickAction) {
        self.sortClickAction(sortButton);
    }
}

- (void)search:(UIButton *)searchButton {
    if (self.searchClickAction) {
        self.searchClickAction(searchButton);
    }
}

@end
