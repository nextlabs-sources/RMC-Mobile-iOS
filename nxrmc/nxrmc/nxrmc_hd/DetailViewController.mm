//
//  DetailViewController.m
//  nxrmc_hd
//
//  Created by EShi on 7/21/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "DetailViewController.h"
#import "NXFilePropertyVC.h"
#import "NXProtectViewController.h"
#import "NXShareViewController.h"
#import "NXPresentNavigationController.h"
#import "NXMasterTabBarViewController.h"
#import "NXPrintInteractionController.h"
#import "NXFavoriteViewController.h"

#import "Masonry.h"

#import "NXDownloadView.h"
#import "NXOverlayView.h"
#import "NXLightView.h"
#import "NXFileOperationToolBar.h"
#import "NXFileContentTitleView.h"
#import "UIImage+ColorToImage.h"

#import "NXLoginUser.h"
#import "NXPolicyEngineWrapper.h"
#import "NXLMetaData.h"
#import "NXServiceOperation.h"
#import "NXFile.h"
#import "NXNetworkHelper.h"
#import "NXCommonUtils.h"
#import "NXConvertFile.h"
#import "NXLogAPI.h"
#import "NXSyncHelper.h"
#import "NXHeartbeatManager.h"
#import "NXMBManager.h"
#import "NXCacheManager.h"
#import "AppDelegate.h"
#import "NXProjectFile.h"
#import "NX3DFileConverter.h"
#import "NXFileParser.h"

#define kFileOptToolBarInitWidth 25.0f


@interface NSData(FOOBAARUIDocumentInteractionControllerFix)

- (NSString *)description;

@end

@implementation NSData(FOOBAARUIDocumentInteractionControllerFix)

-(NSString *)description { return @"The fix for UIDocumentInteractionController`s bug."; }

@end

typedef NS_ENUM(NSInteger, NXServiceOperationStatus) {
    NXSERVICEOPERATIONSTATUS_UNSET = 0,
    NXSERVICEOPERATIONSTATUS_DOWNLOADFILE,
    NXSERVICEOPERATIONSTATUS_GETMETADATA,
};

typedef NS_ENUM(NSInteger, NXViewTagType) {
    NXVIEWTAGTYPE_UNSET         = 0,
    NXVIEWTAGTYPE_STATUSVIEW    = 8808,
    NXVIEWTAGTYPE_OVERLAY       = 8809,
    NXVIEWTAGTYPE_3DVIEW        = 8810,
    NXVIEWTAGTYPE_VDSVIEW       = 8811,
    NXVIEWTAGTYPE_MEDIAVIEW     = 8812,
    NXVIEWTAGTYPE_SELECT2DBUTTON = 8813,
    NXVIEWTAGTYPE_FAILEDFILEVIEW,
    NXVIEWTAGTYPE_FILECONTENTVIEW,
};

typedef NS_ENUM(NSInteger, NXChangePageTagType)
{
    NXChangePageTagTypeLeft = 60001,
    NXChangePageTagTypeRight,
};

@interface DetailViewController ()<UIDocumentInteractionControllerDelegate, NXServiceOperationDelegate,UINavigationControllerDelegate, NXFileOperationToolBarDelegate, UIViewControllerTransitioningDelegate, NXOperationVCDelegate, NXFileParserDelegate>

@property (weak, nonatomic) NXDownloadView *downloadView;
@property (strong,nonatomic) NXLightView *lightView;
@property (strong, nonatomic) UIBarButtonItem *moreButton;
@property (strong, nonatomic) UIBarButtonItem *printButton;

@property (strong, nonatomic) NXFileContentTitleView *titleView;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
//@property (strong, nonatomic) id<NXServiceOperation> serviceOperation;
@property (strong, nonatomic) NSString *localCachePath;

//@property (strong, nonatomic) NXFileBase *metaData;
@property (strong, nonatomic) NXLRights *curFileRights;

@property (assign, nonatomic) BOOL shownFile;
@property (assign, nonatomic) NXServiceOperationStatus serviceStatus;
//@property (assign, nonatomic) BOOL isSimpleShadowSelected;
@property (assign, nonatomic) BOOL shownOpenInMenu;

@property (nonatomic) BOOL isOpenThirdAPPFile;
@property (nonatomic) BOOL isOpenNewProtectedFile;

@property (nonatomic) BOOL isSteward;

@property (nonatomic, strong) NSString *operationID; // duid to identify the opening file operation when sync. if open file B when opening file A, the uuid will be changed, so we can stop open file A.

