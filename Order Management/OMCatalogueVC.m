//
//  OMCatalogueVC.m
//  Order Management
//
//  Created by MAC on 30/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "OMCatalogueVC.h"
#import "CustomTVC.h"
#import "CustomCVC.h"
#import "Cataloue.h"
#import "JMImageCache.h"
#import "ArrayToDicConvert.h"
#import "RecipeCollectionHeaderView.h"
#import "OMProductDetail.h"
#import "OMCartVC.h"
#import "CLVLayout.h"
#import "DatabaseManager.h"

@interface OMCatalogueVC ()
{
    NSMutableArray *arr_Category,*arr_CacheCategoryID,*arr_CacheCategoryName,*arr_Product,*arr_SideMenuCategory,*arr_Space,*arr_Font,*arr_Color,*arr_Header,*arr_SubProduct,*arr_SizeType;
    DBManager *dbManager;
    NSString *parent_Id,*level,*Image_Path,*max_Level;
    ArrayToDicConvert *obj_ArrayyToDic;
    BOOL isfirstTime;
    NSArray *arrProductsInCart;
    DatabaseManager *database;
    NSString *temp_ID_Cat,*str_SizeTag;
    // CLVLayout *layout_Category;
    UICollectionViewFlowLayout *layout_Product,*layout_Category;
}
@end

