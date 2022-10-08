//
//  OMHomeVC.m
//  Order Management
//
//  Created by MAC on 29/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "OMHomeVC.h"
#import "DBManager.h"
#import "ASIHTTPRequest.h"
#import "Attribute.h"
#import "DownloadImage.h"
#import "OMCatalogueVC.h"
#import "CustomCVC.h"
#import "Reachability.h"
#import "OMCustomers.h"
#import "OMOrderVC.h"
#import "OMContactUSVC.h"
#import "OMSettingVC.h"
#import "Singleton.h"
#import "DatabaseManager.h"
#import "OMCartVC.h"
#import "LoadingView.h"
#import "OMMapVC.h"
#import "JMImageCache.h"
#import "OMActivityLogVC.h"
#import "OMUpdateTaskVC.h"
#import "MainViewController.h"
#import "oauthconsumer-master/OAToken.h"
#import "OAuthConsumer.h"
#import "ASIFormDataRequest.h"
#import "NXJsonParser.h"
@interface OMHomeVC ()<MainviewcontrollerDelegate>
{
    DBManager *dbManager;
    __weak IBOutlet UIButton *btnObj_QuickOrder;
    __weak IBOutlet UIButton *btnObj_Catlog;
    __weak IBOutlet UIButton *btnObj_Customer;
    __weak IBOutlet UIButton *btnObj_Task;
    __weak IBOutlet UIButton *btnObj_Map;
    __weak IBOutlet UIButton *btnObj_ContactUs;
    __weak IBOutlet UIButton *btnObj_OrderHistory;
    __weak IBOutlet UILabel *lbl_CurrentDate;
    __weak IBOutlet UILabel *lbl_LastSync;
    __weak IBOutlet UIButton *btn_LogInOut;
    UIBarButtonItem *barLogInOut;
    
    NSMutableArray *arr_TaskList;
    DatabaseManager *objDatabaseManager;
    LoadingView *loadingView;
    BOOL isSyncing;
    BOOL isLoginPressed;
    int TagID;
    NSString *token;
    NSString *secret;
    NSUserDefaults *userDefault;
    NSString *timestamp_StartDate;
    NSMutableArray *arr_AllRecord;
    float GrandTotal;
    NSTimer *DownloadImageProgress,*productProgress;
}
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic,strong) OAConsumer* consumer;
@end

@implementation OMHomeVC
@synthesize lblAgentName;

