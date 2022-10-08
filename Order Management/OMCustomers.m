//
//  OMCustomers.m
//  Order Management
//
//  Created by Yoshemite on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMCustomers.h"
#import "DBManager.h"
#import "Customers.h"
#import "CustomTVC.h"
#import "OMOrderHistoryVC.h"
#import "ArrayToDicConvert.h"

@interface OMCustomers ()
{
    DBManager *dbManager;
    NSMutableArray *arr_AllRecord,*arr_Sum;
    BOOL isfirstTime;
    ArrayToDicConvert *obj_ArrayyToDic;
    NSIndexPath *indexP;
    
}
@end

@implementation OMCustomers

@synthesize TBCustomerList,lblCompnyName,lblAddress,lblContact,lblEmail,lblName,lblNote,lblReferences,lblUserName,lbltitle,TBAddressList,txtVdescription,OderListView,btnBack,lblCompnyAddress,TBOrderList;

@synthesize Vtitle,lblTitle,lblTelephoneNo,lblCompny,lblVatCode,customerSearchB,tblSearchCustomerList;

- (void)viewDidLoad {
    [super viewDidLoad];
    obj_ArrayyToDic = [[ArrayToDicConvert alloc] init];
    ObjAppDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    fontcolor = [UIColor colorWithRed:25/255.0 green:168/255.0 blue:184/255.0 alpha:1];
    lblCompnyName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    lblCompnyName.textColor = fontcolor;
    lblAddress.textColor = fontcolor;
    lblAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    lblContact.textColor = fontcolor;
    lblContact.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    lblReferences.textColor = fontcolor;
    lblReferences.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    lblNote.textColor = [UIColor colorWithRed:155/255.0 green:210/255.0 blue:217/255.0 alpha:1];
    lblNote.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    OderListView.backgroundColor = [UIColor colorWithRed:25/255.0 green:168/255.0 blue:184/255.0 alpha:1];
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    btnBack.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    lbltitle.textColor = [UIColor whiteColor];
    lbltitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    
    alphabetsArray = [[NSMutableArray alloc] init];
    [alphabetsArray addObject:@"A"];
    [alphabetsArray addObject:@"B"];
    [alphabetsArray addObject:@"C"];
    [alphabetsArray addObject:@"D"];
    [alphabetsArray addObject:@"E"];
    [alphabetsArray addObject:@"F"];
    [alphabetsArray addObject:@"G"];
    [alphabetsArray addObject:@"H"];
    [alphabetsArray addObject:@"I"];
    [alphabetsArray addObject:@"J"];
    [alphabetsArray addObject:@"K"];
    [alphabetsArray addObject:@"L"];
    [alphabetsArray addObject:@"M"];
    [alphabetsArray addObject:@"N"];
    [alphabetsArray addObject:@"O"];
    [alphabetsArray addObject:@"P"];
    [alphabetsArray addObject:@"Q"];
    [alphabetsArray addObject:@"R"];
    [alphabetsArray addObject:@"S"];
    [alphabetsArray addObject:@"T"];
    [alphabetsArray addObject:@"U"];
    [alphabetsArray addObject:@"V"];
    [alphabetsArray addObject:@"W"];
    [alphabetsArray addObject:@"Y"];
    [alphabetsArray addObject:@"X"];
    [alphabetsArray addObject:@"Z"];
    
    index = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    [dbManager DeleteNull];
    self.navigationController.navigationBarHidden = NO;
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    
    CustomerList = [[NSMutableArray alloc]init];
    CustomerList = [[self CustomerDetailList] mutableCopy];
    Customers *objCustomer = CustomerList[index];
    arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"All": objCustomer.strCustomerID] mutableCopy];
    [TBOrderList reloadData];
    lblEmail.text =objCustomer.strCustContact;
    lblUserName.text =[NSString stringWithFormat:@"%@ %@",objCustomer.strCustomerName,objCustomer.strCustomerLastName];
    lblUserName.font = [UIFont fontWithName:@"Helvetica" size:14];
    NSString *strvatcode = objCustomer.strVatTax;
    strvatcode = [strvatcode stringByReplacingOccurrencesOfString:@"(null)" withString:@"-"];
    
    //    if (strvatcode == (id)[NSNull null] || strvatcode.length == 0)   strvatcode=@"";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    lblVatCode.text = [NSString stringWithFormat:@"%@ : %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"VATcode"],strvatcode];
    lblVatCode.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    lblVatCode.textColor = fontcolor;
    
    CustAddressList = [[NSMutableArray alloc]init];
    NSNumber *Num = [NSNumber numberWithInteger:index];
    CustAddressList = [[self CurrectCompnyAddress:Num]mutableCopy];
    [TBAddressList reloadData];
    
    dicoAlphabet = [NSMutableDictionary dictionary];
    arrcustomerName = [[NSMutableArray alloc]init];
    for (int i = 0; i< arrCustomers.count; i++){
        Customers *objCustomer = CustomerList[i];
        [arrcustomerName addObject:[NSString stringWithFormat:@"%@ %@",objCustomer.strCustomerName,objCustomer.strCustomerLastName]];
    }
    
    for (NSString *value in arrcustomerName) {
        NSString *capitalizedString = [value capitalizedString];
        NSString *firstLetter = [capitalizedString substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray *arrayForLetter = [dicoAlphabet objectForKey:firstLetter];
        if (arrayForLetter == nil) {
            arrayForLetter = [NSMutableArray array];
            [dicoAlphabet setObject:arrayForLetter forKey:firstLetter];
        }
        [arrayForLetter addObject:value];
    }
    
    Customers *objCustomerAddress;
    if (CustAddressList.count > 0) {
        objCustomerAddress = CustAddressList[0];
    }
    //Anil changes
    NSString *strTelephoneNo = [NSString stringWithFormat:@"%@ , %@",objCustomerAddress.strTelephone,objCustomerAddress.strFaxNo];
    strTelephoneNo = [strTelephoneNo stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    lblTelephoneNo.text = strTelephoneNo;
    lblTelephoneNo.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    lblTelephoneNo.textColor = fontcolor;
    
    //Anil changes
    NSString *countryName = [[self CountryName:objCustomerAddress.strCountry] mutableCopy];
    NSString *strCompnyAddress = [NSString stringWithFormat:@"%@, %@ , %@, %@, %@, %@",objCustomerAddress.strCompnyName,objCustomerAddress.strStreet,objCustomerAddress.strcity,countryName,objCustomerAddress.strPostcode,objCustomerAddress.strTelephone];
    strCompnyAddress = [strCompnyAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    lblCompnyAddress.text = strCompnyAddress;
    lblCompnyAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    lblCompnyAddress.textColor = fontcolor;
    animalSectionTitles = [[dicoAlphabet allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    TBOrderList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //  NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:index inSection:0];
    [self tableView:TBCustomerList didSelectRowAtIndexPath:indexP];
    [TBCustomerList selectRowAtIndexPath:indexP animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self LanguageSetup];
    [TBCustomerList reloadData];

    
}
-(void)LanguageSetup{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    lbl_Edit.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Edit"];
    lbl_New.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"New"];
    lbl_Contact.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Contact"];
    lbl_Address.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Address"];
    lblCompnyName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Company Name"];
    lbltitle.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"LAST ORDERS"];
    lblTitle.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"CLIENTS"];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 0)
        return animalSectionTitles.count;
    else return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 0)
        return [animalSectionTitles objectAtIndex:section];
    else return 0;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UIColor *color = fontcolor;
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:color];
    
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView.tag == 0)
        return alphabetsArray;
    //    else if (tableView.tag == 1)
    //        return arrSearchCustomer
    else return 0;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView.tag == 0)
    {
        for (int i = 0; i< [animalSectionTitles count]; i++) {
            NSString *string = [[animalSectionTitles objectAtIndex:i] substringToIndex:1];
            if ([string isEqualToString:title]) {
                //      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                [TBCustomerList reloadData];
                [TBCustomerList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                break;
            }
        }
        return -1;
    }
    else return 0;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0){
        NSString *sectionTitle = [animalSectionTitles objectAtIndex:section];
        NSArray *sectionAnimals = [dicoAlphabet objectForKey:sectionTitle];
        return [sectionAnimals count];
    }else if (tableView.tag == 1){
        return arrSearchCustomer.count;
    }else if (tableView.tag == 2){
        return [CustAddressList count];
    }else if (tableView == TBOrderList){
        return [arr_AllRecord count];
    }else{
        return 0;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifire = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifire];
    }
    if (tableView.tag == 0) {
        NSString *sectionTitle = [animalSectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionAnimals = [dicoAlphabet objectForKey:sectionTitle];
        NSString *animal = [sectionAnimals objectAtIndex:indexPath.row];
        
        cell.textLabel.text = animal;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        cell.textLabel.textColor = fontcolor;
    }
    else if (tableView.tag == 1)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [[arrSearchCustomer objectAtIndex:indexPath.row]valueForKey:@"firstname"], [[arrSearchCustomer objectAtIndex:indexPath.row]valueForKey:@"lastname" ] ];
    }
    else if (tableView.tag == 2)
    {
        Customers *objCustomer = CustAddressList[indexPath.row];
        
        NSString *countryName = [[self CountryName:objCustomer.strCountry] mutableCopy];
        NSString *fulladdress=[NSString stringWithFormat:@"%ld, %@, %@, %@, %@ , %@, %@, %@, %@",[indexPath row]+1,objCustomer.strCustAddressName,objCustomer.strCustAddressLastName,objCustomer.strCompnyName,objCustomer.strStreet,objCustomer.strcity,objCustomer.strPostcode,countryName,objCustomer.strTelephone];
        fulladdress = [fulladdress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        cell.textLabel.text = fulladdress;
        cell.textLabel.numberOfLines = 2;
        if (indexPath.row == 0) {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        }
        else{
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        }
        
        [TBAddressList setSeparatorColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }else if (tableView == TBOrderList)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        CustomTVC *custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:CellIdentifire];
        if (custom == nil){
            custom = (CustomTVC *)[tableView dequeueReusableCellWithIdentifier:CellIdentifire];
        }
        if (arr_AllRecord.count > 0) {
            
            custom.lbl_OrderID.text = [NSString  stringWithFormat:@"Id : %@",[arr_AllRecord[indexPath.row]objectForKey:@"Order_Id"]];
            
            custom.lbl_OrderDate.text = [NSString stringWithFormat:@"%@ : %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order date"],[arr_AllRecord[indexPath.row]objectForKey:@"Order_Date"]];
            
            if (![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Cart"] && ![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Saved"] && ![[arr_AllRecord[indexPath.row]objectForKey:@"Status"]  isEqual: @"Not Sync"] ) {
                [custom.btn_Status setSelected:true];
            }else{
                [custom.btn_Status setSelected:false];
                
            }
            [custom.btn_Status setTitle:[arr_AllRecord[indexPath.row]objectForKey:@"Status"] forState:UIControlStateNormal];
            
            custom.lbl_OrderTotal.text = [NSString stringWithFormat:@"%@ : %@ %.2f",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Order Total"],[userDefault objectForKey:@"currency_code"],[arr_Sum[indexPath.row] floatValue]];
            custom.btn_ViewOrder.tag = indexPath.row;
            [custom.btn_ViewOrder setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"View Order"] forState:UIControlStateNormal];
            
            [custom.btn_ViewOrder addTarget:self action:@selector(btnClicked_ViewOrder:)forControlEvents:UIControlEventTouchUpInside];
        }else{
        }
        return custom;
    }else{
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifire = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    //    if (cell == nil) {
    //        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    //    }
    if (tableView.tag == 0) {
        CustAddressList = [[NSMutableArray alloc]init];
        NSInteger ValueIndex = 0;
        for (int i = 0; i < indexPath.section ; i++) {
            NSString *str =[animalSectionTitles objectAtIndex:i];
            NSArray *sectionAnimals = [dicoAlphabet objectForKey:str];
            ValueIndex = ValueIndex + sectionAnimals.count;
        }
        ValueIndex = ValueIndex +indexPath.row;
        
        NSNumber *indexvalue = [NSNumber numberWithInt:ValueIndex];
        index = ValueIndex;
        indexP = indexPath;
        CustAddressList = [[self CurrectCompnyAddress:indexvalue]mutableCopy];
        [TBAddressList reloadData];
        Customers *objCustomer = CustomerList[ValueIndex];
        [self GetAllRecordData:objCustomer.strCustomerID];
        
        lblEmail.text = objCustomer.strCustContact;
        lblUserName.text =[NSString stringWithFormat:@"%@ %@",objCustomer.strCustomerName,objCustomer.strCustomerLastName];
        NSString *strvatcode = objCustomer.strVatTax;
        strvatcode = [strvatcode stringByReplacingOccurrencesOfString:@"(null)" withString:@"-"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        lblVatCode.text = [NSString stringWithFormat:@"%@ : %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"VATcode"],strvatcode];
        lblVatCode.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblVatCode.textColor = fontcolor;
        Customers *objCustomerAddress ;
        if (CustAddressList.count > 0) {
            objCustomerAddress = CustAddressList[0];
        }
        
        NSString *strTelephoneNo = [NSString stringWithFormat:@"%@ , %@",objCustomerAddress.strTelephone,objCustomerAddress.strFaxNo];
        strTelephoneNo = [strTelephoneNo stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        lblTelephoneNo.text = strTelephoneNo;
        lblTelephoneNo.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblTelephoneNo.textColor = fontcolor;
        
        NSString *countryName = [[self CountryName:objCustomerAddress.strCountry] mutableCopy];
        NSString *strCompnyAddress = [NSString stringWithFormat:@"%@, %@ , %@, %@, %@, %@",objCustomerAddress.strCompnyName,objCustomerAddress.strStreet,objCustomerAddress.strcity,objCustomerAddress.strPostcode,countryName,objCustomerAddress.strTelephone];
        strCompnyAddress = [strCompnyAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        lblCompnyAddress.text = strCompnyAddress;
        lblCompnyAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblCompnyAddress.textColor = fontcolor;
    }
    else if (tableView.tag == 1){
        NSInteger ValueIndex = 0;
        for (int i = 0; i< CustomerList.count; i++) {
            Customers *objCustomer = CustomerList[i];
            NSString *strEntity_id = objCustomer.entity_ID;
            NSString *select_Customer_entityID = [[arrSearchCustomer valueForKey:@"entity_id"] objectAtIndex:indexPath.row];
            if ([strEntity_id isEqualToString:select_Customer_entityID]) {
                ValueIndex = i;
            }
        }
        NSNumber *indexvalue = [NSNumber numberWithInt:ValueIndex];
        CustAddressList = [[self CurrectCompnyAddress:indexvalue]mutableCopy];
        [TBAddressList reloadData];
        
        Customers *objCustomer = CustomerList[ValueIndex];
        DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
        //        arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"All": objCustomer.strCustomerID] mutableCopy];
        [self GetAllRecordData:objCustomer.strCustomerID];
        
        lblEmail.text = objCustomer.strCustContact;
        lblUserName.text =[NSString stringWithFormat:@"%@ %@",objCustomer.strCustomerName,objCustomer.strCustomerLastName];
        NSString *strvatcode = objCustomer.strVatTax;
        strvatcode = [strvatcode stringByReplacingOccurrencesOfString:@"(null)" withString:@"-"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        lblVatCode.text = [NSString stringWithFormat:@"%@ : %@",[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"VATcode"],strvatcode];
        
        lblVatCode.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblVatCode.textColor = fontcolor;
        Customers *objCustomerAddress;
        if (CustAddressList.count > 0)  objCustomerAddress = CustAddressList[0];
        
        
        //Anil changes
        NSString *strTelephoneNo = [NSString stringWithFormat:@"%@ , %@",objCustomerAddress.strTelephone,objCustomerAddress.strFaxNo];
        strTelephoneNo = [strTelephoneNo stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        lblTelephoneNo.text = strTelephoneNo;
        lblTelephoneNo.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblTelephoneNo.textColor = fontcolor;
        
        //Anil changes
        NSString *countryName = [[self CountryName:objCustomerAddress.strCountry] mutableCopy];
        NSString *strCompnyAddress = [NSString stringWithFormat:@"%@, %@ , %@, %@, %@, %@",objCustomerAddress.strCompnyName,objCustomerAddress.strStreet,objCustomerAddress.strcity,objCustomerAddress.strPostcode,countryName,objCustomerAddress.strTelephone];
        strCompnyAddress = [strCompnyAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        lblCompnyAddress.text = strCompnyAddress;
        lblCompnyAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        lblCompnyAddress.textColor = fontcolor;
        tblSearchCustomerList.hidden = true;
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == TBOrderList) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }else{
        
    }
}
-(void)GetAllRecordData :(NSString *)cust_ID{
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    arr_AllRecord = [[NSMutableArray alloc] init];
    arr_AllRecord = [[objDatabaseManager GetAllRecordPlace:@"All": cust_ID] mutableCopy];
    NSMutableArray *arrSyncedGetRecord = [[objDatabaseManager GetAllRecordPlace:@"GetSyncedRecord":cust_ID] mutableCopy];
    arr_Sum = [[NSMutableArray alloc] init];
    
    if (arr_AllRecord.count > 0) {
        for (int j = 0; j < arr_AllRecord.count; j++) {
            NSString *OrderId = [arr_AllRecord[j] objectForKey:@"Order_Id"];
            if ([[dbManager GetCustomerGroup:[dbManager GetcustomerId:OrderId]]  isEqual: @"0"]) {
                [arr_Sum addObject:[arr_AllRecord[j] objectForKey:@"Price"]];
            }else{
                NSMutableArray *arr_Order  = [[NSMutableArray alloc]init];
                NSMutableArray *arr_ProductCount = [[NSMutableArray alloc]init];
                NSMutableArray *arr_Temp = [[dbManager GetCartFromOrder:[NSString stringWithFormat:@"%@",OrderId]] mutableCopy];
                for (int i = 0; i <arr_Temp.count; i++) {
                    [arr_ProductCount addObject:arr_Temp[i][1]];
                    NSDictionary *dic =  [obj_ArrayyToDic ProductLongDetail:[[dbManager GetProductLongDetail:arr_Temp[i][0]] mutableCopy]];
                    [arr_Order addObject:dic];
                }
                NSMutableArray *arr_GroupPrice = [[objDatabaseManager GetGroupPrice:[dbManager GetCustomerGroup:[dbManager GetcustomerId:OrderId]]] mutableCopy];
                [arr_Sum addObject:[NSString stringWithFormat:@"%f",[self sumOfProduct:arr_Order :arr_GroupPrice :OrderId :arr_ProductCount]]];
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
    [TBOrderList reloadData];
    
    
    
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
#pragma mark - Search Bar Method
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [customerSearchB resignFirstResponder];
    arrSearchCustomer = [[NSMutableArray alloc]init];
    
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    arrSearchCustomer = [[objDatabaseManager GetCustomerDetailBysearch:customerSearchB.text] mutableCopy];
    //  arrSearchCustomer = [[arrCustomers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(firstname  CONTAINS[c] %@)", customerSearchB.text]] mutableCopy];
    [tblSearchCustomerList superview];
    tblSearchCustomerList.hidden = false;
    [tblSearchCustomerList reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    if ([customerSearchB  isEqual: @""]) {
        arrSearchCustomer = [arrCustomers mutableCopy];
        [tblSearchCustomerList reloadData];
        tblSearchCustomerList.hidden = false;
        [customerSearchB resignFirstResponder];
    }
}

#pragma mark GetCustomes Detail - Function
-(NSArray *)CustomerDetailList
{
    arrCustomers = [[NSMutableArray alloc]init];
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    arrCustomers = [[objDatabaseManager getCustomerList:@""] mutableCopy];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"firstname" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *arr =[arrCustomers sortedArrayUsingDescriptors:@[sort]];
    arrCustomers = [arr mutableCopy];
    NSMutableArray *tempCustomers = [@[]mutableCopy];
    
    for (int i = 0; i < arrCustomers.count; i++) {
        NSDictionary *temp = arrCustomers[i];
        Customers *ObjCustomer = [[Customers alloc]initWithDictionary:temp];
        [tempCustomers addObject:ObjCustomer];
    }
    return  tempCustomers;
}

#pragma mark CountryName
-(NSString *)CountryName :(NSString *)code
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    _temp = [[objDatabaseManager GetColuntryName:code] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"name"] objectAtIndex:0];
    }
    return  str;
}

#pragma mark GetCustomerAddress - Function
-(NSArray *)CurrectCompnyAddress :(NSNumber *)_value
{
    int cellnumber = [_value intValue];
    Customers *objCustomer = CustomerList[cellnumber];
    NSString *strCustID = objCustomer.strCustomerID;
    ObjAppDelegate.CustomerID = strCustID;
    
    DatabaseManager *objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    arrCustAddress = [[objDatabaseManager getCustomerAddress:strCustID] mutableCopy];
    NSMutableArray *AddressList = [@[]mutableCopy];
    
    for (int i = 0; i < arrCustAddress.count; i++) {
        NSDictionary *temp = arrCustAddress[i];
        Customers *ObjCustomer = [[Customers alloc]initWithDictionary1:temp];
        [AddressList addObject:ObjCustomer];
    }
    return AddressList;
}
#pragma mark UIButton Action Event
- (IBAction)btnClicked_ViewOrder:(id)sender {
    NSInteger TagID= ((UIButton *)sender).tag;
    if (![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Cart"] && ![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Saved"] && ![[arr_AllRecord[TagID]objectForKey:@"Status"]  isEqual: @"Not Sync"] ){
        OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
        VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
        VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
        VC.Order_Status = @"Close";
        [[self navigationController] pushViewController:VC animated:YES];
    }else{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([userDefault boolForKey:@"Is_Client"] == true) {
            if ([dbManager CheckOrderStatus] == true) {
                UIAlertView *alert =  [[UIAlertView alloc]initWithTitle:@"" message:@"For view and open this order previous order is delete.Are you sure to continue?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                alert.tag = 10;
                [alert show];
            }else{
                OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
                [userDefault setObject:[arr_AllRecord[TagID] objectForKey:@"Order_Id"] forKey:@"Order_Id"];
                [userDefault setObject:[arr_AllRecord[TagID] objectForKey:@"Customer_Id"] forKey:@"Customer_Id"];
                VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
                VC.Order_Status = @"Open";
                VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
                [[self navigationController] pushViewController:VC animated:YES];
            }
        }else{
            [userDefault setBool:true forKey:@"Is_Client"];
            OMOrderHistoryVC *VC = [[self storyboard] instantiateViewControllerWithIdentifier:@"OMOrderHistoryVC"];
            [userDefault setObject:[arr_AllRecord[TagID] objectForKey:@"Order_Id"] forKey:@"Order_Id"];
            [userDefault setObject:[arr_AllRecord[TagID] objectForKey:@"Customer_Id"] forKey:@"Customer_Id"];
            VC.Order_ID = [arr_AllRecord[TagID] objectForKey:@"Order_Id"];
            VC.Order_Status = @"Open";
            VC.Customer_Name = [arr_AllRecord[TagID]objectForKey:@"firstname"];
            [[self navigationController] pushViewController:VC animated:YES];
        }
    }
}
- (IBAction)btnNew_Click:(id)sender {
    ObjAppDelegate.isEdit = NO;
    OMCustomerInfoVC *objCustomerInfo = [[self storyboard]instantiateViewControllerWithIdentifier:@"OMCustomerInfoVC"];
    [[self navigationController]pushViewController:objCustomerInfo animated:YES];
}
- (IBAction)btnEdit_Click:(id)sender {
    ObjAppDelegate.isEdit = YES;
    
    OMCustomerInfoVC *objCustomerInfo = [[self storyboard]instantiateViewControllerWithIdentifier:@"OMCustomerInfoVC"];
    [[self navigationController]pushViewController:objCustomerInfo animated:YES];
    
}
- (IBAction)btnBack_Click:(id)sender {
    [[self navigationController]popViewControllerAnimated:YES];
}
@end
