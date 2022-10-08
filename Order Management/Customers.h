//
//  Customers.h
//  Order Management
//
//  Created by Yoshemite on 09/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Customers : NSObject

//CustomerDetail
-(id)initWithDictionary:(NSDictionary *)_dict;
@property(nonatomic, strong)NSString *strCustomerName;
@property(nonatomic, strong)NSString *strCustomerLastName;
@property(nonatomic, strong)NSString *strCustomerID;
@property(nonatomic, strong)NSString *strCustContact;
@property(nonatomic, strong)NSString *strVatTax;
@property(nonatomic, strong)NSString *strmiddlename;
@property(nonatomic, strong)NSString *strsuffix;
@property(nonatomic, strong)NSString *strdob;
@property(nonatomic, strong)NSString *strgender;
@property(nonatomic, strong)NSString *entity_ID;
@property(nonatomic, strong)NSString *Password;
@property(nonatomic, strong)NSString *group_id;
@property(nonatomic, strong)NSString *store_id;
@property(nonatomic, strong)NSString *sales_agent_id;
@property(nonatomic, strong)NSString *default_billing;
@property(nonatomic, strong)NSString *default_shipping;
@property(nonatomic, strong)NSString *strprefix;





//Customer Address
-(id)initWithDictionary1:(NSDictionary *)_dictAddress;
@property(nonatomic, strong)NSString *strCustAddressName;
@property(nonatomic, strong)NSString *strCustAddressLastName;
@property(nonatomic, strong)NSString *strCompnyName;
@property(nonatomic, strong)NSString *strStreet;
@property(nonatomic, strong)NSString *strcity;
@property(nonatomic, strong)NSString *strPostcode;
@property(nonatomic, strong)NSString *strCountry;
@property(nonatomic, strong)NSString *strTelephone;
@property(nonatomic, strong)NSString *strFaxNo;
@property(nonatomic, strong)NSString *parent_id;
@property(nonatomic, strong)NSString *Address_entity_ID;
@property(nonatomic, strong)NSString *strRegion;


//Country
-(id)initWithDictionary2:(NSDictionary *)_DictCountry;
@property(nonatomic, strong)NSString *strCode;
@property(nonatomic, strong)NSString *strname;

//Customer Group
-(id)initWithDictionaryGroup:(NSDictionary *)_DictCountry;
@property(nonatomic, strong)NSString *strcustomer_group_code;
@property(nonatomic, strong)NSString *strcustomer_group_id;
@property(nonatomic, strong)NSString *strtax_class_id;



@end
