//
//  OMCartVC.m
//  Order Management
//
//  Created by MAC on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMCartVC.h"
#import "CustomTVC.h"
#import "ArrayToDicConvert.h"
#import "OMHomeVC.h"
#import "OMProductDetail.h"
#import "DatabaseManager.h"
#import "AppDelegate.h"

@interface OMCartVC ()
{
    NSMutableArray *arr_Order,*arr_ProductCount,*arr_GroupPrice;
    DBManager *dbManager;
    ArrayToDicConvert *obj_ArrayyToDic;
    NSString *Image_Path,*Other_ProductCount,*Order_Status;
    NSInteger DeletTag;
    DatabaseManager *objDatabaseManager;
    NSMutableArray *arr_SuperAttribute;
    NSInteger product_Total;
    UITextField *txtCommentTemp;
    BOOL status;
}
@end

@implementation OMCartVC
@synthesize  lblColor_Width,lblOther_Width,lblSize_Width,lblSleeve_Width,lblView_Width,ISOpenOrder;
- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    Image_Path = [paths objectAtIndex:0];
    tbl_Cart.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80.0f)];
    txtCommentTemp = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width - 20.0f, view.frame.size.height)];
    txtCommentTemp.delegate = self;
    
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:txtCommentTemp];
    tv_Comment.inputAccessoryView = view;
    [tv_Comment addTarget:self
                   action:@selector(textViewDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    NSLog(@"%@",self.navigationController.viewControllers);
    if (ISOpenOrder == true) {
        NSArray *arr = self.navigationController.viewControllers;
        NSArray *newArr = @[arr[0],self];
        self.navigationController.viewControllers = newArr;
    }else{
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    status = [dbManager CheckOrderStatus];
    arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]] mutableCopy];
    //ORDER COMMENT
    tv_Comment.text = [dbManager GetCommentFromOrder:[userDefault objectForKey:@"Order_Id"]];
    txtCommentTemp.text = tv_Comment.text;
    Order_Status = [dbManager GetStatusFromOrder:[userDefault objectForKey:@"Order_Id"]];
    NSString *GetAttributeIDFromOrder = [dbManager GetAttributeIDFromOrder:[userDefault objectForKey:@"Order_Id"]];
    NSMutableArray *arrTemp = [[GetAttributeIDFromOrder componentsSeparatedByString:@","]mutableCopy];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrTemp];
    NSMutableArray *arr = [orderedSet mutableCopy];
    [arr removeObject:@""];
    arr_SuperAttribute = [[objDatabaseManager GetAttributeName:arr] mutableCopy];
    NSMutableArray *arr_TempAttribute =  [[objDatabaseManager GetAttributeName:arr] mutableCopy];
    float width =0.0;
    if (arr_TempAttribute.count > 0) {
        width = width + 100.0;
        lbl_Color.text = [dbManager GetCode: arr_TempAttribute[0]];
        [arr_TempAttribute removeObjectAtIndex:0];
        lblColor_Width.constant = 100.0;
    }else{
        lblColor_Width.constant = 0.0 ;
        lbl_Color.hidden = YES;
    }
    if (arr_TempAttribute.count > 0) {
        width = width + 100.0;
        lbl_Size.text = [dbManager GetCode: arr_TempAttribute[0]];
        [arr_TempAttribute removeObjectAtIndex:0];
        lblSize_Width.constant = 100.0;
    }else{
        lblSize_Width.constant = 0.0 ;
        lbl_Size.hidden = YES;
    }
    if (arr_TempAttribute.count > 1) {
        width = width + 100.0;
        lbl_SleeveLength.text = [dbManager GetCode: arr_TempAttribute[1]];
        lblSleeve_Width.constant = 100.0;
        [arr_TempAttribute removeObject:arr_TempAttribute[1]];
    }else{
        lblSleeve_Width.constant = 0.0 ;
        lbl_SleeveLength.hidden = YES;
    }
    if (arr_TempAttribute.count > 0) {
        lbl_Other.text = [dbManager GetCode: arr_TempAttribute[0]];
        width = width + 100;
        lblOther_Width.constant = 100.0;
    }else{
        lblOther_Width.constant = 0.0;
        lbl_Other.hidden = YES;
    }
    lblView_Width.constant = width;
    [self.view setNeedsUpdateConstraints];
    arr_Order  = [[NSMutableArray alloc]init];
    arr_ProductCount = [[NSMutableArray alloc]init];
    NSMutableArray *arr_Temp = [[dbManager GetCartFromOrder] mutableCopy];
    for (int i = 0; i <arr_Temp.count; i++) {
        [arr_ProductCount addObject:arr_Temp[i][1]];
        NSDictionary *dic =  [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:arr_Temp[i][0]] mutableCopy]];
        [dic setValue:arr_Temp[i][2] forKey:@"Parent_ID"];
        [arr_Order addObject:dic];
    }
    [self Navigation];
    self.navigationItem.title = @"My Cart";
    [tbl_Cart reloadData];
    [self sumOfProduct];
    [self  LanguageSetup];
}
-(void)LanguageSetup{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    lbl_OrderComment.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order Comments"];
    lbl_Details.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"DETAILS"];
    lbl_Price.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"PRICE"];
    lbl_Quantity.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"QUANTITY"];
    lbl_Sku.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SKU"];
    lbl_Name.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"NAME"];
    lbl_Image.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"IMAGE"];

    [btnObj_Save setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Save"] forState:UIControlStateNormal];
    [btnObj_CancelOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Cancel Order"] forState:UIControlStateNormal];
    [btnObj_PlaceOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Place Order"] forState:UIControlStateNormal];
    [btnObj_SaveClose setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Save & Close"] forState:UIControlStateNormal];
}
-(void)Navigation{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *Cart_Item = [dbManager GetQuantity:[userDefault objectForKey:@"Order_Id"]];
    Other_ProductCount = [NSString stringWithFormat:@"%ld",[Cart_Item integerValue] - [[arr_ProductCount valueForKeyPath:@"@sum.self"]integerValue]];
    NSString *Customer_Name = [dbManager GetCustomerName:[userDefault objectForKey:@"Customer_Id"]];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
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
    self.navigationItem.rightBarButtonItems = @[barButton,bar];
}
-(void)NavigationInside{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *Cart_Item = [NSString stringWithFormat:@"%ld",[Other_ProductCount integerValue] + [[arr_ProductCount valueForKeyPath:@"@sum.self"]integerValue]];    NSString *Customer_Name = [dbManager GetCustomerName:[userDefault objectForKey:@"Customer_Id"]];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
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
    self.navigationItem.rightBarButtonItems = @[barButton,bar];
}
//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    [self updateCart];
//}
-(void)sumOfProduct{
    float sum = 0;
    product_Total = 0;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < arr_ProductCount.count; i++) {
        if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
            NSString *price = [dbManager GetPrice:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
            sum = sum + [price floatValue]* [arr_ProductCount[i] floatValue];
        }
        else{
            sum = sum + [[[arr_Order[i]objectForKey:@"price"]objectForKey:@"value_id"] floatValue]* [arr_ProductCount[i] floatValue];
        }
        product_Total = product_Total + [arr_ProductCount[i] integerValue];
    }//[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Save & Close"]
    lbl_TotalCart.text = [NSString stringWithFormat:@"%@ : %@ %@ %@ %@ %.2f",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Total"],[arr_ProductCount valueForKeyPath:@"@sum.self"],[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Products"],[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"for"],[userDefault objectForKey:@"currency_code"],sum];
}
#pragma mark - UITextViewDelegate Method
-(void)changeFirstResponder{
    [txtCommentTemp becomeFirstResponder]; //will return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    txtCommentTemp.text = tv_Comment.text;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == tv_Comment){
        [[AppDelegate getDelegate].databaseManager updateCommentInOrder:tv_Comment.text];
    }
    [textField resignFirstResponder];
    [txtCommentTemp resignFirstResponder];
    return true;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == tv_Comment){
        tv_Comment.text =txtCommentTemp.text;
        [[AppDelegate getDelegate].databaseManager updateCommentInOrder:tv_Comment.text];
    }
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
    return arr_Order.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    custom.lbl_ProductName.text = [[arr_Order[indexPath.row]objectForKey:@"name"]objectForKey:@"value_id"];
    custom.lbl_SKU.text = [[arr_Order[indexPath.row]objectForKey:@"sku"]objectForKey:@"value_id"];
    
    custom.lbl_Quantity.text = arr_ProductCount[indexPath.row];
    if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_Order[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
        NSString *price = [dbManager GetPrice:[[arr_Order[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
        custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[price floatValue]];
    }
    else{
        custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[arr_Order[indexPath.row]objectForKey:@"price"]objectForKey:@"value_id"] floatValue]* [arr_ProductCount[indexPath.row] floatValue]];
    }
    float width = 0.0;
    if (arr_SuperAttribute.count > 0) {
        custom.View_Attribute.hidden = false;
        if (arr_SuperAttribute.count > 0) {
            custom.lbl_ColorWidth.constant = 100.0;
            custom.lbl_Color.hidden = YES;
            custom.lbl_Color.hidden = NO;
            width = width + 100.0;
            if ([[[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[0]] objectForKey:@"value"]  isEqual: @"0"]) {
                custom.lbl_Color.text = @"";
            }else{
                custom.lbl_Color.text = [[arr_Order[indexPath.row]objectForKey:arr_SuperAttribute[0]]objectForKey:@"value"];
            }
        }else{
            custom.lbl_ColorWidth.constant = 1.0 ;
        }
        if (arr_SuperAttribute.count > 1){
            width = width + 100.0;
            custom.lbl_SizeWidth.constant = 100.0;
            custom.lbl_Size.hidden = YES;
            custom.lbl_Size.hidden = NO;
            custom.lbl_Size.text = [[arr_Order[indexPath.row]objectForKey:arr_SuperAttribute[1]]objectForKey:@"value"];
        }else{
            custom.lbl_SizeWidth.constant = 0.0 ;
        }
        
        if (arr_SuperAttribute.count > 2) {
            custom.lbl_OtherAttribute.hidden = false;
            if ([[[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[2]] objectForKey:@"value"]  isEqual: @"0"]) {
                custom.lbl_OtherAttribute.text = @"";
                
            }else{
                custom.lbl_OtherAttribute.text = [[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[2]] objectForKey:@"value"];
            }
            
            width = width + 100;
            custom.lbl_OtherAttributeWidth.constant = 100.0;
        }else{
            custom.lbl_OtherAttributeWidth.constant = 0.0;
        }
        if (arr_SuperAttribute.count > 3) {
            width = width + 100.0;
            custom.lbl_SleeveWidth.constant = 100.0;
            if ([[[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[3]] objectForKey:@"value"]  isEqual: @"0"]) {
                custom.lbl_SleeveLength.text = @"";
            }else{
                custom.lbl_SleeveLength.text = [[arr_Order[indexPath.row] objectForKey:arr_SuperAttribute[3]] objectForKey:@"value"];
            }
            custom.lbl_SleeveLength.hidden = false;
            
        }else{
            custom.lbl_SleeveWidth.constant = 0.0 ;
        }
    }
    custom.View_SuperTableHeightConsrain.constant = width;
    custom.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:[[[arr_Order[indexPath.row] objectForKey:@"image"] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]]]];
    if (custom.img_Product.image == nil) {
        NSDictionary *imgParent =  [objDatabaseManager GetProductLongDetailImage:arr_Order[indexPath.row][@"Parent_ID"]];
        custom.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:[[imgParent objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]]]];
        if (custom.img_Product.image == nil) {
            custom.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
        }
    }
    custom.btn_ObjPlus.tag = indexPath.row;
    custom.btn_ObjMinus.tag = indexPath.row;
    custom.btn_ObjDeleteProduct.tag = indexPath.row;
    custom.btn_ObjProductMainMenu.tag = indexPath.row;
    [custom.btn_ObjPlus addTarget:self action:@selector(btnClicked_Plusproduct:)forControlEvents:UIControlEventTouchUpInside];
    [custom.btn_ObjMinus addTarget:self action:@selector(btnClicked_Minusproduct:)forControlEvents:UIControlEventTouchUpInside];
    [custom.btn_ObjDeleteProduct addTarget:self action:@selector(btnClicked_Deleteproduct:)forControlEvents:UIControlEventTouchUpInside];
    [custom.btn_ObjProductMainMenu addTarget:self action:@selector(btnClicked_ProductMenu:)forControlEvents:UIControlEventTouchUpInside];
    custom.lbl_Color.text = [custom.lbl_Color.text stringByReplacingOccurrencesOfString:@"0" withString:@""];
    return custom;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
    CustomTVC *custom = (CustomTVC *)cell;
    if (arr_Order.count > 0) {
        custom.View_Attribute.hidden = false;
        if (arr_SuperAttribute.count > 0) {
            custom.lbl_ColorWidth.constant = 100.0;
        }else{
            custom.lbl_ColorWidth.constant = 1.0 ;
        }
    }
    [custom setNeedsUpdateConstraints];
    [custom setNeedsLayout];
}
#pragma mark - IBAction Method
-(void)updateCart{
    
    for (int i = 0; i <arr_Order.count; i++) {
        [dbManager Update_Product:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :arr_ProductCount[i]:Order_Status:tv_Comment.text];
    }
}
- (IBAction)btnClicked_Save:(id)sender {
    for (int i = 0; i <arr_Order.count; i++) {
        [dbManager Update_Product:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :arr_ProductCount[i]:@"Cart":tv_Comment.text];
    }
}
- (IBAction)btnClicked_CancelOrder:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Are you sure you want to delete order with customer?"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Yes"] otherButtonTitles:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"No"], nil];
    //Are you sure you want to delete order with customer?
    alert.tag = 3;
    [alert show];
}
- (IBAction)btnClicked_PlaceOrder:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger sum = [[arr_ProductCount valueForKeyPath:@"@sum.self"] integerValue];
    if (sum > 0) {
        if ([tv_Comment.text  isEqual: @""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Enter Order Comment"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Submit"] otherButtonTitles:nil, nil];
            alert.tag = 15;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }else{
            [self PlaceOrder:tv_Comment.text];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"There should be at least 1 product in cart for place order"] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)btnClicked_SaveAndClose:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger sum = [[arr_ProductCount valueForKeyPath:@"@sum.self"] integerValue];
    if (sum > 0){
        if ([tv_Comment.text  isEqual: @""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Enter Order Comment"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Submit"] otherButtonTitles:nil, nil];
            alert.tag = 16;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }else{
            [self SaveAndCloseOrder:tv_Comment.text];
        }
    }else {
        if (status == true) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"There should be at least 1 product in cart for save order"] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
            [alert show];
        }else{
            if ([tv_Comment.text  isEqual: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Enter Order Comment"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Submit"] otherButtonTitles:nil, nil];
                alert.tag = 16;
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert show];
            }else{
                [self SaveAndCloseOrder:tv_Comment.text];
            }
        }
    }
}
- (IBAction)btnClicked_Plusproduct:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:tag inSection:0];
    [arr_ProductCount replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:tag]integerValue]+1]];
    [tbl_Cart reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationNone];
    [self sumOfProduct];
    [self NavigationInside];
}
- (IBAction)btnClicked_Minusproduct:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    if ([[arr_ProductCount  objectAtIndex:tag]  isEqual: @"0"]) {
    }else{
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:tag inSection:0];
        [arr_ProductCount replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:tag]integerValue]-1]];
        [tbl_Cart reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationNone];
        [self sumOfProduct];
    }
    [self NavigationInside];
}
- (IBAction)btnClicked_Deleteproduct:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    DeletTag = ((UIButton *)sender).tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Are you sure to Delete this Product ?"]delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Yes"] otherButtonTitles:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"No"], nil];
    alert.tag = 21;
    [alert show];
}
- (IBAction)btnClicked_ProductMenu:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    OMProductDetail *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMProductDetail"];
    vc.ProductId = arr_Order[tag][@"Parent_ID"];
    [[self navigationController] pushViewController:vc animated:YES];
}
#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==3){
        if(buttonIndex == 0){
            [dbManager DeleteOrder];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setBool:false forKey:@"Is_Client"];
            NSDate *today = [NSDate new];
            NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
            [dateFormat1 setDateFormat:@"dd-MMM-yyyy   hh:mm"];
            [dbManager InsertActivityLog:[dateFormat1 stringFromDate:today] :[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order is cancelled"]];
            OMHomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMHomeVC"];
            [[self navigationController] pushViewController:vc animated:YES];
        }else {
        }
    }else  if (alertView.tag==15){
        if(buttonIndex == 0){
            [self PlaceOrder:[alertView textFieldAtIndex:0].text];
        }else {
        }
    }else  if (alertView.tag==16){
        if(buttonIndex == 0){
            [self SaveAndCloseOrder:[alertView textFieldAtIndex:0].text];
        }else {
        }
    }else  if (alertView.tag==21){
        if(buttonIndex == 0){
            [dbManager Update_Product:[[arr_Order[DeletTag] objectForKey:@"entity_id"] objectForKey:@"value_id"] :@"0":@"Cart":tv_Comment.text];
            [arr_ProductCount removeObjectAtIndex:DeletTag];
            [arr_Order  removeObjectAtIndex:DeletTag];
            [tbl_Cart reloadData];
            [self sumOfProduct];
            [self NavigationInside];
        }else {
        }
    }else{
    }
}
-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if (alertView.tag == 15) {
        __weak NSString *Comment = [alertView textFieldAtIndex:0].text;
        if(Comment.length > 0){
            return true;
        }else{
            return false;
        }
    }
    return true;
}
#pragma mark - Place Order Method
-(void)PlaceOrder :(NSString *)Comment{
    for (int i = 0; i <arr_Order.count; i++) {
        [dbManager Update_Product:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :arr_ProductCount[i]:@"Cart":Comment];
    }
    [dbManager SavedOrder:@"Not Sync"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:false forKey:@"Is_Client"];
    NSDate *today = [NSDate new];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"dd-MMM-yyyy   hh:mm"];
    [dbManager InsertActivityLog:[dateFormat1 stringFromDate:today] :[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"New order is placed"]];
    OMHomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMHomeVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
#pragma mark - Save & Close Order Method
-(void)SaveAndCloseOrder :(NSString *)Comment{
    for (int i = 0; i <arr_Order.count; i++) {
        [dbManager Update_Product:[[arr_Order[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :arr_ProductCount[i]:@"Cart":Comment];
    }
    [dbManager SavedOrder:@"Saved"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:false forKey:@"Is_Client"];
    OMHomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMHomeVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
@end