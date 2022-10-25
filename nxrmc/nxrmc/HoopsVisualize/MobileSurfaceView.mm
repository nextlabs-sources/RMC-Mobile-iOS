#import "MobileSurfaceView.h"
#import <QuartzCore/QuartzCore.h>

#import "MobileSurface.h"
#import "NXCommonUtils.h"

#import <iostream>
#import <fstream>

// xib file name
#define IPDAD_XIBNAME   @"MobileSurfaceViewController_iPad"
#define IPHONE_XIBNAME  @"MobileSurfaceViewController_iPhone"

// button icon image name
#define ICON_ORBIT          @"ic_orbit.png"
#define ICON_ZOOMAREA       @"ic_zoom_area.png"
#define ICON_SELECT_POINT   @"ic_select_point.png"
#define ICON_SELECT_AREA    @"ic_select_area.png"
#define ICON_FLY            @"ic_fly.png"

// Fix max amount of touches so we can use static array
const int MAX_TOUCHES = 10;


@interface MobileSurfaceView ()

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (assign, nonatomic) BOOL supportCuttingSection;

// Current toolbar state (Operators, Modes, User Code)
@property NSInteger selectedSegmentIndex;
@end

@implementation MobileSurfaceView

+ (Class)layerClass
{
    // Indicate that we will be using OpenGL ES
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    // Update the display when it needs to be repainted
    [super layoutSubviews];
    self.surfacePointer->refresh();
}

- (void)commontInit
{
    // Create instance of our UserMobileSurface
    NSDate*date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970];
    self.guiSurfaceId = (int)time;
    self.surfacePointer = createMobileSurface(self.guiSurfaceId);
    
    // Indicate we will be using multi-touch
    self.multipleTouchEnabled = YES;
    
    // Setup EAGLLayer for OpenGL ES
    CAEAGLLayer * eaglLayer = static_cast<CAEAGLLayer*>(self.layer);
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil];
    
    // Pass self as windowId to bind().
    // __bridge needed for ARC since we need a non-Objective-C pointer
    bool status = self.surfacePointer->bind((__bridge void*)self);
    
    if (status == false) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NXCommonUtils currentBundleDisplayName]
                              message:NSLocalizedString(@"ALERTVIEW_MESSAGE_BINDFAIL", NULL)
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"UI_BOX_OK", NULL)
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (UIImage *)snapshotImage {
    HPS::Canvas ca = self.surfacePointer->GetCanvas();
    
    unsigned int width, height;
    ca.GetWindowKey().GetWindowInfoControl().ShowWindowPixels(width, height);

    //get cache file path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath= [documentsDirectory stringByAppendingPathComponent:@"snapshot.png"];

    HPS::Image::ExportOptionsKit export_options;
    export_options.SetFormat(HPS::Image::Format::Png);
    export_options.SetSize(width, height);
    HPS::Image::File::Export(filePath.UTF8String, ca.GetWindowKey(), export_options);

    export_options.Empty();

    NSData *imageData = [NSData dataWithContentsOfFile:filePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }

    return [UIImage imageWithData:imageData];
}

- (void)addOverlay:(UIView *)overlayView {
    overlayView.userInteractionEnabled = NO;
    overlayView.tag = 121;
    [[self viewWithTag:121] removeFromSuperview];
    [self addSubview:overlayView];
    overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDict = @{@"overlayView":overlayView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlayView]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|" options:0 metrics:nil views:viewDict]];
    
    [self bringSubviewToFront:self.segControl];
    [self bringSubviewToFront:self.button1];
    [self bringSubviewToFront:self.button2];
    [self bringSubviewToFront:self.button3];
    [self bringSubviewToFront:self.button4];
}

- (void)removeOverlay
{
    UIView *overlay = [self viewWithTag:121];
    [overlay removeFromSuperview];
}

- (void)removeCuttingSection {
    [self.segControl removeSegmentAtIndex:2 animated:NO];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commontInit];
    [self updateToolbars];
}