//this two property only used for PDF file.
//@property(nonatomic, strong) NSString *converted3DfilePath; //filePath which convert from 3d pdf file
//@property(nonatomic, strong) NSString *normalPDFfile; //current opened 3d filepath.
//@property(nonatomic, assign) BOOL is3DPDFFile;
//@property(nonatomic, assign) BOOL isMediaFile;
@property(nonatomic, strong) NXFileOperationToolBar *fileOptToolBar;
@property(nonatomic, strong) MASConstraint *fileOptToolBarLeftConstraint;
@property(nonatomic, assign) CGPoint fileOptToolBarPrePanPoint;
@property(nonatomic, assign) BOOL isFileOptToolBarOut;

@property(nonatomic, strong) UIView *noContentView;

@property(nonatomic, strong) NSString *downloadOperationID;  // this ID stand for NXWebFileManager download file operation

@property(nonatomic, strong) NXFileParser *fileParse;
@property(nonatomic, assign) BOOL isOpenForPreview;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isSteward = NO;
    self.fileParse = [[NXFileParser alloc] init];
    self.fileParse.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([self.splitViewController.viewControllers.firstObject isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nav = (UINavigationController *)self.splitViewController.viewControllers.firstObject;
            nav.delegate = self;
        }
    }
    
    // listen to the remote view did finish load
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webviewDidFinishLoad:) name:NOTIFICATION_DETAILVC_PRINT_ENABLED object:nil];
}

- (void)webviewDidFinishLoad:(NSNotification *)notification
{
    WeakObj(self);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        StrongObj(self);
        self.printButton.enabled = YES;
        // update UI by rights
        if (self.curFileRights) {
            if (![self.curFileRights PrintRight] && !self.isSteward) {
                self.printButton.enabled = NO;
            }
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.splitViewController.collapsed) {
        self.splitViewController.displayModeButtonItem.enabled = YES;

    }
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NXOfflineFileManager sharedInstance] cancelRefreshOfflineFileExpireDateOpt:self.curFile];
    [self.documentController dismissPreviewAnimated:YES];
    [self.documentController dismissMenuAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.splitViewController.displayModeButtonItem.enabled = NO;
    
    if (self.fileParse.fileContentType == NXFileContentTypeMedia) {
        [self.fileParse pauseMediaFile:self.curFile];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self closeFile];
    
    [self showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_MEMORY_WARNING", nil)];
    
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // cancel the operation and stop background thread
    [self cancelOperation];
//    [self cancelSyncMetaData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog();
}


- (UIDocumentInteractionController *)documentController
{
    if(_documentController == nil)
    {
        _documentController = [[UIDocumentInteractionController alloc]init];
        _documentController.delegate = self;
    }
    return _documentController;
}

#pragma mark - public method
-(void) showAutoDismissLabel:(NSString *) labelContent
{
    [NXMBManager showMessage:labelContent toView:self.view hideAnimated:YES afterDelay:1.0];
}

#pragma mark - relayout UI

- (void)configureView {
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - white"] style:UIBarButtonItemStylePlain target:self action:@selector(detailBtnPressed:)];
    moreButton.accessibilityLabel = @"FILE_CONTENT_DETAILS";
    moreButton.accessibilityValue = @"FILE_CONTENT_DETAILS";
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"print - white"] style:UIBarButtonItemStylePlain target:self action:@selector(printBtnPressed:)];
    printButton.accessibilityLabel = @"FILE_CONTENT_PRINT";
    printButton.accessibilityValue = @"FILE_CONTENT_PRINT";
    self.moreButton = moreButton;
    self.printButton = printButton;
    self.titleView = [[NXFileContentTitleView alloc] initWithFrame:CGRectMake(0, 5, MAXFLOAT, 30) title:self.curFile.name repoAlias:self.curFile.serviceAlias];
    self.titleView.fileTitle  = NSLocalizedString(@"UI_TITLE_DETAIL", NULL);
    self.titleView.fileRepoAlias = @"";
    self.navigationItem.titleView=self.titleView;
    
    [self showNoFileContentView];
}

#pragma mark - Open file
- (void)openFile:(NXFileBase *)file
{
    [self openFile:file forPreview:NO];
}

- (void)openFileForPreview:(NXFileBase *)file
{
    [self openFile:file forPreview:YES];
}

