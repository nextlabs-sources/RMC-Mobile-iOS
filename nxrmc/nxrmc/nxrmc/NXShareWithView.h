//
//  NXEmailAndOthersView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/1/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface NXShareWithView : UIView
@property(nonatomic,strong)NSMutableArray *emailsArray;
@property(nonatomic,strong)NSMutableArray *deleteProjectArray;
@property(nonatomic,strong)NSArray<NSDictionary *>*dataArray;// if users,set @{@"0":emails},if project,set @{@"1":projectNames},if workSpace,set @{@"2":wrokSpace}
@property(nonatomic, assign)CGFloat collectionViewMinHeight;
@property(nonatomic, assign)CGFloat collectionViewMaxHeight;
@property(nonatomic, weak) id delegate;
@end
@protocol NXShareWithViewSelegate <NSObject>

- (void)theShareWithViewHasChanged;

@end

