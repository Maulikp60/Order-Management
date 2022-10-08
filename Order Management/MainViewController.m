//
//  MainViewController.m
//  TechnoGerms.com
//
//  Created by Ammad iOS on 06/12/2013.
//  Copyright (c) 2013 Techno. All rights reserved.

//  codegerms.com See more details on codegerms.com

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Singleton.h"
//NSString *client_id = @"5cc34e84d55ee4a78faadfc803919b59";
//NSString *secret = @"fbc1a4f39a687347ec0b7ba3d4afa56a";
//NSString *callback = @"http://csvihara.ddns.net/array312.php";
NSString *callback = @"qb://success";


@interface MainViewController ()
{
    NSString *client_id,*secret;
    NSUserDefaults *userdefault;
}
@end

@implementation MainViewController
@synthesize webview, isLogin,accessToken;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userdefault = [NSUserDefaults standardUserDefaults];
    client_id = [[Singleton sharedSingleton] getConsumerKey];
    secret = [[Singleton sharedSingleton] getConsumerSecret];
    consumer = [[OAConsumer alloc] initWithKey:client_id secret:secret realm:nil];
    NSURL* requestTokenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/initiate",[userdefault objectForKey:@"StoreURL"]]];
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:consumer
                                                                                  token:nil
                                                                                  realm:nil
                                                                      signatureProvider:[[OAPlaintextSignatureProvider alloc] init]];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:callback];
    [requestTokenRequest setHTTPMethod:@"GET"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    
     [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
   
    NSURL* authorizeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/admin/oauth_authorize",[userdefault objectForKey:@"StoreURL"]]];
    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                            consumer:consumer
                                                                               token:nil
                                                                               realm:nil
                                                                   signatureProvider:nil];
    NSString* oauthToken = requestToken.key;
    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    //oauth_token_secret
    NSString* oauthTokenSecret = requestToken.secret;
    OARequestParameter* oauthTokenSecretParam = [[OARequestParameter alloc] initWithName:@"oauth_token_secret" value:oauthTokenSecret];
    [authorizeRequest setParameters:[NSArray arrayWithObjects:oauthTokenParam,oauthTokenSecretParam, nil]];
    
    //http://csvihara.ddns.net/shop/admin/oauth_authorize?oauth_callback=http%3A%2F%2Fcsvihara.ddns.net%2F&oauth_token=dbfea177d5f4515bc5db585420b6f964
    [webview loadRequest:authorizeRequest];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"HTTP BODY: %@",httpBody);
    accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    [AppDelegate getDelegate].accessToken = accessToken;
    [AppDelegate getDelegate].consumer = consumer ;
    OAToken *token_sync  = [[OAToken alloc] init];
    OAConsumer *consumer_sync = [[OAConsumer alloc]init];
    [token_sync saveCustomObject:accessToken];
    [consumer_sync saveCustomObject:consumer];
//    [userdefault setObject:accessToken forKey:@"accessToken"];
//    [userdefault setObject:consumer forKey:@"consumer"];
//    [userdefault synchronize];
    if (self.delegate != nil)
        [self.delegate performSelector:@selector(getAccessTokenSuccess) withObject:nil];
    
    [self.navigationController popViewControllerAnimated:YES];

    if (accessToken) {
        /** USE ACCESS TOKEN
        NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
        OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:userdatarequestu
                                                                                   consumer:consumer
                                                                                      token:accessToken
                                                                                      realm:nil
                                                                          signatureProvider:nil];

        [requestTokenRequest setHTTPMethod:@"GET"];
        
        
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:requestTokenRequest
                                 delegate:self
                        didFinishSelector:@selector(didReceiveuserdata:data:)
                          didFailSelector:@selector(didFailOdatah:error:)];    
         */
    } else {
        // ERROR!
    }
}


- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
   // NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
    // ERROR!
}


- (void)didFailOdatah:(OAServiceTicket*)ticket error:(NSError*)error {
    // ERROR!
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //  [indicator startAnimating];
        NSString *temp = [NSString stringWithFormat:@"%@",request];
  //  BOOL result = [[temp lowercaseString] hasPrefix:@"http://codegerms.com/callback"];
   // if (result) {
//    NSRange textRange = [[temp lowercaseString] rangeOfString:[@"http://csvihara.ddns.net" lowercaseString]];
    NSRange textRange = [[temp lowercaseString] rangeOfString:[callback lowercaseString]];
    
    if(textRange.location != NSNotFound){
        
    
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            [webView stopLoading];
            //
            //https://api.twitter.com/oauth/access_token
            NSURL* accessTokenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token",[userdefault objectForKey:@"StoreURL"]]];

            requestToken.verifier = verifier;


            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:consumer token:requestToken realm:nil signatureProvider:nil];
            
//            OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
//            OARequestParameter* callBackParam = [[OARequestParameter alloc] initWithName:@"callback" value:callback];
                OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:callback];
            
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
            
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                              didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
        }
        
        //[webView removeFromSuperview];
        
        return YES;
    }
    
    return YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    // ERROR!
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // [indicator stopAnimating];
}



@end