- (void)openFile:(NXFileBase *)file forPreview:(BOOL)preview
{
    self.isOpenForPreview = preview;
    [self closeFile];
    if (!preview) {
        self.navigationItem.rightBarButtonItems = @[self.moreButton, self.printButton];
    }
    self.moreButton.enabled = NO;
    self.printButton.enabled = NO;
    self.curFile = file;
    self.titleView.fileTitle = self.curFile.name;
    self.titleView.fileRepoAlias = self.curFile.serviceAlias;
    self.operationID = [[NSUUID UUID] UUIDString];
    // add waiting view
    [self addProcessFileProgressView:NO fileName:file.name];  // we do not support progress yet for NXFileParse
    
    [self.fileParse parseFile:file];

}

#pragma mark - NXFileParserDelegate/ after parse file
- (void)NXFileParser:(NXFileParser *)fileParser didFinishedParseFile:(NXFileBase *)file resultView:(UIView *)resultView error:(NSError *)error
{
    dispatch_main_async_safe(^{
        [self.downloadView removeFromSuperview];
        if(error || !resultView){
            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_LOAD_FILE_FAIL", nil) image:nil hideAnimated:YES afterDelay:3*kDelay ];
            [self openFileFailed:file.name];
            
        }else{
            
            if (file.localPath.lastPathComponent.length > 0) {
                file.name = file.localPath.lastPathComponent;
            }
            
            self.titleView = [[NXFileContentTitleView alloc] initWithFrame:CGRectMake(0, 5, MAXFLOAT, 30) title:file.name repoAlias:file.serviceAlias];
            self.titleView.fileRepoAlias = @"";
            self.navigationItem.titleView=self.titleView;
            
            if (file.sorceType == NXFileBaseSorceTypeShareWithMe) {
                
                if (!file.size) {
                    file.size = [[NSFileManager defaultManager] contentsAtPath:file.localPath].length;
                }
            }
            // set the content file to display file content
            [self addfileContentView:resultView];
            [self afterOpenFile];
        }

    });
}

- (void)NXFileParser:(NXFileParser *)fileParser didFinishedParseNXLFile:(NXFileBase *)nxlFile resultView:(UIView *)resultView rights:(NXLRights *)rights isSteward:(BOOL)isSteward stewardID:(NSString *)stewardID error:(NSError *)error
{
    dispatch_main_async_safe(^{
        [self.downloadView removeFromSuperview];
        if (error || !resultView) {
            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_LOAD_FILE_FAIL", nil) image:nil hideAnimated:YES afterDelay:3*kDelay ];
            [self openFileFailed:nxlFile.name];
        }else{
            self.curFileRights = rights;
            self.isSteward = isSteward;
            
            if (nxlFile.localPath.length > 0) {
                nxlFile.name = nxlFile.localPath.lastPathComponent;
            }
            
            if (self.curFile.name) {
                nxlFile.name = self.curFile.name;
            }
            
            self.titleView = [[NXFileContentTitleView alloc] initWithFrame:CGRectMake(0, 5, MAXFLOAT, 30) title:nxlFile.name repoAlias:nxlFile.serviceAlias];
            self.titleView.fileRepoAlias = @"";
            self.navigationItem.titleView = self.titleView;
            
            if (nxlFile.sorceType == NXFileBaseSorceTypeShareWithMe) {
                
                if (!nxlFile.size) {
                    nxlFile.size = [[NSFileManager defaultManager] contentsAtPath:nxlFile.localPath].length;
                }
            }
            // set the content file to display file content
            [self addfileContentView:resultView];
           /*
            // add lightView
            if (!fileParser.isSteward) {
                if (![rights PrintRight] && fileParser.fileContentType == NXFileContentTypeNormal ||fileParser.fileContentType == NXFileContentTypePDF) {
                    NXLightView *lightView = [[NXLightView alloc]initWithFrame:resultView.frame andSuperView:resultView];
                    [resultView addSubview:lightView];
                    [lightView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(resultView);
                    }];
                }
            }
            */
            [self afterOpenFile];
        }
    });
    
}




- (void)afterOpenFile
{
    if ([self.delegate respondsToSelector:@selector(afterOpenFile)]) {
        [self.delegate afterOpenFile];
    }
    _shownFile = YES;
    //overlay test code. if you do not want to show overlay, please comment this line.
    self.moreButton.enabled = YES;
    self.printButton.enabled = YES;
    if (self.fileParse.fileContentType == NXFileContentTypeMedia) {
        self.printButton.enabled = NO;
    }
    [self showOverlay];
   // [self showChangePageButton];
    [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
//        NSLog(@"upload log infomation");
    }];
    
    // update UI by rights
    if (self.curFileRights) {
        if (![self.curFileRights PrintRight] && !self.isSteward) {
            self.printButton.enabled = NO;
        }
    }
    if(self.curFile.sorceType == NXFileBaseSorceTypeRepoFile && !self.isOpenForPreview){
          [self addFileOptToolBar];
    }
    
    if (self.fileParse.fileContentType == NXFileContentTypeRemoteView) {
        self.printButton.enabled = NO;
    }
}

