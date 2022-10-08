//
//  OMUpdateTaskVC.m
//  OrderManagement
//
//  Created by MAC on 09/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMUpdateTaskVC.h"
#import "CustomTVC.h"
#import "DatabaseManager.h"
#import "DBManager.h"

@interface OMUpdateTaskVC ()
{
    NSMutableArray *arr_TaskList;
    DatabaseManager *objDatabaseManager;
    NSInteger DeletTag;
    NSInteger TopOrigin,tableHeight;
    DBManager *dbManager;
    NSUserDefaults *userDefault;
}
@end

@implementation OMUpdateTaskVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefault = [NSUserDefaults standardUserDefaults];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideHandler:)name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    arr_TaskList = [[objDatabaseManager GetTaskListDic] mutableCopy];
    [tbl_TaskList reloadData];
    tbl_TaskList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    TopOrigin = tbl_TaskList.frame.origin.y;
    tableHeight = tbl_TaskList.frame.size.height;
    [self LanguageSetup];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)LanguageSetup{
    lbl_Delete.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"DELETE"];
    lbl_TaskName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"TASK NAME"];
}
#pragma mark - UITableViewDelegate & DataSource Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr_TaskList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (arr_TaskList.count > 0) {
        custom.txt_EditTask.text = arr_TaskList[indexPath.row][@"TaskName"];
        custom.txt_EditTask.tag = indexPath.row;
        custom.btn_ObjDeleteProduct.tag = indexPath.row;
        [custom.btn_ObjDeleteProduct addTarget:self action:@selector(btnClicked_Deleteproduct:)forControlEvents:UIControlEventTouchUpInside];
    }else{
    }
    custom.txt_EditTask.userInteractionEnabled = YES;

    return custom;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSInteger tag = textView.tag;
    NSLog(@"%ld",(long)tag);
    tbl_TaskList.frame = CGRectMake(tbl_TaskList.frame.origin.x , TopOrigin-40*tag, tbl_TaskList.frame.size.width, tableHeight-264);

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        tbl_TaskList.frame = CGRectMake(tbl_TaskList.frame.origin.x , TopOrigin, tbl_TaskList.frame.size.width, tableHeight);
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}
- (void) keyboardWillHideHandler:(NSNotification *)notification {
    tbl_TaskList.frame = CGRectMake(tbl_TaskList.frame.origin.x , TopOrigin, tbl_TaskList.frame.size.width, tableHeight);

    //show another viewcontroller here
}
#pragma mark - UIButton Event
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSInteger tag = textView.tag;
    NSLog(@"%ld",(long)tag);
     tbl_TaskList.frame = CGRectMake(tbl_TaskList.frame.origin.x , TopOrigin, tbl_TaskList.frame.size.width, tableHeight);
    [objDatabaseManager UpdateTask:textView.text :arr_TaskList[tag][@"rowid"]];
}
- (IBAction)btnClicked_Deleteproduct:(id)sender {
    [self.view endEditing:true];
    DeletTag = ((UIButton *)sender).tag;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Are you sure to Delete this Task ?"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Yes"] otherButtonTitles:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"No"], nil];
    alert.tag = 451;
    [alert show];
}

#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 451){
        if(buttonIndex == 0){
            [objDatabaseManager DeleteTask:arr_TaskList[DeletTag][@"rowid"]];
            arr_TaskList = [[objDatabaseManager GetTaskListDic] mutableCopy];
            [tbl_TaskList reloadData];
        }else {
        }
    }else{
    }
}
@end
