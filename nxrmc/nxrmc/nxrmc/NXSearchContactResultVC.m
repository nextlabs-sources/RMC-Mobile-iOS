//
//  NXSearchContactResultVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/26.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSearchContactResultVC.h"
#import "NXLocalContactsVC.h"
#import "NXRMCDef.h"
#import "Masonry.h"
#import "NXEmailContactCell.h"
@interface NXSearchContactResultVC ()<UITableViewDelegate,UITableViewDataSource,NXEmailContactCellDelegate>
@property(nonatomic, strong)NSMutableArray *resultContacts;
@property(nonatomic, strong)UITableView *tableView;
@end

@implementation NXSearchContactResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.tableFooterView = [[UIView alloc]init];
    [tableView registerClass:[NXEmailContactCell class] forCellReuseIdentifier:@"cell"];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kMargin * 9);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else{

        [tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 9);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.resultContacts.count;
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [searchController.searchBar text];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[c] %@", searchString];
    self.resultContacts = [NSMutableArray arrayWithArray:[self.allContactsArray filteredArrayUsingPredicate:preicate]];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXEmailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    NXEmailContact *contact = self.resultContacts[indexPath.row];
    cell.contactModel = contact;
    return cell;
}
#pragma mark ------> delegate
- (void)emailBtnWhichTitle:(NSString *)title ClickedFromEmailBtnView:(NXEmailBtnsView *)emailBtnsView {
    if ([self.delegate respondsToSelector:@selector(theEmailBtnBeClickedOnSearchResultPageWithTitle:)]) {
        [self.delegate theEmailBtnBeClickedOnSearchResultPageWithTitle:title];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
