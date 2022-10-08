//
//  OMProductDetail.m
//  Order Management
//
//  Created by MAC on 02/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMProductDetail.h"
#import "CustomCVC.h"
#import "CustomTVC.h"
#import "ArrayToDicConvert.h"
#import "OMCartVC.h"
#import "DatabaseManager.h"
@interface OMProductDetail ()
{
    NSMutableArray *arr_SubProduct,*arr_MainProductImage,*arr_AssociatedProduct,*arr_ProductCount,*arr_Customers,*arr_SuperAttribute,*arr_GroupPrice,*arr_ClvImage,*arr_crosssellproduct,*arr_allProductid;
    DBManager *dbManager;
    DatabaseManager *objDatabaseManager;
    ArrayToDicConvert *obj_ArrayyToDic;
    NSDictionary *Dic_MainProductDetail;
    NSString *Image_Path,*Product_Type,*Other_ProductCount;
    NSUserDefaults *userDefault;
    BOOL Is_Client,Image_Show,Is_Collection;
    NSInteger TagId,Image_Swipe_Tag,is_in_stock;
}
@end

@implementation OMProductDetail
@synthesize ProductId,SuPerAttributeViewWidthConstraint,HeaderViewWidthConstrain,tblWidthConstrain,lblColorWidth,lblOtherWidth,lblSizeWidth,lblSleevewidth,lblPriceWidth,imgmainWidth,lblSkuwidth;
- (void)viewDidLoad {
    [super viewDidLoad];
    obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    obj_ViewSuperAttribute.hidden = true;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"Is_Productprice"] == false) {
        lblPriceWidth.constant = 140.0;
    }else{
        lblPriceWidth.constant = 0.0;
    }
    if ([userDefault boolForKey:@"Is_Sku"] == true) {
        imgmainWidth.constant = 330;
        lblSkuwidth.constant = 0;
    }else{
        imgmainWidth.constant = 190;
        lblSkuwidth.constant = 140;
    }
    
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    Image_Path = [paths objectAtIndex:0];
    view_Customer.hidden = YES;
    [self Get_Product];
    [self setnavigation];
    obj_ViewSuperAttribute.hidden = false;
    arr_Customers = [[objDatabaseManager getCustomerList:@""] mutableCopy];
    [tbl_CustomerList reloadData];
}
-(void)setnavigation{
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        NSString *Cart_Item = [dbManager GetQuantity:[userDefault objectForKey:@"Order_Id"]];
        Other_ProductCount = [NSString stringWithFormat:@"%ld",[Cart_Item integerValue] - [[arr_ProductCount valueForKeyPath:@"@sum.self"]integerValue]];
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
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }else{
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(Clicked_Cart)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 100, 42)];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }
}

-(void)setnavigationInside{
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        NSString *Cart_Item = [NSString stringWithFormat:@"%ld",[Other_ProductCount integerValue] + [[arr_ProductCount valueForKeyPath:@"@sum.self"]integerValue]];
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
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }else{
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(Clicked_Cart)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 100, 42)];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }
}

