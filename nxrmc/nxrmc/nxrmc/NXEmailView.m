//
//  NXEmailView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXEmailView.h"

#import "Masonry.h"

#import "NXEmailCell.h"
#import "NXDisplayEmailCell.h"
#import "NXAccountInputTextField.h"

#import "HexColor.h"
#import "NXColllectionViewFlowLayoutout.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"

@interface NXEmailView ()<UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    NSMutableArray<NSString *> *_emailsArray;
}

@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, weak) UILabel *promptLabel;

@property(nonatomic, assign) CGFloat height; //height of this object.
@end

@implementation NXEmailView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self =  [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - getter setter
- (NSMutableArray<NSString *> *)emailsArray {
    if (!_emailsArray) {
        _emailsArray = [NSMutableArray array];
    }
    return _emailsArray;
}

- (NSArray<NSString *> *)vaildEmails {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.emailsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NXCommonUtils isValidateEmail:obj]) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (void)setPromptMessage:(NSString *)promptMessage {
    if ([_promptMessage isEqualToString:promptMessage]) {
        return;
    }
    self.promptLabel.text = promptMessage;
}

- (void)setEmailsArray:(NSMutableArray<NSString *> *)emailsArray {
    _emailsArray = emailsArray;
    [self.collectionView reloadData];
}
- (void)addAEmail:(NSString *)str {
    if (str && ![self.emailsArray containsObject:str]) {
        [self.emailsArray addObject:str];
    }
    [self.collectionView reloadData];
}
- (void)setEditable:(BOOL)editable {
    if (editable == _editable)  {
        return;
    }
    _editable = editable;
    if (!editable) {
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
        }];
        self.textField.enabled = NO;
        self.textField.hidden = YES;
        self.collectionView.userInteractionEnabled = NO;
    } else {
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
        }];
        self.textField.enabled = YES;
        self.textField.hidden = NO;
        self.collectionView.userInteractionEnabled = YES;
    }
}

- (BOOL)isExistInvalidEmail {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.emailsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NXCommonUtils isValidateEmail:obj]) {
            [array addObject:obj];
        }
    }];
    if (self.emailsArray.count>array.count) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)contain:(NSString *)email {
    __block BOOL ret = NO;
    [self.emailsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj compare:email options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            ret = YES;
            *stop = YES;
        }
    }];
    
    return ret;
}
#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context {
    //Whatever you do here when the reloadData finished
    
    CGFloat collectionViewContentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    CGFloat newHeight = collectionViewContentHeight ? collectionViewContentHeight + kMargin * 2 : 0;
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
    
    WeakObj(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongObj(self);
        if (self.height != newHeight) {
            self.height = newHeight;
            if (self.delegate && [self.delegate respondsToSelector:@selector(emailView:didChangeHeightTo:)]) {
                [self.delegate emailView:self didChangeHeightTo:newHeight];
            }
            if ( self.collectionView.contentSize.height > self.collectionView.bounds.size.height) {
               [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height) animated:YES];
            }
        }
    });
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emailViewDidBeginEditing:)]) {
        [self.delegate emailViewDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
        // get the last input text when lost focus
        if (![self contain:textField.text]) {
            [self.emailsArray addObject:textField.text];
            [self.collectionView reloadData];
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(emailView:didInputEmail:))) {
                [self.delegate emailView:self didInputEmail:textField.text];
            }
        }
        textField.text = nil;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(emailViewDidEndingEditing:)]) {
        [self.delegate emailViewDidEndingEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] && range.location == textField.text.length) {
        if ([textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
            if (![self contain:textField.text]) {
                [self.emailsArray addObject:textField.text];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(emailView:didInputEmail:))) {
                    [self.delegate emailView:self didInputEmail:textField.text];
                }
                [self.collectionView reloadData];
            }
            textField.text = nil;
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.textField.text.length > 0 && ![self contain:textField.text]) {
        [self.emailsArray addObject:textField.text];
        [self.collectionView reloadData];
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(emailView:didInputEmail:))) {
            [self.delegate emailView:self didInputEmail:textField.text];
        }
    }
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(emailViewDidReturn:))) {
        [self.delegate emailViewDidReturn:self];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emailsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NXEmailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.editable? @"cell":@"displayCell" forIndexPath:indexPath];
    
    NSString *email = self.emailsArray[indexPath.row];
    
    cell.title = email;
    
    WeakObj(self);
    cell.deleteBlock = ^(id sender) {
        StrongObj(self);
        [self.emailsArray removeObjectAtIndex:indexPath.row];
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(emailView:didInputEmail:))) {
            [self.delegate emailView:self didInputEmail:email];
        }
        [self.collectionView reloadData];
    };
    
    cell.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [NXEmailCell sizeForTitle:self.emailsArray[indexPath.row]];
    if (self.editable) {
        return size;
    } else {
        return CGSizeMake(size.width - kMargin/4 * 6, size.height);
    }
}