- (void)viewDidLoad {
    [super viewDidLoad];
    //    NSMutableArray *colA = [NSMutableArray array];
    //    NSMutableArray *colB = [NSMutableArray array];
    //    NSString* fileContents = [NSString  stringWithContentsOfURL:[NSURL URLWithString:@"FL_insurance_sample.csv"] usedEncoding:nil error:nil];
    //    NSArray* rows = [fileContents componentsSeparatedByString:@"\n"];
    //    for (NSString *row in rows){
    //        NSArray* columns = [row componentsSeparatedByString:@","];
    //        [colA addObject:columns[0]];
    //        [colB addObject:columns[1]];
    //    }
    
    userDefault = [NSUserDefaults standardUserDefaults];
    loadingView = [LoadingView loadingView];
    btnObj_Catlog.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_QuickOrder.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_ContactUs.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_Customer.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_Map.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_OrderHistory.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    btnObj_Task.transform = CGAffineTransformMakeRotation( ( -90 * M_PI ) / 360 );
    //    NSArray *arr = self.navigationController.viewControllers;
    NSArray *newArr = @[self];
    self.navigationController.viewControllers = newArr;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkForAutoSync];
    [self SetPagelayout];
    if ([[userDefault objectForKey:@"Download_Type"]  isEqual: @"CategoryImage"]) {
        lbl_ImageProcess.text = @"Downloading category images...";
    }else if ([[userDefault objectForKey:@"Download_Type"]  isEqual: @"ProductImage"]) {
        lbl_ImageProcess.text = @"Downloading product images...";
    }else{
        lbl_ImageProcess.text = @"";
    }
    DownloadImageProgress = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(ShowImage_Progress) userInfo:nil repeats:YES];
    productProgress = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ShowProduct_Progress) userInfo:nil repeats:YES];
    [self LanguageSetup];
    //    NSMutableArray *arrayOfImages = [[userDefault objectForKey:@"arr_RemainQuery"] mutableCopy];
    //    for (int i = 0; i < arrayOfImages.count; i++) {
    //        [dbManager QueryExecute:arrayOfImages[i]];
    //        if (i == arrayOfImages.count - 1) {
    //            NSMutableArray *arr_RemainQuery = [[NSMutableArray alloc] init];
    //            [userDefault setObject:arr_RemainQuery forKey:@"arr_RemainQuery"];
    //        }
    //        //        [arrayOfImages removeObjectAtIndex:i];
    //        //        i--;
    //    }
    //    NSLog(@"%@",arrayOfImages);
}
-(void)LanguageSetup{
    self.navigationItem.title = [dbManager GetValue:[userDefault objectForKey:@"Language"]:@"MAIN MENU"];
    lbl_ObjMap.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Map"];
    lbl_ObjCatalog.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Catalog"];
    lbl_ObjContactUs.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Contact Us"];
    lbl_ObjOrderHistory.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order History"];
    lbl_ObjQuickOrder.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Quick Order"];
    lbl_ObjTask.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Task"];
    lbl_ObjCustomer.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Customers"];
    lbl_NewTask.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"New Task"];
    lbl_UpdateTask.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Update Task"];
}
-(void)ShowImage_Progress{
    if ([[userDefault objectForKey:@"Download_Type"]  isEqual: @"CategoryImage"]) {
        lbl_ImageProcess.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Downloading category images..."];
    }else if ([[userDefault objectForKey:@"Download_Type"]  isEqual: @"ProductImage"]) {
        lbl_ImageProcess.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Downloading product images..."];
    }else{
        lbl_ImageProcess.text = @"";
    }
}
-(void)ShowProduct_Progress{
    lbl_Productprocess.text = [userDefault objectForKey:@"Download_Product"];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [DownloadImageProgress invalidate];
    [productProgress invalidate];
}
-(void)checkForAutoSync{
    __weak NSString *key = @"NextSyncDate";
    if ([userDefault valueForKey:key]){
        NSDate *now = [NSDate date];
        NSDate *nextSync = [userDefault valueForKey:key];
        if ([now compare:nextSync] == NSOrderedDescending) {
            NSLog(@"date1 is later than date2");
            OAToken *token_Check = [self GetToken];
            if (token_Check.key!= nil){
                [self btnClicked_Sync:nil];
            }
        } else if ([now compare:nextSync] == NSOrderedAscending) {
            NSLog(@"date1 is earlier than date2");
        } else {
            NSLog(@"dates are the same");
        }
    }
}
-(void)updateNextSyncDate{
    __weak NSString *key = @"NextSyncDate";
    __weak NSString *keyTimeForNextSync = @"keyTimeForNextSync";
    int anIndex = -1;
    
    if ([userDefault valueForKey:keyTimeForNextSync]){
        NSNumber *num = [userDefault valueForKey:keyTimeForNextSync];
        anIndex = [num intValue];
    }
    
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
}
-(void)SetPagelayout{
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    lbl_CurrentDate.text = [dateFormat stringFromDate:today];
    self.navigationController.navigationBarHidden = NO;
    
    if ([userDefault valueForKey:@"lastSyncDate"]){
        lbl_LastSync.text = [userDefault valueForKey:@"lastSyncDate"];
    }else{
        lbl_LastSync.text = @"Not yet synced";
    }
    
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    arr_TaskList = [[dbManager GetTaskList] mutableCopy];
    [clv_TaskList reloadData];
    
    barLogInOut = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logout btn"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(btnClicked_Reset:)];
    
    if ([userDefault objectForKey:@"key"] != nil){
        barLogInOut.tintColor = [UIColor whiteColor];
    }else{
        barLogInOut.tintColor = [UIColor colorWithRed:76.0/255.0 green:192.0/255.0 blue:225.0/255.0 alpha:1.0];
    }
    
    
    NSString *logoURL = [userDefault objectForKey:@"LogoURL"];
    NSURL *url = [NSURL URLWithString:logoURL];
    
    [[JMImageCache sharedCache] imageForURL:url completionBlock:^(UIImage *image) {
        UIImage *imgOriginal =[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *barLogo = [[UIBarButtonItem alloc] initWithImage:imgOriginal style:UIBarButtonItemStylePlain target:nil action:nil];
        
        if ([userDefault objectForKey:@"dealer"] == nil) {
            self.navigationItem.leftBarButtonItems = @[barLogo];
        }else{
            NSString *Title = [dbManager GetSalesName:[userDefault objectForKey:@"dealer"]];
            // UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:Title style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationItem.leftBarButtonItems = @[barLogo];
            lblAgentName.text = Title;
        }
        
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        
    }];
    
    if ([userDefault boolForKey:@"Is_Client"] == false) {
        self.navigationItem.rightBarButtonItems = @[barLogInOut];
    }else{
        NSString *Cart_Item = [dbManager GetQuantity:[userDefault objectForKey:@"Order_Id"]];
        NSString *Customer_Name = [dbManager GetCustomerName:[userDefault objectForKey:@"Customer_Id"]];
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(Clicked_Cart)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 140, 42)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 50, 42)];
        [label setFont:[UIFont fontWithName:@"Arial" size:16]];
        [label setText:Cart_Item];
        label.textAlignment = NSTextAlignmentLeft;
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [button addSubview:label];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:Customer_Name style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.rightBarButtonItems = @[barLogInOut,barButton,bar];
        NSArray *arr = [objDatabaseManager GetCustomerName:[userDefault objectForKey:@"Customer_Id"]];
        lbl_CustomerName.text = [NSString stringWithFormat:@"Customer : %@ %@",[arr[0] objectForKey:@"firstname"],[arr[0] objectForKey:@"lastname"]];
    }
    NSMutableArray *arrComment = [userDefault objectForKey:@"messages"];
    if (arrComment.count > 0) {
        for (int i = 0; i < arrComment.count ; i++) {
            if (i == 0) {
                txt_ServerComment.text = arrComment[0];
            }else{
                txt_ServerComment.text = [NSString stringWithFormat:@"%@ \n %@",txt_ServerComment.text,arrComment[i]];
            }
        }
    }else{
        txt_ServerComment.text = @"";
    }
    
    if (self.shouldStartSync == true){
        self.shouldStartSync = false;
        [self btnClicked_Sync:self];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. kkkk
}
-(void)Clicked_Cart{
    OMCartVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCartVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
-(IBAction)unwindSegueMainMenu:(UIStoryboardSegue *)segue{
    NSLog(@"Back to Main Menu");
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_UpdateTask:(id)sender {
    if (isSyncing)
        return;
    OMUpdateTaskVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMUpdateTaskVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)btnClicked_AddNewTask:(id)sender {
    if (isSyncing)
        return;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Write Task Description" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
- (IBAction)btnClicked_ActivityLog:(id)sender {
    if (isSyncing)
        return;
    OMActivityLogVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMActivityLogVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)btnClicked_Setting:(id)sender {
    if (isSyncing)
        return;
    OMSettingVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMSettingVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)btnClicked_Customer:(id)sender {
    if (isSyncing)
        return;
    if ([[userDefault objectForKey:@"Customer_Master"]  isEqual: @"1"]) {
        OMCustomers *ObjOMCustomer = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMCustomers"];
        [[self navigationController] pushViewController:ObjOMCustomer animated:YES];
    }else{
        
    }
}
- (IBAction)btnClicked_Map:(id)sender {
    if (isSyncing)
        return;
    if ([[userDefault objectForKey:@"Customer_Master"]  isEqual: @"1"]) {
        OMMapVC *ObjOMCustomer = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMMapVC"];
        [[self navigationController] pushViewController:ObjOMCustomer animated:YES];
    }else{
        
    }
}
- (IBAction)btnClicked_OrderHistory:(id)sender {
    if (isSyncing)
        return;
    OMOrderVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMOrderVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
- (IBAction)btnClicked_Task:(id)sender {
    if (!view_Task.hidden) {
        view_Task.hidden =true;
    }else{
        view_Task.hidden = false;
    }
}
- (IBAction)btnClicked_QuickOrder:(id)sender {
    if (isSyncing)
        return;
    if ([[userDefault objectForKey:@"Product"]  isEqual: @"1"]) {
        OMCatalogueVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCatalogueVC"];
        vc.PageDefination = @"QuickOrder";
        [[self navigationController] pushViewController:vc animated:YES];
    }else{
        
    }
}
- (IBAction)btnClicked_Catlog:(id)sender {
    if (isSyncing)
        return;
    if ([[userDefault objectForKey:@"Product"]  isEqual: @"1"]) {
        OMCatalogueVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCatalogueVC"];
        vc.PageDefination = @"Catlog";
        [[self navigationController] pushViewController:vc animated:YES];
    }else{
    }
}
- (IBAction)btnClicked_ContactUs:(id)sender {
    if (isSyncing)
        return;
    OMContactUSVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMContactUSVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (IBAction)btnClicked_Sync:(id)sender {
    if (isSyncing)
        return;
    if ([userDefault boolForKey:@"completefirstsync"] == true) {
        return;
    }
    if ([self connected]){
        OAToken *token_Check = [self GetToken];
        if (token_Check.key!= nil){
            [self callAfterSixtySecond];
        }else{
            Reachability *reachability = [Reachability reachabilityForLocalWiFi];
            NetworkStatus networkStatus = [reachability currentReachabilityStatus];
            if (networkStatus == 1) {
                if ([userDefault boolForKey:@"Is_Wifi"] == false) {
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"For Sync in wifi network you need to change setting" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }else{
                if ([userDefault boolForKey:@"Is_Data"] == false) {
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"For Sync in lan network you need to change setting" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
    }else{
        [self updateNextSyncDate];
    }
}
- (IBAction)btnClicked_Reset:(id)sender {
    
    if ([self  GetToken] != nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Are you sure you want to logout? It will clear all your records."] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 31;
        [alert show];
    }else{
        isLoginPressed = true;
        MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        vc.delegate = self;
        //vc.shouldClearCache = true;
        [[self navigationController] pushViewController:vc animated:YES];
    }
}
#pragma mark - MainViewControllerDelegate
-(void)getAccessTokenSuccess{
    [self callAfterSixtySecond];
}
-(void)getAccessTokenFail{
    
}
-(void)DeleteRecord{
    NSString *ConsumerKey = [userDefault objectForKey:@"ConsumerKey"];
    NSString *ConsumerSecret = [userDefault objectForKey:@"ConsumerSecret"];
    NSString *LogoURL = [userDefault objectForKey:@"LogoURL"];
    NSString *StoreURL = [userDefault objectForKey:@"StoreURL"];
    
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
    
    //    self.accesstoken = nil;
    //    self.tokensecret = nil;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [userDefault synchronize];
    
    [userDefault setObject:ConsumerKey forKey:@"ConsumerKey"];
    [userDefault setObject:ConsumerSecret forKey:@"ConsumerSecret"];
    [userDefault setObject:LogoURL forKey:@"LogoURL"];
    [userDefault setObject:StoreURL forKey:@"StoreURL"];
    [userDefault setBool:true forKey:@"isLaunch"];
    [userDefault synchronize];
    
    barLogInOut.tintColor = [UIColor colorWithRed:76.0/255.0 green:192.0/255.0 blue:225.0/255.0 alpha:1.0];
    [self SetPagelayout];
}
- (OAToken *)GetToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"accessToken"];
    _accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return _accessToken;
}
- (OAConsumer *)GetConsumer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"consumer"];
    _consumer = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return _consumer;
}
-(void)callAfterSixtySecond{
    isSyncing = true;
    [self DelteAllRecord];
}

#pragma mark - Fail Alert
-(void)showNetwortFailerAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There is some problem with network. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark - Webservice for Delete All Records
-(void)DelteAllRecord{
    timestamp_StartDate = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSURL * url;
    [loadingView startLoadingWithMessage:@"Removing unnecessary records..." inView:self.view];
    if ([[userDefault objectForKey:@"Product"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@deleted/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
        OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
        [request setHTTPMethod:@"GET"];
        [request setParameters:[NSArray arrayWithObject:callbackParam]];
        [request setTimeoutInterval:300];
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:request delegate:nil completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
            if (data == nil) {
                [self GetLanguageDetail];
            }else{
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSMutableArray class]]){
                    for (int i = 0;  i < [json count]; i++) {
                        NSString *str_Message = [NSString stringWithFormat:@"Delete Record of %d  From Record %lu",i+1,(unsigned long)[json count]];
                        [loadingView changeLoadingMessage:str_Message];
                        id json_Parse = [json objectAtIndex:i];
                        [dbManager DeleteRecord:json_Parse];
                    }
                    [self GetLanguageDetail];
                }
                else if([json isKindOfClass:[NSDictionary class]]){
                    if ([json objectForKey:@"messages"]) {
                        [loadingView stopLoading];
                        isSyncing = false;
                        MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                        vc.delegate = self;
                        [[self navigationController] pushViewController:vc animated:YES];
                    }else{
                        [dbManager DeleteRecord:json];
                        [self GetLanguageDetail];
                    }
                    
                }
                else{
                    [self GetLanguageDetail];
                }
            }
        } failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            [self showNetwortFailerAlert];
            isSyncing = false;
        }];
    }else{
        [self GetLanguageDetail];
    }
}
#pragma mark - GetLangauage Detail
-(void)GetLanguageDetail{
    if ([[userDefault objectForKey:@"IsLanguage"]  isEqual: @"1"]) {
        [self GetLoginDetail];
    }else{
        [loadingView changeLoadingMessage:@"Getting language data..."];
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@login/languagetranslations/yes",[[Singleton sharedSingleton] getBaseURL]]];
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
        OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
        [request setHTTPMethod:@"GET"];
        [request setParameters:[NSArray arrayWithObject:callbackParam]];
        [request setTimeoutInterval:300];
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
            if (data == nil) {
                [self GetLoginDetail];
            }else{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    isSyncing = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    [dbManager ClearLanguageMaster];
                    [userDefault setObject:@"1" forKey:@"IsLanguage"];
                    NSArray *LanguageArray= [[[json objectForKey:@"login"] objectForKey:@"translations"]allKeys];
                    for (int i = 0; i < [LanguageArray count];i++) {
                        NSString *lang = LanguageArray[i];
                        [userDefault setObject:LanguageArray[0] forKey:@"Language"];
                        NSDictionary *json_lang = [[[json objectForKey:@"login"] objectForKey:@"translations"] valueForKey:lang];
                        NSArray *LanguageArrayWord= [json_lang allKeys];
                        for (int j = 0; j <LanguageArrayWord.count; j++) {
                            [dbManager InsertLanguage:lang :LanguageArrayWord[j] :[json_lang valueForKey:LanguageArrayWord[j]]];
                        }
                    }
                    [self GetLoginDetail];
                }
            }
        } failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            [self showNetwortFailerAlert];
            isSyncing = false;
        }];
    }
}
#pragma mark - Get Login Details;
-(void)GetLoginDetail{
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting sales agent data..."]];
    //    [loadingView changeLoadingMessage:@"Getting sales agent data..."];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@login",[[Singleton sharedSingleton] getBaseURL]]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self GetCountry];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json objectForKey:@"messages"]) {
                [loadingView stopLoading];
                isSyncing = false;
                MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                vc.delegate = self;
                [[self navigationController] pushViewController:vc animated:YES];
            }else{
                [userDefault setObject:[[json objectForKey:@"login"]objectForKey:@"currency_code"] forKey:@"currency_code"];
                [userDefault setObject:[[json objectForKey:@"login"]objectForKey:@"dealer"] forKey:@"dealer"];
                [userDefault setObject:[[[json objectForKey:@"login"] objectForKey:@"comments"] objectForKey:@"messages"] forKey:@"messages"];
                NSMutableArray *arrComment = [[[json objectForKey:@"login"] objectForKey:@"comments"] objectForKey:@"messages"];
                if (arrComment.count > 0) {
                    for (int i = 0; i < arrComment.count ; i++) {
                        if (i == 0) {
                            txt_ServerComment.text = arrComment[0];
                        }else{
                            txt_ServerComment.text = [NSString stringWithFormat:@"%@ \n %@",txt_ServerComment.text,arrComment[i]];
                        }
                    }
                }
                [self GetCountry];
            }
        }
    } failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}

