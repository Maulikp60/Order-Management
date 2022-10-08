//
//  Address.h
//  Order Management
//
//  Created by Yoshemite on 30/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject
//Customer Address
-(id)initWithDictionary1:(NSDictionary *)_dictAllAddress;
@property(nonatomic, strong)NSString *strattribute_set_id;
@property(nonatomic, strong)NSString *strcity;
@property(nonatomic, strong)NSString *strcompany;
@property(nonatomic, strong)NSString *strcountry_id;
@property(nonatomic, strong)NSString *strcreated_at;
@property(nonatomic, strong)NSString *strcustomer_id;
@property(nonatomic, strong)NSString *strdefault_billing;
@property(nonatomic, strong)NSString *strdefault_shipping;
@property(nonatomic, strong)NSString *strentity_id;
@property(nonatomic, strong)NSString *strentity_type_id;
@property(nonatomic, strong)NSString *strfax;
@property(nonatomic, strong)NSString *strfirstname;
@property(nonatomic, strong)NSString *strincrement_id;
@property(nonatomic, strong)NSString *stris_active;
@property(nonatomic, strong)NSString *strlastname;
@property(nonatomic, strong)NSString *strparent_id;
@property(nonatomic, strong)NSString *strpostcode;
@property(nonatomic, strong)NSString *strregion;
@property(nonatomic, strong)NSString *strstreet;
@property(nonatomic, strong)NSString *strtelephone;
@property(nonatomic, strong)NSString *updated_at;

@end