-(void)Get_Product{
    arr_ProductCount = [[NSMutableArray alloc]init];
    arr_AssociatedProduct = [[NSMutableArray alloc]init];
    Dic_MainProductDetail = [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:ProductId] mutableCopy]];
    arr_crosssellproduct = [[NSMutableArray alloc] init];
    NSString *str_CrosssellProduct = [dbManager GetCrosssellProduct:ProductId];
    if ([str_CrosssellProduct  isEqual: @""]) {
        
    }else{
        arr_crosssellproduct = [[str_CrosssellProduct componentsSeparatedByString:@","] mutableCopy];
    }
    for (int i = 0; i < arr_crosssellproduct.count; i++) {
        if ([dbManager CheckVisibleproduct:arr_crosssellproduct[i]] == true) {
            
        }else{
            [arr_crosssellproduct removeObjectAtIndex:i];
            i--;
        }
    }
    [clv_CrosssellProduct reloadData];
    if ([Dic_MainProductDetail[@"is_in_stock"][@"value_id"]  isEqual: @"0"]) {
        is_in_stock = 1;
    }else{
        is_in_stock = 2;
    }
    Product_Type = [[Dic_MainProductDetail objectForKey:@"type_id"] objectForKey:@"value_id"];
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]] mutableCopy];
    }else{
    }
    if ([Product_Type  isEqual: @"simple"]) {
        obj_ViewSuperAttribute.hidden = YES;
        SuPerAttributeViewWidthConstraint.constant = 0.0;
        if ([userDefault boolForKey:@"Is_Sku"] == true) {
            HeaderViewWidthConstrain.constant =300.0;
        }else{
            HeaderViewWidthConstrain.constant = 440.0;
        }
        tblWidthConstrain.constant = 440.0;
        if ([userDefault  boolForKey:@"Is_Client"] == true) {
            NSString *str_Quantity = [dbManager GetAllOrderRecord:ProductId];
            [arr_ProductCount addObject:str_Quantity];
        }else{
            [arr_ProductCount addObject:@"0"];
        }
    }else{
        float width = 440.0;
        if ([userDefault boolForKey:@"Is_Sku"] == true) {
            HeaderViewWidthConstrain.constant =662.0;
        }else{
            HeaderViewWidthConstrain.constant = 802.0;
        }
        NSString *str_AssociatedProduct = [dbManager GetAssociatedProduct:ProductId];
        NSString *str = [dbManager GetAttributeID:ProductId];
        arr_SuperAttribute = [[objDatabaseManager GetAttributeName:[str componentsSeparatedByString:@","]] mutableCopy];
        NSMutableArray *arr_TempAttribute = [[objDatabaseManager GetAttributeName:[str componentsSeparatedByString:@","]] mutableCopy];
        if (arr_TempAttribute.count > 0) {
            width = width + 90.0;
            lblColorWidth.constant = 90.0;
            lbl_Color.text = [dbManager GetCode: arr_TempAttribute[0]];
            [arr_TempAttribute removeObjectAtIndex:0];
        }else{
            lblColorWidth.constant = 0.0 ;
            lbl_Color.hidden = YES;
        }
        if (arr_TempAttribute.count > 0){
            width = width + 90.0;
            lblSizeWidth.constant = 90.0;
            lbl_Size.text = [dbManager GetCode: arr_TempAttribute[0]];
            [arr_TempAttribute removeObjectAtIndex:0];
        }else{
            lblSizeWidth.constant = 0.0 ;
            lbl_Size.hidden = YES;
        }
        if (arr_TempAttribute.count > 0) {
            width = width + 90.0;
            lbl_Sleeve.text = [dbManager GetCode: arr_TempAttribute[0]];
            lblSleevewidth.constant = 90.0;
        }else{
            lblSleevewidth.constant = 0.0 ;
            lbl_Sleeve.hidden = YES;
        }
        if (arr_TempAttribute.count > 1) {
            lbl_LastAttribute.text = [dbManager GetCode: arr_TempAttribute[1]];
            width = width + 95.0;
            lblOtherWidth.constant = 95.0;
        }else{
            lblOtherWidth.constant = 0.0;
            lbl_LastAttribute.hidden = YES;
        }
        tblWidthConstrain.constant = width;
        SuPerAttributeViewWidthConstraint.constant = width  - 440.0;
        str_AssociatedProduct =  [str_AssociatedProduct stringByReplacingOccurrencesOfString:@"{\n    " withString:@""];
        str_AssociatedProduct = [str_AssociatedProduct stringByReplacingOccurrencesOfString:@";\n}" withString:@""];
        str_AssociatedProduct = [str_AssociatedProduct stringByReplacingOccurrencesOfString:@"\n    " withString:@""];
        str_AssociatedProduct = [str_AssociatedProduct stringByReplacingOccurrencesOfString:@"=" withString:@";"];
        str_AssociatedProduct = [str_AssociatedProduct stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableArray *arrTemp = [[str_AssociatedProduct componentsSeparatedByString:@";"]mutableCopy];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrTemp];
        NSMutableArray *arr_productId = [[orderedSet array]mutableCopy];
        NSMutableArray *arrTemp_AssociatedProduct = [[NSMutableArray alloc] init];
        NSMutableArray *arrTemp_ProductCount = [[NSMutableArray alloc] init];
        for (int i = 0; i < arr_productId.count; i++) {
            NSDictionary *dic =  [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:[arr_productId objectAtIndex:i]] mutableCopy]];
            [arrTemp_AssociatedProduct addObject:dic];
            if ([userDefault  boolForKey:@"Is_Client"] == true) {
                NSString *str_Quantity = [dbManager GetAllOrderRecord:[[dic objectForKey:@"entity_id"] objectForKey:@"value_id"]];
                [arrTemp_ProductCount addObject:str_Quantity];
            }else{
                [arrTemp_ProductCount addObject:@"0"];
            }
        }
        NSMutableArray *arrTemp_AssociatedProduct_check,*arrTemp_ProductCount_check,*arrChkSuperAttribute;
        NSArray *arr_SotOrder;
        NSString *superAttributeCode;
        for (int SA = 0; SA <arr_SuperAttribute.count; SA++) {
            arr_SotOrder = [[NSMutableArray alloc] init];
            arrTemp_AssociatedProduct_check = [[NSMutableArray alloc] init];
            arrTemp_ProductCount_check = [[NSMutableArray alloc] init];
            arr_SotOrder = [objDatabaseManager  GetSortOrder:arr_SuperAttribute[SA]];
            superAttributeCode = arr_SuperAttribute[SA];
            
            if ([[arr_SotOrder valueForKey:@"sort_order"] containsObject:@"1"]) {
                if (SA > 0) {
                    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrChkSuperAttribute];
                    NSMutableArray *arr_TempSuperAttribute = [[orderedSet array]mutableCopy];
                    NSMutableArray *arr_secondAttributeProduct,*arr_secondattributeCount;
                    for (int z = 0; z <arr_TempSuperAttribute.count; z++) {
                        arr_secondAttributeProduct = [[NSMutableArray alloc] init];
                        arr_secondattributeCount = [[NSMutableArray alloc] init];
                        for (int p = 0; p < arrTemp_AssociatedProduct.count; p++) {
                            NSString *str_attributeValue  =  [[[arrTemp_AssociatedProduct valueForKey:arr_SuperAttribute[SA-1]] valueForKey:@"value"] objectAtIndex:p];
                            NSLog(@"%@",str_attributeValue);
                            if ([str_attributeValue isEqual: arr_TempSuperAttribute[z]]) {
                                [arr_secondAttributeProduct addObject:arrTemp_AssociatedProduct[p]];
                                [arr_secondattributeCount addObject:arrTemp_ProductCount[p]];
                            }else{
                            }
                        }
                        for (int i = 0; i < arr_SotOrder.count; i++) {
                            for (int  k =0 ; k <arr_secondAttributeProduct.count; k++) {
                                if ([[[arr_SotOrder objectAtIndex:i] objectForKey:@"option_id"]  isEqual:[[[arr_secondAttributeProduct valueForKey:superAttributeCode] valueForKey:@"value_id"] objectAtIndex:k]]) {
                                    [arrTemp_AssociatedProduct_check addObject:arr_secondAttributeProduct[k]];
                                    [arrTemp_ProductCount_check addObject:arr_secondattributeCount[k]];
                                }else{
                                }
                            }
                            if (i+1 == arr_SotOrder.count) {
                                if (z+1 == arr_TempSuperAttribute.count) {
                                    arrTemp_AssociatedProduct = [arrTemp_AssociatedProduct_check mutableCopy];
                                    arrTemp_ProductCount = [arrTemp_ProductCount_check mutableCopy];
                                }
                            }
                        }
                    }
                }else{
                    for (int i = 0; i < arr_SotOrder.count; i++) {
                        for (int  k =0 ; k <arrTemp_AssociatedProduct.count; k++) {
                            if ([[[arr_SotOrder objectAtIndex:i] objectForKey:@"option_id"]  isEqual:[[[arrTemp_AssociatedProduct valueForKey:superAttributeCode] valueForKey:@"value_id"] objectAtIndex:k]]) {
                                [arrTemp_AssociatedProduct_check addObject:arrTemp_AssociatedProduct[k]];
                                [arrTemp_ProductCount_check addObject:arrTemp_ProductCount[k]];
                            }else{
                                
                            }
                        }
                        if (i+1 == arr_SotOrder.count) {
                            arrTemp_AssociatedProduct = [arrTemp_AssociatedProduct_check mutableCopy];
                            arrTemp_ProductCount = [arrTemp_ProductCount_check mutableCopy];
                        }
                    }
                }
            }else{
                arr_SotOrder = [[NSMutableArray alloc] init];
                arrTemp_AssociatedProduct_check = [arrTemp_AssociatedProduct mutableCopy];
                arrTemp_ProductCount_check = [arrTemp_ProductCount mutableCopy];
            }
            NSString *first_attribute,*second_Attribute,*status_check;
            arrChkSuperAttribute = [[NSMutableArray alloc] init];
            for (int s = 0; s <arrTemp_AssociatedProduct_check.count; s++) {
                NSLog(@"%@",superAttributeCode);
                [arrChkSuperAttribute addObject:[[[arrTemp_AssociatedProduct_check valueForKey:superAttributeCode] valueForKey:@"value"] objectAtIndex:s]];
                if (s == 0) {
                }else{
                    first_attribute = [[[arrTemp_AssociatedProduct_check valueForKey:superAttributeCode] valueForKey:@"value"] objectAtIndex:s-1];
                    second_Attribute = [[[arrTemp_AssociatedProduct_check valueForKey:superAttributeCode] valueForKey:@"value"] objectAtIndex:s];
                    if ([first_attribute isEqualToString:second_Attribute]) {
                        status_check = @"Yes";
                    }else{
                        if (s+1 == arrTemp_AssociatedProduct_check.count) {
                            if ([status_check  isEqual: @"Yes"]) {
                                
                            }else{
                                break;
                            }
                        }
                    }
                }
            }
        }
        arr_AssociatedProduct = [arrTemp_AssociatedProduct_check mutableCopy];
    for (int ImageIndex = 0; ImageIndex < arr_AssociatedProduct.count; ImageIndex++) {
            if ([arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] == nil) {
            }else{
                if ([[[arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] objectForKey:@"value_id"]  containsString:@"."]) {
                    [arr_ClvImage addObject:[[[arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
                    //                    cell.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[ImageIndex]]]];
                }else{
                }
            }
        }
        
        arr_ProductCount = [arrTemp_ProductCount_check mutableCopy];
    }
    arr_ClvImage =[[NSMutableArray alloc] init];
    NSMutableArray *arr_MainProductImagesub = [[objDatabaseManager GetMediaGallery:ProductId] mutableCopy];
    for (int i = 0;  i <arr_MainProductImagesub.count; i++) {
        NSString *str = arr_MainProductImagesub[i][@"file"];
        [arr_ClvImage addObject:[str stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
    }
    
    [tbl_OtherProduct reloadData];
    [clv_ImgList reloadData];
    lbl_ProductName.text = [NSString stringWithFormat:@" %@   (%@)",[[Dic_MainProductDetail objectForKey:@"name"] objectForKey:@"value_id"],Dic_MainProductDetail[@"sku"][@"value_id"]];
    //    lbl_Sku.text = [NSString stringWithFormat:@"%@",[[Dic_MainProductDetail objectForKey:@"sku"] objectForKey:@"value_id"]];
    txt_ProductDescription.text = [[Dic_MainProductDetail objectForKey:@"description"] objectForKey:@"value_id"];
    
    if ([[[Dic_MainProductDetail objectForKey:@"image"] objectForKey:@"value_id"]  containsString:@"."]) {
        img_Main.image = [UIImage imageWithData:
                          [NSData dataWithContentsOfFile:
                           [Image_Path stringByAppendingPathComponent:
                            [
                             [
                              [Dic_MainProductDetail
                               objectForKey:@"image"]
                              objectForKey:@"value_id"]
                             stringByReplacingOccurrencesOfString:@"/" withString:@"!"]
                            ]
                           ]
                          ];
    }else{
        img_Main.image = [UIImage imageNamed:@"NotAvalible"];
    }
    if (img_Main.image == nil) {
        img_Main.image = [UIImage imageNamed:@"NotAvalible"];
    }
    tbl_OtherProduct.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tbl_OtherProduct setNeedsUpdateConstraints];
    [tbl_OtherProduct setNeedsLayout];
    [self LanguageSetup];
}
-(void)LanguageSetup{
    lbl_Price.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"PRICE"];
    lbl_Sku.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"SKU"];
    lbl_Quantity.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"QUANTITY"];
    lbl_Crossellproduct.text = [NSString stringWithFormat:@"    %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Cross-sell products"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        [self updateCart];
    }
}
-(void)Clicked_Cart{
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        OMCartVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCartVC"];
        [[self navigationController] pushViewController:vc animated:YES];
    }else{
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
    if (tableView == tbl_CustomerList) {
        return arr_Customers.count;
    }else{
        if ([Product_Type  isEqual: @"simple"]) {
            return 1;
        }else{
            return arr_AssociatedProduct.count;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (tableView == tbl_CustomerList) {
        custom.lbl_CustomerName.text = [arr_Customers[indexPath.row] valueForKey:@"firstname"];
    }else{
        custom.preservesSuperviewLayoutMargins = false;
        custom.contentView.preservesSuperviewLayoutMargins = false;
        custom.View_SuperTableHeightConsrain.constant = SuPerAttributeViewWidthConstraint.constant;
        if ([userDefault boolForKey:@"Is_Productprice"] == false) {
            custom.lbl_priceattributewidth.constant = 140.0;
        }else{
            custom.lbl_priceattributewidth.constant = 0.0;
        }
        if ([userDefault boolForKey:@"Is_Sku"] == false) {
            custom.lbl_skuattributewidth.constant = 140.0;
        }else{
            custom.lbl_skuattributewidth.constant = 0.0;
        }
        if ([Product_Type  isEqual: @"simple"]) {
            custom.lbl_ColorWidth.constant = 1.0;
            custom.lbl_SizeWidth.constant = 1.0;
            custom.lbl_SleeveWidth.constant = 1.0;
            custom.lbl_OtherAttributeWidth.constant = 1.0;
            custom.lbl_SKU.text = [[Dic_MainProductDetail objectForKey:@"sku"] objectForKey:@"value_id"];
            if ([userDefault  boolForKey:@"Is_Client"] == true) {
                if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:ProductId]) {
                    NSString *price = [dbManager GetPrice:ProductId :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
                    custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[price floatValue]];
                    
                }else{
                    custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[Dic_MainProductDetail objectForKey:@"price"] objectForKey:@"value_id"]floatValue]];
                }
            }else {
                custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[Dic_MainProductDetail objectForKey:@"price"] objectForKey:@"value_id"]floatValue]];
            }
            custom.lbl_Quantity.text = arr_ProductCount[indexPath.row];
            if (is_in_stock == 1) {
                custom.btnObj_Information.hidden = true;
                custom.lbl_OutOfStock.hidden =false;
            }else{
                custom.btnObj_Information.hidden = false;
                custom.lbl_OutOfStock.hidden =true;
            }
            
        }else{
            if (arr_AssociatedProduct.count > 0) {
                if (is_in_stock == 1) {
                    custom.btnObj_Information.hidden = true;
                    custom.lbl_OutOfStock.hidden =false;
                }
                else{
                    if ([arr_AssociatedProduct[indexPath.row][@"is_in_stock"][@"value_id"]  isEqual: @"0"] ) {
                        custom.btnObj_Information.hidden = true;
                        custom.lbl_OutOfStock.hidden =false;
                        
                    }else{
                        custom.btnObj_Information.hidden = false;
                        custom.lbl_OutOfStock.hidden =true;
                    }
                    
                }custom.View_Attribute.hidden = false;
                if (arr_SuperAttribute.count  > 0) {
                    custom.lbl_ColorWidth.constant = 90.0;
                    custom.lbl_Color.hidden = NO;
                    custom.lbl_Color.text = [[arr_AssociatedProduct[indexPath.row] objectForKey:arr_SuperAttribute[0]] objectForKey:@"value"];
                    
                }else{
                    custom.lbl_ColorWidth.constant = 1.0 ;
                }
                if (arr_SuperAttribute.count > 1){
                    custom.lbl_SizeWidth.constant = 90.0;
                    custom.lbl_Size.hidden = NO;
                    custom.lbl_Size.text = [[arr_AssociatedProduct[indexPath.row] objectForKey:arr_SuperAttribute[1]] objectForKey:@"value"];
                }else{
                    custom.lbl_SizeWidth.constant = 0.0 ;
                }
                if (arr_SuperAttribute.count > 2) {
                    custom.lbl_SleeveWidth.constant = 90.0;
                    custom.lbl_SleeveLength.text = [[arr_AssociatedProduct[indexPath.row] objectForKey:arr_SuperAttribute[2]] objectForKey:@"value"];
                    custom.lbl_SleeveLength.hidden = false;
                }else{
                    custom.lbl_SleeveWidth.constant = 0.0 ;
                    custom.lbl_SleeveLength.hidden = true;
                }
                if (arr_SuperAttribute.count > 3) {
                    custom.lbl_OtherAttribute.text = [[arr_AssociatedProduct[indexPath.row] objectForKey:arr_SuperAttribute[3]] objectForKey:@"value"];
                    custom.lbl_OtherAttribute.hidden = false;
                    custom.lbl_OtherAttributeWidth.constant = 95.0;
                }else{
                    custom.lbl_OtherAttributeWidth.constant = 0.0;
                }
                custom.lbl_SKU.text = [[arr_AssociatedProduct[indexPath.row] objectForKey:@"sku"] objectForKey:@"value_id"];
                if ([userDefault  boolForKey:@"Is_Client"] == true) {
                    if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_AssociatedProduct[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
                        NSString *price = [dbManager GetPrice:[[arr_AssociatedProduct[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
                        custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[price floatValue]];
                    }
                    else{
                        custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[arr_AssociatedProduct[indexPath.row] objectForKey:@"price"] objectForKey:@"value_id"]floatValue]];
                    }
                }else{
                    custom.lbl_Price.text = [NSString stringWithFormat:@"%@ %.2f",[userDefault objectForKey:@"currency_code"],[[[arr_AssociatedProduct[indexPath.row] objectForKey:@"price"] objectForKey:@"value_id"]floatValue]];
                }
                custom.lbl_Quantity.text = arr_ProductCount[indexPath.row];
            }else{
            }
        }
        custom.btn_ObjPlus.tag = indexPath.row;
        custom.btn_ObjMinus.tag = indexPath.row;
        [custom.btn_ObjPlus addTarget:self action:@selector(btnClicked_Plusproduct:)forControlEvents:UIControlEventTouchUpInside];
        [custom.btn_ObjMinus addTarget:self action:@selector(btnClicked_Minusproduct:)forControlEvents:UIControlEventTouchUpInside];
    }
    [custom layoutIfNeeded];
    return custom;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    CustomTVC *custom = (CustomTVC *)cell;
    if ([Product_Type  isEqual: @"simple"]) {
        custom.View_SuperTableHeightConsrain.constant = 0.0f;
    }else{
        custom.View_SuperTableHeightConsrain.constant = SuPerAttributeViewWidthConstraint.constant;
    }
    [custom setNeedsLayout];
    [custom layoutSubviews];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tbl_CustomerList) {
        if (![[[arr_Customers objectAtIndex:indexPath.row]objectForKey:@"default_shipping"]  isEqual: @"(null)"] && ![[[arr_Customers objectAtIndex:indexPath.row]objectForKey:@"default_billing"]  isEqual: @"(null)"]) {
            TagId = indexPath.row;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Are you sure to select this customer?"] delegate:self cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Yes"] otherButtonTitles:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"No"], nil];
            alert.tag = 57;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"This customer has not set default address.Please select other coustmer."] delegate:nil cancelButtonTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Ok"] otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
    CustomTVC *custom = (CustomTVC *)cell;
    [custom setNeedsUpdateConstraints];
    [custom setNeedsLayout];
}

