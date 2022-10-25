//
//  NXFileValidityPickViewController.m
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 07/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import "NXFileValidityPickViewController.h"
#import "Masonry.h"
#import "NXLFileValidateDateModel.h"
@interface NXFileValidityPickViewController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, copy) NSString *currentSelected;

@end

@implementation NXFileValidityPickViewController

-(instancetype)initWithDateModel:(NXLFileValidateDateModel *)dateModel;
{
    self = [super init];
    if (self) {
        _dateModel = [[NXLFileValidateDateModel alloc] init];
        _dateModel.startTime = dateModel.startTime;
        _dateModel.endTime = dateModel.endTime;
        _dateModel.year = dateModel.year;
        _dateModel.month = dateModel.month;
        _dateModel.week = dateModel.week;
        _dateModel.day = dateModel.day;
        _dateModel.type = dateModel.type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _pickView = [[UIPickerView alloc] init];
    _navHeight = 0;
    
    self.pickView.delegate = self;
    self.pickView.delegate = self;
    
    _dateArray = [[NSMutableArray alloc] initWithObjects:@"Relative",@"Date range",@"Absolute date",@"Never expire",nil];
    [self.view addSubview:_pickView];
    
    switch (_dateModel.type) {
        case NXLFileValidateDateModelTypeNeverExpire:
            [_pickView selectRow:3 inComponent:0 animated:NO];
            break;
        case NXLFileValidateDateModelTypeAbsolute:
            [_pickView selectRow:2 inComponent:0 animated:NO];
            break;
        case NXLFileValidateDateModelTypeRange:
            [_pickView selectRow:1 inComponent:0 animated:NO];
            break;
        case NXLFileValidateDateModelTypeRelative:
            [_pickView selectRow:0 inComponent:0 animated:NO];
            break;
        default:
            break;
    }
    
    [self commonInit];
    // Do any additional setup after loading the view.
}

-(void)commonInit
{
    /** foot view */
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    footView.layer.masksToBounds = YES;
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0]];
    cancelButton.layer.cornerRadius = 5.0;
    
    UIButton *OKButton = [[UIButton alloc] init];
    [OKButton setTitle:@"Done" forState:UIControlStateNormal];
    [OKButton addTarget:self action:@selector(onClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [OKButton setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:160.0/255.0 blue:84.0/255.0 alpha:1.0]];
    [OKButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    OKButton.layer.cornerRadius = 5.0;
    
    [footView addSubview:cancelButton];
    [footView addSubview:OKButton];
    [self.view addSubview:footView];
    
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@(75));
        make.width.equalTo(self.view);
    }];
    _navHeight += 75;
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(45);
        make.centerX.equalTo(footView).offset(-75);
        make.bottom.equalTo(footView.mas_bottom).offset(-15);
    }];
    
    [OKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(45);
        make.centerX.equalTo(footView).offset(75);
        make.bottom.equalTo(footView.mas_bottom).offset(-15);
    }];
    
    [_pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(footView.mas_top);
        make.height.equalTo(@(44*3));
    }];
    
    _navHeight += 180;
    self.navc.viewHeight = _navHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Selector Method

- (void)onTapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickCancelButton:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickDoneButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.selectItemCompBlock) {
        _selectItemCompBlock(_dateModel);
    }
}

#pragma -mark UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _dateArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_dateArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            self.dateModel.type = NXLFileValidateDateModelTypeRelative;
            NSLog(@"pickview:current selectDateType is Relative");
            break;
        case 1:
            self.dateModel.type = NXLFileValidateDateModelTypeRange;
              NSLog(@"pickview:current selectDateType is Range");
            break;
        case 2:
            self.dateModel.type = NXLFileValidateDateModelTypeAbsolute;
             NSLog(@"pickview:current selectDateType is Absolute");
            break;
        case 3:
            self.dateModel.type = NXLFileValidateDateModelTypeNeverExpire;
            NSLog(@"pickview:current selectDateType is Never Expire");
            break;
        default:
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180, 44)];
    myLabel.text = [_dateArray objectAtIndex:row];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.font = [UIFont boldSystemFontOfSize:14.0];
    myLabel.textColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
    return myLabel;
}


@end
