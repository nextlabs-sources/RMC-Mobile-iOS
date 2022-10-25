//
//  NXGoogleDriveAuther.m
//  nxrmc
//
//  Created by EShi on 8/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGoogleDriveAuther.h"
#import "AppDelegate.h"
#import "AppAuth.h"
#import "GTMAppAuth.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
#import "NXCommonUtils.h"
#import "GTLRDriveService.h"
#import "NXGoogleDrive.h"
#import "NSData+zip.h"

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

/*! @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */
static NSString *const kClientID = GOOGLEDRIVECLIENTID;

/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
static NSString *const kRedirectURI = GOOGLEDRIVE_REDIRECT_URI;

/*! @brief @c NSCoding key for the authState property.
 */
static NSString *const kExampleAuthorizerKey = @"authorization";

@interface NXGoogleDriveAuther()<NXServiceOperationDelegate>

@end
@implementation NXGoogleDriveAuther
- (void) authRepoInViewController:(UIViewController *) vc
{
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    self.authViewController = vc;
    NSArray *scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDrive, OIDScopeEmail, OIDScopeProfile,nil];
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                            
                                                            if (!configuration) {
                                                                NSLog(@"error %@", error.localizedDescription);                                                                return;
                                                            }
                                                            
                                                            // builds authentication request
                                                            OIDAuthorizationRequest *request =
                                                            [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                                                                          clientId:kClientID
                                                                                                            scopes:scopes
                                                                                                       redirectURL:redirectURI
                                                                                                      responseType:OIDResponseTypeCode
                                                                                              additionalParameters:nil];
                                                            // performs authentication request
                                                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                            appDelegate.currentAuthorizationFlow =
                                                            [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                                           presentingViewController:vc
                                                                                                           callback:^(OIDAuthState *_Nullable authState,
                                                                                                                      NSError *_Nullable error) {
                                                                                                               if (authState) {
                                                                                                                   
                                                                                                                   GTMAppAuthFetcherAuthorization *authorization =
                                                                                                                   [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                                                                                   
                                                                                                                   [self saveGtmAuthorization:authorization];
                                                                                                                   NSLog(@"Got authorization tokens. Access token: %@",
                                                                                                                         authState.lastTokenResponse.accessToken);
                                                                                                               } else {
                                                                                                                   [self saveGtmAuthorization:nil];
                                                                                                                   NSLog(@"Authorization error: %@", [error localizedDescription]);
                                                                                                               }
                                                                                                           }];
                                                        }];
    self.authViewController = vc;
    self.repoType = kServiceGoogleDrive;
}

- (void)authRepoInViewController:(UIViewController *)vc repostioryAlias:(NSString *)repoAlias {
  
}


- (void)authRepoWithRepostioryAlias:(NSString *)repoAlias {
  
}


- (void)saveGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
// for sync
//    authorization = [NSKeyedUnarchiver unarchiveObjectWithData:authData];
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(repoAuther:didFinishAuth:)) && authorization != nil) {
        // step1. saveauth to keychain
        NSString *keychainKey = [[NSUUID UUID] UUIDString];
        [GTMAppAuthFetcherAuthorization saveAuthorization:authorization
                                        toKeychainForName:keychainKey];
        // step2. notify delegate
        NSDictionary *authInfoDict = @{AUTH_RESULT_ACCOUNT:authorization.userEmail, AUTH_RESULT_ACCOUNT_ID:authorization.userID, AUTH_RESULT_ACCOUNT_TOKEN:keychainKey, AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:kServiceGoogleDrive]};
        [self.delegate repoAuther:self didFinishAuth:authInfoDict];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate repoAuthCanceled:self];
        });
    }
}

- (void)dealloc
{
    DLog(@"GoogleAuther dealloc");
}


@end