+ (id) mobileSurfaceViewWithXibFileWithSupportCuttingSection:(BOOL)supportCuttingSection
{
    NSString *nibName = IPHONE_XIBNAME;
    if ([NXCommonUtils getUserInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        nibName = IPDAD_XIBNAME;
    }
    MobileSurfaceView *view = (MobileSurfaceView*)[[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil]lastObject];
    if (supportCuttingSection == NO) {
        [view removeCuttingSection];
    }
    return view;
}
- (void)setButtonImageTitle:(UIButton *)button withTitle:(NSString *)title withImage:(NSString *)image
{
    button.hidden = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
}

- (void)updateToolbars
{
    if (self.selectedSegmentIndex == TOOLBAR_OPERATORS) {
        [self setButtonImageTitle:self.button1 withTitle:nil withImage:ICON_ORBIT];
        [self setButtonImageTitle:self.button2 withTitle:nil withImage:ICON_ZOOMAREA];
        [self setButtonImageTitle:self.button3 withTitle:nil withImage:ICON_SELECT_POINT];
        [self setButtonImageTitle:self.button4 withTitle:nil withImage:ICON_SELECT_AREA];
        [self setButtonImageTitle:self.button5 withTitle:nil withImage:ICON_FLY];
    } else if (self.selectedSegmentIndex == TOOLBAR_MODES) {
        [self setButtonImageTitle:self.button1 withTitle:NSLocalizedString(@"BUTTON_TITLE_1", NULL) withImage:nil];
        [self setButtonImageTitle:self.button2 withTitle:NSLocalizedString(@"BUTTON_TITLE_2", NULL) withImage:nil];
        [self setButtonImageTitle:self.button3 withTitle:NSLocalizedString(@"BUTTON_TITLE_3", NULL) withImage:nil];
        [self setButtonImageTitle:self.button4 withTitle:NSLocalizedString(@"BUTTON_TITLE_4", NULL) withImage:nil];
        [self setButtonImageTitle:self.button5 withTitle:NSLocalizedString(@"BUTTON_TITLE_5", NULL) withImage:nil];
    } else if (self.selectedSegmentIndex == TOOLBAR_USER_CODE){
        [self setButtonImageTitle:self.button1 withTitle:NSLocalizedString(@"BUTTON_TITLE_6", NULL) withImage:nil];
        [self setButtonImageTitle:self.button2 withTitle:NSLocalizedString(@"BUTTON_TITLE_7", NULL) withImage:nil];
        [self setButtonImageTitle:self.button3 withTitle:NSLocalizedString(@"BUTTON_TITLE_8", NULL) withImage:nil];
        [self setButtonImageTitle:self.button4 withTitle:NSLocalizedString(@"BUTTON_TITLE_9", NULL) withImage:nil];
        [self setButtonImageTitle:self.button5 withTitle:NSLocalizedString(@"BUTTON_TITLE_10", NULL) withImage:nil];
    }
}

- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    self.selectedSegmentIndex = sender.selectedSegmentIndex;
    [self updateToolbars];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(segControlValueChanged:)])
    {
        [self.delegate segControlValueChanged:sender];
    }
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    // Connect button presses with UserMobileSurface actions
    if(self.delegate && [self.delegate respondsToSelector:@selector(buttonPressed:withSelectedSegmentIndex:)])
    {
        [self.delegate buttonPressed:sender withSelectedSegmentIndex:self.selectedSegmentIndex];
    }
}

- (int) buildTouchEvent:(NSSet*) touches withXArray:(int*)xPosArray withYArray:(int*)yPosArray withIdArray:(HPS::TouchID*)idArray {

    float const scaleFactor = self.contentScaleFactor;
    
    // Build touch event data from the input touches
    int numTouches = 0;
    for (UITouch * touch in touches) {
        if (numTouches >= MAX_TOUCHES)
            break;
        
        CGPoint location = [touch locationInView:self];
        
        xPosArray[numTouches] = (int)(scaleFactor * location.x);
        yPosArray[numTouches] = (int)(scaleFactor * location.y);
        
        // UITouch * can serve as touch id
        idArray[numTouches] = (HPS::TouchID)touch;
        numTouches++;
    }
    
    return numTouches;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int xPosArray[MAX_TOUCHES];
    int yPosArray[MAX_TOUCHES];
    HPS::TouchID idArray[MAX_TOUCHES];
    
    NSSet * allTouches = [event allTouches];
    
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    int tap_count = (int)[touch tapCount];
    
    int numTouches = [self buildTouchEvent:touches withXArray:xPosArray withYArray:yPosArray withIdArray:idArray];
    self.surfacePointer->touchDown(numTouches, xPosArray, yPosArray, idArray, tap_count);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int xPosArray[MAX_TOUCHES];
    int yPosArray[MAX_TOUCHES];
    HPS::TouchID idArray[MAX_TOUCHES];
    
    int numTouches = [self buildTouchEvent:touches withXArray:xPosArray withYArray:yPosArray withIdArray:idArray];
    self.surfacePointer->touchMove(numTouches, xPosArray, yPosArray, idArray);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int xPosArray[MAX_TOUCHES];
    int yPosArray[MAX_TOUCHES];
    HPS::TouchID idArray[MAX_TOUCHES];
    
    int numTouches = [self buildTouchEvent:touches withXArray:xPosArray withYArray:yPosArray withIdArray:idArray];
    self.surfacePointer->touchUp(numTouches, xPosArray, yPosArray, idArray);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.surfacePointer->touchesCancel();
}

- (void)dealloc {
    destoryMobileSurface(self.guiSurfaceId);
}
@end