#pragma mark - UICollectionViewDelegate & DataSource Method

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == clv_CrosssellProduct) {
        return arr_crosssellproduct.count;
    }else{
        return arr_ClvImage.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == clv_CrosssellProduct) {
        CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        NSDictionary *arrDetail = [[objDatabaseManager GetDeatilsell:arr_crosssellproduct[indexPath.row]] mutableCopy];
        NSDictionary *ImageDetailt = [objDatabaseManager GetDeatilsellImage:[arr_crosssellproduct[indexPath.row] mutableCopy]];
        NSLog(@"arrdetail %@",arrDetail);
        if ([ImageDetailt valueForKey:@"value_id"]) {
            NSString *imageName = [ImageDetailt[@"value_id"] stringByReplacingOccurrencesOfString:@"/" withString:@"!"];
            cell.img_Product.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:imageName]]];
            
        }else{
            
        }
        cell.lbl_ProductName.text = [arrDetail objectForKey:@"value_id"];
        
        return cell;
    }else{
        CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        //    if ([[[arr_AssociatedProduct[indexPath.row]objectForKey:@"small_image"] objectForKey:@"value_id"]  containsString:@"."]) {
        //        cell.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:[[[arr_AssociatedProduct[indexPath.row]objectForKey:@"small_image"] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]]]];
        //    }else{
        //        cell.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
        //    }
        cell.img_Product.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[indexPath.row]]]];
        if (cell.img_Product.image == nil) {
            cell.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
        }
        return cell;
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == clv_ImgList) {
        Is_Collection = true;
        Image_Swipe_Tag = indexPath.row;
        if ([UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[indexPath.row]]]] == nil) {
            
        }else{
            img_Blur.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[indexPath.row]]]];
            if (arr_ClvImage.count > 1) {
                btn_ObjLeftSwipe.hidden = false;
                btn_ObjRightSwipe.hidden = false;
                
            }
            view_Blur.hidden = NO;
            self.navigationController.navigationBarHidden = true;
            
        }
        //    if ([[[arr_AssociatedProduct[indexPath.row]objectForKey:@"small_image"] objectForKey:@"value_id"]  containsString:@"."]) {
        //        arr_MainProductImage = [[objDatabaseManager GetMediaGallery:[[arr_AssociatedProduct[indexPath.row] objectForKey:@"entity_id"] objectForKey:@"value_id"]] mutableCopy];
        //        if (arr_MainProductImage.count > 1) {
        //            btn_ObjRightSwipe.hidden = false;
        //            btn_ObjLeftSwipe.hidden = false;
        //        }else{
        
        //    }else{
        //    }
        
    }else{
        NSLog(@"product id %@",ProductId);
        if ([userDefault  boolForKey:@"Is_Client"] == true) {
            [self updateCart];
        }
        ProductId =  arr_crosssellproduct[indexPath.row];
        [self Get_Product];
        [self setnavigation];
    }
}
#pragma mark - IBAction Method
- (IBAction)btnClicked_BlurImage:(id)sender {
    Is_Collection = false;
    UIImage *img;
    if ([[[Dic_MainProductDetail objectForKey:@"image"] objectForKey:@"value_id"]  containsString:@"."]) {
        img = [UIImage imageWithData:
               [NSData dataWithContentsOfFile:
                [Image_Path stringByAppendingPathComponent:
                 [
                  [
                   [Dic_MainProductDetail
                    objectForKey:@"image"]
                   objectForKey:@"value_id"]
                  stringByReplacingOccurrencesOfString:@"/" withString:@"!"]
                 ]
                ]
               ];
    }else{
        
    }
    if (img == nil) {
        
    }else{
        img_Blur.image = img_Main.image;
        NSMutableArray *arr_ClvImagetemp =[[NSMutableArray alloc] init];
        for (int ImageIndex = 0; ImageIndex < arr_AssociatedProduct.count; ImageIndex++) {
            if ([arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] == nil) {
            }else{
                if ([[[arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] objectForKey:@"value_id"]  containsString:@"."]) {
                    [arr_ClvImagetemp addObject:[[[arr_AssociatedProduct[ImageIndex]objectForKey:@"small_image"] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
                    //                    cell.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[ImageIndex]]]];
                }else{
                }
            }
        }
        
        self.navigationController.navigationBarHidden = true;
        arr_MainProductImage = [[objDatabaseManager GetMediaGallery:ProductId] mutableCopy];
        for (int i = 0;  i <arr_ClvImagetemp.count; i++) {
            NSDictionary *dic = @{@"file":arr_ClvImagetemp[i],@"position":[NSString stringWithFormat:@"%lu",arr_MainProductImage.count+1]};
            [arr_MainProductImage addObject:dic];
        }
        //        arr_MainProductImage =  [[arr_MainProductImage arrayByAddingObjectsFromArray:arr_ClvImage] mutableCopy];
        if (arr_MainProductImage.count > 1) {
            Image_Swipe_Tag = 0;
            btn_ObjLeftSwipe.hidden = NO;
            btn_ObjRightSwipe.hidden = NO;
        }else{
            btn_ObjLeftSwipe.hidden = YES;
            btn_ObjRightSwipe.hidden = YES;
        }
        view_Blur.hidden = NO;
    }
}
- (IBAction)btnClicked_HideView:(id)sender {
    view_Blur.hidden=YES;
    self.navigationController.navigationBarHidden = false;
}
-(void) updateCart{
    NSMutableArray *arr_SubmitOrder = [[NSMutableArray alloc]init];
    if ([Product_Type  isEqual: @"simple"]) {
        NSString *price = @"0";
        if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:ProductId]) {
            price = [dbManager GetPrice:ProductId :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
            
        }else{
            price = [[Dic_MainProductDetail objectForKey:@"price"] objectForKey:@"value_id"];
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[arr_ProductCount objectAtIndex:0] forKey:@"Quantity"];
        [dic setObject: ProductId forKey:@"entity_id"];
        [dic setObject:price forKey:@"base_Price"];
        [arr_SubmitOrder addObject:dic];
        if ([dbManager CheckOrderStatus] == YES) {
            [dbManager InsertOrder:arr_SubmitOrder :@"Cart" :@"":@"":ProductId:@"0":@"0"];
        }else{
            [dbManager InsertOrder:arr_SubmitOrder:[dbManager GetStatusFromOrder:[userDefault objectForKey:@"Order_Id"]]:[dbManager GetCommentFromOrder:[userDefault objectForKey:@"Order_Id"]]:@"":ProductId:@"0":@"0"];
        }
    }else{
        
        for (int i = 0; i <arr_AssociatedProduct.count; i++) {
            NSString *price = @"0";
            if ([[arr_GroupPrice valueForKey:@"entity_id"] containsObject:[[arr_AssociatedProduct[i] objectForKey:@"entity_id"] objectForKey:@"value_id"]]) {
                price = [dbManager GetPrice:[[arr_AssociatedProduct[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] :[dbManager GetCustomerGroup:[userDefault objectForKey:@"Customer_Id"]]];
            }
            else{
                price = [[arr_AssociatedProduct[i] objectForKey:@"price"] objectForKey:@"value_id"];
            }
            
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[arr_ProductCount objectAtIndex:i] forKey:@"Quantity"];
            [dic setObject:price forKey:@"base_Price"];
            [dic setObject: [[arr_AssociatedProduct[i] objectForKey:@"entity_id"] objectForKey:@"value_id"] forKey:@"entity_id"];
            [arr_SubmitOrder addObject:dic];
            
            
        }
        if ([dbManager CheckOrderStatus] == YES) {
            [dbManager InsertOrder:arr_SubmitOrder :@"Cart" :@"":[dbManager GetAttributeID:ProductId]:ProductId:@"0":@"0"];
        }else{
            [dbManager InsertOrder:arr_SubmitOrder:[dbManager GetStatusFromOrder:[userDefault objectForKey:@"Order_Id"]]:[dbManager GetCommentFromOrder:[userDefault objectForKey:@"Order_Id"]]:[dbManager GetAttributeID:ProductId]:ProductId:@"0":@"0"];
        }
    }
}
- (IBAction)btnClicked_Plus:(id)sender {
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        for (int i = 0; i <arr_ProductCount.count; i++) {
            [arr_ProductCount replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:i]integerValue]+1]];
        }
        [tbl_OtherProduct reloadData];
        // [self updateCart];
        [self setnavigationInside];
    }else{
        view_Customer.hidden = NO;
    }
}
- (IBAction)btnClicked_Minus:(id)sender {
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        if ([arr_ProductCount containsObject:@"0"]) {
        }else{
            for (int i = 0; i <arr_ProductCount.count; i++) {
                [arr_ProductCount replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:i]integerValue]- 1]];
            }
            [tbl_OtherProduct reloadData];
        }
    }else{
    }
    //   [self updateCart];
    [self setnavigationInside];
}
- (IBAction)btnClicked_Plusproduct:(id)sender {
    if ([userDefault  boolForKey:@"Is_Client"] == true) {
        NSInteger tag= ((UIButton *)sender).tag;
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:tag inSection:0];
        [arr_ProductCount replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:tag]integerValue]+1]];
        // [tbl_OtherProduct reloadData];
        [tbl_OtherProduct reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationNone];
        // [self updateCart];
        [self setnavigationInside];
    }else{
        view_Customer.hidden = NO;
    }
}
- (IBAction)btnClicked_Minusproduct:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:tag inSection:0];
    if ([[arr_ProductCount  objectAtIndex:tag]  isEqual: @"0"]) {
    }else{
        [arr_ProductCount replaceObjectAtIndex:tag withObject:[NSString stringWithFormat:@"%ld",[[arr_ProductCount objectAtIndex:tag]integerValue]-1]];
        //        [tbl_OtherProduct reloadData];
        [tbl_OtherProduct reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationNone];
    }
    // [self updateCart];
    [self setnavigationInside];
}
- (IBAction)btnClicked_LeftSwipe:(id)sender {
    if (Is_Collection == false) {
        Image_Swipe_Tag--;
        if (Image_Swipe_Tag == -1) {
            Image_Swipe_Tag = arr_MainProductImage.count-1;
        }
        if ([arr_MainProductImage[Image_Swipe_Tag][@"file"] containsString:@"."]) {
            NSString *str = arr_MainProductImage[Image_Swipe_Tag][@"file"];
            NSString *file = [Image_Path stringByAppendingPathComponent:[str stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
            img_Blur.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:file]];
        }else{
            img_Blur.image = [UIImage imageNamed:@"NotAvalible"];
        }
    }else{
        Image_Swipe_Tag--;
        if (Image_Swipe_Tag == -1) {
            Image_Swipe_Tag = arr_ClvImage.count-1;
        }
        img_Blur.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[Image_Swipe_Tag]]]];
    }
}

