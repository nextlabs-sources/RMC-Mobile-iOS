//
//  NXProtectedFileListView.m
//  nxrmc
//
//  Created by Sznag on 2020/12/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectedFileListView.h"
#import "Masonry.h"
#import "NXProtectedFIileTableViewCell.h"
@interface NXProtectedFileListView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)NSArray *fileListArray;
@property (nonatomic, strong)UITableView *tableView;
@end
@implementation NXProtectedFileListView
- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFileList:(NSArray *)files {
    if (self = [super init]) {
        _fileListArray = files;
        [self commonInitUIWithFileList:files];
        
    }
    return self;
}
- (void)commonInitUIWithFileList:(NSArray *)files {
    UITableView *tableView = [[UITableView alloc] init];
    [self addSubview:tableView];
    [tableView registerClass:[NXProtectedFIileTableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    long height = 60;
    if (files.count>1) {
        tableView.showsVerticalScrollIndicator = YES;
        height = 120;
    }
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(height));
        make.bottom.equalTo(self);
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileListArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProtectedFIileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.fileListArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NXFileBase *file = self.fileListArray[indexPath.row];
    if (self.fileClickedCompletion) {
        self.fileClickedCompletion(file);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
