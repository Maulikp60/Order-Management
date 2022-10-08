//
//  Customers.m
//  Order Management
//
//  Created by Yoshemite on 09/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "Customers.h"

@implementation Customers
@synthesize strCustomerName,strCustAddressName,strCustAddressLastName,strCompnyName,strStreet,strcity,strPostcode,strCountry,strTelephone,strCustomerID,strCustContact,strCustomerLastName,strVatTax,strFaxNo,strmiddlename,strsuffix,strdob,strgender,entity_ID,parent_id,Password,store_id,group_id,sales_agent_id,default_billing,default_shipping,strcustomer_group_code,strcustomer_group_id,strtax_class_id,Address_entity_ID,strprefix,strRegion;

@synthesize strname,strCode;

-(id)initWithDictionary:(NSDictionary *)_dict
{
    self = [super init];
    
    strCustomerName = _dict[@"firstname"];
    strCustomerLastName = _dict[@"lastname"];
    strCustomerID = _dict[@"Customer_id"];
    strCustContact = _dict[@"email"];
    strVatTax = _dict[@"taxvat"];
    if ([_dict[@"middlename"] isEqualToString:@"(null)"])
        strmiddlename = @"";
    else
        strmiddlename =_dict[@"middlename"];
    if ([_dict[@"suffix"] isEqualToString:@"(null)"])
        strsuffix = @"";
    else
        strsuffix = _dict[@"suffix"];
    
    if ([_dict[@"dob"] isEqualToString:@"(null)"])
        strdob = @"";
    else
        strdob = _dict[@"dob"];
    if ([_dict[@"gender"] isEqualToString:@"(null)"])
        strgender = @"";
    else
        strgender = _dict[@"gender"];
    
    entity_ID = _dict[@"entity_id"];
    Password = _dict[@"password_hash"];
    group_id = _dict[@"group_id"];
    store_id = _dict[@"store_id"];
    sales_agent_id = _dict[@"sales_agent_id"];
    default_shipping = _dict[@"default_shipping"];
    default_billing = _dict[@"default_billing"];
    if ([_dict[@"prefix"] isEqualToString:@"(null)"])
        strgender = @"";
    else
        strprefix = _dict[@"prefix"];
    
    return self;
}
-(id)initWithDictionary1:(NSDictionary *)_dictAddress;
{
    self = [super init];
    strCustAddressName = _dictAddress[@"firstname"];
    strCustAddressLastName = _dictAddress[@"lastname"];
    strCompnyName = _dictAddress[@"company"];
    strStreet = _dictAddress[@"street"];
    strcity = _dictAddress[@"city"];
    strCountry = _dictAddress[@"country_id"];
    strTelephone = _dictAddress[@"telephone"];
    strFaxNo = _dictAddress[@"fax"];
    parent_id = _dictAddress[@"parent_id"];
    Address_entity_ID = _dictAddress[@"entity_id"];
    strRegion = _dictAddress[@"region"];


    return self;
}
-(id)initWithDictionary2:(NSDictionary *)_DictCountry
{
    self = [super init];
    strCode = _DictCountry[@"code"];
    strname = _DictCountry[@"name"];
    return self;
}
-(id)initWithDictionaryGroup:(NSDictionary *)_DictCountry
{
    self = [super init];
    strcustomer_group_code = _DictCountry[@"customer_group_code"];
    strcustomer_group_id = _DictCountry[@"customer_group_id"];
    strtax_class_id = _DictCountry[@"tax_class_id"];

    return self;
}



@end
