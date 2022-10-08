//
//  OMConfigurationVC.m
//  Order Management
//
//  Created by MAC on 27/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMConfigurationVC.h"
#import "OMHomeVC.h"

@interface OMConfigurationVC ()

@end

@implementation OMConfigurationVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = true;
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)showNetwortFailerAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There is some problem with network. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)btnClicked_Done:(id)sender {
    if ([txt_EnterUrl.text  isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter url" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSURL *configUrl = [NSURL URLWithString:txt_EnterUrl.text];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:configUrl
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:20.0];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];
        if (error == nil){
            NSPropertyListFormat format;
            NSString *errorStr = nil;
            NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:data
                                                                        mutabilityOption:NSPropertyListImmutable
                                                                                  format:&format
                                                                        errorDescription:&errorStr];
            if (errorStr == nil){
                @try {
                    if (dictionary[@"ConsumerKey"]) {
                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                        [userDefault setObject:[dictionary objectForKey:@"ConsumerKey"] forKey:@"ConsumerKey"];
                        [userDefault setObject:[dictionary objectForKey:@"ConsumerSecret"] forKey:@"ConsumerSecret"];
                        [userDefault setObject:[dictionary objectForKey:@"LogoURL"] forKey:@"LogoURL"];
                        [userDefault setObject:[dictionary objectForKey:@"StoreURL"] forKey:@"StoreURL"];
                        [userDefault setBool:true forKey:@"isLaunch"];
                        [userDefault synchronize];
                        OMHomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMHomeVC"];
                        vc.shouldStartSync = true;
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Config.Xml file is wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                } @catch (NSException *e) {
                }
            }
            else {
            }
        }else{
            [self showNetwortFailerAlert];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([txt_EnterUrl.text  isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter url" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSURL *configUrl = [NSURL URLWithString:txt_EnterUrl.text];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:configUrl
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:20.0];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];
        if (error == nil){
            NSPropertyListFormat format;
            NSString *errorStr = nil;
            NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:data
                                                                        mutabilityOption:NSPropertyListImmutable
                                                                                  format:&format
                                                                        errorDescription:&errorStr];
            if (errorStr == nil){
                @try {
                    if (dictionary[@"ConsumerKey"]) {
                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                        [userDefault setObject:[dictionary objectForKey:@"ConsumerKey"] forKey:@"ConsumerKey"];
                        [userDefault setObject:[dictionary objectForKey:@"ConsumerSecret"] forKey:@"ConsumerSecret"];
                        [userDefault setObject:[dictionary objectForKey:@"LogoURL"] forKey:@"LogoURL"];
                        [userDefault setObject:[dictionary objectForKey:@"StoreURL"] forKey:@"StoreURL"];
                        [userDefault setBool:true forKey:@"isLaunch"];
                        [userDefault synchronize];
                        OMHomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMHomeVC"];
                        vc.shouldStartSync = true;
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Config.Xml file is wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                } @catch (NSException *e) {
                }
            }
            else {
            }
        }else{
            [self showNetwortFailerAlert];
        }
    }

    return true;
}
@end