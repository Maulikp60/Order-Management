//
//  OMCustomerInfoVC.m
//  Order Management
//
//  Created by Yoshemite on 12/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMCustomerInfoVC.h"
#import "Address.h"
#import "Singleton.h"
#import "SalesAgent.h"
#import "MainViewController.h"
#import "oauthconsumer-master/OAToken.h"
#import "OAuthConsumer.h"

@interface OMCustomerInfoVC ()
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic,strong) OAConsumer* consumer;
@end

@implementation OMCustomerInfoVC

@synthesize txtCustBirthDate,txtCustEmail,txtCustFirstName,txtCustLastName,txtCustMiddleName,txtCustPrefix,txtCustSuffix,txtgroupID,txtPassword,txtsales_agent_id;

@synthesize txtCity,txtAddCompny,txtCountry,txtFax,txtGender,txtState,txtTelephone,txtVatNumber,txtZip,tblAddressList;

@synthesize mainScrollV,subView,txtVAddress,btnbillingAddress,btnSave,btnShppingAddress,btnBack,btnRefreshCustGroup,btnNewAddress,txtCustGroup,txtRegion,txtRePassword;
@synthesize txtAddFirstName,txtAddLastName,txtAddMiddleName,txtAddSuffix;

@synthesize btnClearAllTextfield,btnsalesagent;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadingView = [LoadingView loadingView];

    //Anil
    fontcolor = [UIColor colorWithRed:25/255.0 green:168/255.0 blue:184/255.0 alpha:1];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    strSelectedWS = [[NSString alloc]init];
    strSelectedWS = @"not Selected";
    ObjAppDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    // self.navigationController.navigationBarHidden = YES;
    DictPostAddress = [[NSMutableDictionary alloc]init];
    counter = 0;
    [txtVAddress.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [txtVAddress.layer setBorderWidth:1.0];
    //The rounded corner part, where you specify your view's corner radius:
    txtVAddress.layer.cornerRadius = 5;
    txtVAddress.clipsToBounds = YES;
    //GetSaleAgent List
    
    arrSalesAgent = [[NSMutableArray alloc]init];
    arrSalesAgent = [[self SalesAgent] mutableCopy];
    salesAgentList = [[NSMutableArray alloc]init];
    for (int i = 0; i<arrSalesAgent.count; i++) {
        SalesAgent *objsalesagent = arrSalesAgent[i];
        NSString *strname = [NSString stringWithFormat:@"%@",objsalesagent.strfirstname];
        [salesAgentList addObject:strname];
    }
    //CustomerGroup List
    custGroup = [[NSMutableArray alloc]init];
    custGroup = [[self CustGroup] mutableCopy];
    custGroupList = [[NSMutableArray alloc]init];
    for (int i = 0; i<custGroup.count; i++) {
        Customers *objCustgroup = custGroup[i];
        [custGroupList addObject:objCustgroup.strcustomer_group_code];
    }
    //Country List
    CountryArray = [[NSMutableArray alloc]init];
    CountryArray = [[self Country] mutableCopy];
    CountryList = [[NSMutableArray alloc]init];
    for (int i = 0; i<CountryArray.count; i++) {
        Customers *objCountry = CountryArray[i];
        [CountryList addObject:objCountry.strname];
    }
    
    isshappingAddress = YES;
    btnShppingAddress.backgroundColor = [UIColor greenColor];
    Shapping_status = @"1";
    isbillingAddress = YES;
    btnbillingAddress.backgroundColor = [UIColor greenColor];
    billing_status = @"1";
    
    btnRefreshCustGroup.layer.cornerRadius = 10;
    btnRefreshCustGroup.layer.borderWidth = 1;
    btnbillingAddress.layer.cornerRadius = 10;
    btnbillingAddress.clipsToBounds = YES;
    btnShppingAddress.layer.cornerRadius = 10;
    btnShppingAddress.clipsToBounds = YES;
    btnsalesagent.layer.cornerRadius = 10;
    btnsalesagent.layer.borderWidth = 1;
    //Changes
    arrAddress = [[NSMutableArray alloc]init];
    
    if (ObjAppDelegate.isEdit == YES) {
        NSString *customerID = ObjAppDelegate.CustomerID;
        arrCustomer = [[self Customer_Detail:customerID] mutableCopy];
        //Customer Detail
        Customers *objCustomer = arrCustomer[0];
        txtCustPrefix.text = objCustomer.strprefix;
        txtCustFirstName.text = objCustomer.strCustomerName;
        txtCustMiddleName.text = objCustomer.strmiddlename;
        txtCustLastName.text = objCustomer.strCustomerLastName;
        txtCustEmail.text = objCustomer.strCustContact;
        NSString *strdob = objCustomer.strdob;
        NSString *convertedDate;
        if (strdob.length == 0 || strdob == (id)[NSNull null]){}
        else{
            NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"yyyy-MM-dd"];
            NSArray *arr = [objCustomer.strdob componentsSeparatedByString:@" "];
            NSString *tempDate ;
            if (arr.count > 0)  tempDate = arr[0];
            else    tempDate = objCustomer.strdob;
            NSDate *date = [dateformate dateFromString:tempDate];
            dateformate = [[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"MMM dd, yyyy"];
            convertedDate = [dateformate stringFromDate:date];
        }
        txtCustBirthDate.text = convertedDate;
        txtCustSuffix.text = objCustomer.strsuffix;
        NSString *strvat = objCustomer.strVatTax;
        strvat = [strvat stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        // if (strvat == (id)[NSNull null] || strvat.length == 0) strvat =@"";
        txtVatNumber.text = strvat;
        if ([objCustomer.strgender isEqualToString:@"0"])   txtGender.text = @"Male";
        else if ([objCustomer.strgender isEqualToString:@"1"])  txtGender.text = @"Female";
        else{}
        txtPassword.text = objCustomer.Password;
        txtRePassword.text = objCustomer.Password;
        txtgroupID.text = objCustomer.group_id;
        txtRegion.text = objCustomer.strRegion;
        NSString *strsaleagent = @"";
        if (objCustomer.sales_agent_id.length != 0 || objCustomer.sales_agent_id != (id)[NSNull null] )
            strsaleagent = [dbManager GetSalesName:objCustomer.sales_agent_id];
        txtsales_agent_id.text = strsaleagent;
        str_New_CustomerID = objCustomer.strCustomerID;
        str_Customer_entity_id = objCustomer.strCustomerID;
        NSString *strgroupname = [[self CustGroupName:objCustomer.group_id] mutableCopy];
        txtCustGroup.text = strgroupname;
        arrAddress = [[self CustomerAddress:customerID] mutableCopy];
        Address *objAddress;
        if (arrAddress.count> 0)    objAddress = arrAddress[0];
        // Customers *objCustomerAddress = arrAddress[0];
        indexAddress = 0;
        txtAddCompny.text = objAddress.strcompany;
        txtCity.text = objAddress.strcity;
        NSString *countryName = [[self CountryName:objAddress.strcountry_id] mutableCopy];
        txtCountry.text = countryName;
        txtZip.text = objAddress.strpostcode;
        txtTelephone.text = objAddress.strtelephone;
        txtFax.text = objAddress.strfax;
        txtVAddress.text = objAddress.strstreet;
        [self RedioButtonStatus];
        strAddressID = objAddress.strentity_id;
        txtAddFirstName.text = objAddress.strfirstname;
        txtAddLastName.text = objAddress.strlastname;
        txtRegion.text = objAddress.strregion;

        arrAddressCount = [[NSMutableArray alloc] init];
        
        for(int x = 0; x < arrAddress.count; x++){
            Address *objAddress = arrAddress[x];
            NSString *countryName = [[self CountryName:objAddress.strcountry_id] mutableCopy];
            NSString *strstreet = [NSString stringWithFormat:@"%d. %@,%@,%@",(x+1) ,objAddress.strstreet,objAddress.strcity,countryName];
            
            strstreet = [strstreet stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            [arrAddressCount addObject:strstreet];
        }
        [tblAddressList reloadData];
    }else if (ObjAppDelegate.isEdit == NO){
        
        txtCountry.text = @"España";
        //set default sales agent
        NSMutableArray *_temp = [[NSMutableArray alloc]init];
        _temp = [[objDatabaseManager getselceAgent] mutableCopy];
        NSString *str=    @"";
        if (_temp.count > 0) {
            str = [[_temp valueForKey:@"firstname"] objectAtIndex:0];
        }
        txtsales_agent_id.text = [NSString stringWithFormat:@"%@",str];
        
        //set default customerGroup
        NSMutableArray *_temp1 = [[NSMutableArray alloc]init];
        _temp1 = [[objDatabaseManager getdefaultCustomerGroup] mutableCopy];
        NSString *str1=    @"";
        if (_temp1.count > 0) {
            str1 = [[_temp1 valueForKey:@"customer_group_code"] objectAtIndex:0];
        }
        txtCustGroup.text = [NSString stringWithFormat:@"%@",str1];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"CLIENTS";
    // self.navigationController.navigationBarHidden = YES;
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];
    [dbManager DeleteNull];
    [self LanguageSetup];
}
-(void)LanguageSetup{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    lbl_AccountInformation.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Account Information:"];
    lbl_CustomerGroup.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Customer Group *:"];
    lbl_Prefix.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Prefix:"];
    lbl_FirstName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"First Name *:"];
    lbl_MiddleName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Middle Name :"];
    lbl_LastName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Last Name *:"];
    lbl_Company.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Company :"];
    lbl_City.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"City *:"];
    lbl_Region.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Region:"];
    lbl_Country.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Country *:"];
    lbl_ZipCode.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Zip/Postal Code *:"];
    lbl_Telephone.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Telephone :"];
    lbl_Fax.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Fax :"];
    lbl_StreetAddress.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Street Address :"];
    lbl_TaxVatNumber.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Tax/VAT Number:"];
    lbl_CustomerEmail.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Customer Email *:"];
    lbl_Password.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Password *:"];
    lbl_Repassword.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Re-Password *:"];
    lbl_DefaultBillingAddress.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Defailt billing Address:"];
    lbl_DefaultShippingAddress.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Defailt Shipping Address:"];
    lbl_AddressFirstName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"First Name *:"];
    lbl_AddressSecondName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Middle Name :"];
    lbl_AddressLastName.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Last Name *:"];
    lbl_AddressSufix.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Suffix:"];
    lbl_Gender.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Gender:"];
    lbl_DateOfBirth.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Date Of Birth:"];
    lbl_PasswordSection.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Password Section :"];
    lbl_AddressSection.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Address Section :"];
    lbl_SalesAgent.text = [dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Sales Agent *:"];
    [btnRefreshCustGroup  setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Refresh"] forState:UIControlStateNormal];
    [btnClearAllTextfield  setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Clear"] forState:UIControlStateNormal];
    [btnSave  setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Save"] forState:UIControlStateNormal];
    [btnNewAddress  setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Add New Address"] forState:UIControlStateNormal];
    [btnsalesagent  setTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Refresh"] forState:UIControlStateNormal];
}
#pragma mark CountryName
-(NSString *)CountryName :(NSString *)code
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager GetColuntryName:code] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"name"] objectAtIndex:0];
    }
    return  str;
}
//A
#pragma mark salesagentID
-(NSString *)salesAgentID :(NSString *)Name
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager GetsalesAgentID:Name] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"user_id"] objectAtIndex:0];
    }
    return  str;
}
//A
#pragma mark CountryCode
-(NSString *)CountryCode :(NSString *)Name
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager GetColuntryCode:Name] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"code"] objectAtIndex:0];
    }
    return  str;
}
#pragma mark GetCustomerAddress - Function
-(NSArray *)CustomerAddress :(NSString *)custID
{
    arrCustAddress = [[objDatabaseManager getCustomerAddress:custID] mutableCopy];
    NSMutableArray *AddressList = [@[]mutableCopy];
    
    for (int i = 0; i < arrCustAddress.count; i++) {
        NSDictionary *temp = arrCustAddress[i];
        Address *Objaddress = [[Address alloc]initWithDictionary1:temp];
        // Customers *ObjCustomer = [[Customers alloc]initWithDictionary1:temp];
        [AddressList addObject:Objaddress];
    }
    return AddressList;
}
#pragma mark CoustomerDetail
-(NSArray *)Customer_Detail :(NSString *)custID
{
    NSMutableArray *arrCustomers = [[objDatabaseManager getCustomer:custID] mutableCopy];
    NSMutableArray *tempCustomers = [@[]mutableCopy];
    
    for (int i = 0; i < arrCustomers.count; i++) {
        NSDictionary *temp = arrCustomers[i];
        Customers *ObjCustomer = [[Customers alloc]initWithDictionary:temp];
        [tempCustomers addObject:ObjCustomer];
    }
    return  tempCustomers;
}
#pragma mark GetCountry - Function
-(NSArray *)Country
{
    arrCountry = [[NSMutableArray alloc]init];
    arrCountry = [[objDatabaseManager GetCountry] mutableCopy];
    NSMutableArray *CountryList1 = [@[]mutableCopy];
    for (int i = 0; i < arrCountry.count; i++) {
        NSDictionary *tempCountry = arrCountry[i];
        Customers *ObjCountry = [[Customers alloc]initWithDictionary2:tempCountry];
        [CountryList1 addObject:ObjCountry ];
    }
    return  CountryList1;
}
#pragma mark GetSalesAgent - Function
-(NSArray *)SalesAgent
{
    salesAgent = [[NSMutableArray alloc]init];
    salesAgent = [[objDatabaseManager GetsalesAgent] mutableCopy];
    NSMutableArray *salesagentList = [@[]mutableCopy];
    for (int i = 0; i < salesAgent.count; i++) {
        NSDictionary *tempsalesagent = salesAgent[i];
        SalesAgent *Objsalesagent = [[SalesAgent alloc]initWithDictionary:tempsalesagent];
        [salesagentList addObject:Objsalesagent];
    }
    return  salesagentList;
}