- (void)openFileFailed:(NSString *)fileContentPath
{
    UIView *failedContentView = [[UIView alloc] init];
    failedContentView.backgroundColor = [UIColor whiteColor];
    failedContentView.tag = NXVIEWTAGTYPE_FAILEDFILEVIEW;
    [self.view addSubview:failedContentView];
    [failedContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    [[self.view viewWithTag:NXVIEWTAGTYPE_FILECONTENTVIEW] removeFromSuperview];
  //  [self showChangePageButton];
}

- (void)openNotSupportFile:(NSString *) fileContentPath isNXLFile:(BOOL) isNXL
{
    [self hintUserOpenInOtherApp:isNXL];
    UIView *failedContentView = [[UIView alloc] init];
    failedContentView.backgroundColor = [UIColor whiteColor];
    failedContentView.tag = NXVIEWTAGTYPE_FAILEDFILEVIEW;
    [self.view addSubview:failedContentView];
    [failedContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
  //  [self showChangePageButton];
    
}

#pragma mark - UI layout, response
- (void)openUnSupportFileIn3rd
{
    self.documentController.URL = [[NSURL alloc]initFileURLWithPath:self.localCachePath];
    NSString *uti = [NXCommonUtils getUTIForFile:self.localCachePath];
    self.documentController.UTI = uti ? uti : @"public.content";
    self.shownOpenInMenu = YES;
    [self.documentController presentOptionsMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void)updateProgress:(CGFloat)progress
{
    [self.downloadView.progressBar setProgress:progress];
}

- (void)addProcessFileProgressView:(BOOL)isSupportProgress fileName:(NSString *)fileName;
{
    NXDownloadView *downloadView = [[NXDownloadView alloc]initWithFrame:CGRectZero showDownloadView:isSupportProgress];
    downloadView.translatesAutoresizingMaskIntoConstraints = NO;
    downloadView.fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    downloadView.tag = NXVIEWTAGTYPE_STATUSVIEW;
    self.downloadView = downloadView;
    
    //auto layout
    [self.view addSubview:downloadView];
    
    [downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.trailing.equalTo(self.view);
        make.leading.equalTo(self.view);
    }];
    
    if(isSupportProgress)
    {
        [downloadView.progressBar setProgress:0.0f];
        [downloadView.fileName setText:fileName];
    }
    else
    {
//        [downloadView.activityView startAnimating];
    }
}


- (void)showAlertView:(NSString*)title message:(NSString*)message
{
    [NXCommonUtils showAlertView:title message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) OKActionHandle:nil cancelActionHandle:nil inViewController:self position:self.view];
}

- (void)hintUserOpenInOtherApp:(BOOL)isNxlFile
{
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_HINT_USER_MESSAGE", NULL) style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
        if (!isNxlFile) {
            [self openUnSupportFileIn3rd];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    } cancelActionHandle: nil inViewController:self position:self.view];
}

- (void)showOverlay {
    BOOL isNXL = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:self.curFile];
    if (!isNXL) {
        return;
    }
    WeakObj(self);
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:self.curFile withWatermark:YES withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *waterMark, NSString *owner, BOOL isOwner, NSError *error) {
        StrongObj(self);
        if (error) {
            DLog(@"%@", error.localizedDescription);
        } else {
            if (!isOwner && [rights getObligation:NXLOBLIGATIONWATERMARK]) {
                
                NXOverlayTextInfo *overlayTextInfo = [NXHeartbeatManager sharedInstance].getOverlayTextInfo;
                if (!overlayTextInfo) { // No overlay text info, for the heartbeat may not returned
                    return;
                }
                // here to suit for older version of nxl format, if we can't set nxl watermark style, we use default content
                if (waterMark.count != 0) {
                    NSMutableString *waterMarkString = [[NSMutableString alloc] init];
                    for(NXWatermarkWord *watermarkWord in waterMark) {
                        [waterMarkString appendString:[watermarkWord watermarkLocalizedString]];
                    }
                    overlayTextInfo.text = waterMarkString;
                }
                
                
                dispatch_main_async_safe(^{
                    NXOverlayView *overlayView = [[NXOverlayView alloc] initWithFrame:CGRectZero Obligation:overlayTextInfo];
                    [self.fileParse addOverlayer:overlayView toFile:self.curFile];
                });
            }
        }
    }];
}

