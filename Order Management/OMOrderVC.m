//
//  OMOrderVC.m
//  Order Management
//
//  Created by MAC on 13/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMOrderVC.h"
#import "DatabaseManager.h"
#import "CustomTVC.h"
#import "OMOrderHistoryVC.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
#import "Singleton.h"
#import "OMCartVC.h"
#import "LoadingView/LoadingView.h"
#import "JMImageCache.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "oauthconsumer-master/OAToken.h"
#import "OAConsumer.h"
#import "ArrayToDicConvert.h"
@interface OMOrderVC ()
{
    DatabaseManager *objDatabaseManager;
    NSMutableArray *arr_AllRecord;
    DBManager *dbManager;
    NSUserDefaults *userDefault;
    NSInteger TagID;
    NSMutableArray *arr_Status,*arr_Sum;
    LoadingView *loadingView;
    BOOL issync,isBack;
    ArrayToDicConvert *obj_ArrayyToDic;
    BOOL checkSelect;
    NSString *strID;
}
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic,strong) OAConsumer* consumer;
@end

@implementation OMOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
    
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    userDefault = [NSUserDefaults standardUserDefaults];
    arr_Status = [[NSMutableArray alloc]initWithObjects:@"All",@"Synced",@"Not Sync",@"Saved",nil];
    loadingView = [LoadingView loadingView];
    userDefault = [NSUserDefaults standardUserDefaults];
    NSString *logoURL = [userDefault objectForKey:@"LogoURL"];
    NSURL *url = [NSURL URLWithString:logoURL];
    UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back)];
    
    [[JMImageCache sharedCache] imageForURL:url completionBlock:^(UIImage *image) {
        UIImage *imgOriginal =[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *barLogo = [[UIBarButtonItem alloc] initWithImage:imgOriginal style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.leftBarButtonItems = @[barBack, barLogo];
        
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        self.navigationItem.leftBarButtonItem = barBack;
    }];
    if ([userDefault boolForKey:@"Is_Client"] == false) {
        self.navigationItem.rightBarButtonItems = @[];
    }else{
        NSString *Cart_Item = [dbManager GetQuantity:[userDefault objectForKey:@"Order_Id"]];
        
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
        NSString *Customer_Name = [dbManager GetCustomerName:[userDefault objectForKey:@"Customer_Id"]];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:Customer_Name style:UIBarButtonItemStylePlain target:nil action:nil];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = false;
    btnSync.enabled = true;
    [userDefault setBool:false forKey:@"checkSelect"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    [self GetAllRecordData :@"all"];
    [self LanguageSetup];
}
-(void)LanguageSetup{
    lbl_ID.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"ID"];
    lbl_Status.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"STATUS"];
    lbl_Action.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"ACTION"];
    lbl_Total.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"TOTAL"];
    lbl_BillTo.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"BILLTO"];
    lbl_OrderDate.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"ORDERS DATE"];
    lbl_OrderStatus.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order Status"];
    self.navigationItem.title = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"ORDER"];
    [btnSync setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Submit orders"] forState:UIControlStateNormal];
}
-(void)GetAllRecordData :(NSString *)All{
    arr_Sum = [[NSMutableArray alloc] init];
    arr_AllRecord = [[NSMutableArray alloc] init];
    NSMutableArray *arrSyncedGetRecord = [[NSMutableArray alloc] init];
    if ([All  isEqual: @"all"]) {
        arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"All":@"0"] mutableCopy];
        arrSyncedGetRecord = [[objDatabaseManager GetAllRecordPlace:@"GetSyncedRecord":@"0"] mutableCopy];
    }else if ([All isEqual:@"Synced"]){
        arrSyncedGetRecord = [[objDatabaseManager GetAllRecordPlace:@"GetSyncedRecord":@"0"] mutableCopy];
    }else if ([All isEqual:@"Not Sync"]){
        arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"AllPlaceOrder":@"0"] mutableCopy];
    }else if ([All isEqual:@"Saved"]){
        arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"Saved":@"0"] mutableCopy];
    }
    if (arr_AllRecord.count > 0) {
        for (int j = 0; j < arr_AllRecord.count; j++) {
            if ([[arr_AllRecord[j] objectForKey:@"Customer_Id"]  isEqual: @"<null>"]) {
                [arr_Sum addObject:[arr_AllRecord[j] objectForKey:@"Price"]];
            }else{
                [arr_Sum addObject:[dbManager GetGrandTotal:[arr_AllRecord[j] objectForKey:@"Order_Id"]]];
                /*NSString *OrderId = [arr_AllRecord[j] objectForKey:@"Order_Id"];
                if ([[dbManager GetCustomerGroup:[dbManager GetcustomerId:OrderId]]  isEqual: @"0"]) {
                    [arr_Sum addObject:[arr_AllRecord[j] objectForKey:@"Price"]];
                }else{
                    NSMutableArray *arr_Order  = [[NSMutableArray alloc]init];
                    NSMutableArray *arr_ProductCount = [[NSMutableArray alloc]init];
                    NSMutableArray *arr_Temp = [[dbManager GetCartFromOrder:OrderId] mutableCopy];
                    for (int i = 0; i <arr_Temp.count; i++) {
                        [arr_ProductCount addObject:arr_Temp[i][1]];
                        NSDictionary *dic =  [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:arr_Temp[i][0]] mutableCopy]];
                        [arr_Order addObject:dic];
                    }
                    NSMutableArray *arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[dbManager GetcustomerId:OrderId]]] mutableCopy];
                    [arr_Sum addObject:[NSString stringWithFormat:@"%f",[self sumOfProduct:arr_Order :arr_GroupPrice :OrderId :arr_ProductCount]]];
                }*/
            }
            if (j+1 == arr_AllRecord.count) {
                for (int i = 0; i <arrSyncedGetRecord.count; i++) {
                    [arr_Sum addObject:[arrSyncedGetRecord[i] objectForKey:@"Grand_Total"]];
                }
                [arr_AllRecord addObjectsFromArray:arrSyncedGetRecord];
                break;
            }
        }
    }else{
        for (int i = 0; i <arrSyncedGetRecord.count; i++) {
            [arr_Sum addObject:[arrSyncedGetRecord[i] objectForKey:@"Grand_Total"]];
        }
        [arr_AllRecord addObjectsFromArray:arrSyncedGetRecord];
    }
    if ([[arr_AllRecord valueForKey:@"Status"] containsObject:@"Not Sync"]) {
        btnSync.hidden = false;
    }else{
        btnSync.hidden = true;
    }
    tbl_AllOrder.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tbl_AllOrder reloadData];
}
-(float)sumOfProduct :(NSMutableArray *)arr_Order :(NSMutableArray *)arr_GroupPrice :(NSString *)Order_ID :(NSMutableArray *)arr_ProductCount{
    float sum = 0;
    for (int i = 0; i < arr_Order.count; i++) {
        if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
            NSString *price = [dbManager GetPrice:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[dbManager GetcustomerId:Order_ID]]];
            sum = sum + [price floatValue]* [arr_ProductCount[i] floatValue];
        }
        else{
            sum = sum + [[[arr_Order[i]objectForKey:@"price"]objectForKey:@"value_id"] floatValue]* [arr_ProductCount[i] floatValue];
        }
    }
    return sum;
}
-(void)Clicked_Cart{
    OMCartVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCartVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
#pragma mark - UIbar Butoon Method
-(void)action_Back{
    if (issync == true)
        return;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Search Bar Method
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
#pragma mark - UITableViewDelegate & DataSource Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr_AllRecord.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (arr_AllRecord.count > 0) {
        if (![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Cart"] && ![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Saved"] && ![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Not Sync"] ) {
            [custom.btn_Status setSelected:true];
        }else{
            [custom.btn_Status setSelected:false];
        }
        [custom.btn_Status setTitle:[arr_AllRecord[indexPath.row]objectForKey:@"Status"] forState:UIControlStateNormal];
        custom.lbl_OrderID.text = [NSString  stringWithFormat:@"%@",[arr_AllRecord[indexPath.row]objectForKey:@"Order_Id"]];
        custom.lbl_OrderDate.text = [arr_AllRecord[indexPath.row]objectForKey:@"Order_Date"];
        if ([arr_AllRecord[indexPath.row]objectForKey:@"firstname"] == [NSNull null]) {
            custom.lbl_BillTo.text = @"";
        }else{
            custom.lbl_BillTo.text = [arr_AllRecord[indexPath.row]objectForKey:@"firstname"];
        }
        custom.lbl_OrderTotal.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[arr_Sum[indexPath.row] floatValue]];
        custom.btn_ViewOrder.tag = indexPath.row;
        custom.btn_Status.tag = indexPath.row;
        if ([[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Synced"]) {
//            [custom.btn_ViewOrder setTitle:@"View Order" forState:UIControlStateNormal];
             [custom.btn_ViewOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"View Order"] forState:UIControlStateNormal];
        }else{
//            [custom.btn_ViewOrder setTitle:@"View Order" forState:UIControlStateNormal];
             [custom.btn_ViewOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"View Order"] forState:UIControlStateNormal];
        }
        [custom.btn_ViewOrder addTarget:self action:@selector(btnClicked_ViewOrder:)forControlEvents:UIControlEventTouchUpInside];
        [custom.btn_Status addTarget:self action:@selector(btnClicked_StatusOrder:)forControlEvents:UIControlEventTouchUpInside];
        
    }else{
    }
    return custom;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_Status:(id)sender {
    if (issync == true)
        return;
    [Dropobj fadeOut];
    [self showPopUpWithTitle:@"Select Status Type" withOption:arr_Status  xy:CGPointMake(10,58) size:CGSizeMake(220,240) isMultiple:YES];
}

- (IBAction)btnClicked_SyncOrder:(id)sender {
    if (issync == true)
        return;
    issync = true;
    if ([self connected]){
        OAToken *token_Check = [self GetToken];
        if (token_Check.key!= nil){
            [self checkToken];
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
        issync = false;
    }
}
-(void)checkToken{
    NSURL * url;
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
                [self InsertOnServer];
            }else{
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSMutableArray class]]){
                    [self InsertOnServer];
                }
                else if([json isKindOfClass:[NSDictionary class]]){
                    if ([json objectForKey:@"messages"]) {
                        issync = false;
                        MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                        vc.delegate = self;
                        [[self navigationController] pushViewController:vc animated:YES];
                    }else{
                        [self InsertOnServer];
                    }
                }
                else{
                    [self InsertOnServer];
                }
            }
        } failedBlock:^{
            NSLog(@"Failed");
            [self showNetwortFailerAlert];
            issync = false;
        }];
    }else{
        [self InsertOnServer];
    }
}
-(void)getAccessTokenSuccess{
    [self checkToken];
}
#pragma mark UpdateNewCustomerOn server
-(void)InsertOnServer{
    [loadingView startLoadingWithMessage:@"Syncing Customer.." inView:self.view];
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager getNewCustomer] mutableCopy];
    arrcustID = [[NSMutableArray alloc]init];

    if (_temp.count == 0) {
        [self SyncOrder];
    }
    for (int i = 0; i< _temp.count; i++) {
        strID = [[_temp valueForKey:@"Customer_id"] objectAtIndex:i];
        [arrcustID addObject:strID];
        NSMutableArray *CustAddress = [[objDatabaseManager getCustomerAddress:strID] mutableCopy];
        NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:CustAddress ,@"addresses", nil];
        NSString *strdob =[[_temp valueForKey:@"dob"]objectAtIndex:i];
        if (strdob == (id)[NSNull null] || strdob.length == 0 ) strdob = @"";
        NSString *strpostcode =[[_temp valueForKey:@"postcode"]objectAtIndex:i];
        if (strpostcode == (id)[NSNull null] || strpostcode.length == 0 ) strpostcode = @"";
        [eventData setObject:[[_temp valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
        [eventData setObject:[[_temp valueForKey:@"middlename" ]objectAtIndex:i] forKey:@"middlename"];
        [eventData setObject:[[_temp valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
        [eventData setObject:[[_temp valueForKey:@"email" ]objectAtIndex:i] forKey:@"email"];
        [eventData setObject:strdob forKey:@"dob"];
        [eventData setObject:[[_temp valueForKey:@"suffix" ]objectAtIndex:i] forKey:@"suffix"];
        [eventData setObject:[[_temp valueForKey:@"prefix" ]objectAtIndex:i] forKey:@"prefix"];
        [eventData setValue:[[_temp valueForKey:@"prefix" ]objectAtIndex:i] forKey:@"prefix"];
        [eventData setValue:[[_temp valueForKey:@"password_hash" ]objectAtIndex:i] forKey:@"password"];
        [eventData setValue:[[_temp valueForKey:@"group_id" ]objectAtIndex:i] forKey:@"group_id"];
        [eventData setValue:[[_temp valueForKey:@"entity_id" ]objectAtIndex:i] forKey:@"entity_id"];
        [eventData setValue:[[_temp valueForKey:@"gender" ]objectAtIndex:i] forKey:@"gender"];
        [eventData setValue:[[_temp valueForKey:@"sales_agent_id" ]objectAtIndex:i] forKey:@"sales_agent_id"];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        if (i == _temp.count-1) {
            [self CreateCustomers:jsonData2:YES];
        }
        else
            [self CreateCustomers:jsonData2:NO];
    }
}
#pragma mark CreateNew Customer WebService
- (void)CreateCustomers :(NSData *)Customer :(BOOL)alertshow{
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
            NSLog(@"JSON Response: %@",json);
            if ([json isKindOfClass:[NSDictionary class]]){
                arrcustIDCopy = [[NSMutableArray alloc]init];
                [arrcustIDCopy addObject:[arrcustID objectAtIndex:0]];
                [dbManager Delete_Local_Add_NewCustomerAddress:[arrcustIDCopy objectAtIndex:0]];
                [dbManager Delete_Local_Add_NewCustomer:[arrcustIDCopy objectAtIndex:0]];
                [dbManager UpdateCustomerId:[arrcustIDCopy objectAtIndex:0] :json[@"create-customer"][@"cust_id"]];
                NSLog(@"%@",arrcustIDCopy[0]);
                [arrcustID removeObjectAtIndex:0];
                
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    issync = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    NSString *strsuccess = [[json objectForKey:@"create-customer"] objectForKey:@"success"];
                    if ([strsuccess isEqualToString:@"true"]) {
                        if (alertshow == YES) {
                            [self GetCustomers];
                        }
                    }
                    else{
                    }
                }
            }else{
            }
            issync = false;
        }}failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            issync = false;
        }];
}
#pragma mark - Webservice for GetCustomer
- (void)GetCustomers{
    [loadingView changeLoadingMessage:@"Getting Customer"];
    [dbManager CreateCustomerMaster:@"Customer_Master"];
    [dbManager CreateCustomerAddress:@"CustomerAddress"];
    NSURL * url;
    if ([[userDefault objectForKey:@"Customer_Master"]  isEqual: @"1"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/moddate/%@",[[Singleton sharedSingleton] getBaseURL],[userDefault objectForKey:@"timestamp"]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/",[[Singleton sharedSingleton]getBaseURL]]];
    }
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AppDelegate getDelegate].callback];
    [request setHTTPMethod:@"GET"];
    [request setParameters:[NSArray arrayWithObject:callbackParam]];
    [request setTimeoutInterval:300];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSDictionary class]]){
            if ([json objectForKey:@"messages"]) {
                [loadingView stopLoading];
                issync = false;
                MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                vc.delegate = self;
                [[self navigationController] pushViewController:vc animated:YES];
            }else{
                [dbManager InsertCustomerMaster:@"Customer_Master" :json :@"false" :@"false"];
                [self SyncOrder];
            }
        }else{
            [self SyncOrder];
        }
        issync = false;
    } failedBlock:^{
        [self SyncOrder];
        issync = false;
    }];
}
-(void)SyncOrder{
    btnSync.enabled = false;
    [loadingView changeLoadingMessage:@"Synced order.."];
    NSMutableArray *arr_AllRecord_Sync = [[objDatabaseManager GetAllRecordPlace:@"AllPlaceOrder":@"0"] mutableCopy];
    if (arr_AllRecord_Sync.count == 0) {
        [loadingView stopLoading];
        btnSync.enabled = true;
    }
    for (int TagID_Sync = 0; TagID_Sync <arr_AllRecord_Sync.count; TagID_Sync++) {
        float GrandTotal = 0 ;
        NSArray *arr_Record = [objDatabaseManager GetParticularOrderList:[arr_AllRecord_Sync[TagID_Sync]objectForKey:@"Order_Id"]];
        NSMutableArray *arr_SendRecord = [[NSMutableArray alloc]init];
        for (int i =0;i < arr_Record.count;i++){
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
        NSDictionary *dict=@{@"customer": [arr_AllRecord_Sync[TagID_Sync] objectForKey:@"Customer_Id"],
                             @"dealer":[userDefault objectForKey:@"dealer"],
                             @"comment":[dbManager GetCommentFromOrder:[arr_AllRecord_Sync[TagID_Sync]objectForKey:@"Order_Id"]],
                             @"products":arr_SendRecord
                             };
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
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
        OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
        [dataFetcher fetchDataWithRequest:request delegate:self completionBlock:^(OAServiceTicket *ticket, NSMutableData *data) {
            if (data == nil) {
            }else{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"JSON Response: %@",json);
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    issync = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    if ([[[json objectForKey:@"create-order"] objectForKey:@"success"]  isEqual: @"true"]) {
                        [userDefault setBool:false forKey:@"Is_Client"];
                        [dbManager UpdateOrderID:[arr_AllRecord_Sync[TagID_Sync]objectForKey:@"Order_Id"] :[[[json objectForKey:@"create-order"] objectForKey:@"order_details"] objectForKey:@"entity_id"]:[NSString stringWithFormat:@"%.2f",GrandTotal]];
                    }else{
                    }
                }
            }
            if (TagID_Sync == arr_AllRecord_Sync.count - 1) {
                [loadingView stopLoading];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Sync Success" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                issync = false;
                NSDate *today = [NSDate new];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd-MMM-yyyy"];
                NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
                [dateFormat1 setDateFormat:@"dd-MMM-yyyy   hh:mm"];
                [dbManager InsertActivityLog:[dateFormat1 stringFromDate:today] :@"Sync completed"];
                [self GetAllRecordData:@"all"];
                [btn_ObjStatus setTitle:arr_Status[0] forState:UIControlStateNormal];
                tbl_AllOrder.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }
        } failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            [self showNetwortFailerAlert];
            issync = false;
            if (TagID_Sync == arr_AllRecord_Sync.count - 1) {
                [loadingView stopLoading];
                [self GetAllRecordData:@"all"];
                [btn_ObjStatus setTitle:arr_Status[0] forState:UIControlStateNormal];
                tbl_AllOrder.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }
        }];
    }
}
-(void)showNetwortFailerAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There is some problem with network. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (IBAction)btnClicked_ViewOrder:(id)sender {
    if (issync == true)
        return;
    if ([userDefault boolForKey:@"checkSelect"] == false) {
        TagID= ((UIButton *)sender).tag;
        if (![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Cart"] && ![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Saved"] && ![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Not Sync"] ) {
            OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
            VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
            VC.Customer_ID = [arr_AllRecord[TagID] objectForKey:@"Customer_Id"];
            VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
            VC.Order_Status = @"Close";
            [[self navigationController] pushViewController:VC animated:YES];
        }else{
            if ([userDefault boolForKey:@"Is_Client"] == true) {
                if ([dbManager CheckOrderStatus] == true) {
                    UIAlertView *alert =  [[UIAlertView alloc]initWithTitle:@"" message:@"For view and open this order previous order is delete.Are you sure to continue?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    alert.tag = 10;
                    [alert show];
                }else{
                    OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
                    VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
                    VC.Order_Status = @"Open";
                    VC.Customer_ID = [arr_AllRecord[TagID] objectForKey:@"Customer_Id"];
                    VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
                    [[self navigationController] pushViewController:VC animated:YES];
                }
            }else{
                OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
                VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
                VC.Order_Status = @"Open";
                VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
                VC.Customer_ID = [arr_AllRecord[TagID] objectForKey:@"Customer_Id"];
                [[self navigationController] pushViewController:VC animated:YES];
            }
        }
    }else{
    }
}
- (IBAction)btnClicked_StatusOrder:(id)sender {
    return;
}

#pragma mark - Check internet connection
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10){
        if(buttonIndex == 0){
            [dbManager DeleteOrder];
            OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
            VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
            VC.Customer_ID = [arr_AllRecord[TagID] objectForKey:@"Customer_Id"];
            VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
            VC.Order_Status = @"Open";
            [[self navigationController] pushViewController:VC animated:YES];
        }
        else if(buttonIndex == 1){
        }
        else {
        }
    }
    else{
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
    [btn_ObjStatus setTitle:arr_Status[anIndex] forState:UIControlStateNormal];
    if (anIndex == 0) {
        [self GetAllRecordData :@"all"];
    }else{
        [self GetAllRecordData :arr_Status[anIndex]];
    }
}
@end