#pragma mark
- (void)commonInit {
    //TODO
    
    UILabel *promptLabel = [[UILabel alloc] init];
    [self addSubview:promptLabel];
    
    NXAccountInputTextField *textField = [[NXAccountInputTextField alloc] init];
    textField.accessibilityValue = @"EMAIL_ADDRESS_INPUT_TEXTVIEW";
    [self addSubview:textField];
    
    UIView *rightview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    rightview.contentMode = UIViewContentModeScaleAspectFit;
    UIButton *addBtn = [[UIButton alloc]init];
   // addBtn.backgroundColor = [UIColor cyanColor];
    addBtn.contentMode = UIViewContentModeScaleAspectFit;
    [addBtn setImage:[UIImage imageNamed:@"Add_Icon"] forState:UIControlStateNormal];
    addBtn.frame = CGRectMake(0, 0, 32, 32);
    [rightview addSubview:addBtn];
    

    [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    textField.rightView = rightview;
    textField.rightView.contentMode = UIViewContentModeScaleAspectFit;
    textField.rightViewMode = UITextFieldViewModeAlways;
    NXColllectionViewFlowLayoutout *layout = [[NXColllectionViewFlowLayoutout alloc] init];
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    
    layout.sectionInset = UIEdgeInsetsMake(kMargin, 0, kMargin, 0);
    layout.maximumInteritemSpacing = kMargin;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self addSubview:collectionView];
    
    promptLabel.textColor = [UIColor colorWithHexString:@"#000000"];
    promptLabel.font = [UIFont boldSystemFontOfSize:14];
    promptLabel.textAlignment = NSTextAlignmentLeft;
    promptLabel.text = NSLocalizedString(@"UI_SHARE_WITH", NULL);
    [promptLabel setHidden:NO];
    
    NSAttributedString *attstr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_ENTER_EMAIL_ADDRESS", NULL) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    textField.attributedPlaceholder = attstr;
    
    textField.delegate = self;
    textField.clipsToBounds = YES;
    textField.tintColor = [UIColor lightGrayColor];
    
    collectionView.backgroundColor = self.backgroundColor;
    [collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[NXEmailCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView registerClass:[NXDisplayEmailCell class] forCellWithReuseIdentifier:@"displayCell"];
    
    self.promptLabel = promptLabel;
    self.collectionView = collectionView;
    self.textField = textField;
    self.textField.accessibilityValue = @"EMAIL_VIEW_TEXT_FIELD";
    self.editable = YES;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            }];
            
            [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(textField);
                make.right.equalTo(promptLabel);
                make.top.equalTo(promptLabel.mas_bottom).offset(kMargin/4);
            }];
            
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(collectionView.mas_bottom).offset(kMargin/2);
                make.left.equalTo(promptLabel);
                make.right.equalTo(promptLabel);
                make.height.equalTo(@(40));
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kMargin/4);
            }];
        }
    }
    else
    {
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.left.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin);
        }];
        
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(textField);
            make.right.equalTo(promptLabel);
            make.top.equalTo(promptLabel.mas_bottom).offset(kMargin/4);
        }];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(collectionView.mas_bottom).offset(kMargin/2);
            make.left.equalTo(promptLabel);
            make.right.equalTo(promptLabel);
            make.height.equalTo(@(40));
            make.bottom.equalTo(self).offset(-kMargin/4);
        }];
    }
    
#if 0
    promptLabel.backgroundColor = [UIColor blueColor];
    collectionView.backgroundColor = [UIColor orangeColor];
    textField.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor greenColor];
#endif
}
- (void)addBtnClicked:(id)sender {
    if (self.rightBtnClicked) {
        self.rightBtnClicked();
    }
}
@end