- (void) addFileOptToolBar
{
    return; // for bug 48644 Should remove the float button in opened file
//    [self.fileOptToolBar removeFromSuperview];
//    self.fileOptToolBar = [[NXFileOperationToolBar alloc] initWithFrame:CGRectMake(0, 0, FILE_TOOL_BAR_WIDTH, FILE_TOOL_BAR_HEIGHT) file:(NXFile *)self.curFile type:NXFileOperationToolBarTypeFileContent];
//    [self.view addSubview:self.fileOptToolBar];
//    __weak typeof(self) weakSelf = self;
//    [self.fileOptToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@FILE_TOOL_BAR_WIDTH);
//        make.height.equalTo(@FILE_TOOL_BAR_HEIGHT);
//        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-20);
//        weakSelf.fileOptToolBarLeftConstraint = make.left.equalTo(weakSelf.view.mas_right).offset(-kFileOptToolBarInitWidth);
//    }];
//    self.fileOptToolBar.delegate = self;
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fileOperationToolBarDrag:)];
//    [self.fileOptToolBar addGestureRecognizer:pan];
//    
//    [self.view bringSubviewToFront:self.fileOptToolBar];
}



- (void)fileOperationToolBarDrag:(UIPanGestureRecognizer *)panGesture
{
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        self.fileOptToolBarPrePanPoint = [panGesture locationInView:self.view];
        
    }else if(panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint newPoint = [panGesture locationInView:self.view];
        CGFloat diffX = self.fileOptToolBarPrePanPoint.x - newPoint.x;
        self.fileOptToolBarPrePanPoint = newPoint;
        
        if (diffX > 0 && self.view.frame.size.width - self.fileOptToolBar.frame.origin.x + diffX  > FILE_TOOL_BAR_WIDTH ) {
            return;
        }
        
        if (diffX < 0 && self.view.frame.size.width - self.fileOptToolBar.frame.origin.x - diffX < kFileOptToolBarInitWidth) {
            return;
        }
        
        if (diffX > 0) {
            self.isFileOptToolBarOut = YES;
        }else
        {
            self.isFileOptToolBarOut = NO;
        }
        
        
        self.fileOptToolBar.frame = CGRectMake(self.fileOptToolBar.frame.origin.x - diffX, self.fileOptToolBar.frame.origin.y, self.fileOptToolBar.frame.size.width, self.fileOptToolBar.frame.size.height);
        
    }else if(panGesture.state == UIGestureRecognizerStateEnded)
    {
        if (self.isFileOptToolBarOut) {
            
            [self expandFileOperationToolBar];
            
        }else
        {
            [self shrinkFileOperationToolBar];
        }
    }
}

- (void)expandFileOperationToolBar
{
    if (self.fileOptToolBar) {
        __weak typeof(self) weakSelf = self;
        [self.fileOptToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@FILE_TOOL_BAR_WIDTH);
            make.height.equalTo(@FILE_TOOL_BAR_HEIGHT);
            make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-20);
            make.left.equalTo(weakSelf.view.mas_right).offset(-FILE_TOOL_BAR_WIDTH);
        }];
        
        self.fileOptToolBar.btnShow.hidden = YES;
    }
}

- (void)shrinkFileOperationToolBar
{
    if (self.fileOptToolBar) {
        __weak typeof(self) weakSelf = self;
        [self.fileOptToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@FILE_TOOL_BAR_WIDTH);
            make.height.equalTo(@FILE_TOOL_BAR_HEIGHT);
            make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-20);
            make.left.equalTo(weakSelf.view.mas_right).offset(-kFileOptToolBarInitWidth);
        }];
        
        self.fileOptToolBar.btnShow.hidden = NO;
    }
}

