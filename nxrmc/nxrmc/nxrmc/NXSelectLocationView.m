//
//  NXSelectLocationView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSelectLocationView.h"
#import "Masonry.h"
#import "NXTreeFolderCell.h"
#import "NXFileBase.h"
#import "NXLoginUser.h"
#import "NXRepositoryModel.h"
@interface NXSelectLocationView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataArray;
@end
@implementation NXSelectLocationView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInitUI];
    }
    return self;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)commonInitUI {
    
    UILabel *selectLabel = [[UILabel alloc] init];
    selectLabel.text = @"Select a folder";
    [self addSubview:selectLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[NXTreeFolderCell class] forCellReuseIdentifier:@"cell"];
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(@20);
    }];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selectLabel.mas_bottom).offset(5);
        make.left.right.equalTo(selectLabel);
        make.bottom.equalTo(self).offset(-10);
    }];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXTreeFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXFolderModel *model = self.dataArray[indexPath.row];
    if (self.selectedCompletion) {
        self.selectedCompletion(model.fileBase, model.path);
    }
   
}

- (void)setSelectedFolder:(NXFileBase *)selectedFolder {
    [self.dataArray removeAllObjects];
    _selectedFolder = selectedFolder;
    BOOL isShowRootFolder = YES;
    NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:selectedFolder.repoId];
    NXFileBase *rootFolder =  [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:model];
    NSArray *folderArray = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:rootFolder];
    if (model.service_type.integerValue == kServiceSharepointOnline || model.service_type.integerValue == kServiceSharepoint) {
        isShowRootFolder = NO;
    }
    NSArray *array = [selectedFolder.fullPath componentsSeparatedByString:@"/"];
    NSString *selectedSecondFolderName = array[1];
    if ([selectedSecondFolderName isEqualToString:@""]) {
        NXFolderModel *rootModel = [[NXFolderModel alloc] init];
        rootModel.level = 0;
        rootModel.fullPath = rootFolder.fullPath;
        rootModel.expanded = YES;
        rootModel.selected = YES;
        rootModel.title = @"Root";
        rootModel.fileBase = rootFolder;
        [self.dataArray addObject:rootModel];
    }else{
        NSString *currentPath = [[NSString alloc] init];
        for (int i = 0; i<array.count; i++) {
            NXFolderModel *currentModel = [[NXFolderModel alloc] init];
            currentModel.level = i;
            currentModel.expanded = YES;
            currentModel.title = array[i];
            currentModel.expanded = YES;
            if (currentModel.title) {
                currentModel.fullPath = [currentPath stringByAppendingPathComponent:currentModel.title];
            }
            if (i == 0) {
                currentModel.title = @"Root";
                currentModel.fileBase = rootFolder;
                currentModel.fullPath = rootFolder.fullPath;
            }else{
                if (i==array.count-1) {
                    currentModel.selected = YES;
                    currentModel.fileBase = selectedFolder;
                }else{
                   
                    currentModel.path = currentModel.fullPath;
                    currentModel.fileBase = selectedFolder;
                    currentModel.selected = NO;
                }
            }
            currentPath = currentModel.fullPath;
            [self.dataArray addObject:currentModel];
        }
    }

    for (NXFileBase *item in folderArray) {
        if ([item isKindOfClass:[NXFolder class]]) {
            if (![item.name isEqualToString:selectedSecondFolderName]) {
                NXFolderModel *secondFolder = [[NXFolderModel alloc] init];
                secondFolder.level = 1;
                secondFolder.title = item.name;
                secondFolder.expanded = NO;
                secondFolder.fileBase = item;
                [self.dataArray addObject:secondFolder];
            }
        }
    }
    if (!isShowRootFolder) {
        [self.dataArray removeObjectAtIndex:0];
    }
    [self.tableView reloadData];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
