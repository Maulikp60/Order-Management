//
//  OMOrderHistoryVC.m
//  Order Management
//
//  Created by MAC on 13/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMOrderHistoryVC.h"
#import "CustomTVC.h"
#import "ArrayToDicConvert.h"
#import "OMCartVC.h"
#import "DatabaseManager.h"
@interface OMOrderHistoryVC ()
{
    NSMutableArray *arr_Order,*arr_ProductCount,*arr_GroupPrice,*arr_SuperAttribute,*arr_BasePrice,*arr_ShippedQunatity,*arr_Comment;
    DBManager *dbManager;
    ArrayToDicConvert *obj_ArrayyToDic;
    NSUserDefaults *userDefault;
    DatabaseManager *objDatabaseManager;
    NSString *Status;
    BOOL isBack;
}
@end

@implementation OMOrderHistoryVC
@synthesize Order_ID,Customer_Name,Order_Status,Customer_ID;
@synthesize  lblColor_Width,lblOther_Width,lblSize_Width,lblSleeve_Width,lblView_Width;

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefault = [NSUserDefaults standardUserDefaults];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [userDefault setBool:true forKey:@"checkSelect"];
    isBack = false;
    NSLog(@"%@",Order_ID);
    self.navigationController.navigationBarHidden = false;
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    self.navigationItem.title = Customer_Name;
    arr_Comment  = [[NSMutableArray alloc] init];
    if ([Order_Status  isEqual: @"Open"]) {
        btn_ObjOpernOrder.hidden =false;
    }else{
        arr_Comment = [[objDatabaseManager GetCommentSyncedOrder:Order_ID] mutableCopy];
        btn_ObjOpernOrder.hidden = true;
    }
    view_CommentList.layer.borderColor = [UIColor redColor].CGColor;
    
    [tbl_CommentList reloadData];
    tv_Comment.text = [dbManager GetCommentFromOrder:Order_ID];
    NSString *GetAttributeIDFromOrder = [dbManager GetAttributeIDFromOrder:Order_ID];
    NSMutableArray *arrTemp = [[GetAttributeIDFromOrder componentsSeparatedByString:@","]mutableCopy];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrTemp];
    NSMutableArray *arr = [orderedSet mutableCopy];
    [arr removeObject:@""];
    arr_SuperAttribute = [[objDatabaseManager GetAttributeName:arr] mutableCopy];
    NSMutableArray *arr_TempAttribute =  [[objDatabaseManager GetAttributeName:arr] mutableCopy];
    float width =0.0;
    
    if (arr_TempAttribute.count > 0) {
        width = width + 112.0;
        lbl_Color.text = [dbManager GetCode: arr_TempAttribute[0]];
        [arr_TempAttribute removeObject:arr_TempAttribute[0]];
        lblColor_Width.constant = 112.0;
    }else{
        lblColor_Width.constant = 0.0 ;
        lbl_Color.hidden = YES;
    }
    if (arr_TempAttribute.count > 0){
        width = width + 112.0;
        lbl_Size.text = [dbManager GetCode: arr_TempAttribute[0]];
        [arr_TempAttribute removeObject:arr_TempAttribute[0]];
        lblSize_Width.constant = 112.0;
    }else{
        lblSize_Width.constant = 0.0 ;
        lbl_Size.hidden = YES;
    }
    if (arr_TempAttribute.count > 0) {
        lbl_Other.text = [dbManager GetCode: arr_TempAttribute[0]];
        width = width + 112.0;
        lblOther_Width.constant = 112.0;
    }else{
        lblOther_Width.constant = 0.0;
        lbl_Other.hidden = YES;
    }
    if (arr_TempAttribute.count > 1) {
        width = width + 112.0;
        lbl_SleeveLength.text = [dbManager GetCode: arr_TempAttribute[1]];
        lblSleeve_Width.constant = 112.0;
        [arr_TempAttribute removeObject:arr_TempAttribute[1]];
    }else{
        lblSleeve_Width.constant = 0.0 ;
        lbl_SleeveLength.hidden = YES;
    }
    lbl_OrderID.text = [NSString stringWithFormat:@"%@ : %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order"],Order_ID];
    lblView_Width.constant = width;
    [self.view setNeedsUpdateConstraints];
    arr_ProductCount = [[NSMutableArray alloc]init];
    arr_ShippedQunatity = [[NSMutableArray alloc]init];
    arr_Order  = [[NSMutableArray alloc]init];
    arr_BasePrice = [[NSMutableArray alloc] init];
    NSMutableArray *arr_Temp = [[dbManager GetCartFromOrder:Order_ID] mutableCopy];
    Status = arr_Temp[0][4];
    for (int i = 0; i <arr_Temp.count; i++) {
        [arr_ProductCount addObject:arr_Temp[i][1]];
        [arr_ShippedQunatity addObject:arr_Temp[i][5]];
        [arr_BasePrice addObject:arr_Temp[i][2]];
        NSDictionary *dic =  [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:arr_Temp[i][0]] mutableCopy]];
        [arr_Order addObject:dic];
    }
    tbl_ViewOrder.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tbl_CommentList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[dbManager GetcustomerId:Order_ID]]] mutableCopy];
    [tbl_ViewOrder reloadData];
    if ([Status isEqual: @"Synced"]) {
        lbl_ProductSum.text = [NSString stringWithFormat:@"Total : %@ Products for %@ %.2f",[arr_ProductCount valueForKeyPath:@"@sum.self"],[userDefault objectForKey:@"currency_code"],[arr_Temp[0][3]floatValue]];
        Status = @"Synced";
    }else{
        [self sumOfProduct];
    }
    [self LanguageSetup];
}
-(void)LanguageSetup{
    lbl_CommentHistory.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"COMMENTS HISTORY"];
    lbl_Name.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"NAME"];
    lbl_Quantity.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"QUANTITY"];
    lbl_Sku.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SKU"];
    lbl_Price.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"PRICE"];
    lbl_Total.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"TOTAL"];
    lbl_OrderComments.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order Comments"];
    [btnObj_MainMenu setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Main Menu"] forState:UIControlStateNormal];
    [btn_ObjOpernOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Open Order"] forState:UIControlStateNormal];
    [btnObj_OrderList setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back to Order List"] forState:UIControlStateNormal];
}
#pragma mark - Sum Of Product
-(void)sumOfProduct{
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
    lbl_ProductSum.text = [NSString stringWithFormat:@"Total : %@ Products for %@ %.2f",[arr_ProductCount valueForKeyPath:@"@sum.self"],[userDefault objectForKey:@"currency_code"],sum];
}
#pragma mark - UIbar Butoon Method
-(void)action_Back{
    if (isBack)
        return;
    else
        isBack = true;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate & DataSource Method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tbl_ViewOrder) {
        return 51;
    }else if (tableView == tbl_CommentList){
        NSString *txt = arr_Comment[indexPath.row][@"comment"];
        CGRect size = [txt boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 214, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}context:nil];
        if (size.size.height + 5 > 45) {
            return size.size.height + 5;
        }else{
            return 45;
        }
    }else{
        return 51;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tbl_CommentList) {
        return arr_Comment.count;
    }else{
        return arr_Order.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (tableView  == tbl_CommentList) {
        if (custom == nil){
            custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
        }
        NSString *str = arr_Comment[indexPath.row][@"created_at"]; /// here this is your date with format yyyy-MM-dd
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //// here set format of date which is in your output date (means above str with format)
        
        NSDate *date = [dateFormatter dateFromString: str]; // here you can fetch date from string with define format
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];// here set format which you want...
        
        NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
        
        custom.lbl_CommentDescription.text = [NSString stringWithFormat:@"%@",arr_Comment[indexPath.row][@"comment"]];
        custom.lbl_CommentStatus.text = [NSString stringWithFormat:@"%@ (%@)",convertedString,arr_Comment[indexPath.row][@"status"]];
        return custom;
    }else{
        if (arr_Order.count > 0) {
            if (custom == nil){
                custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
            }
            float width = 0.0;
            if (arr_SuperAttribute.count > 0) {
                custom.View_Attribute.hidden = false;
                if (arr_SuperAttribute.count > 0) {
                    custom.lbl_ColorWidth.constant = 112.0;
                    custom.lbl_Color.hidden = NO;
                    width = width + 112.0;
                    custom.lbl_Color.text = [[arr_Order[indexPath.row]objectForKey:arr_SuperAttribute[0]]objectForKey:@"value"];
                    if ([custom.lbl_Color.text  isEqual: @"0"]) {
                        custom.lbl_Color.text = @"";
                    }
                }else{
                    custom.lbl_ColorWidth.constant = 1.0 ;
                    custom.lbl_Color.text =@"";
                }
                if (arr_SuperAttribute.count > 1){
                    width = width + 112.0;
                    custom.lbl_SizeWidth.constant = 112.0;
                    custom.lbl_Size.hidden = NO;
                    custom.lbl_Size.text = [[arr_Order[indexPath.row]objectForKey:arr_SuperAttribute[1]]objectForKey:@"value"];
                    if ([custom.lbl_Size.text  isEqual: @"0"]) {
                        custom.lbl_Size.text = @"";
                    }
                }else{
                    custom.lbl_SizeWidth.constant = 0.0 ;
                    custom.lbl_Size.text = @"";
                }
                if (arr_SuperAttribute.count > 3) {
                    width = width + 112.0;
                    custom.lbl_SleeveWidth.constant = 112.0;
                    if ( [[[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[3]] objectForKey:@"value"]  isEqual: @"0"]) {
                        custom.lbl_SleeveLength.text = @"";
                    }else{
                        custom.lbl_SleeveLength.text = [[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[3]] objectForKey:@"value"];
                    }
                    custom.lbl_SleeveLength.hidden = false;
                }else{
                    custom.lbl_SleeveWidth.constant = 0.0 ;
                }
                if (arr_SuperAttribute.count > 2) {
                    custom.lbl_OtherAttribute.hidden = false;
                    if ([[[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[2]] objectForKey:@"value"]  isEqual: @"0"]) {
                        
                        custom.lbl_OtherAttribute.text = @"";
                    }else{
                        custom.lbl_OtherAttribute.text = [[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[2]] objectForKey:@"value"];
                        
                    }
                    
                    custom.lbl_OtherAttribute.frame =CGRectMake(width, 10, 112.0, 30);
                    
                    width = width + 112.0;
                }else{
                    custom.lbl_OtherAttributeWidth.constant = 0.0;
                }
            }
            [custom setNeedsUpdateConstraints];
            [custom setNeedsLayout];
            custom.View_SuperTableHeightConsrain.constant = width;
            custom.lbl_ProductName.text = [[arr_Order[indexPath.row]objectForKey:@"name"]objectForKey:@"value_id"];
            custom.lbl_SKU.text = [[arr_Order[indexPath.row]objectForKey:@"sku"]objectForKey:@"value_id"];
            
            custom.lbl_Quantity.text = [NSString stringWithFormat:@"%0.0f / %@",[arr_ShippedQunatity[indexPath.row] floatValue],arr_ProductCount[indexPath.row]];
            if ([Status isEqual: @"Synced"]){
                custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[arr_BasePrice[indexPath.row] floatValue]];
                custom.lbl_Total.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[arr_BasePrice[indexPath.row] floatValue]* [arr_ProductCount[indexPath.row] floatValue]];
            }else{
                if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_Order[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
                    NSString *price = [dbManager GetPrice:[[arr_Order[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[dbManager GetcustomerId:Order_ID]]];
                    custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[price floatValue]];
                    custom.lbl_Total.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[price floatValue]* [arr_ProductCount[indexPath.row] floatValue]];
                }
                else{
                    custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[arr_Order[indexPath.row]objectForKey:@"price"]objectForKey:@"value_id"] floatValue]];
                    custom.lbl_Total.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[arr_Order[indexPath.row]objectForKey:@"price"]objectForKey:@"value_id"] floatValue]* [arr_ProductCount[indexPath.row] floatValue]];
                }
            }
        }else{
        }
        return custom;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
    CustomTVC *custom = (CustomTVC *)cell;
    if (arr_Order.count > 0) {
        custom.View_Attribute.hidden = false;
        if (arr_SuperAttribute.count > 0) {
            custom.lbl_ColorWidth.constant = 112.0;
        }else{
            custom.lbl_ColorWidth.constant = 1.0 ;
        }
    }
    [custom setNeedsUpdateConstraints];
    [custom setNeedsLayout];
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setNeedsUpdateConstraints];
    [cell setNeedsLayout];
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_OrderComment:(id)sender {
    if ([Order_Status  isEqual: @"Open"]) {
        //nothing to do
    }else{
        view_CommentList.hidden = false;
    }
}
- (IBAction)btnClicked_HideCommentView:(id)sender {
    view_CommentList.hidden = true;
}

- (IBAction)btnClicked_OpenOrder:(id)sender {
    [userDefault setBool:true forKey:@"Is_Client"];
    [userDefault setObject:Order_ID forKey:@"Order_Id"];
    [userDefault setObject:Customer_ID forKey:@"Customer_Id"];
    OMCartVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMCartVC"];
    VC.ISOpenOrder = true;
    [[self navigationController] pushViewController:VC animated:YES];
}
- (IBAction)btnClicked_BackOrder:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnClicked_MainMenu:(id)sender {
    [self performSegueWithIdentifier:@"segueBackToMainMenu" sender:nil];
}

@end