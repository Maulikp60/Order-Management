//
//  Address.m
//  Order Management
//
//  Created by Yoshemite on 30/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "Address.h"

@implementation Address

@synthesize strpostcode,strattribute_set_id,strcity,strcompany,strcountry_id,strcreated_at,strcustomer_id,strdefault_billing,strdefault_shipping,strentity_id,strentity_type_id,strfax,strfirstname,strincrement_id,stris_active,strlastname,strparent_id,strregion,strstreet,strtelephone,updated_at;


-(id)initWithDictionary1:(NSDictionary *)_dictAddress;
{
    self = [super init];
    strattribute_set_id = _dictAddress[@"attribute_set_id"];
    strcity = _dictAddress[@"city"];
    strcompany = _dictAddress[@"company"];
    strcountry_id = _dictAddress[@"country"];
    strcreated_at = _dictAddress[@"created_at"];
    strcustomer_id = _dictAddress[@"customer_id"];
    strdefault_billing = _dictAddress[@"default_billing"];
    strdefault_shipping = _dictAddress[@"default_shipping"];
    strentity_id = _dictAddress[@"entity_id"];
    strentity_type_id = _dictAddress[@"entity_type_id"];
    strfax = _dictAddress[@"fax"];
    strfirstname = _dictAddress[@"firstname"];
    strincrement_id = _dictAddress[@"increment_id"];
    stris_active = _dictAddress[@"is_active"];
    strlastname = _dictAddress[@"lastname"];
    strparent_id = _dictAddress[@"parent_id"];
    strpostcode = _dictAddress[@"postcode"];
    strregion = _dictAddress[@"region"];
    strstreet = _dictAddress[@"street"];
    strtelephone = _dictAddress[@"telephone"];
    updated_at = _dictAddress[@"updated_at"];
  
    return self;
}

@end