#pragma mark - Webservice for GetCountry
- (void)GetCountry{
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting countries..."]];
    //    [loadingView changeLoadingMessage:@"Getting countries..."];
    [dbManager CreateCountry:@"Country"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Country"]  isEqual: @"1"]) {
        [self performSelectorOnMainThread:@selector(GetAttribute) withObject:nil waitUntilDone:true];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@countries/",[[Singleton sharedSingleton] getBaseURL]]];
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
        OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
        [request setHTTPMethod:@"GET"];
        [request setParameters:[NSArray arrayWithObject:callbackParam]];
        [request setTimeoutInterval:300];
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
            if (data == nil) {
                [self performSelectorOnMainThread:@selector(GetAttribute) withObject:nil waitUntilDone:true];
            }else{
                NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSMutableArray class]]){
                    if (json.count > 0){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            for (int i =0 ; i <json.count; i ++) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSString *message = [NSString stringWithFormat: @"%d country of %lu total",i+1,(long)json.count];
                                    [loadingView changeLoadingMessage:message];
                                });
                                NSDictionary *dic = [json objectAtIndex:i];
                                [dbManager InsertCountry:@"Country":dic];
                                if (i+1 == json.count) {
                                    [userDefault setObject:@"1" forKey:@"Country"];
                                    [self performSelectorOnMainThread:@selector(GetAttribute) withObject:nil waitUntilDone:true];
                                }
                            }
                        });
                    }
                }else{
                    [self performSelectorOnMainThread:@selector(GetAttribute) withObject:nil waitUntilDone:true];
                }
            }
        } failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            [self showNetwortFailerAlert];
            isSyncing = false;
        }];
    }
}
#pragma mark - Webservice for Get Attribute
-(void)GetAttribute{
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting attributes..."]];
    [dbManager CreateAttributeMaster:@"Attribute_Master"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Attributes"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@attributes/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
        //        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@attributes",[[Singleton sharedSingleton] getBaseURL]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@attributes",[[Singleton sharedSingleton] getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self performSelectorOnMainThread:@selector(GetCategory) withObject:nil waitUntilDone:true];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *AttributeArray= [json allKeys];
                    for (int i =0 ; i <AttributeArray.count; i ++) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *message = [NSString stringWithFormat: @"%d attribute of %lu total",i+1,(long)AttributeArray.count];
                            [loadingView changeLoadingMessage:message];
                            if (i+1 == AttributeArray.count) {
                            }
                        });
                        NSDictionary *dic = [json valueForKey:[AttributeArray objectAtIndex:i]];
                        [dbManager InsertAttributes:@"Attribute_Master":dic];
                        if (i+1 == AttributeArray.count) {
                            [userDefault setObject:@"1" forKey:@"Attributes"];
                            [self performSelectorOnMainThread:@selector(GetCategory) withObject:nil waitUntilDone:true];
                        }
                    }
                });
            }else{
                [self performSelectorOnMainThread:@selector(GetCategory) withObject:nil waitUntilDone:true];
            }
        }
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}
#pragma mark - Webservice for Get Category
- (void)GetCategory{
    NSLog(@"Get Category time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Retrieving categories..."]];
    [dbManager CreateCategoryMaster:@"Category_Master"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Category"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@categories/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@categories",[[Singleton sharedSingleton] getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self performSelectorOnMainThread:@selector(GetSaleAgent) withObject:nil waitUntilDone:true];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *ProductArray= [json allKeys];
                    for (int i =0 ; i <ProductArray.count; i ++) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *message = [NSString stringWithFormat: @"%d category of %lu total",i +1,(long)ProductArray.count];
                            [loadingView changeLoadingMessage:message];
                        });
                        NSDictionary *dic = [json valueForKey:[ProductArray objectAtIndex:i]];
                        [dbManager InsertCategory:@"Category_Master":dic];
                        if (i+1 == ProductArray.count) {
                            [userDefault setObject:@"1" forKey:@"Category"];
                            [self performSelectorOnMainThread:@selector(GetSaleAgent) withObject:nil waitUntilDone:true];
                        }
                    }
                });
            }else{
                [self performSelectorOnMainThread:@selector(GetSaleAgent) withObject:nil waitUntilDone:true];
            }
        }
        
    } failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}

