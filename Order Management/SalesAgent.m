//
//  SalesAgent.m
//  OrderManagement
//
//  Created by Yoshemite on 04/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "SalesAgent.h"

@implementation SalesAgent
@synthesize strcustomer_group_id,stremail,strfirstname,stris_active,strlastname,strpassword,struser_id,strusername;


-(id)initWithDictionary:(NSDictionary *)_dictSalesAgent
{
    self = [super init];
        strcustomer_group_id = _dictSalesAgent[@"customer_group_id"];
        stremail = _dictSalesAgent[@"email"];
        strfirstname = _dictSalesAgent[@"firstname"];
        stris_active = _dictSalesAgent[@"is_active"];
        strlastname = _dictSalesAgent[@"lastname"];
        strpassword = _dictSalesAgent[@"password"];
        struser_id = _dictSalesAgent[@"user_id"];
        strusername = _dictSalesAgent[@"username"];
    return self;
}
@end
