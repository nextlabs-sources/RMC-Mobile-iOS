//
//  NXOneDriveTestVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 25/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDriveTestVC.h"
#import "NXGetAuthURLAPI.h"
#import "NXGetAccessTokenAPI.h"
#import "NXOneDriveFileListAPI.h"
#import "NXGetRepositoryDetailsAPI.h"
#import "NXOneDriveDownloadFileAPI.h"
#import "NXRMCStruct.h"
#import "NXOneDriveFileItem.h"
@interface NXOneDriveTestVC ()
@property (nonatomic, strong)NSString *authURL;
@property (nonatomic, strong)NSString *repoId;
@property (nonatomic, strong)NSString *authToken;
@end

@implementation NXOneDriveTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NXGetAuthURLRequest *request = [[NXGetAuthURLRequest alloc]init];
    NSDictionary *dict =@{@"parameters": @{@"type":@"ONE_DRIVE",@"name":@"SZNAG"}};
    [request requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXGetAuthURLResponse *result = (NXGetAuthURLResponse *)response;
            self.authURL = result.authURL;
            NSLog(@"获取到了URL %@,",self.authURL);
        }
    }];
}
- (IBAction)getURL:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.authURL] options:@{} completionHandler:nil];
    
}
- (IBAction)getRepoId:(id)sender {
    NXGetRepositoryDetailsAPIRequest *request = [[NXGetRepositoryDetailsAPIRequest alloc]init];
   [request requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
       if (!error) {
           NXGetRepositoryDetailsAPIResponse *result = (NXGetRepositoryDetailsAPIResponse *)response;
           for (NXRMSRepoItem *item in result.rmsRepoList) {
               if ([item.repoType isEqualToString:@"ONE_DRIVE"]) {
                   self.repoId = item.repoId;
                   NSLog(@"获取到了云盘Id %@",self.repoId);
               }
           }
       }
    }];
}
- (IBAction)getAuthToken:(id)sender {
    NXGetAccessTokenAPIRequest *request = [[NXGetAccessTokenAPIRequest alloc]init];
   [request requestWithObject:self.repoId Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
       if (!error) {
           NXGetAccessTokenAPIResponse *result = (NXGetAccessTokenAPIResponse *)response;
           self.authToken = result.accessToken;
           NSLog(@"获取token成功：%@",self.authToken);
       }
   }];
}
- (IBAction)getFileList:(id)sender {
    NSString *string = [NSString stringWithFormat:@"Bearer %@",self.authToken];
//    NXOneDriveFileListAPIRequest *request = [[NXOneDriveFileListAPIRequest alloc]init];
//    [request requestWithObject:string Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//
//    }];
//    NXOneDriveDownloadFileAPIRequest *downloadRequest = [[NXOneDriveDownloadFileAPIRequest alloc]init];
//    NSDictionary *dict = @{@"accessToken":string,@"downloadUrlStr":@"https://public.bn1302.livefilestore.com/y4mZhhYlCw34b8doxsN-uULY_oRGOqa9l3KonNMfy9dpeS6jG5wScUCjEvpPQgtdjVPvdc2c2-Ukfhv1U6tG_dunavsN3FdkyQOdTRFEf2NKmfh1B0jmtUHT3Hh5Q7MaZmbEbdDoT2CLZx6lEuE5k9WagGZPRo7SSq6maD8q7yuh5DeKcrkw4sGKYV3tgMdnWrWomdEv1Ak8_v74GgVNqodZT5s4uM4kcUAMR_58ELZ12sIbpX6vnNc-VxAXQGmBRYEtLj9NAj_EVx0L7UYsFggHQ"};
//    [downloadRequest requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//        NSLog(@"---%lu",(unsigned long)((NXOneDriveDownloadFileAPIResponse*)response).fileData.length);
//    }];
    // 如何是根目录就传"root",子目录传id
//    NSURL *downloadURL = [NSURL URLWithString:@"https://public.bn1302.livefilestore.com/y4mZhhYlCw34b8doxsN-uULY_oRGOqa9l3KonNMfy9dpeS6jG5wScUCjEvpPQgtdjVPvdc2c2-Ukfhv1U6tG_dunavsN3FdkyQOdTRFEf2NKmfh1B0jmtUHT3Hh5Q7MaZmbEbdDoT2CLZx6lEuE5k9WagGZPRo7SSq6maD8q7yuh5DeKcrkw4sGKYV3tgMdnWrWomdEv1Ak8_v74GgVNqodZT5s4uM4kcUAMR_58ELZ12sIbpX6vnNc-VxAXQGmBRYEtLj9NAj_EVx0L7UYsFggHQ"];
    
//    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.onedrive.com/v1.0/drive/items/%@/children",@"root"]];
    NSURL *quotaUrl = [[NSURL alloc]initWithString:@"https://api.onedrive.com/v1.0/drive"];
//     NSURL *downloadUrl = [[NSURL alloc]initWithString:@"https://api.onedrive.com/v1.0/drive/items/5FA0638BAD1648EA!193/content"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:quotaUrl];;
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:string forHTTPHeaderField:@"Authorization"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *itemArray = [NSMutableArray array];
        NSArray *drvieFiles = dict[@"value"];
        for (NSDictionary *fileDict in drvieFiles) {
            NXOneDriveFileItem *item = [[NXOneDriveFileItem alloc]initWithDictionary:fileDict];
            [itemArray addObject:item];
        }
        NSLog(@"---%@--",itemArray);
    }];
    
    [task resume];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