#pragma mark - Get Sales Agent
-(void)GetSaleAgent{
    NSLog(@"Get sales agent time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Retrieving agents..."]];
    NSURL * url;
    if ([[userDefault objectForKey:@"SalesAgent"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@salesagents/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@salesagents/",[[Singleton sharedSingleton] getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self CustomerGropus];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    isSyncing = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    [dbManager InsertSalesAgent:json];
                    [self CustomerGropus];
                }
            }else{
                [self CustomerGropus];
            }
        }
    } failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
        
    }];
}
#pragma mark - Webservice for Get Groups
- (void)CustomerGropus{
    NSLog(@"Get Customer Group time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting customer groups..."]];
    [dbManager CreateCustGroups:@"CustGroups"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@custgroups",[[Singleton sharedSingleton] getBaseURL]]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
        }else{
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json objectForKey:@"messages"]) {
                [loadingView stopLoading];
                isSyncing = false;
                MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                vc.delegate = self;
                [[self navigationController] pushViewController:vc animated:YES];
            }else{
                [dbManager InsertCustGroups:@"CustGroups":json];
            }
        }
        [self NewCustomer_List];
    } failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}
#pragma mark - New Customer List
-(void)NewCustomer_List{
    NSLog(@"New Customer list time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Uploading customer data..."]];
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager getNewCustomer] mutableCopy];
    arrcustID = [[NSMutableArray alloc]init];
    
    for (int i = 0; i< _temp.count; i++) {
        strID = [[_temp valueForKey:@"Customer_id"] objectAtIndex:i];
        [arrcustID addObject:strID];
        NSMutableArray *arrCustAddress = [[objDatabaseManager getCustomerAddress:strID] mutableCopy];
        NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:arrCustAddress ,@"addresses", nil];
        [eventData setObject:[[_temp valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
        [eventData setObject:[[_temp valueForKey:@"middlename" ]objectAtIndex:i] forKey:@"middlename"];
        [eventData setObject:[[_temp valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
        [eventData setObject:[[_temp valueForKey:@"email" ]objectAtIndex:i] forKey:@"email"];
        [eventData setObject:[[_temp valueForKey:@"dob" ]objectAtIndex:i] forKey:@"dob"];
        [eventData setObject:[[_temp valueForKey:@"suffix" ]objectAtIndex:i] forKey:@"suffix"];
        [eventData setObject:[[_temp valueForKey:@"prefix" ]objectAtIndex:i] forKey:@"prefix"];
        [eventData setValue:[[_temp valueForKey:@"prefix" ]objectAtIndex:i] forKey:@"prefix"];
        [eventData setValue:[[_temp valueForKey:@"Password" ]objectAtIndex:i] forKey:@"Password"];
        [eventData setValue:[[_temp valueForKey:@"group_id" ]objectAtIndex:i] forKey:@"group_id"];
        [eventData setValue:[[_temp valueForKey:@"entity_id" ]objectAtIndex:i] forKey:@"entity_id"];
        [eventData setValue:[[_temp valueForKey:@"sales_agent_id" ]objectAtIndex:i] forKey:@"sales_agent_id"];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        //        [self CreateCustomers:jsonData2];
        [dbManager CreateCustomerMaster:@"Customer_Master"];
        [dbManager CreateCustomerAddress:@"CustomerAddress"];
        
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/",[[Singleton sharedSingleton] getBaseURL]]];
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:[[OAPlaintextSignatureProvider alloc]init]];
        [request prepare];
        
        OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
        [request setHTTPMethod:@"POST"];
        [request setParameters:[NSArray arrayWithObject:callbackParam]];
        [request setHTTPBody:jsonData2];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        
        [request setTimeoutInterval:300];
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
            if (data == nil) {
                if (![dbManager isNewCustomerCreatedInOffline]){
                    [self UpdateCustomer_List];
                }
            }else{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSDictionary class]]){
                    NSString *strsuccess = [[json objectForKey:@"create-customer"] objectForKey:@"success"];
                    if ([strsuccess isEqualToString:@"true"]) {
                        arrcustIDCopy = [[NSMutableArray alloc]init];
                        [arrcustIDCopy addObject:[arrcustID objectAtIndex:0]];
                        [dbManager Delete_Local_Add_NewCustomerAddress:[arrcustIDCopy objectAtIndex:0]];
                        [dbManager Delete_Local_Add_NewCustomer:[arrcustIDCopy objectAtIndex:0]];
                        [dbManager UpdateCustomerId:[arrcustIDCopy objectAtIndex:0] :json[@"create-customer"][@"cust_id"]];
                        NSLog(@"%@",arrcustIDCopy[0]);
                        [arrcustID removeObjectAtIndex:0];
                    }
                    else{
                    }
                }
                if (arrcustID.count == 0){
                    NSLog(@"response time anil");
                    [self UpdateCustomer_List];
                }
            }
            
        } failedBlock:^{
            [loadingView stopLoading];
            [self showNetwortFailerAlert];
            isSyncing = false;
        }];
        
    }
    if (_temp.count <= 0) {
        [self UpdateCustomer_List];
    }
}
#pragma mark CreateNew Customer WebService
- (void)CreateCustomers :(NSData *)Customer{
    [dbManager CreateCustomerMaster:@"Customer_Master"];
    [dbManager CreateCustomerAddress:@"CustomerAddress"];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/",[[Singleton sharedSingleton] getBaseURL]]];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:[[OAPlaintextSignatureProvider alloc]init]];
    [request prepare];
    
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setHTTPBody:Customer];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                NSString *strsuccess = [[json objectForKey:@"create-customer"] objectForKey:@"success"];
                if ([strsuccess isEqualToString:@"true"]) {
                    [dbManager Delete_Local_Add_NewCustomerAddress:strID];
                    [dbManager Delete_Local_Add_NewCustomer:strID];
                    [dbManager UpdateCustomerId:strID :json[@"create-customer"][@"cust_id"]];
                }
                else{
                }
            }
        }
        if (![dbManager isNewCustomerCreatedInOffline]){
            [self UpdateCustomer_List];
        }
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}
#pragma mark Update customer List
-(void)UpdateCustomer_List{
    NSLog(@"Get update time");
    
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager getUpadtedCustomer] mutableCopy];
    for (int i = 0; i< _temp.count; i++) {
        strID = [[_temp valueForKey:@"Customer_id"] objectAtIndex:i];
        NSString *strsuffix = [[_temp valueForKey:@"suffix"] objectAtIndex:i];
        NSMutableArray *arrCustAddress = [[objDatabaseManager getCustomerAddress:strID] mutableCopy];
        DictPostAddress = [[NSMutableDictionary alloc]init];
        for (int i = 0; i< arrCustAddress.count; i++) {
            NSMutableDictionary *DictAddress = [[NSMutableDictionary alloc]init];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
            [DictAddress setObject:strsuffix forKey:@"suffix"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"region" ]objectAtIndex:i] forKey:@"region"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"street" ]objectAtIndex:i] forKey:@"street"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"company" ]objectAtIndex:i] forKey:@"company"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"city" ]objectAtIndex:i] forKey:@"city"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"country" ]objectAtIndex:i] forKey:@"country"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"postcode" ]objectAtIndex:i] forKey:@"postcode"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"telephone" ]objectAtIndex:i] forKey:@"telephone"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"fax" ]objectAtIndex:i] forKey:@"fax"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"default_shipping" ]objectAtIndex:i] forKey:@"default_shipping"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"default_billing" ]objectAtIndex:i] forKey:@"default_billing"];
            [DictAddress setObject:[[arrCustAddress valueForKey:@"entity_id" ]objectAtIndex:i] forKey:@"id"];
            NSString *straddressID = [[arrCustAddress valueForKey:@"entity_id" ]objectAtIndex:i];
            NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:DictAddress,straddressID, nil];
            [DictPostAddress addEntriesFromDictionary:FinelData];
        }
        NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:DictPostAddress ,@"addresses", nil];
        [eventData setObject:[[_temp valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
        [eventData setObject:[[_temp valueForKey:@"middlename" ]objectAtIndex:i] forKey:@"middlename"];
        [eventData setObject:[[_temp valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
        [eventData setObject:[[_temp valueForKey:@"email" ]objectAtIndex:i] forKey:@"email"];
        [eventData setObject:[[_temp valueForKey:@"dob" ]objectAtIndex:i] forKey:@"dob"];
        [eventData setObject:[[_temp valueForKey:@"suffix" ]objectAtIndex:i] forKey:@"suffix"];
        [eventData setObject:[[_temp valueForKey:@"prefix" ]objectAtIndex:i] forKey:@"prefix"];
        [eventData setValue:[[_temp valueForKey:@"Password" ]objectAtIndex:i] forKey:@"password"];
        [eventData setValue:[[_temp valueForKey:@"group_id" ]objectAtIndex:i] forKey:@"group_id"];
        [eventData setValue:[[_temp valueForKey:@"sales_agent_id" ]objectAtIndex:i] forKey:@"sales_agent_id"];
        [eventData setValue:[[_temp valueForKey:@"gender" ]objectAtIndex:i] forKey:@"gender"];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        [self UpdateCustomers:jsonData2];
    }
    if (_temp.count <= 0) {
        [self GetCustomers];
    }
}

#pragma mark UpdateCustomer
- (void)UpdateCustomers :(NSData *)Customer{
    NSLog(@"Get update customer time");
    
    [dbManager CreateCustomerMaster:@"Customer_Master"];
    [dbManager CreateCustomerAddress:@"CustomerAddress"];
    NSString *customerID = @"";
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/%@",[[Singleton sharedSingleton] getBaseURL],customerID]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:[[OAPlaintextSignatureProvider alloc]init]];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"PUT"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setHTTPBody:Customer];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                [dbManager Delete_Local_Update_CustomerAddress:strID];
                [dbManager Delete_Local_Update_NewCustomer:strID];
            }else{
            }
        }
        if (![dbManager isNewCustomerCreatedInOffline]){
            [self GetCustomers];
        }
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}
#pragma mark - Webservice for Get Customer
- (void)GetCustomers{
    NSLog(@"Get Customer time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting customers..."]];
    [dbManager CreateCustomerMaster:@"Customer_Master"];
    [dbManager CreateCustomerAddress:@"CustomerAddress"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Customer_Master"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/",[[Singleton sharedSingleton]getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self  GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self SyncOrder];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                NSString *strError = [[[[json objectForKey:@"messages"] objectForKey:@"error"] valueForKey:@"code"] objectAtIndex:0];
                if ([strError intValue] == 405){
                    [self SyncOrder];
                }else{
                    if ([[userDefault objectForKey:@"Customer_Master"]  isEqual: @"1"]) {
                        [dbManager InsertCustomerMaster:@"Customer_Master" :json :@"false" :@"false"];
                        [self SyncOrder];
                        
                    }else{
                        NSData *customerdata = [NSKeyedArchiver archivedDataWithRootObject:json];
                        [[NSUserDefaults standardUserDefaults] setObject:customerdata forKey:@"CustomerInformation"];
                        [dbManager InsertCustomerMaster:@"Customer_Master" :json :@"false" :@"false"];
                        [self SyncOrder];
                    }
                }
            }else{
                [self SyncOrder];
            }
        }
        
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}

