//
//  NXDefine.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 27/04/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#ifndef NXDefine_h
#define NXDefine_h


#endif /* NXDefine_h */

//// 判断是真机还是模拟器
//#if TARGET_OS_IPHONE
//// iPhone Device
//#endif
//
//#if TARGET_IPHONE_SIMULATOR
//// iPhone Simulator
//#endif

#define dispatch_main_async_safe(block)             \
if ([NSThread isMainThread]) {                      \
block();                                            \
} else {                                            \
dispatch_async(dispatch_get_main_queue(), block);   \
}

#ifdef __cplusplus
#define NX_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define NX_EXTERN	        extern __attribute__((visibility ("default")))
#endif

#define weakSelf(weakSelf) __weak typeof(self)weakSelf = self;
#define strongSelf(strongSelf) __strong typeof(weakSelf)strongSelf = weakSelf; if (!strongSelf) return;

// 由角度获取弧度
#define NXDegreesToRadian(x) (M_PI * (x) / 180.0)
// 由弧度获取角度
#define NXRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#define NXNotificationCenter [NSNotificationCenter defaultCenter]
#define NXUserDefaults [NSUserDefaults standardUserDefaults]
#define NXFirstWindow [UIApplication sharedApplication].windows.firstObject
#define NXRootViewController NXFirstWindow.rootViewController

/** APP版本号 */
#define NXAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
/** APP BUILD 版本号 */
#define NXAppBuildVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
/** APP名字 */
#define NXAppDisplayName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
/** 当前语言 */
#define NXLocalLanguage [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]
/** 当前国家 */
#define NXLocalCountry [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]


/******* RGB颜色 *******/
#define NXColor(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0  blue:(b) / 255.0  alpha:1.0]
/******* RGB颜色 *******/


/******* 屏幕尺寸 *******/
#define NXMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define NXMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define NXMainScreenBounds [UIScreen mainScreen].bounds
/******* 屏幕尺寸 *******/


/******* 设备型号和系统 *******/
/** 检查系统版本 */
#define NXSYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define NXSYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define NXSYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define NXSYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define iOS5_OR_LATER NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")
#define iOS6_OR_LATER NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")
#define iOS7_OR_LATER NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define iOS8_OR_LATER NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define iOS9_OR_LATER NXSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")

/** 系统和版本号 */
#define NXDevice [UIDevice currentDevice]
#define NXDeviceName NXDevice.name                           // 设备名称
#define NXDeviceModel NXDevice.model                         // 设备类型
#define NXDeviceLocalizedModel NXDevice.localizedModel       // 本地化模式
#define NXDeviceSystemName NXDevice.systemName               // 系统名字
#define NXDeviceSystemVersion NXDevice.systemVersion         // 系统版本
#define NXDeviceOrientation NXDevice.orientation             // 设备朝向
//#define NXDeviceUUID NXDevice.identifierForVendor.UUIDString // UUID // 使用苹果不让上传App Store!!!
#define NXiOS8 ([NXDeviceSystemVersion floatValue] >= 8.0)   // iOS8以上
#define NXiPhone ([NXDeviceModel rangeOfString:@"iPhone"].length > 0)
#define NXiPod ([NXDeviceModel rangeOfString:@"iPod"].length > 0)
#define NXiPad (NXDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
/******* 设备型号和系统 *******/

///******* 日志打印替换 *******/
//#import <CocoaLumberjack/CocoaLumberjack.h>
//#ifdef DEBUG
//
//#define NXLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//#define NXLogError(frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//#define NXLogWarn(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//#define NXLogInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//#define NXLogDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//#define NXLogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//
//
//#define NXAssert(...) NSAssert(__VA_ARGS__)
//
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//
//#else
//
//#define NXLog(...)
//#define NXLogError(frmt, ...)
//#define NXLogWarn(frmt, ...)
//#define NXLogInfo(frmt, ...)
//#define NXLogDebug(frmt, ...)
//
//#define NXAssert(...)
//static const int ddLogLevel = LOG_LEVEL_OFF;
//
//#endif
///******* 日志打印替换 *******/


/******* 归档解档 *******/
#define NXCodingImplementation                              \
- (void)encodeWithCoder:(NSCoder *)aCoder {                 \
unsigned int count = 0;                                     \
Ivar *ivars = class_copyIvarList([self class], &count);     \
for (int i = 0; i < count; i++) {                           \
Ivar ivar = ivars[i];                                       \
const char *name = ivar_getName(ivar);                      \
NSString *key = [NSString stringWithUTF8String:name];       \
id value = [self valueForKey:key];                          \
[aCoder encodeObject:value forKey:key];                     \
}                                                           \
free(ivars);                                                \
}                                                           \
\
- (instancetype)initWithCoder:(NSCoder *)aDecoder {         \
if (self = [super init]) {                                  \
unsigned int count = 0;                                     \
Ivar *ivars = class_copyIvarList([self class], &count);     \
for (int i = 0; i < count; i++) {                           \
Ivar ivar = ivars[i];                                       \
const char *name = ivar_getName(ivar);                      \
NSString *key = [NSString stringWithUTF8String:name];       \
id value = [aDecoder decodeObjectForKey:key];               \
[self setValue:value forKey:key];                           \
}                                                           \
free(ivars);                                                \
}                                                           \
return self;                                                \
}
/******* 归档解档 *******/