- (IBAction)btnClicked_RightSwipe:(id)sender {
    if (Is_Collection == false) {
        Image_Swipe_Tag++;
        if (Image_Swipe_Tag == arr_MainProductImage.count) {
            Image_Swipe_Tag = 0;
        }
        if ([arr_MainProductImage[Image_Swipe_Tag][@"file"] containsString:@"."]) {
            NSString *str = arr_MainProductImage[Image_Swipe_Tag][@"file"];
            NSString *file = [Image_Path stringByAppendingPathComponent:[str stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
            img_Blur.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:file]];
        }else{
            img_Blur.image = [UIImage imageNamed:@"NotAvalible"];
        }
    }else{
        Image_Swipe_Tag++;
        if (Image_Swipe_Tag == arr_ClvImage.count) {
            Image_Swipe_Tag = 0;
        }
        img_Blur.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_ClvImage[Image_Swipe_Tag]]]];
    }
}
#pragma mark - Search Bar Method
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    arr_Customers = [[objDatabaseManager getCustomerList:search_bar.text] mutableCopy];
    [tbl_CustomerList reloadData];
    [search_bar resignFirstResponder];
}
#pragma mark - Alert View Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 57){
        if(buttonIndex == 0){
            [userDefault setObject:[dbManager GetMaxOrderID] forKey:@"Order_Id"];
            [userDefault  setBool:true forKey:@"Is_Client"];
            arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[[arr_Customers objectAtIndex:TagId]objectForKey:@"Customer_id"]]] mutableCopy];
            [userDefault setObject:[[arr_Customers objectAtIndex:TagId]objectForKey:@"Customer_id"] forKey:@"Customer_Id"];
            view_Customer.hidden = YES;
            [tbl_OtherProduct reloadData];
            [self setnavigation];
        }
        else if(buttonIndex == 1){
        }
        else {
        }
    }
    else{
    }
}
@end