#pragma mark - Sync All Record
-(void)SyncOrder{
    NSLog(@"Get sync order time");
    arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"AllPlaceOrder":@"0"] mutableCopy];
    if (arr_AllRecord.count > 0) {
        [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Placing order(s)..."]];
        for (int j = 0; j <arr_AllRecord.count; j++) {
            GrandTotal = 0 ;
            NSArray *arr_Record = [objDatabaseManager GetParticularOrderList:[arr_AllRecord[j]objectForKey:@"Order_Id"]];
            NSMutableArray *arr_SendRecord = [[NSMutableArray alloc]init];
            for (int i =0;i <arr_Record.count;i++){
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setObject:[arr_Record[i] objectForKey:@"Parent_ID"] forKey:@"product"];
                [dic setObject:[arr_Record[i] objectForKey:@"qty"] forKey:@"qty"];
                GrandTotal = [[arr_Record[i] objectForKey:@"qty"]floatValue] * [[arr_Record[i] objectForKey:@"Base_Price"]floatValue] + GrandTotal;
                NSString *Attribute_Id = [arr_Record[i] objectForKey:@"Attribute_Id"];
                if ([Attribute_Id  isEqual: @""]) {
                }else{
                    NSArray *arrAttribute = [Attribute_Id componentsSeparatedByString:@","];
                    NSMutableDictionary *Attribute_Dic = [[NSMutableDictionary alloc]init];
                    for (int k = 0;  k <arrAttribute.count; k++) {
                        NSArray *arr_AttributeDescription =  [objDatabaseManager GetAttributeDetail:[arr_Record[i] objectForKey:@"product"] :arrAttribute[k]];
                        [Attribute_Dic setObject:[arr_AttributeDescription[0] objectForKey:@"value_id"] forKey:arrAttribute[k]];
                    }
                    [dic setObject:Attribute_Dic forKey:@"super_attribute"];
                }
                [arr_SendRecord addObject:dic];
            }
            NSDictionary *dict=@{@"customer": [arr_AllRecord[j] objectForKey:@"Customer_Id"],
                                 @"dealer":[userDefault objectForKey:@"dealer"],
                                 @"comment":[dbManager GetCommentFromOrder:[arr_AllRecord[j]objectForKey:@"Order_Id"]],
                                 @"products":arr_SendRecord
                                 };
            NSError *errJson = nil;
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&errJson];
            NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@orders",[[Singleton sharedSingleton] getBaseURL]]];
            OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:[[OAPlaintextSignatureProvider alloc]init]];
            [request prepare];
            OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
            [request setHTTPMethod:@"POST"];
            [request setParameters:[NSArray arrayWithObject:callbackParam]];
            [request setHTTPBody:jsonData2];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
            [request setTimeoutInterval:300];
            
            //New Changes
            
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            
            [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
                if (data == nil) {
                }else{
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"JSON Response: %@",json);
                    if ([[[json objectForKey:@"create-order"] objectForKey:@"success"]  isEqual: @"true"]) {
                        [userDefault setBool:false forKey:@"Is_Client"];
                        //                        [dbManager DeleteOrder]
                        [dbManager UpdateOrderID:[arr_AllRecord[j]objectForKey:@"Order_Id"] :[[[json objectForKey:@"create-order"] objectForKey:@"order_details"] objectForKey:@"entity_id"]:[NSString stringWithFormat:@"%.2f",GrandTotal]];
                    }else{
                    }
                }
                if (j == arr_AllRecord.count - 1) {
                    [self performSelectorOnMainThread:@selector(GetOrder) withObject:nil waitUntilDone:true];
                }
            } failedBlock:^{
                NSLog(@"Failed");
                [loadingView stopLoading];
                [self showNetwortFailerAlert];
                isSyncing = false;
            }];
        }
    }else{
        [self performSelectorOnMainThread:@selector(GetOrder) withObject:nil waitUntilDone:true];
    }
}
#pragma mark - Webservice for Get Order
-(void)GetOrder{
    NSLog(@"Get order time");
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Retrieving orders..."]];
    NSURL *url;
    if ([[userDefault objectForKey:@"Order"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@orders/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@orders",[[Singleton sharedSingleton] getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self performSelectorOnMainThread:@selector(GetProduct) withObject:nil waitUntilDone:true];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *AttributeArray= [json allKeys];
                    for (int i =0 ; i <AttributeArray.count; i ++) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *message = [NSString stringWithFormat: @"%d order of %lu total",i+1,(long)AttributeArray.count];
                            [loadingView changeLoadingMessage:message];
                        });
                        NSDictionary *dic = [json valueForKey:[AttributeArray objectAtIndex:i]];
                        [dbManager InsertSyncedOrder:@"Order_Master":dic];
                        if (i+1 == AttributeArray.count) {
                            [userDefault setObject:@"1" forKey:@"Order"];
                            [self performSelectorOnMainThread:@selector(GetProduct) withObject:nil waitUntilDone:true];
                        }
                        
                    }
                });
                
            }else{
                [self performSelectorOnMainThread:@selector(GetProduct) withObject:nil waitUntilDone:true];}
        }
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}