-(void) showChangePageButton
{
    [self removeChangePageButton];
    if(self.curFile.sorceType == NXFileBaseSorceType3rdOpenIn || self.curFile.sorceType == NXFileBaseSorceTypeLocal || self.delegate == nil || self.isOpenForPreview)
    {
        return;
    }
    UIButton *leftChangeButton = [[UIButton alloc] init];
    leftChangeButton.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3];
    leftChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    leftChangeButton.tag = NXChangePageTagTypeLeft;
    [leftChangeButton setImage:[UIImage imageNamed:@"prePageIcon"] forState:UIControlStateNormal];
    [leftChangeButton addTarget:self action:@selector(rightSwipeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftChangeButton];
   
    
    UIButton *rightChangeButton = [[UIButton alloc] init];
    rightChangeButton.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3];
    rightChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    rightChangeButton.tag = NXChangePageTagTypeRight;
    [rightChangeButton setImage:[UIImage imageNamed:@"nextPageIcon"] forState:UIControlStateNormal];
    [rightChangeButton addTarget:self action:@selector(leftSwipeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightChangeButton];
  
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            
            [leftChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.mas_safeAreaLayoutGuideCenterY);
                make.leading.equalTo(self.view.mas_safeAreaLayoutGuideLeading);
                make.width.equalTo(@(32));
                make.height.equalTo(@(65));
            }];
            
            [rightChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.mas_safeAreaLayoutGuideCenterY);
                make.trailing.equalTo(self.view.mas_safeAreaLayoutGuideTrailing);
                make.width.equalTo(@(32));
                make.height.equalTo(@(65));
            }];
        }
    }
    else
    {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:leftChangeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:leftChangeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:leftChangeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:leftChangeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:65.0]];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:rightChangeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:rightChangeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:rightChangeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:rightChangeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:65.0]];
    }
}

- (void) leftSwipeButtonClick:(UIButton *) leftSwipeButton
{
    if (_serviceStatus == NXSERVICEOPERATIONSTATUS_DOWNLOADFILE) {
        return;
    }
    
    if (self.fileParse.fileContentType == NXFileContentTypeMedia) {
        [self.fileParse pauseMediaFile:self.curFile];
    }
    
    if ([self.delegate respondsToSelector:@selector(detailViewController:SwipeToNextFileFrom:)]) {
        [self.delegate detailViewController:self SwipeToNextFileFrom:self.curFile];
    }
    
}

- (void) rightSwipeButtonClick:(UIButton *) rightSwipeButton
{
    if (_serviceStatus == NXSERVICEOPERATIONSTATUS_DOWNLOADFILE) {
        return;
    }
    
    if (self.fileParse.fileContentType == NXFileContentTypeMedia) {
        [self.fileParse pauseMediaFile:self.curFile];
    }
    
    if ([self.delegate respondsToSelector:@selector(detailViewController:SwipeToNextFileFrom:)]) {
        [self.delegate detailViewController:self SwipeToPreFileFrom:self.curFile];
    }
}

-(void) removeChangePageButton
{
    UIView *leftBtn = [self.view viewWithTag:NXChangePageTagTypeLeft];
    [leftBtn removeFromSuperview];
    UIView *rightBtn = [self.view viewWithTag:NXChangePageTagTypeRight];
    [rightBtn removeFromSuperview];
}


- (void) addfileContentView:(UIView *)fileContentView
{
    if (fileContentView) {
        [[self.view viewWithTag:NXVIEWTAGTYPE_FILECONTENTVIEW] removeFromSuperview];
        fileContentView.tag = NXVIEWTAGTYPE_FILECONTENTVIEW;
        [self.view addSubview:fileContentView];
        [fileContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.bottom.equalTo(self.mas_bottomLayoutGuide);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
    }
}

- (void)showNoFileContentView
{
//    self.noContentView = (UIImageView *)[self.view viewWithTag:FILE_CONTENT_NO_CONTENT_VIEW_TAG];
//    if (self.noContentView == nil) {
//        self.noContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NXIcon"]];
//        self.noContentView.translatesAutoresizingMaskIntoConstraints = NO;
//        self.noContentView.tag = FILE_CONTENT_NO_CONTENT_VIEW_TAG;
//        [self.view addSubview:self.noContentView];
//        
//        [self.noContentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.view);
//            make.width.equalTo(self.view).multipliedBy(0.4);
//            make.height.equalTo(self.noContentView.mas_width);
//        }];
//    }
    
    // comment it because it show when show file content before.
}

#pragma mark - button click event
- (void)printBtnPressed:(id)sender
{
    // should add overlay or not.
    if ([[NXLoginUser sharedInstance].nxlOptManager isNXLFile:self.curFile]) {
        [[NXLoginUser sharedInstance].nxlOptManager canDoOperation:NXLRIGHTPRINT forFile:self.curFile withCompletion:^(BOOL isAllowed, NSString *duid, NXLRights *rights, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                if (isAllowed) {
                    NXOverlayTextInfo *overlayInfo = nil;
                    self.isSteward = isOwner;
                    self.curFileRights = rights;
                    if (!self.isSteward && [rights getObligation:NXLOBLIGATIONWATERMARK]) {
                        overlayInfo = [[NXHeartbeatManager sharedInstance] getOverlayTextInfo];
                        // here to suit for older version of nxl format, if we can't set nxl watermark style, we use default content
                        if ([rights getWatermarkString] != nil) {
                            NSArray *watermarkContent = [[rights getWatermarkString] parseWatermarkWords];
                            NSMutableString *watermarkString = [[NSMutableString alloc] init];
                            for (NXWatermarkWord *watermarkWord in watermarkContent) {
                                [watermarkString appendString:[watermarkWord watermarkLocalizedString]];
                            }
                            overlayInfo.text = watermarkString;
                        }
                    }
                    [self printWithOverlay:overlayInfo];
                }else{
                    if (error.localizedDescription) {
                        [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription];
                    }else {
                         [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_NO_PRINTING_RIGHT", NULL)];
                    }
                }
            });
            
        }];
    } else {
        [self printWithOverlay:nil];
    }
}

