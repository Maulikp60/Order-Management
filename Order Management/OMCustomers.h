//
//  OMCustomers.h
//  Order Management
//
//  Created by Yoshemite on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"
#import "OMCustomerInfoVC.h"
#import "AppDelegate.h"
@interface OMCustomers : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrCustomers, *CustomerList;
    NSMutableArray *arrCustAddress, *CustAddressList;
    NSMutableArray *alphabetsArray;
    NSMutableArray *dataArray,*arrSearchCustomer;
    NSMutableDictionary *dicoAlphabet;
    NSMutableArray *arrcustomerName;
    NSArray *animalSectionTitles;
    UIColor *fontcolor;
    AppDelegate *ObjAppDelegate;
    NSInteger index;

    __weak IBOutlet UILabel *lbl_New;
    __weak IBOutlet UILabel *lbl_Edit;
    __weak IBOutlet UILabel *lbl_Contact;
    __weak IBOutlet UILabel *lbl_Address;
    

}
@property (weak, nonatomic) IBOutlet UITableView *TBCustomerList;
@property (weak, nonatomic) IBOutlet UILabel *lblCompnyName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblContact;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UITableView *TBAddressList;
@property (weak, nonatomic) IBOutlet UILabel *lblReferences;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UITextView *txtVdescription;
@property (weak, nonatomic) IBOutlet UIView *OderListView;
@property (weak, nonatomic) IBOutlet UILabel *lbltitle;
@property (weak, nonatomic) IBOutlet UITableView *TBOrderList;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISearchBar *customerSearchB;
@property (weak, nonatomic) IBOutlet UIButton *btnNew;
- (IBAction)btnNew_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
- (IBAction)btnEdit_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *Vtitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
- (IBAction)btnBack_Click:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTelephoneNo;
@property (weak, nonatomic) IBOutlet UILabel *lblCompny;
@property (weak, nonatomic) IBOutlet UILabel *lblVatCode;
@property (weak, nonatomic) IBOutlet UILabel *lblCompnyAddress;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchCustomerList;


-(NSArray *)CurrectCompnyAddress :(NSNumber *)_value;
-(NSArray *)CustomerDetailList;

@end