#pragma mark - Webservice for Get Product
- (void)GetProduct{
    [loadingView changeLoadingMessage:[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Getting products..."]];
    [dbManager CreateProductMaster:@"Product_Master"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Product"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@products/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@products/",[[Singleton sharedSingleton] getBaseURL]]];
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
//    });
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:500];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        if (data == nil) {
            [self performSelectorOnMainThread:@selector(SetNewTimeStamp) withObject:nil waitUntilDone:true];
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    isSyncing = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        NSArray *ProductArray= [json allKeys];
                        for (int i =0 ; i <ProductArray.count; i ++) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *message = [NSString stringWithFormat: @"%d product of %lu total",i+1,(long)ProductArray.count];
                                
                                [loadingView changeLoadingMessage:message];
                               
                            });
                            NSDictionary *dic = [json valueForKey:[ProductArray objectAtIndex:i]];
                            [dbManager InsertProduct:@"Product_Master":dic];
                            if (i+1 == ProductArray.count) {
                                [userDefault setObject:@"1" forKey:@"Product"];
                                [self performSelectorOnMainThread:@selector(SetNewTimeStamp) withObject:nil waitUntilDone:true];
                            }
                        }
                    });
                    
                }
                
            }else{
                isSyncing = false;
                [self performSelectorOnMainThread:@selector(SetNewTimeStamp) withObject:nil waitUntilDone:true];
            }
        }
    } failedBlock:^{
        [loadingView stopLoading];
        [self showNetwortFailerAlert];
        isSyncing = false;
    }];
}