- (void)printWithOverlay:(NXOverlayTextInfo *)overlayTextInfo {
    WeakObj(self);
    [self.fileParse snapShot:self.curFile compBlock:^(id image) {
        StrongObj(self);
      BOOL res = NO;
      res =  [[NXPrintInteractionController sharedInstance] printObject:image withOverlay:overlayTextInfo];
         if (res) {
             UIPrintInteractionCompletionHandler handle = ^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError * __nullable error){
                 if (error) {
                     DLog(@"error when print document: %@", error.localizedDescription);
                 }
             };
             
             if ([NXCommonUtils isiPad]) {
                 
                 [[NXPrintInteractionController sharedInstance].printer presentFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES completionHandler:handle]; //iPad
                 
             } else {
                 [[NXPrintInteractionController sharedInstance].printer presentAnimated:YES completionHandler:handle];  //iPhone
             }
             
         }else{
             [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_FILE_TYPE_DO_NOT_SUPPORT_PRINT", NULL)];
         }
    }];
}

- (void)detailBtnPressed:(id)sender
{
    NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
    vc.fileItem = self.curFile;
    vc.shouldOpen = YES;
    vc.isSteward = self.isSteward;
    
    if ([self.curFile isKindOfClass:[NXOfflineFile class]]) {
        if (self.curFile.sorceType == NXFileBaseSorceTypeProject) {
            vc.fileItem  = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:(NXOfflineFile *)self.curFile];
        }else if (self.curFile.sorceType == NXFileBaseSorceTypeMyVaultFile){
            vc.fileItem  = [[NXOfflineFileManager sharedInstance] getMyVaultFilePartner:(NXOfflineFile *)self.curFile];
        }else if (self.curFile.sorceType == NXFileBaseSorceTypeShareWithMe){
            vc.fileItem  = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:(NXOfflineFile *)self.curFile];
        }else if (self.curFile.sorceType == NXFileBaseSorceTypeWorkSpace) {
            vc.fileItem = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:(NXOfflineFile *)self.curFile];
        }else if (self.curFile.sorceType == NXFileBaseSorceTypeSharedWithProject) {
            vc.fileItem = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:(NXOfflineFile *)self.curFile];
        }
    }
    
    if ([self.delegate isKindOfClass:[NXFavoriteViewController class]]) {
        vc.isFromFavPage = YES;
    }
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark - tools


- (NXFileContentType) checkFileContentType:(NSString *) filePath
{
    NSString *extension = [NXCommonUtils getExtension:filePath error:nil];
    
    if (![NXCommonUtils isTheSupportedFormat:extension]) {
        return NXFileContentTypeNotSupport;
    }
    
    if ([extension isEqualToString:FILEEXTENSION_PDF]) {
        return NXFileContentTypePDF;
    }
    
    if ([NXCommonUtils is3DFileFormat:extension]) {
        if ([NXCommonUtils is3DFileNeedConvertFormat:extension]) {
            return NXFileContentType3DNeedConvert;
        }else
        {
            return NXFileContentType3D;
        }
    }
    
//    if ([NXCommonUtils isRemoteViewSupportFormat:extension]) {
//        return NXFileContentTypeRemoteView;
//    }
    
    NSString* mimetype = [NXCommonUtils getMiMeType:filePath];
    if ([[mimetype lowercaseString] hasPrefix:@"audio/"] || [[mimetype lowercaseString] hasPrefix:@"video/"]) {
        return NXFileContentTypeMedia;
    } else{
        return NXFileContentTypeNormal;
    }
}


