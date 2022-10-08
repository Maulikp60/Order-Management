//
//  OMContactUSVC.m
//  Order Management
//
//  Created by MAC on 18/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMContactUSVC.h"
#import "SKPSMTPMessage.h"
#import "Reachability.h"
#import "OMCartVC.h"
@interface OMContactUSVC () <SKPSMTPMessageDelegate>{
    NSUserDefaults *userDefault;
}
@property(nonatomic,strong)SKPSMTPMessage *testMsg;
@end

@implementation OMContactUSVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
   
    userDefault =[NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"Is_Client"] == false) {
        self.navigationItem.rightBarButtonItems = @[];
    }else{
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(Clicked_Cart)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 110, 42)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 42)];
        [label setFont:[UIFont fontWithName:@"Arial" size:16]];
        [label setText:@"Cart"];
        label.textAlignment = NSTextAlignmentLeft;
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [button addSubview:label];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItems = @[barButton];
    }
    [self LanguageSetup];
}
-(void)LanguageSetup{
    DBManager *dbManager =[[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    lbl_SendMessage.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SEND US A MESSAGE"];
    [btnObj_Send setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Send"] forState:UIControlStateNormal];
    txt_Email.placeholder = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"E-mail"];
    txt_Name.placeholder = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Name"];
    txt_Phone.placeholder = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Phone"];
//    UIBarButtonItem *btn_Back= [[UIBarButtonItem alloc] initWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back)];
//    self.navigationItem.leftBarButtonItem = btn_Back;
}

-(void)Clicked_Cart{
    OMCartVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCartVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Bar Butoon Method
-(void)action_Back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_SendMessage:(id)sender {
    if (![self connected]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Check your internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        __weak NSString *msg = [self validateLoginForm];
        if ([msg isEqualToString:@""]) {
            [self.view endEditing:true];
            [self sendMessageInBack];
        }else{
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertMessage show];
        }
    }
}

#pragma mark - Send Email
- (void)sendMessageInBack{
    NSLog(@"Start Sending");
    _testMsg = [[SKPSMTPMessage alloc] init];
    _testMsg.relayHost = @"smtp.gmail.com";
    _testMsg.fromEmail = [userDefault objectForKey:@"Agent_Email"];
    _testMsg.toEmail =txt_Email.text;
    _testMsg.login =[userDefault objectForKey:@"Agent_Email"];;
    _testMsg.pass =[userDefault objectForKey:@"Agent_Password"];;
    _testMsg.requiresAuth = YES;
    _testMsg.subject = @"Inquiry Form";
    _testMsg.wantsSecure = YES;
    _testMsg.delegate = self;
    
    NSString *str = [NSString stringWithFormat:@"%@  %@   %@",txt_Name.text,txt_Phone.text,tv_Message.text];
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               str,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    _testMsg.parts = [NSArray arrayWithObjects:plainPart,nil];
    [_testMsg send];
    
}
-(void)messageSent:(SKPSMTPMessage *)message{
    NSLog(@"delegate - message sent");
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Submit Succesfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    message=nil;
}
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    message=nil;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Try again.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Validation Email
-(NSString *)validateLoginForm{
    __weak NSString *msg = @"";
    if( [[txt_Name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Name should not be empty.";
    }else if([[txt_Email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Email should not be empty.";
    }else if([[tv_Message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Message should not be empty.";
    }else if([[userDefault objectForKey:@"Agent_Email"]  isEqual: @""]){
        msg = @"First insert email and password from setting page.";
    }
    return msg;
}

#pragma mark - Check internet connection
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
@end