#pragma mark - Update time stamp
-(void)SetNewTimeStamp{
    isSyncing = false;
    [userDefault setObject:timestamp_StartDate forKey:@"timestamp"];
    [loadingView stopLoading];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message: [dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Sync Success"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    // set last sync date
    NSDate *today = [NSDate new];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    lbl_LastSync.text = [dateFormat stringFromDate:today];
    [userDefault setObject:lbl_LastSync.text  forKey:@"lastSyncDate"];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"dd-MMM-yyyy   hh:mm"];
    [dbManager InsertActivityLog:[dateFormat1 stringFromDate:today] :[dbManager GetValue:[userDefault objectForKey:@"Language"]:@"Sync completed"]];
    [self updateNextSyncDate];
    DownloadImage *downloadImage = [[DownloadImage alloc]init];
    [downloadImage DownloadBackgroundImage];
    [self LanguageSetup];
}

#pragma mark - UICollectionViewDelegate & DataSource Method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  arr_TaskList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.lbl_Task.text = arr_TaskList[indexPath.row][1];
    if ([arr_TaskList[indexPath.row][2]  isEqual: @"0"]){
        cell.img_TaskProgress.backgroundColor = [UIColor lightGrayColor];
        cell.img_Task.image = [UIImage imageNamed:@"UnSelectedTask"];
    }else{
        cell.img_TaskProgress.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:168.0/255.0 blue:183.0/255.0 alpha:1.0];
        cell.img_Task.image = [UIImage imageNamed:@"SelectedTask"];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *status = arr_TaskList[indexPath.row][2];
    if ([status  isEqual: @"0"]) {
        status = @"1";
    }else{
        status = @"0";
    }
    [dbManager Update_Task:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]:status];
    arr_TaskList = [[dbManager GetTaskList] mutableCopy];
    [clv_TaskList reloadData];
}
#pragma mark - UIAlertViewDelegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        [self.view endEditing:true];
        if(buttonIndex == 0){
            __weak NSString *str_TaskDescription = [alertView textFieldAtIndex:0].text;
            if(str_TaskDescription.length > 0){
                [dbManager InsertTask:str_TaskDescription];
                arr_TaskList = [[dbManager GetTaskList] mutableCopy];
                [clv_TaskList reloadData];
            }else{
                [self.view endEditing:true];
            }
        }
    } if (alertView.tag==31){
        if(buttonIndex == 0){
            [self DeleteRecord];
            isSyncing = false;
            [loadingView stopLoading];
        }
    }
}
#pragma mark - Check internet connection
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
@end
