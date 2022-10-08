//
//  OMActivityLogVC.m
//  OrderManagement
//
//  Created by MAC on 05/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMActivityLogVC.h"
#import "DatabaseManager.h"
#import "CustomTVC.h"
#import "DBManager.h"
@interface OMActivityLogVC ()
{
    DBManager *dbManager;
    DatabaseManager *objDatabaseManager;
    NSMutableArray *arr_ActivityLog;
    NSUserDefaults *userDefault;
}
@end

@implementation OMActivityLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefault = [NSUserDefaults standardUserDefaults];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    arr_ActivityLog = [[objDatabaseManager GetActivityLog] mutableCopy];
    [tbl_ActivityLog reloadData];
    tbl_ActivityLog.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    [self LanguageSetup];
    // Do any additional setup after loading the view.
}
-(void)LanguageSetup{
    lbl_Date.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"DATE"];
    lbl_Name.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"NAME"];
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back)];
    self.navigationItem.leftBarButtonItem = barBack;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIbar Butoon Method
-(void)action_Back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate & DataSource Method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr_ActivityLog.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (arr_ActivityLog.count > 0) {
       custom.lbl_Date.text = arr_ActivityLog[indexPath.row][@"Activity_Date"];
        custom.lbl_ActivityLog.text = arr_ActivityLog[indexPath.row][@"Activity_Name"];
        
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

@end
