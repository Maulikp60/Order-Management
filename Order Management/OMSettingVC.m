//
//  OMSettingVC.m
//  Order Management
//
//  Created by MAC on 18/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMSettingVC.h"
#import "DBManager.h"
#import "OMConfigurationVC.h"
#import "JMImageCache.h"
#import "DatabaseManager.h"
@interface OMSettingVC ()
{
    NSUserDefaults *userDefault;
    DBManager *dbManager;
    NSMutableArray *arr_Time,*arr_Language;
    NSString *str_DropdownTag;
    DatabaseManager *objDatabaseManager;
}
@end

@implementation OMSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefault = [NSUserDefaults standardUserDefaults];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    arr_Time = [[NSMutableArray alloc]initWithObjects:@"30 Min",@"2 Hr",@"6 Hr",@"24 Hr",nil];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    [obj_Language setTitle:[userDefault objectForKey:@"Language"] forState:UIControlStateNormal];
    arr_Language = [[[objDatabaseManager  GetLanguageList] valueForKey:@"Language"] mutableCopy];
    if ([userDefault boolForKey:@"Is_Wifi"] == false) {
        [btn_ObjWifi setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
    }else{
        [btn_ObjWifi setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
    }
    if ([userDefault boolForKey:@"Is_Data"] == false) {
        [btn_ObjData setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
    }else{
        [btn_ObjData setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
    }
    if ([userDefault boolForKey:@"Is_Productprice"] == false) {
        [btn_objProductPrice setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
    }else{
        [btn_objProductPrice setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
    }
    if ([userDefault boolForKey:@"Is_Sku"] == false) {
        [btn_objsku setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
    }else{
        [btn_objsku setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
    }
    if ([userDefault boolForKey:@"Is_AutoFrequency"] == false) {
        [Obj_SwitchFrequency setOn:false];
    }else{
        [Obj_SwitchFrequency setOn:true];
    }
    txt_Email.text = [userDefault objectForKey:@"Agent_Email"];
    txt_Password.text = [userDefault objectForKey:@"Agent_Password"];
    [self LanguageSetup];
}
-(void)LanguageSetup{
    self.navigationItem.title = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SETTINGS"];
    lbl_AutomaticFrequncy.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"AUTOMATIC-SYNC-FREQUENCY"];
    lbl_Data.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"USE 3G/4G DATA"];
    lbl_Language.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"language"];
    lbl_Email.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Email"];
    lbl_Password.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Password"];
    lbl_Wifi.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"WIFI"];
    [btn_ObjReset setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"RESET"] forState:UIControlStateNormal];
    [btn_ObjSave setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SAVE"] forState:UIControlStateNormal];
     lbl_Showsku.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Show SKU"];
     lbl_ShowProduct.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Show Product Price"];
    UIBarButtonItem *btn_Back= [[UIBarButtonItem alloc] initWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back)];
    self.navigationItem.leftBarButtonItem = btn_Back;

}

#pragma mark - Bar Butoon Method
-(void)action_Back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_LangaugeSelection:(id)sender {
    str_DropdownTag = @"Language";
    [Dropobj fadeOut];
    [self showPopUpWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Select application language"] withOption:arr_Language xy:obj_Language.frame.origin size:CGSizeMake(200,240) isMultiple:YES];
}

- (IBAction)btnClicked_Save:(id)sender {
    if ([txt_Email.text  isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Please enter email"] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
        [alert show];
    }else if ([txt_Password.text  isEqual: @""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Please enter password"] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [userDefault setObject:txt_Email.text forKey:@"Agent_Email"];
        [userDefault setObject:txt_Password.text forKey:@"Agent_Password"];
        [self.view endEditing:true];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Email Account detail has been saved successfully."] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)btnClicked_Switch:(id)sender {
    if ([sender isOn]) {
        str_DropdownTag = @"AutoFrequncy";
        [Obj_SwitchFrequency setOn:true];
        [userDefault setBool:true forKey:@"Is_AutoFrequency"];
        [Dropobj fadeOut];
        [self showPopUpWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Select Auto Sync Frequency Time"] withOption:arr_Time xy:Obj_SwitchFrequency.frame.origin size:CGSizeMake(200,240) isMultiple:YES];
    }else{
        [Obj_SwitchFrequency setOn:false];
        [userDefault setBool:false forKey:@"Is_AutoFrequency"];
        __weak NSString *key = @"NextSyncDate";
        __weak NSString *keyTimeForNextSync = @"keyTimeForNextSync";
        [userDefault removeObjectForKey:key];
        [userDefault removeObjectForKey:keyTimeForNextSync];
    }
}
- (IBAction)btnClicked_Wifi:(id)sender {
    if ([userDefault boolForKey:@"Is_Wifi"] == true) {
        [btn_ObjWifi setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
        [userDefault setBool:false forKey:@"Is_Wifi"];
    }else{
        [btn_ObjWifi setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
        [userDefault setBool:true forKey:@"Is_Wifi"];
    }
}
- (IBAction)btnClicked_Data:(id)sender {
    if ([userDefault boolForKey:@"Is_Data"] == true) {
        [btn_ObjData setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
        [userDefault setBool:false forKey:@"Is_Data"];
    }else{
        [btn_ObjData setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
        [userDefault setBool:true forKey:@"Is_Data"];
    }
}
- (IBAction)btnClicked_Reset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Are you sure you want to reset all data.?"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Yes"] otherButtonTitles:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"No"], nil];
    alert.tag = 31;
    [alert show];
}
- (IBAction)btnClicked_productprice:(id)sender {
    if ([userDefault boolForKey:@"Is_Productprice"] == true) {
        [btn_objProductPrice setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
        [userDefault setBool:false forKey:@"Is_Productprice"];
    }else{
        [btn_objProductPrice setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
        [userDefault setBool:true forKey:@"Is_Productprice"];
    }
}
- (IBAction)btnClicked_Sku:(id)sender {
    if ([userDefault boolForKey:@"Is_Sku"] == true) {
        [btn_objsku setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
        [userDefault setBool:false forKey:@"Is_Sku"];
    }else{
        [btn_objsku setBackgroundImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
        [userDefault setBool:true forKey:@"Is_Sku"];
    }
}

#define ACCESSTOKEN_KEY @"doubanaccesstoken"
#define TOKENSECRET_KEY  @"doubantokensecret"
-(void)DeleteRecord{
    [dbManager ClearAttribute_Master];
    [dbManager ClearCategory_Master];
    [dbManager ClearCountry];
    [dbManager ClearCustGroups];
    [dbManager ClearCustomer_Master];
    [dbManager ClearCustomerAddress];
    [dbManager ClearMediaGallery_Master];
    [dbManager ClearOrder_Master];
    [dbManager ClearPrice_Master];
    [dbManager ClearProduct_Attribute_Master];
    [dbManager ClearProduct_Master];
    [dbManager ClearStore_Master];
    [dbManager ClearTaskList];
    [dbManager ClearWebsite_Master];
    [dbManager ClearActivitylog];
    [dbManager clearSalesAgent];
    
    NSUserDefaults *userDefault1 = [NSUserDefaults standardUserDefaults];
    [userDefault1 removeObjectForKey:ACCESSTOKEN_KEY];
    [userDefault1 removeObjectForKey:TOKENSECRET_KEY];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [userDefault1 synchronize];
    
    [[JMImageCache sharedCache] removeAllObjects];
    OMConfigurationVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMConfigurationVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==31){
        if(buttonIndex == 0){
            [self DeleteRecord];
        }else {
        }
    }else{
    }
}
#pragma mark - DropDownList Method
-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:NO];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    [Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    if ([str_DropdownTag  isEqual: @"AutoFrequncy"]) {
        [userDefault  setObject:arr_Time[anIndex] forKey:@"AutoFrequncy_Time"];
        __weak NSString *key = @"NextSyncDate";
        __weak NSString *keyTimeForNextSync = @"keyTimeForNextSync";
        if ([userDefault valueForKey:key]){
            [userDefault removeObjectForKey:key];
            [userDefault removeObjectForKey:keyTimeForNextSync];
        }
        [userDefault setObject:[NSNumber numberWithInt:anIndex] forKey:keyTimeForNextSync];
        
        /* @"30 Min",@"2 Hr",@"6 Hr",@"24 Hr" */
        NSDate *now = [NSDate date];
        NSDate *new;
        if (anIndex == 0){
            // 30 Min
            new = [now dateByAddingTimeInterval:1800];
        }else if (anIndex == 1){
            // 2 Hr
            new = [now dateByAddingTimeInterval:7200];
        }else if (anIndex == 2){
            // 6 Hr
            new = [now dateByAddingTimeInterval:21600];
        }else if (anIndex == 1){
            // 24 Hr
            new = [now dateByAddingTimeInterval:86400];
        }
        [userDefault setObject:new forKey:key];
    }else{
        [userDefault setObject:arr_Language[anIndex] forKey:@"Language"];
        [obj_Language setTitle:arr_Language[anIndex] forState:UIControlStateNormal];
        [self LanguageSetup];
    }
}

@end