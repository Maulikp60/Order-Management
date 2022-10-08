//
//  OMCustomerInfoVC.h
//  Order Management
//
//  Created by Yoshemite on 12/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQActionSheetPickerView.h"
#import "ASIHTTPRequest.h"
#import "DatabaseManager.h"
#import "Customers.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "OMHomeVC.h"
#import "DBManager.h"
#import "Reachability.h"
#import "Address.h"
#import "LoadingView.h"
#import "SuperVC.h"
@interface OMCustomerInfoVC :SuperVC <IQActionSheetPickerViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *CountryArray,*custGroup,*custGroupList,*arrSalesAgent,*salesAgentList;
    NSMutableArray *arrCountry,*arrCustomer_Group,*salesAgent;
    NSMutableArray *CountryList,*CustAddressList,*CustomerList;
    AppDelegate *ObjAppDelegate;
    NSMutableArray *arrCustAddress;
    DBManager *dbManager;
    NSMutableArray *arrAddressCount;
    NSString *Shapping_status,*billing_status;
    BOOL isshappingAddress, isbillingAddress,isnewAddress;
    NSString *strAddressID;
    NSMutableDictionary *DictPostAddress;
    NSInteger indexAddress,counter;
    NSString *str_New_CustomerID,*str_Customer_entity_id;
    NSMutableArray *arrAddress;
    NSMutableArray *arrCustomer;
    LoadingView *loadingView;
    UIColor *fontcolor;
    DatabaseManager *objDatabaseManager;
    NSString *strID;
    BOOL issync, isclear;
    NSString *strSelectedWS;
    BOOL isAddnewAddress;

    // NSMutableData *data;
    
    //Langauge Change Label
    
    __weak IBOutlet UILabel *lbl_AccountInformation;
    __weak IBOutlet UILabel *lbl_CustomerGroup;
    __weak IBOutlet UILabel *lbl_Prefix;
    __weak IBOutlet UILabel *lbl_FirstName;
    __weak IBOutlet UILabel *lbl_MiddleName;
    __weak IBOutlet UILabel *lbl_LastName;
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_City;
    __weak IBOutlet UILabel *lbl_Region;
    __weak IBOutlet UILabel *lbl_Country;
    __weak IBOutlet UILabel *lbl_ZipCode;
    __weak IBOutlet UILabel *lbl_Telephone;
    __weak IBOutlet UILabel *lbl_Fax;
    __weak IBOutlet UILabel *lbl_StreetAddress;
    __weak IBOutlet UILabel *lbl_TaxVatNumber;
    __weak IBOutlet UILabel *lbl_CustomerEmail;
    __weak IBOutlet UILabel *lbl_Password;
    __weak IBOutlet UILabel *lbl_Repassword;
    __weak IBOutlet UILabel *lbl_DefaultBillingAddress;
    __weak IBOutlet UILabel *lbl_DefaultShippingAddress;
    __weak IBOutlet UILabel *lbl_AddressFirstName;
    __weak IBOutlet UILabel *lbl_AddressSecondName;
    __weak IBOutlet UILabel *lbl_AddressLastName;
    __weak IBOutlet UILabel *lbl_AddressSufix;
    __weak IBOutlet UILabel *lbl_Gender;
    __weak IBOutlet UILabel *lbl_DateOfBirth;
    __weak IBOutlet UILabel *lbl_PasswordSection;
    __weak IBOutlet UILabel *lbl_AddressSection;
    __weak IBOutlet UILabel *lbl_SalesAgent;
}
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollV;
@property (weak, nonatomic) IBOutlet UIView *subView;

// Customer Information
@property (weak, nonatomic) IBOutlet UITextField *txtCustPrefix;
@property (weak, nonatomic) IBOutlet UITextField *txtCustFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtCustMiddleName;
@property (weak, nonatomic) IBOutlet UITextField *txtCustLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtCustSuffix;
@property (weak, nonatomic) IBOutlet UITextField *txtCustEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtCustBirthDate;
@property (weak, nonatomic) IBOutlet UITextField *txtGender;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtgroupID;
//@property (weak, nonatomic) IBOutlet UITextField *txtstoreID;
@property (weak, nonatomic) IBOutlet UITextField *txtsales_agent_id;
@property (weak, nonatomic) IBOutlet UIButton *btnRefreshCustGroup;
@property (weak, nonatomic) IBOutlet UITextField *txtRegion;
@property (weak, nonatomic) IBOutlet UITextField *txtCustGroup;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;
@property (weak, nonatomic) IBOutlet UIButton *btnClearAllTextfield;
- (IBAction)btnClearAllTextfield_Click:(id)sender;

//Customer Address Information
//@property (weak, nonatomic) IBOutlet UILabel *txtAddLastName;
////@property (weak, nonatomic) IBOutlet UITextField *txtAddPrefix;
//@property (weak, nonatomic) IBOutlet UILabel *txtAddMiddleName;
//@property (weak, nonatomic) IBOutlet UILabel *txtAddFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddMiddleName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddSuffix;
@property (weak, nonatomic) IBOutlet UITextField *txtAddCompny;
//@property (weak, nonatomic) IBOutlet UITextField *txtAddStreet;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtCountry;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UITextField *txtZip;
@property (weak, nonatomic) IBOutlet UITextField *txtTelephone;
@property (weak, nonatomic) IBOutlet UITextField *txtFax;
@property (weak, nonatomic) IBOutlet UITextField *txtVatNumber;
@property (weak, nonatomic) IBOutlet UITextView *txtVAddress;
@property (weak, nonatomic) IBOutlet UITableView *tblAddressList;
@property (weak, nonatomic) IBOutlet UIButton *btnbillingAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnShppingAddress;
- (IBAction)btnShappingAddress_Click:(id)sender;
- (IBAction)btnbillingAddress_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)btnSave_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnNewAddress;
- (IBAction)btnAddNewAddress_Click:(id)sender;

-(NSArray *)Country;
- (IBAction)btnBack_Click:(id)sender;

- (IBAction)btnRefreshCustGroup_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnsalesagent;
- (IBAction)btnGetsalesagent_click:(id)sender;

-(BOOL)isChangeAddress;

@end