#pragma mark GetCustGroup - Function
-(NSArray *)CustGroup
{
    arrCustomer_Group = [[NSMutableArray alloc]init];
    arrCustomer_Group = [[objDatabaseManager GetCustGroup] mutableCopy];
    NSMutableArray *CustGroupList = [@[]mutableCopy];
    for (int i = 0; i < arrCustomer_Group.count; i++) {
        NSDictionary *tempCustgroup = arrCustomer_Group[i];
        Customers *ObjCust_Group = [[Customers alloc]initWithDictionaryGroup:tempCustgroup];
        [CustGroupList addObject:ObjCust_Group];
    }
    return  CustGroupList;
}
#pragma mark GetCustGroupID
-(NSString *)CustGroupID :(NSString *)Name
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager GetGroupID:Name] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"customer_group_id"] objectAtIndex:0];
    }
    return  str;
}
#pragma mark GetCustGroupName
-(NSString *)CustGroupName :(NSString *)ID
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager GetGroupName:ID] mutableCopy];
    NSString *str;
    if (_temp.count > 0) {
        str = [[_temp valueForKey:@"customer_group_code"] objectAtIndex:0];
    }
    return  str;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIActionSheet For Time and Date Selection
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    switch (pickerView.tag){
        case 113: txtCountry.text =[titles componentsJoinedByString:@" - "];
            [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
            break;
        case 111: txtCustGroup.text =[titles componentsJoinedByString:@" - "];
            [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
            break;
        case 115: txtGender.text =[titles componentsJoinedByString:@" - "];
            [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
            break;
        case 114: txtsales_agent_id.text =[titles componentsJoinedByString:@" - "];
            [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
            break;
        default:
            break;
    }
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    switch (pickerView.tag){
        case 112:{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            [formatter setDateFormat:@"MMM dd, yyyy"];
            
            txtCustBirthDate.text = [formatter stringFromDate:date];
            [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
            break;
        }
        case 7:{
            break;
        }
        case 115:{
            break;
        }
        default:
            break;
    }
}
#pragma mark UITextField delegate Methods
-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
}
-(void)UpdateTextField:(UIDatePicker *)sennder
{
    //  [self DateCheck:sennder.date];
}
- (void) tapped{
    [self.view endEditing:YES];
    [mainScrollV setContentOffset:CGPointMake(0,-64) animated:YES];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == txtCustBirthDate) {
        [self.view endEditing:YES];
        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
        IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
        [picker setTag:112];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
        return  false;
    }
    else if (textField == txtCountry){
        [self.view endEditing:YES];
        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
        //Anil
        if (CountryList.count> 0) {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Country Picker" delegate:self];
            [picker setTag:113];
            [picker setTitlesForComponenets:@[CountryList]];
            [picker show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is not any country in the list" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        
        return false;
    }
    else if (textField == txtGender){
        [self.view endEditing:YES];
        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
        IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Gender" delegate:self];
        [picker setTag:115];
        [picker setTitlesForComponenets:@[@[@"Male",@"Female"]]];
        [picker show];
        return false;
    }
    else if (textField == txtCustGroup){
        [self.view endEditing:YES];
        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
        //Anil
        if (custGroupList.count > 0) {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"CustomerGroups Picker" delegate:self];
            [picker setTag:111];
            [picker setTitlesForComponenets:@[custGroupList]];
            [picker show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is not any Customer Group in the list" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        return false;
    }
    else if (textField == txtsales_agent_id){
        [self.view endEditing:YES];
        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
        //Anil
        if (salesAgentList.count > 0) {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Sales Agent List Picker" delegate:self];
            [picker setTag:114];
            [picker setTitlesForComponenets:@[salesAgentList]];
            [picker show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is not any Sales Agent in the list" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        return false;
    }
    else{
        return  true;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [mainScrollV setContentOffset:CGPointMake(0,0) animated:YES];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
}
// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    [nextResponder becomeFirstResponder];

    if (textField.tag == 112 ||textField.tag == 113 || textField.tag == 115 || textField.tag == 111 || textField.tag ==114)
        [self.view endEditing:YES];
//    }
//    if (nextResponder) {
//        [mainScrollV setContentOffset:CGPointMake(0,textField.center.y-150) animated:YES];
//        // Found next responder, so set it.
//        [nextResponder becomeFirstResponder];
//    } else {
//        [mainScrollV setContentOffset:CGPointMake(0,-64) animated:YES];
//        return YES;
//    }
    //
    return NO;
}
#pragma mark Valitation
-(NSString *)validateField{
    __weak NSString *msg = @"";
    if([[txtCustFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Customer first name should not be empty.";
    }else if([[txtCustLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Customer last name should not be empty.";
    }else if( [[txtCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"City should not be empty";
//    }else if( [[txtAddFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
//        msg = @"Address first name should not be empty.";
//    }else if( [[txtAddLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        //msg = @"Address last name should not be empty.";
    }else if( [[txtCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"City should not be empty";
    }else if([[txtCountry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ) {
        msg = @"Country should not be empty.";
    }else if([[txtZip.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ) {
        msg = @"Zip should not be empty";
    }else if([[txtCustGroup.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ) {
        msg = @"Customer group should not be empty";
    }else if( [[txtCustEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        msg = @"Customer Email should not be empty.";
    }else if([[txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] && ObjAppDelegate.isEdit == NO) {
        msg = @"Password should not be empty";
    }else if([[txtRePassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] && ObjAppDelegate.isEdit == NO ) {
        msg = @"conform password should not be empty";
    }else if(![txtRePassword.text isEqualToString:txtPassword.text] && ObjAppDelegate.isEdit == NO) {
        msg = @"Both Password should not match be empty";
    }else if (![self isValidEmailAddress:txtCustEmail.text]){
        msg = @"Please enter valid email.";
        
    }else if(ObjAppDelegate.isEdit == YES){
        if([dbManager CheckEditCustomerEmailStatus:txtCustEmail.text :ObjAppDelegate.CustomerID] == YES){
            msg = @"Email is already exists";
        }
    }
    else if(ObjAppDelegate.isEdit == NO){
        if([dbManager CheckEmailStatus:txtCustEmail.text] == YES){
            msg = @"Email is already exists";
        }
    }
    return msg;
}
- (BOOL) isValidEmailAddress:(NSString *) candidate
{
    
    if (![self isEmpty:candidate])
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:candidate];
    }
    return NO;
}
- (BOOL) isEmpty:(NSString *) candidate
{
    return [[candidate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""];
}

//-(BOOL) NSStringIsValidEmail:(NSString *)checkString
//{
//    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
//    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
//    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:checkString];
//}
-(void)RedioButtonStatus
{
    Address *objAddress;
    if ([objAddress.strdefault_shipping isEqualToString:@"0"]){
        isshappingAddress = NO;
        btnShppingAddress.backgroundColor = [UIColor redColor];
        Shapping_status = @"0";
    }
    else if ([objAddress.strdefault_shipping isEqualToString:@"1"]){
        isshappingAddress = YES;
        btnShppingAddress.backgroundColor = [UIColor greenColor];
        Shapping_status = @"1";
    }
    
    if ([objAddress.strdefault_billing isEqualToString:@"0"]){
        isbillingAddress = NO;
        btnbillingAddress.backgroundColor = [UIColor redColor];
        billing_status = @"0";
    }
    else if ([objAddress.strdefault_billing isEqualToString:@"1"]){
        isbillingAddress = YES;
        btnbillingAddress.backgroundColor = [UIColor greenColor];
        billing_status = @"1";
    }
}
-(void)ClearAddressData{
  //  txtAddFirstName.text = @"";
    txtAddLastName.text = @"";
    txtAddMiddleName.text = @"";
    txtVAddress.text=@"";
    txtAddCompny.text=@"";
    txtCity.text = @"";
    txtZip.text= @"";
    txtTelephone.text = @"";
    txtFax.text = @"";
    //txtCountry.text = @"";
    txtRegion.text = @"";
    
    //txtCustGroup.text = @"";
    isshappingAddress = NO;
    btnShppingAddress.backgroundColor = [UIColor redColor];
    isbillingAddress = NO;
    btnbillingAddress.backgroundColor = [UIColor redColor];
    Shapping_status = @"0";
    billing_status = @"0";
    isclear = YES;
}
-(void)ClearAllData{
    [self ClearAddressData];
    txtVatNumber.text = @"";
    txtCustPrefix.text = @"";
    txtCustFirstName.text = @"";
    txtCustMiddleName.text = @"";
    txtCustLastName.text = @"";
    txtCustSuffix.text = @"";
    txtGender.text = @"";
    txtCustBirthDate.text = @"";
    txtAddCompny.text = @"";
    txtCustEmail.text =@"";
    txtPassword.text = @"";
    txtRePassword.text = @"";
    txtsales_agent_id.text = @"";
    [self.view endEditing:YES];
    [mainScrollV setContentOffset:CGPointMake(0,-64) animated:YES];
}

//Changes
#pragma mark InsertCustomerAddress
-(void)InsertCustomerAddress
{
    if (ObjAppDelegate.isEdit == NO || isAddnewAddress == YES) {
        NSString *str_Last_CustomerID = [dbManager Get_Last_CustomerID];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *strCount = [userDefault objectForKey:@"NewCustomerCount"];
        if (ObjAppDelegate.isEdit == NO) {
            str_New_CustomerID = [NSString stringWithFormat:@"%d",[str_Last_CustomerID intValue] + 100 + [strCount intValue] ];
        }
        else{
            str_New_CustomerID = ObjAppDelegate.CustomerID;
        }
        
        NSString *newAddressID = @"0";//[NSString stringWithFormat:@"%d",[strAddressID intValue] + counter];;
        NSString *countryCode = [[self CountryCode:txtCountry.text] mutableCopy];
        
        NSDictionary *dict=@{@"firstname": txtCustFirstName.text,
                             @"lastname":txtCustLastName.text,
                             @"middlename":txtCustMiddleName.text,
                             //@"suffix":txtCustSuffix.text,
                             @"region":txtRegion.text,
                             @"street":txtVAddress.text,
                             @"company":txtAddCompny.text,
                             @"city":txtCity.text,
                             @"country": countryCode,
                             @"postcode":txtZip.text,
                             @"telephone":txtTelephone.text,
                             @"fax":txtFax.text,
                             @"default_shipping":Shapping_status,
                             @"default_billing":billing_status,
                             @"entity_id":newAddressID,
                             @"parent_id":str_New_CustomerID
                             };
        // NSString *str_Last_AddressID = [dbManager Get_Last_AddressID];
        //NSString *str_New_AddressID = [NSString stringWithFormat:@"%d",[str_Last_AddressID intValue] + 100 + counter];
        NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:dict,newAddressID, nil];
        [dbManager InsertTempCustomersAddress:@"CustomerAddress" :FinelData :@"true" :@"false"];
        [dbManager DeleteNull];
        counter = counter+1;
        [self ClearAddressData];
        
        [DictPostAddress addEntriesFromDictionary:FinelData];
        
        arrAddressCount = [[NSMutableArray alloc]init];
        Address *Objaddress = [[Address alloc]initWithDictionary1:dict];
        [arrAddress addObject:Objaddress];
        for(int x = 0; x < arrAddress.count; x++){
            Address *objAddress = arrAddress[x];
            NSString *countryName = [[self CountryName:objAddress.strcountry_id] mutableCopy];
            NSString *strstreet = [NSString stringWithFormat:@"%d. %@,%@,%@",(x+1) ,objAddress.strstreet,objAddress.strcity,countryName];
            strstreet = [strstreet stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            [arrAddressCount addObject:strstreet];
        }
    }
    else{
        str_New_CustomerID = ObjAppDelegate.CustomerID;
        [self UpdateCustomerSelectedAddres];
    }
    [tblAddressList reloadData];
}

-(void)UpdateCustomerData
{
    //[self UpdatecustAddress];
    DictPostAddress = [[NSMutableDictionary alloc]init];
    // Customers *objCustomer = arrCustomer[0];
    NSString *strgroupID = [[self CustGroupID:txtCustGroup.text] mutableCopy];
    NSString *customerID = ObjAppDelegate.CustomerID;
    NSString *str_defaultbilling = [dbManager GetDefaultbilling:customerID];
    NSString *str_defaultshipping = [dbManager GetDefaultshipping:customerID];
    NSString *convertedDate=@"";
    if(![[txtCustBirthDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
        //        [dateformate setDateFormat:@"dd-MMM-yyyy"];
        [dateformate setDateFormat:@"MMM dd, yyyy"];
        
        NSDate *date = [dateformate dateFromString:txtCustBirthDate.text];
        dateformate = [[NSDateFormatter alloc]init];
        [dateformate setDateFormat:@"yyyy-MM-dd"];
        convertedDate = [dateformate stringFromDate:date];
    }
    NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:DictPostAddress ,@"addresses", nil];
    [eventData setObject:txtCustFirstName.text forKey:@"firstname"];
    [eventData setObject:txtCustMiddleName.text forKey:@"middlename"];
    [eventData setObject:txtCustLastName.text forKey:@"lastname"];
    [eventData setObject:txtCustEmail.text forKey:@"email"];
    [eventData setObject:convertedDate forKey:@"dob"];
    [eventData setObject:txtCustSuffix.text forKey:@"suffix"];
    [eventData setObject:customerID forKey:@"entity_id"];
    [eventData setObject:str_defaultbilling forKey:@"default_billing"];
    [eventData setObject:str_defaultshipping forKey:@"default_shipping"];
    
    NSString *Gender=@"";
    if ([txtGender.text isEqualToString:@"Male"]) {
        Gender = @"0";
    }
    else if ([txtGender.text isEqualToString:@"Female"]){
        Gender = @"1";
    }
    else{
    }
    [eventData setObject:Gender forKey:@"gender"];
    [eventData setValue:txtCustPrefix.text forKey:@"prefix"];
    [eventData setValue:txtPassword.text forKey:@"password_hash"];
    NSString *strfirstname = [[txtsales_agent_id.text componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *salesagentID = @"";
    if (strfirstname.length == 0 || strfirstname == (id)[NSNull null]){}
    else salesagentID = [[self salesAgentID:strfirstname] mutableCopy];
    [eventData setValue:salesagentID forKey:@"sales_agent_id"];
    [eventData setObject:txtVatNumber.text forKey:@"taxvat"];
    [eventData setValue:strgroupID forKey:@"group_id"];
    
    NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:eventData,customerID, nil];
    [dbManager InsertCustomerMaster:@"Customer_Master" :FinelData :@"false" :@"true"];
    [dbManager DeleteNull];

    if (![self connected]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Customer information has been updated in offline." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else{
        strSelectedWS = @"UpdateCustomers";
        [self CheckOathaction];
    }
}
#pragma mark Update customer List
-(void)UpdateCustomer_List
{
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager getUpadtedCustomer] mutableCopy];
    for (int i = 0; i< _temp.count; i++) {
        strID = [[_temp valueForKey:@"Customer_id"] objectAtIndex:i];
        NSString *strsuffix = [[_temp valueForKey:@"suffix"] objectAtIndex:i];
        NSMutableArray *arrCustAddress2 = [[objDatabaseManager getCustomerAddress:strID] mutableCopy];
        DictPostAddress = [[NSMutableDictionary alloc]init];
        
        
        for (int i = 0; i< arrCustAddress2.count; i++) {
            NSMutableDictionary *DictAddress = [[NSMutableDictionary alloc]init];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
            [DictAddress setObject:strsuffix forKey:@"suffix"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"region" ]objectAtIndex:i] forKey:@"region"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"street" ]objectAtIndex:i] forKey:@"street"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"company" ]objectAtIndex:i] forKey:@"company"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"city" ]objectAtIndex:i] forKey:@"city"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"country" ]objectAtIndex:i] forKey:@"country"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"postcode" ]objectAtIndex:i] forKey:@"postcode"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"telephone" ]objectAtIndex:i] forKey:@"telephone"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"fax" ]objectAtIndex:i] forKey:@"fax"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"default_shipping" ]objectAtIndex:i] forKey:@"default_shipping"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"default_billing" ]objectAtIndex:i] forKey:@"default_billing"];
            [DictAddress setObject:[[arrCustAddress2 valueForKey:@"entity_id" ]objectAtIndex:i] forKey:@"id"];
            NSString *straddressID = [[arrCustAddress2 valueForKey:@"entity_id" ]objectAtIndex:i];
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
        [eventData setValue:[[_temp valueForKey:@"Password" ]objectAtIndex:i] forKey:@"password_hash"];
        [eventData setValue:[[_temp valueForKey:@"group_id" ]objectAtIndex:i] forKey:@"group_id"];
        [eventData setValue:[[_temp valueForKey:@"sales_agent_id" ]objectAtIndex:i] forKey:@"sales_agent_id"];
        [eventData setValue:[[_temp valueForKey:@"gender" ]objectAtIndex:i] forKey:@"gender"];
        
        // NSMutableDictionary *finel = [NSMutableDictionary dictionaryWithObjectsAndKeys:eventData ,strID, nil];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        if (i == _temp.count - 1) {
            [self UpdateCustomers:jsonData2:YES];
        }
        else
        {
            [self UpdateCustomers:jsonData2:NO];
        }
    }
    if (_temp.count <= 0) {
        strSelectedWS = @"GetCustomers";
        [self CheckOathaction];
    }
}

-(void)NewCustomerData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *strCount = [userDefault objectForKey:@"NewCustomerCount"];
    
    NSString *strgroupID = [[self CustGroupID:txtCustGroup.text] mutableCopy];
    NSString *str_Last_CustomerID = [dbManager Get_Last_CustomerID];
    str_New_CustomerID = [NSString stringWithFormat:@"%d",[str_Last_CustomerID intValue] + 100 + [strCount intValue] ];
    NSString *str_defaultbilling = [dbManager GetDefaultbilling:str_New_CustomerID];
    NSString *str_defaultshipping = [dbManager GetDefaultshipping:str_New_CustomerID];
    NSString *convertedDate=@"";
    NSLog(@"bday%@",txtCustBirthDate.text);
    if(![[txtCustBirthDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
        [dateformate setDateFormat:@"MMM dd, yyyy"];
        NSDate *date = [dateformate dateFromString:txtCustBirthDate.text];
        dateformate = [[NSDateFormatter alloc]init];
        [dateformate setDateFormat:@"yyyy-MM-dd"];
        convertedDate = [dateformate stringFromDate:date];
    }
    counter = counter+1;
    DictPostAddress = [[NSMutableDictionary alloc]init];
    //[self NewAddress];
    NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:DictPostAddress,@"addresses", nil];
    [eventData setObject:txtCustFirstName.text forKey:@"firstname"];
    [eventData setObject:txtCustMiddleName.text forKey:@"middlename"];
    [eventData setObject:txtCustLastName.text forKey:@"lastname"];
    [eventData setObject:txtCustEmail.text forKey:@"email"];
    [eventData setObject:convertedDate forKey:@"dob"];
    [eventData setObject:txtCustSuffix.text forKey:@"suffix"];
    [eventData setObject:txtVatNumber.text forKey:@"taxvat"];
    [eventData setObject:str_defaultbilling forKey:@"default_billing"];
    [eventData setObject:str_defaultshipping forKey:@"default_shipping"];
    //    [eventData setObject:str_Last_CustomerID forKey:@"entity_id"]; //1 april
    [eventData setObject:str_New_CustomerID forKey:@"entity_id"];
    
    NSString *Gender=@"";
    if ([txtGender.text isEqualToString:@"Male"]) {
        Gender = @"0";
    }
    else if ([txtGender.text isEqualToString:@"Female"]){
        Gender = @"1";
    }
    else{
    }
    [eventData setObject:Gender forKey:@"gender"];
    [eventData setValue:txtCustPrefix.text forKey:@"prefix"];
    [eventData setValue:txtPassword.text forKey:@"password_hash"];
    NSString *strfirstname = txtsales_agent_id.text;
    // NSString *strfirstname = [[txtsales_agent_id.text componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *salesagentID = @"";
    if (strfirstname.length == 0 || strfirstname == (id)[NSNull null]){}
    else salesagentID = [[self salesAgentID:strfirstname] mutableCopy];
    [eventData setValue:salesagentID forKey:@"sales_agent_id"];
    [eventData setValue:strgroupID forKey:@"group_id"];
    NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:eventData,str_New_CustomerID, nil];
    [dbManager InsertCustomerMaster:@"Customer_Master" :FinelData :@"true" :@"false"];
    [dbManager DeleteNull];
    NSString *strCount1 = [userDefault objectForKey:@"NewCustomerCount"];
    
    NSString *newCount = [NSString stringWithFormat:@"%d",[strCount1 intValue] + 1] ;
    [userDefault setObject:newCount forKey:@"NewCustomerCount"];
    if (![self connected]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"New Customer has been saved in offline." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else{
        strSelectedWS = @"CreateCustomers";
        [self CheckOathaction];
        
    }
}
-(void)CheckOathaction{
    if (issync == true)
        return;
    issync = true;
    if ([self connected]){
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        OAToken *token_Check = [self GetToken];
        if (token_Check.key!= nil){
            
            //        NSString *straccesstoken = [userDefault valueForKey:@"accessToken"] ;
            //        NSString *strconsumer = [userDefault valueForKey:@"consumer"] ;
            if ([strSelectedWS isEqualToString:@"CustGroup"])
                [self CustomerGropus];
            else if ([strSelectedWS isEqualToString:@"salesagent"])
                [self GetSaleAgent];
            else if ([strSelectedWS isEqualToString:@"CreateCustomers"])
                [self InsertOnServer];
            else if ([strSelectedWS isEqualToString:@"UpdateCustomers"])
                [self UpdateCustomer_List];
            else if ([strSelectedWS isEqualToString:@"GetCustomers"])
                [self GetCustomers];
            else{}
            
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
    }
}

#pragma mark UpdateNewCustomerOn server
-(void)InsertOnServer
{
    [loadingView startLoadingWithMessage:@"Syncing Customer.." inView:self.view];
    NSMutableArray *_temp = [[NSMutableArray alloc]init];
    _temp = [[objDatabaseManager getNewCustomer] mutableCopy];
    for (int i = 0; i< _temp.count; i++) {
        strID = [[_temp valueForKey:@"Customer_id"] objectAtIndex:i];
        
        NSMutableArray *CustAddress = [[objDatabaseManager getCustomerAddress:strID] mutableCopy];
        NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:CustAddress ,@"addresses", nil];
        
        //        NSString *strfirstname =[[_temp valueForKey:@"firstname"]objectAtIndex:i];
        //        if (strfirstname == (id)[NSNull null] || strfirstname.length == 0 ) strfirstname = @"";
        //
        //        NSString *strmiddlename =[[_temp valueForKey:@"middlename"]objectAtIndex:i];
        //        if (strmiddlename == (id)[NSNull null] || strmiddlename.length == 0 ) strmiddlename = @"";
        //
        //        NSString *strlastname =[[_temp valueForKey:@"lastname"]objectAtIndex:i];
        //        if (strlastname == (id)[NSNull null] || strlastname.length == 0 ) strlastname = @"";
        //
        //        NSString *stremail =[[_temp valueForKey:@"email"]objectAtIndex:i];
        //        if (stremail == (id)[NSNull null] || stremail.length == 0 ) stremail = @"";
        
        NSString *strdob =[[_temp valueForKey:@"dob"]objectAtIndex:i];
        if (strdob == (id)[NSNull null] || strdob.length == 0 ) strdob = @"";
        
        //        NSString *strregion =[[_temp valueForKey:@"region"]objectAtIndex:i];
        //        if (strregion == (id)[NSNull null] || strregion.length == 0 ) strregion = @"";
        //
        //        NSString *strstreet =[[_temp valueForKey:@"street"]objectAtIndex:i];
        //        if (strstreet == (id)[NSNull null] || strstreet.length == 0 ) strstreet = @"";
        //
        //        NSString *strcompany =[[_temp valueForKey:@"company"]objectAtIndex:i];
        //        if (strcompany == (id)[NSNull null] || strcompany.length == 0 ) strcompany = @"";
        //
        //        NSString *strcity =[[_temp valueForKey:@"city"]objectAtIndex:i];
        //        if (strcity == (id)[NSNull null] || strcity.length == 0 ) strcity = @"";
        //
        //        NSString *strcountry_id =[[_temp valueForKey:@"country_id"]objectAtIndex:i];
        //        if (strcountry_id == (id)[NSNull null] || strcountry_id.length == 0 ) strcountry_id = @"";
        
        NSString *strpostcode =[[_temp valueForKey:@"postcode"]objectAtIndex:i];
        if (strpostcode == (id)[NSNull null] || strpostcode.length == 0 ) strpostcode = @"";
        [eventData setObject:[[_temp valueForKey:@"firstname" ]objectAtIndex:i] forKey:@"firstname"];
        [eventData setObject:[[_temp valueForKey:@"middlename" ]objectAtIndex:i] forKey:@"middlename"];
        [eventData setObject:[[_temp valueForKey:@"lastname" ]objectAtIndex:i] forKey:@"lastname"];
        [eventData setObject:[[_temp valueForKey:@"email" ]objectAtIndex:i] forKey:@"email"];
        [eventData setObject:[[_temp valueForKey:@"taxvat" ]objectAtIndex:i] forKey:@"taxvat"];

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
- (void)CreateCustomers :(NSData *)Customer :(BOOL)alertshow
{
    //Anil
    [loadingView changeLoadingMessage:@"Add New Customer"];
    
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
                [dbManager Delete_Local_Add_NewCustomerAddress:strID];
                [dbManager Delete_Local_Add_NewCustomer:strID];
                [dbManager UpdateCustomerId:strID :json[@"create-customer"][@"cust_id"]];
                
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
//                    UIAlertView *alert;
//
//                    if (alertshow == YES) {
//                       
//
//                        NSString *strerror = [json objectForKey:@"error"];
//                        alert = [[UIAlertView alloc]initWithTitle:@"success" message:strerror delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                        [alert show];
//                    }

                    double delayInSeconds = 3.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        issync = false;
                        MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                        vc.delegate = self;
                        [[self navigationController] pushViewController:vc animated:YES];
                    });

                    
                }else{
                    NSString *strsuccess = [[json objectForKey:@"create-customer"] objectForKey:@"success"];
                   //UIAlertView *alert;
                    if ([strsuccess isEqualToString:@"true"]) {
                        [self GetCustomers];

                        //Today
                        if (alertshow == YES) {
                            double delayInSeconds = 3.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"success" message:@"New customer added successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                [alert show];
                            });
                           
                        }
                    }
                    else{
                        
                        
                    }
                }
                
            }else{
            }
            [loadingView stopLoading];
            issync = false;
        }}failedBlock:^{
            NSLog(@"Failed");
            [loadingView stopLoading];
            issync = false;
        }];
}
#pragma mark UpdateCustomer
- (void)UpdateCustomers :(NSData *)Customer :(BOOL)alertshow
{
    //Anil
    [loadingView startLoadingWithMessage:@"Change Customer information.." inView:self.view];

   // [loadingView changeLoadingMessage:@"Change Customer information"];
    [dbManager CreateCustomerMaster:@"Customer_Master"];
    [dbManager CreateCustomerAddress:@"CustomerAddress"];
    NSString *customerID = ObjAppDelegate.CustomerID;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@customers/%@",[[Singleton sharedSingleton] getBaseURL],customerID]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:[self GetConsumer]  token:[self GetToken] realm:nil signatureProvider:[[OAPlaintextSignatureProvider alloc]init]];
    [request prepare];
    
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
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    issync = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    [self GetCustomers];

                    // NSString *strsuccess = [[json objectForKey:@"update-customer"] objectForKey:@"success"];
                    if (alertshow == YES) {
                        double delayInSeconds = 3.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            UIAlertView *alert;
                            alert = [[UIAlertView alloc]initWithTitle:@"success" message:@"Update Customer Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                            [alert show];

                        });

                        
                        //                        strSelectedWS = @"GetCustomers";
                        //                        [self CheckOathaction];
                    }
                    NSString *strsuccess1 = [[json objectForKey:@"update-customer"] objectForKey:@"success"];
                    //UIAlertView *alert;
                    if ([strsuccess1 isEqualToString:@"true"]) {
                        //alert = [[UIAlertView alloc]initWithTitle:@"success" message:@"Update Customer Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [dbManager Delete_Local_Update_CustomerAddress:strID];
                        [dbManager Delete_Local_Add_CustomerAddress:strID];
                        [dbManager Delete_Local_Update_NewCustomer:strID];
                    }
                    else{
                    }
                }
            }
            if (![dbManager isUpdateCustomerCreatedInOffline]){
                // [self CheckOathaction];
                [loadingView stopLoading];
                issync = false;
                //                strSelectedWS = @"GetCustomers";
                //                [self CheckOathaction];
            }
            
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
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
                [dbManager DeleteNull];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
        [loadingView stopLoading];
        issync = false;
    } failedBlock:^{
        [loadingView stopLoading];
        issync = false;
    }];
}
//Anil
#pragma mark - Webservice for Get Groups
- (void)CustomerGropus{
    [loadingView changeLoadingMessage:@"Getting Customer group"];
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
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    issync = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    [dbManager InsertCustGroups:@"CustGroups":[json mutableCopy]];
                }
            }else{
                
            }
            [loadingView stopLoading];
            issync = false;
        }
    }failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        issync = false;
    }];
}
#pragma mark - Get Sales Agent
-(void)GetSaleAgent{
    [loadingView changeLoadingMessage:@"Getting Sales Agent"];
    NSURL * url;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
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
            
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]){
                if ([json objectForKey:@"messages"]) {
                    [loadingView stopLoading];
                    issync = false;
                    MainViewController * vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                    vc.delegate = self;
                    [[self navigationController] pushViewController:vc animated:YES];
                }else{
                    [dbManager InsertSalesAgent:json];
                }
                
            }else{
                
            }
        }
        [loadingView stopLoading];
        issync = false;
    } failedBlock:^{
        NSLog(@"Failed");
        [loadingView stopLoading];
        issync = false;
    }];
}
-(void)getAccessTokenSuccess{
    if ([strSelectedWS isEqualToString:@"CustGroup"])
        [self CustomerGropus];
    else if ([strSelectedWS isEqualToString:@"salesagent"])
        [self GetSaleAgent];
    else if ([strSelectedWS isEqualToString:@"CreateCustomers"])
        [self InsertOnServer];
    else if ([strSelectedWS isEqualToString:@"UpdateCustomers"])
        [self UpdateCustomer_List];
    else if ([strSelectedWS isEqualToString:@"GetCustomers"])
        [self GetCustomers];
    else{}
}
//Anil Changes
#pragma mark UIAlertView Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 5151){
        if (alertView.cancelButtonIndex != buttonIndex){
//            BOOL isChange = [self isChangeAddress];
//            isAddnewAddress = YES;
//            if (isChange == YES)
            isAddnewAddress = YES;
                [self InsertCustomerAddress];
        }
    }else{
        if (buttonIndex == 0) {
            [self ClearAllData];
            [self.navigationController popViewControllerAnimated:YES];
        }else if (buttonIndex == 0){
        }
    }
}
#pragma mark UIButton Action event
- (IBAction)btnBack_Click:(id)sender {
    [[self navigationController]popViewControllerAnimated:YES];
}