- (BOOL)checkFileFormat:(NSString *)mimetype
{
    // check the file format,we need to decide what file format nxrmc will support,now just judge the mimetype and file extension
    if([mimetype isEqualToString:@"application/octet-stream"] &&
       ![NXCommonUtils is3DFileFormat:[NXCommonUtils getExtension:self.localCachePath error:nil]])
    {
        return NO;
    }
    return YES;
}


#pragma mark - Clean up
- (void)closeFile
{
    [self.fileParse closeFile:self.curFile];
    self.navigationItem.rightBarButtonItems = @[];
    if(self.shownFile)
    {
        self.shownFile = NO;
    }
  
    [[self.view viewWithTag:NXVIEWTAGTYPE_FAILEDFILEVIEW] removeFromSuperview];
    [[self.view viewWithTag:NXVIEWTAGTYPE_FILECONTENTVIEW] removeFromSuperview];
    
   
    // show no content view
    self.noContentView.hidden = NO;
    
    self.titleView.fileTitle  = NSLocalizedString(@"UI_TITLE_DETAIL", NULL);
    self.titleView.fileRepoAlias = @"";
    
    // set the variable to nil
    self.curFile = nil;
    self.curFileRights = nil;
    self.curService = nil;
    self.localCachePath = nil;
//    self.metaData = nil;
    self.shownOpenInMenu = NO;
    self.operationID = nil;
    
//    self.converted3DfilePath = nil;
//    self.normalPDFfile = nil;
//    self.is3DPDFFile = NO;
//    self.isMediaFile = NO;
    [self removeChangePageButton];
    
    [self.documentController dismissPreviewAnimated:YES];
    [self.documentController dismissMenuAnimated:YES];
    
    [self.fileOptToolBar removeFromSuperview];
    
    [[self.view viewWithTag:NXVIEWTAGTYPE_STATUSVIEW] removeFromSuperview];
    [NXMBManager hideHUDForView:self.view];
}

- (void)cancelOperation
{
    [self.fileParse closeFile:self.curFile];
}


#pragma mark - NXFileOperationToolBarDelegate
- (void)fileOperationToolBar:(NXFileOperationToolBar *)toolBar didSelectItem:(NXFileOperationToolBarItemType) type
{
    if (self.curFile) {
        switch (type) {
            case NXFileOperationToolBarItemTypeFavorite:
            {
                if (self.curFile.isFavorite) {
                    [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:self.curFile withCompletion:^(NXFileBase *file) {
                        
                    }];
                }else{
                    [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:self.curFile withCompleton:^(NXFileBase *file) {
                        
                    }];
                }  
            }
                break;
            case NXFileOperationToolBarItemTypeOffline:
            {
                if (self.curFile.isOffline) {
                    [[NXLoginUser sharedInstance].myRepoSystem unmarkOfflineFileItem:self.curFile];
                }else{
                    [[NXLoginUser sharedInstance].myRepoSystem markOfflineFileItem:self.curFile];
                }
            }
                break;
            case NXFileOperationToolBarItemTypeProtect:
            {
                NXProtectViewController *vc = [[NXProtectViewController alloc] init];
                vc.fileItem = self.curFile;
                vc.delegate = self;
//                vc.providesPresentationContextTransitionStyle = true;
//                vc.definesPresentationContext = true;
//                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
            case NXFileOperationToolBarItemTypeShare:
            {
                NXShareViewController *vc = [[NXShareViewController alloc] init];
                vc.fileItem = self.curFile;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
            case NXFileOperationToolBarItemTypeShow:
            {
                [self expandFileOperationToolBar];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - NXProtectVCDelegate

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
   // if ([vc isKindOfClass:[NXProtectViewController class]]) {
//        NXBoundService *servicie = [NXCommonUtils boudServiceByServiceType:(ServiceType)resultFile.serviceType.integerValue ServiceAccountId:resultFile.serviceAccountId];
//        [self openFile:resultFile currentService:servicie isOpen3rdAPPFile:NO isOpenNewProtectedFile:YES];
//    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
//    NSLog(@"documentInteractionControllerDidDismissOptionsMenu");
    self.shownOpenInMenu  = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISplitViewControllerDelegate
//-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
//{
//    barButtonItem.image = [UIImage imageNamed:@"Back"];
//    self.navigationItem.leftBarButtonItem = barButtonItem;
//}
-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (barButtonItem == self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.leftBarButtonItem = backButton;
       
    }
}
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:[NXMasterTabBarViewController class]])
    {
        if(self.splitViewController.isCollapsed)
        {
            [self closeFile];
        }
    }
}
@end