@implementation OMCatalogueVC
@synthesize PageDefination,HeaderViewHeightConstraint,SideViewWidthtConstraint;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    database = [[DatabaseManager alloc] initwithDBName:@"Order Management System"];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    if (isfirstTime == false) {
        isfirstTime = true;
        str_SizeTag = [dbManager GetValue:[userDefault objectForKey:@"Language"] :[userDefault objectForKey:@"Catalogue_ViewSize"]];
        if ([str_SizeTag  isEqual: @""] || [userDefault valueForKey:@"Catalogue_ViewSize"] == nil) {
            str_SizeTag = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Small"];
            [userDefault setObject:@"Small" forKey:@"Catalogue_ViewSize"];
        }
        [btn_ObjSize setTitle:str_SizeTag forState:UIControlStateNormal];
        layout_Category = (UICollectionViewFlowLayout *)[clv_CategoryList collectionViewLayout];
        layout_Product= (UICollectionViewFlowLayout *)[clv_ProductList collectionViewLayout];
        if ([str_SizeTag  isEqual: [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Large"]]) {
            [layout_Category setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            [layout_Product setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            
        }else{
            [layout_Category setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layout_Product setScrollDirection:UICollectionViewScrollDirectionVertical];
        }
        obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        Image_Path = [paths objectAtIndex:0];
        if ([PageDefination  isEqual: @"QuickOrder"]) {
            view_Header.hidden = YES;
            view_SideMenu.hidden = YES;
            clv_CategoryList.hidden = YES;
            clv_ProductList.hidden = NO;
            view_Search.hidden = NO;
            HeaderViewHeightConstraint.constant = 50;
            SideViewWidthtConstraint.constant = 0;
            [self.view setNeedsUpdateConstraints];
            [self.view setNeedsLayout];
            //            self.navigationItem.title = @"Quick Order";
            self.navigationItem.title = [NSString stringWithFormat:@"%@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Quick Order"]];
        }else{
            clv_ProductList.hidden = YES;
            clv_CategoryList.hidden = NO;
            //            self.navigationItem.title = @"Catalog";
            self.navigationItem.title = [NSString stringWithFormat:@"%@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Catalog"]];
        }
        parent_Id = @"0";
        level = @"2";
        max_Level = [[dbManager GetMaxLevel]mutableCopy];
        arr_CacheCategoryID = [[NSMutableArray alloc]init];
        arr_CacheCategoryName = [[NSMutableArray alloc]init];
        tbl_Category.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
        arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
        
        arr_Product = [[NSMutableArray alloc]init];
        
        arr_SideMenuCategory = [[database GetCategory:level :parent_Id] mutableCopy];
        
        arr_Space = [[NSMutableArray alloc]initWithObjects:@"",@"  ",@"    ",@"      ",@"        ",@"          ",@"           ",@"              ",@"                ",@"                  ",nil];
        arr_Font = [[NSMutableArray alloc]initWithObjects:@"24.0f",@"22.0f",@"20.0f",@"18.0f",@"18.0f",@"18.0f",@"13.0f",@"12.0f",@"11.0f",@"10.0f",nil];
        arr_Color = [[NSMutableArray alloc]init];
        arr_Color = [[NSMutableArray alloc]initWithObjects:@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",@"whiteColor",nil];
        arr_Header = [[NSMutableArray alloc]initWithObjects:@"  Category",@"    Product",nil];
        arr_SizeType = [[NSMutableArray alloc] initWithObjects:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Large"],[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Medium"],[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Small"], nil];
        lbl_CatogryStructure.text = [arr_CacheCategoryName componentsJoinedByString:@" -> "];
        lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Category"];
        [tbl_Category reloadData];
        
        [clv_CategoryList reloadData];
    }else{
        search_bar.text = @"";
    }
    if ([PageDefination  isEqual: @"QuickOrder"]) {
        [search_bar becomeFirstResponder];
    }
    
    if ([userDefault boolForKey:@"Is_Client"] == false) {
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
        self.navigationItem.rightBarButtonItems = @[barButton,bar];
    }
    
    if ([userDefault boolForKey:@"Is_Client"] == true){
        arrProductsInCart = [database getProductlistInCurrentOrder];
    }else{
        arrProductsInCart = nil;
    }
    [tbl_Category reloadData];
    [clv_CategoryList reloadData];
    [clv_ProductList reloadData];
    [self LanguageSetup];
}
-(void)LanguageSetup{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    lbl_ProductMenu.text = [NSString stringWithFormat:@"     %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"PRODUCTS MENU"]];
}
-(void)Clicked_Cart{
    OMCartVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMCartVC"];
    [[self navigationController] pushViewController:vc animated:YES];
}
#pragma mark - UIbar Butoon Method
-(void)action_Back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Search Bar Method
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    arr_Product =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetailSearch:search_bar.text] mutableCopy]];
    [clv_ProductList reloadData];
    clv_ProductList.hidden = NO;
    [search_bar resignFirstResponder];
}
#pragma mark - UITableViewDelegate & DataSource Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr_SideMenuCategory.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (custom == nil){
        custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (arr_SideMenuCategory.count > 0) {
        custom.lbl_CategoryTitle.text =[NSString stringWithFormat:@"%@%@",[arr_Space objectAtIndex:[arr_SideMenuCategory[indexPath.row][@"level"]integerValue]],arr_SideMenuCategory[indexPath.row][@"name"]];
        custom.lbl_CategoryTitle.font = [UIFont systemFontOfSize:[[arr_Font objectAtIndex:[arr_SideMenuCategory[indexPath.row][@"level"]integerValue]] floatValue]];
        NSString *strColor = [arr_Color objectAtIndex:[arr_SideMenuCategory[indexPath.row][@"level"]integerValue]];
        SEL selector = NSSelectorFromString(strColor);
        UIColor *color = [UIColor blackColor];
        if ([UIColor respondsToSelector:selector]) {
            color = [UIColor performSelector:selector];
        }
        custom.lbl_CategoryTitle.textColor = color;
    }
    return custom;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger indexValue = indexPath.row;
    NSString *cat_IDTemp = @"-1";
    NSString *temp_Level = @"-1";
    BOOL CatCheck = false;
    parent_Id = arr_SideMenuCategory[indexPath.row][@"entity_id"];
    level = [NSString stringWithFormat:@"%ld",[arr_SideMenuCategory[indexValue][@"level"] integerValue]+1];
    NSMutableArray *arr =  [[database GetCategory:level :parent_Id] mutableCopy];
    if (arr.count == 0) {
        arr_CacheCategoryID = [[NSMutableArray alloc] init];
        arr_CacheCategoryName = [[NSMutableArray alloc] init];
        arr_Product =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
        [clv_ProductList reloadData];
        clv_ProductList.hidden = NO;
        clv_CategoryList.hidden = YES;
        NSString *temp_id = parent_Id;
        for (int maxlevel = [level intValue]; maxlevel > 2; maxlevel --) {
            if (maxlevel == [level intValue]) {
                [arr_CacheCategoryID insertObject:parent_Id atIndex:0];
                [arr_CacheCategoryName insertObject:arr_SideMenuCategory[indexPath.row][@"name"] atIndex:0];
            }else{
                temp_id = [dbManager GetSuperLevel:temp_id];
                [arr_CacheCategoryID insertObject:temp_id atIndex:0];
                [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
            }
        }
    }else{
        NSString *temp_id;
        NSInteger indexValue = indexPath.row;
        BOOL flag_Cache = false;
        BOOL SubCheck = false;
        BOOL ProductCheck = false;
        arr_CacheCategoryName = [[NSMutableArray alloc] init];
        arr_CacheCategoryID = [[NSMutableArray alloc] init];
        NSMutableArray *arr_Temp = [[database GetCategory:[NSString stringWithFormat:@"%ld",[arr_SideMenuCategory[indexPath.row][@"level"]integerValue]+1] :arr_SideMenuCategory[indexPath.row][@"entity_id"]] mutableCopy];
        
        for (int i = 0 ; i < arr_Temp.count; i++) {
            if ([arr_SideMenuCategory containsObject:[arr_Temp objectAtIndex:i]]){
                flag_Cache = false;
                if ([arr_SideMenuCategory[indexPath.row][@"level"]  isEqual: @"2"]) {
                    if (temp_ID_Cat == arr_SideMenuCategory[indexPath.row][@"entity_id"]) {
                        [arr_SideMenuCategory removeObject:[arr_Temp objectAtIndex:i]];
                        CatCheck = false;
                        parent_Id = @"0";
                        level = @"2";
                    }else{
                        CatCheck = true;
                        parent_Id = arr_SideMenuCategory[indexPath.row][@"entity_id"];
                        level = @"3";
                        SubCheck = true;
                    }
                    arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
                    arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
                }
                else{
                    if (temp_ID_Cat == arr_SideMenuCategory[indexPath.row][@"entity_id"]) {
                        [arr_SideMenuCategory removeObject:[arr_Temp objectAtIndex:i]];
                        CatCheck = false;
                        ProductCheck = true;
                        temp_id =  parent_Id;
                        cat_IDTemp = [dbManager GetSuperLevel:parent_Id];
                        temp_Level = [NSString stringWithFormat:@"%ld",[level integerValue]-1];
                        arr_Category = [[database GetCategory:temp_Level :cat_IDTemp] mutableCopy];
                        arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:cat_IDTemp] mutableCopy]];
                    }else{
                        CatCheck = true;
                        SubCheck = true;
                        arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
                        arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
                    }
                }
            }
            else{
                flag_Cache = true;
                indexValue ++;
                temp_id =  parent_Id;
                [arr_SideMenuCategory insertObject:[arr_Temp objectAtIndex:i] atIndex:indexValue];
                arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
                arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
            }
        }
        
        if (CatCheck == true) {
            if ([level  isEqual: @"3"]) {
                [arr_CacheCategoryID insertObject:parent_Id atIndex:0];
                [arr_CacheCategoryName insertObject:arr_SideMenuCategory[indexPath.row][@"name"] atIndex:0];
            }else{
                temp_id =  parent_Id;
                for (int maxlevel = [level integerValue]; maxlevel > 2; maxlevel --) {
                    if (maxlevel == [level integerValue]) {
                        [arr_CacheCategoryID insertObject:parent_Id atIndex:0];
                        [arr_CacheCategoryName insertObject:arr_SideMenuCategory[indexPath.row][@"name"] atIndex:0];
                        
                    }else{
                        
                        temp_id = [dbManager GetSuperLevel:temp_id];
                        [arr_CacheCategoryID insertObject:temp_id atIndex:0];
                        [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
                    }
                }
            }
            
        }else{
            
        }
        if (flag_Cache == false) {
            for (int n = indexPath.row; n < [arr_SideMenuCategory count]; n++) {
                if (indexPath.row == arr_SideMenuCategory.count - 1) {
                }else{
                    if (SubCheck == false) {
                        if ([arr_SideMenuCategory[indexPath.row][@"level"]integerValue] < [arr_SideMenuCategory[indexPath.row+1][@"level"]integerValue]) {
                            [arr_SideMenuCategory removeObjectAtIndex:indexPath.row+1];
                            n--;
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        [tbl_Category reloadData];
        [clv_CategoryList reloadData];
        clv_ProductList.hidden = YES;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        lbl_Header.text =[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Category"];
        clv_CategoryList.hidden = NO;
        if (flag_Cache == true) {
            for (int maxlevel = [level integerValue]; maxlevel > 2; maxlevel --) {
                if (maxlevel == [level integerValue]) {
                    [arr_CacheCategoryID insertObject:parent_Id atIndex:0];
                    [arr_CacheCategoryName insertObject:arr_SideMenuCategory[indexPath.row][@"name"] atIndex:0];
                    
                }else{
                    temp_id = [dbManager GetSuperLevel:temp_id];
                    [arr_CacheCategoryID insertObject:temp_id atIndex:0];
                    [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
                }
            }
        }
        if (ProductCheck == true) {
            if ([cat_IDTemp  isEqual: @"-1"] ) {
                for (int maxlevel = [level integerValue]; maxlevel > 2; maxlevel --) {
                    if (maxlevel == [level integerValue]) {
                        [arr_CacheCategoryID insertObject:parent_Id atIndex:0];
                        [arr_CacheCategoryName insertObject:arr_SideMenuCategory[indexPath.row][@"name"] atIndex:0];
                        
                    }else{
                        temp_id = [dbManager GetSuperLevel:temp_id];
                        [arr_CacheCategoryID insertObject:temp_id atIndex:0];
                        [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
                    }
                }
            }else{
                temp_id = cat_IDTemp;
                for (int maxlevel = [temp_Level integerValue]; maxlevel > 2; maxlevel --) {
                    if (maxlevel == [temp_Level integerValue]) {
                        [arr_CacheCategoryID insertObject:cat_IDTemp atIndex:0];
                        [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
                        
                    }else{
                        temp_id = [dbManager GetSuperLevel:temp_id];
                        [arr_CacheCategoryID insertObject:temp_id atIndex:0];
                        [arr_CacheCategoryName insertObject:[dbManager GetSuperLevelName:temp_id] atIndex:0];
                    }
                }
            }
        }
    }
    temp_ID_Cat = arr_SideMenuCategory[indexPath.row][@"entity_id"];
    lbl_CatogryStructure.text = [arr_CacheCategoryName componentsJoinedByString:@" -> "];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - UICollectionViewDelegate & DataSource Method
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *large = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Large"];
    NSString *Small = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Small"];
    
    if ([str_SizeTag  isEqual:large]) {
        return CGSizeMake(clv_ProductList.frame.size.width,clv_ProductList.frame.size.height);
    }else if ([str_SizeTag  isEqual: Small]){
        return CGSizeMake(150,200);
    }else{
        return CGSizeMake(300,400);
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (collectionView == clv_CategoryList) {
        if(arr_SubProduct.count > 0){
            return 2;
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (clv_ProductList.hidden == NO) {
        lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Product"];
    }else{
        lbl_Header.text =[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Category"];
    }
    if (collectionView == clv_CategoryList) {
        if (arr_Category.count > 0) {
            lbl_Header.hidden = false;
        }else{
            lbl_Header.hidden = true;
        }
        if (section == 0) {
            return  arr_Category.count;
        }else{
            return arr_SubProduct.count;
        }
        return  arr_Category.count;
    }else{
        if (arr_Product.count > 0) {
            lbl_Header.hidden = false;
        }else{
            lbl_Header.hidden = true;
        }
        return  arr_Product.count;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        if (arr_Header.count > 0) {
            NSString *title = [[NSString alloc]initWithFormat:@"%@",[arr_Header objectAtIndex:indexPath.section]];
            headerView.title.text = title;
        }
        reusableview = headerView;
    }
    return reusableview;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == clv_CategoryList) {
        if (indexPath.section == 0) {
            CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            
            cell.lbl_CategoryName.hidden = NO;
            cell.img_Catgory.hidden = NO;
            cell.lbl_ProductName.hidden = YES;
            cell.lbl_ShortDescription.hidden = YES;
            cell.lbl_Sku.hidden = YES;
            cell.img_Product.hidden = YES;
            cell.view_ProductDescription.hidden = YES;
            cell.lbl_CategoryName.text = arr_Category[indexPath.row][@"name"];
            if ([arr_Category[indexPath.row][@"thumbnail"]  isEqual: @"<null>"] || [arr_Category[indexPath.row][@"thumbnail"] isEqual:@"(null)"] ) {
                cell.img_Catgory.image = [UIImage   imageNamed:@"NotAvalible"];
            }else{
                cell.img_Catgory.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:arr_Category[indexPath.row][@"thumbnail"]]]];
            }
            cell.imgTick.hidden = true;
            cell.lblQuantity.hidden = true;
            return cell;
            
        }else{
            CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            cell.lbl_CategoryName.hidden = YES;
            cell.img_Catgory.hidden = YES;
            cell.lbl_ProductName.hidden = NO;
            cell.lbl_ShortDescription.hidden = NO;
            cell.lbl_Sku.hidden = NO;
            cell.img_Product.hidden = NO;
            cell.view_ProductDescription.hidden = NO;
            cell.lbl_ProductName.text = [arr_SubProduct[indexPath.row]objectForKey:@"name"];
            cell.lbl_Sku.text = [NSString stringWithFormat:@"%@",[arr_SubProduct[indexPath.row]objectForKey:@"sku"]];
            cell.lbl_ShortDescription.text = [arr_SubProduct[indexPath.row]objectForKey:@"short_description"];
            if ([[arr_SubProduct[indexPath.row]objectForKey:@"small_image"]  isEqual: @""]) {
                cell.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
            }else{
                if ([arr_SubProduct[indexPath.row]objectForKey:@"small_image"]){
                    cell.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:[[arr_SubProduct[indexPath.row]objectForKey:@"small_image"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]]]];
                }else{
                    cell.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
                }
            }
            
            cell.lblQuantity.hidden = true;
            cell.imgTick.hidden = true;
            int qty = 0;
            for (NSDictionary *dict in arrProductsInCart) {
                if ([dict[@"Parent_ID"] intValue] == [arr_SubProduct[indexPath.row][@"entity_id"] intValue]){
                    cell.lblQuantity.hidden = false;
                    cell.imgTick.hidden = false;
                    qty += [dict[@"Quantity"] intValue];
                }
            }
            if (qty > 0){
                cell.lblQuantity.text = [NSString stringWithFormat:@"%d",qty];
            }
            return cell;
        }
    }else{
        CustomCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        cell.lbl_ProductName.text = [arr_Product[indexPath.row]objectForKey:@"name"];
        cell.lbl_Sku.text = [NSString stringWithFormat:@"%@",[arr_Product[indexPath.row]objectForKey:@"sku"]];
        cell.lbl_ShortDescription.text = [arr_Product[indexPath.row]objectForKey:@"short_description"];
        if ([[arr_Product[indexPath.row]objectForKey:@"small_image"]  isEqual: @""]) {
            cell.img_Product.image = [UIImage imageNamed:@"NotAvalible"];
        }else{
            cell.img_Product.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:[Image_Path stringByAppendingPathComponent:[[arr_Product[indexPath.row]objectForKey:@"small_image"]stringByReplacingOccurrencesOfString:@"/" withString:@"!"]]]];
        }
        cell.lblQuantity.hidden = true;
        cell.imgTick.hidden = true;
        
        int qty = 0;
        for (NSDictionary *dict in arrProductsInCart) {
            if ([dict[@"Parent_ID"] intValue] == [arr_Product[indexPath.row][@"entity_id"] intValue]){
                cell.lblQuantity.hidden = false;
                cell.imgTick.hidden = false;
                qty += [dict[@"Quantity"] intValue];
            }
        }
        if (qty > 0){
            cell.lblQuantity.text = [NSString stringWithFormat:@"%d",qty];
        }
        return cell;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (clv_ProductList.hidden == NO) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Product"];
        
    }else{
        for (UICollectionViewCell *cell in [clv_CategoryList visibleCells]) {
            NSIndexPath *indexPath = [clv_CategoryList indexPathForCell:cell];
            if (indexPath.section == 0) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                
                lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Category"];
                
            }else{
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                
                lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Product"];
                
            }
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == clv_CategoryList) {
        if (indexPath.section == 0) {
            parent_Id = arr_Category[indexPath.row][@"entity_id"];
            level = [NSString stringWithFormat:@"%ld",[level integerValue]+1];
            [arr_CacheCategoryID addObject:parent_Id];
            [arr_CacheCategoryName addObject:arr_Category[indexPath.row][@"name"]];
            NSMutableArray *arr =  [[database GetCategory:level :parent_Id] mutableCopy];
            if (arr.count == 0) {
                arr_Product =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
                [clv_ProductList reloadData];
                clv_ProductList.hidden = NO;
                clv_CategoryList.hidden = YES;
            }else{
                NSInteger indexValue = indexPath.row;
                
                arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
                arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
                NSMutableArray *arr_Temp = [[database GetCategory:[NSString stringWithFormat:@"%@",level] :parent_Id] mutableCopy];
                for (int i = 0 ; i < arr_Temp.count; i++) {
                    indexValue ++;
                    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"%K LIKE[c] %@", @"entity_id",parent_Id];
                    NSArray *theFilteredArray = [arr_SideMenuCategory filteredArrayUsingPredicate:aPredicate];
                    NSUInteger index = [arr_SideMenuCategory indexOfObject:theFilteredArray[0]];
                    
                    [arr_SideMenuCategory insertObject:[arr_Temp objectAtIndex:i] atIndex:index +1];
                }
                [tbl_Category reloadData];
                [clv_CategoryList reloadData];
            }
            lbl_CatogryStructure.text = [arr_CacheCategoryName componentsJoinedByString:@" -> "];
            
        }else{
            OMProductDetail *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMProductDetail"];
            vc.ProductId = [arr_SubProduct[indexPath.row]objectForKey:@"entity_id"];
            [[self navigationController] pushViewController:vc animated:YES];
        }
        
    }else{
        OMProductDetail *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OMProductDetail"];
        vc.ProductId = [arr_Product[indexPath.row]objectForKey:@"entity_id"];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}
#pragma mark - IBAction Method
- (IBAction)btn_ClickedBack:(id)sender {
    if ([level  isEqual: @"2"]) {
        lbl_CatogryStructure.text = @"";
    }else{
        level = [NSString stringWithFormat:@"%ld",[level integerValue] - 1];
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"%K LIKE[c] %@", @"name",[arr_CacheCategoryName lastObject]];
        NSArray *theFilteredArray = [arr_SideMenuCategory filteredArrayUsingPredicate:aPredicate];
        
        if ([theFilteredArray count]) {
            NSUInteger index = [arr_SideMenuCategory indexOfObject:theFilteredArray[0]];
            for (int i = index; i <arr_SideMenuCategory.count; i) {
                if (index == arr_SideMenuCategory.count - 1) {
                    break;
                }
                if ([arr_SideMenuCategory[index][@"level"]integerValue] < [arr_SideMenuCategory[index+1][@"level"]integerValue]) {
                    [arr_SideMenuCategory removeObjectAtIndex:index+1];
                }else{
                    break;
                }
            }
        }
        [tbl_Category reloadData];
        
        [arr_CacheCategoryID removeLastObject];
        [arr_CacheCategoryName removeLastObject];
        parent_Id = [arr_CacheCategoryID lastObject];
        clv_CategoryList.hidden = NO;
        clv_ProductList.hidden = YES;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        lbl_Header.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Category"];
        arr_Category = [[database GetCategory:level :parent_Id] mutableCopy];
        arr_SubProduct =  [obj_ArrayyToDic ProductShortDetail:[[dbManager GetProductShortDetail:parent_Id] mutableCopy]];
        [clv_CategoryList reloadData];
        lbl_CatogryStructure.text = [arr_CacheCategoryName componentsJoinedByString:@" -> "];
    }
}
- (IBAction)btn_ClickedSizeChange:(id)sender {
    [Dropobj fadeOut];
    [self showPopUpWithTitle:@"Select Size Type" withOption:arr_SizeType xy:CGPointMake(self.view.frame.size.width - 210, 58) size:CGSizeMake(200, 200) isMultiple:YES];
}
#pragma mark - Dropdown list method
-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:NO];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (anIndex == 0) {
        str_SizeTag = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Large"];
        [userDefault setObject:@"Large" forKey:@"Catalogue_ViewSize"];
        
    }else if (anIndex == 1) {
        str_SizeTag = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Medium"];
        [userDefault setObject:@"Medium" forKey:@"Catalogue_ViewSize"];
        
    }else  {
        str_SizeTag = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Small"];
        [userDefault setObject:@"Small" forKey:@"Catalogue_ViewSize"];
        
    }
    [btn_ObjSize setTitle:[arr_SizeType objectAtIndex:anIndex] forState:UIControlStateNormal];
    if ([str_SizeTag  isEqual: [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Large"]]) {
        [layout_Category setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout_Product setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }else{
        [layout_Category setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout_Product setScrollDirection:UICollectionViewScrollDirectionVertical];
    }
    [clv_CategoryList reloadData];
    [clv_ProductList reloadData];
}
@end