- (IBAction)btnRefreshCustGroup_Click:(id)sender {
    if ([self connected]){
        strSelectedWS = @"CustGroup";
        [self CheckOathaction];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Internet is not active." delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"OK", nil];
        [alert show];
    }
}
- (IBAction)btnGetsalesagent_click:(id)sender {
    if ([self connected]){
        strSelectedWS = @"salesagent";
        [self CheckOathaction];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Internet is not active." delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

//Anil
- (IBAction)btnShappingAddress_Click:(id)sender {
    Shapping_status = [[NSString alloc]init];
    if (ObjAppDelegate.isEdit == NO && counter == 0) {
        Shapping_status = @"1";
        isshappingAddress = YES;
        btnShppingAddress.backgroundColor = [UIColor greenColor];
    }
    else if(ObjAppDelegate.isEdit == YES || counter > 0){
        NSString *customerID = ObjAppDelegate.CustomerID;
        [objDatabaseManager set_DefaultShaping:customerID];
        Address *objAddress;
        if (arrAddress.count > 0) objAddress = [arrAddress objectAtIndex:indexAddress];
        [objDatabaseManager set_DefaultShapingAddress:objAddress.strentity_id];
        Shapping_status = @"1";
        isshappingAddress = YES;
        btnShppingAddress.backgroundColor = [UIColor greenColor];
    }
}
//Anil
- (IBAction)btnbillingAddress_Click:(id)sender {
    billing_status = [[NSString alloc]init];
    if (ObjAppDelegate.isEdit == NO && counter == 0) {
        billing_status = @"1";
        isbillingAddress = YES;
        btnbillingAddress.backgroundColor = [UIColor greenColor];
    }
    else if(ObjAppDelegate.isEdit == YES || counter > 0)
    {
        NSString *customerID = ObjAppDelegate.CustomerID;
        [objDatabaseManager set_Defaultbilling:customerID];
        Address *objAddress;
        if (arrAddress.count > 0) objAddress = [arrAddress objectAtIndex:indexAddress];
        [objDatabaseManager set_DefaultbillingAddress:objAddress.strentity_id];
        billing_status = [[NSString alloc]init];
        billing_status = @"1";
        isbillingAddress = YES;
        btnbillingAddress.backgroundColor = [UIColor greenColor];
    }
}
- (IBAction)btnAddNewAddress_Click:(id)sender {
    __weak NSString *msg = [self validateField];
    if ([msg isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure to add this address " delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 5151;
        [alert show];
        
        return;
        BOOL isChange = [self isChangeAddress];
        isAddnewAddress = YES;
        if (isChange == YES)[self InsertCustomerAddress];
        
        else {
            
        }
    }else{
        UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertMessage show];
    }
    
}
- (IBAction)btnSave_Click:(id)sender {
    __weak NSString *msg = [self validateField];
    if ([msg isEqualToString:@""]) {
        if (ObjAppDelegate.isEdit == NO){
            [self InsertCustomerAddress];
            [self NewCustomerData];
        }
        else{
            BOOL isChange = [self isChangeAddress];
            if (isChange == YES)[self InsertCustomerAddress];
            else {
            }
            [self UpdateCustomerData];
        }
    }else{
        UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertMessage show];
    }
    
}
#pragma mark UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrAddressCount count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifire = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifire];
    }
    cell.textLabel.text = [arrAddressCount objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    cell.textLabel.textColor = fontcolor;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Address *objtempAddress;
    if (arrAddress.count > 0) objtempAddress = [arrAddress objectAtIndex:indexAddress];
    NSString *customerID = ObjAppDelegate.CustomerID;
    BOOL isChange = [self isChangeAddress];
    if (isChange == YES && isclear == NO) {
        strAddressID = objtempAddress.strentity_id;
        [self UpdateCustomerSelectedAddres];
//        NSString *countryCode = @"0";
//        if (![txtCountry.text isEqualToString:@""]){
//            countryCode  = [[self CountryCode:txtCountry.text] mutableCopy];
//        }
//        NSDictionary *dict=@{@"firstname"       : txtAddFirstName.text,
//                             @"lastname"        :txtAddLastName.text,
//                             @"region"          :txtRegion.text,
//                             @"street"          :txtVAddress.text,
//                             @"company"         :txtAddCompny.text,
//                             @"city"            :txtCity.text,
//                             @"country"         : countryCode,
//                             @"postcode"        :txtZip.text,
//                             @"telephone"       :txtTelephone.text,
//                             @"fax"             :txtFax.text,
//                             @"default_shipping":Shapping_status,
//                             @"default_billing" :billing_status,
//                             @"entity_id"       :strAddressID,
//                             };
//        NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:dict,strAddressID, nil];
//        [dbManager UpdateCustomersAddress:@"CustomerAddress" :FinelData :@"false" :@"true"];
    }
    arrAddress = [[self CustomerAddress:customerID] mutableCopy];
    indexAddress = indexPath.row;
    Address *objAddress = [arrAddress objectAtIndex:indexPath.row];
    txtAddCompny.text = objAddress.strcompany;
    txtCity.text = objAddress.strcity;
    NSString *countryName = [[self CountryName:objAddress.strcountry_id] mutableCopy];
    txtCountry.text = countryName;
    txtZip.text = objAddress.strpostcode;
    txtTelephone.text = objAddress.strtelephone;
    txtFax.text = objAddress.strfax;
    str_New_CustomerID = objAddress.strparent_id;
    str_Customer_entity_id = objAddress.strparent_id;
    txtVAddress.text = objAddress.strstreet;
    txtAddFirstName.text = objAddress.strfirstname;
    txtAddLastName.text = objAddress.strlastname;
    [self RedioButtonStatus];
    
    //Customer Information
    Customers *objCustomer = arrCustomer[0];
    txtCustPrefix.text = objCustomer.strprefix;
    NSString *strgroupname = [[self CustGroupName:objCustomer.group_id] mutableCopy];
    txtCustGroup.text = strgroupname;
    NSString *strsaleagent = @"";
    if (objCustomer.sales_agent_id.length == 0 || objCustomer.sales_agent_id == (id)[NSNull null] ) {
        
    }
    else strsaleagent = [dbManager GetSalesName:objCustomer.sales_agent_id];
    txtsales_agent_id.text = strsaleagent;
    strAddressID = objAddress.strentity_id;
    arrAddressCount = [[NSMutableArray alloc] init];
    for(int x = 0; x < arrAddress.count; x++){
        Address *objAddress = arrAddress[x];
        NSString *countryName = [[self CountryName:objAddress.strcountry_id] mutableCopy];
        NSString *strstreet = [NSString stringWithFormat:@"%d. %@,%@,%@",(x+1) ,objAddress.strstreet,objAddress.strcity,countryName];
        strstreet = [strstreet stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        [arrAddressCount addObject:strstreet];
    }
    [tblAddressList reloadData];
}
-(void)UpdateCustomerSelectedAddres{
    
    if([dbManager CheckAddressExit:strAddressID] == YES){
        NSString *countryCode = @"0";
        if (![txtCountry.text isEqualToString:@""]){
            countryCode  = [[self CountryCode:txtCountry.text] mutableCopy];
        }
        NSDictionary *dict=@{@"firstname"       : txtCustFirstName.text,
                             @"lastname"        :txtCustLastName.text,
                             @"region"          :txtRegion.text,
                             @"street"          :txtVAddress.text,
                             @"company"         :txtAddCompny.text,
                             @"city"            :txtCity.text,
                             @"country"         :countryCode,
                             @"postcode"        :txtZip.text,
                             @"telephone"       :txtTelephone.text,
                             @"fax"             :txtFax.text,
                             @"default_shipping":Shapping_status,
                             @"default_billing" :billing_status,
                             @"entity_id"       :strAddressID,
                             };
        NSMutableDictionary *FinelData = [NSMutableDictionary dictionaryWithObjectsAndKeys:dict,strAddressID, nil];
        [dbManager UpdateCustomersAddress:@"CustomerAddress" :FinelData :@"false" :@"true"];
    }
}

-(BOOL)isChangeAddress{
    Address *objAddress;
    if (arrAddress.count > 0)   objAddress = [arrAddress objectAtIndex:indexAddress];
    NSString *countryCode = [[self CountryCode:txtCountry.text] mutableCopy];
    if (![txtCustFirstName.text isEqualToString:objAddress.strfirstname]) {
        return true;
    }
//    else  if (![txtAddFirstName.text isEqualToString:objAddress.strfirstname]) {
//        return true;
//    }
    else  if (![txtCustLastName.text isEqualToString:objAddress.strlastname]) {
        return true;
    }else  if (![countryCode isEqualToString:objAddress.strcountry_id]) {
        return true;
    }else  if (![txtVAddress.text isEqualToString:objAddress.strstreet]) {
        return true;
    }else  if (![txtCity.text isEqualToString:objAddress.strcity]) {
        return true;
    }else  if (![txtZip.text isEqualToString:objAddress.strpostcode]) {
        return true;
    }else  if (![txtTelephone.text isEqualToString:objAddress.strtelephone]) {
        return true;
    }else  if (![txtFax.text isEqualToString:objAddress.strfax]) {
        return true;
    }else{
        return false;
    }
}

#pragma mark - Check internet connection
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (IBAction)btnClearAllTextfield_Click:(id)sender {
    [self ClearAddressData];
}

@end