//
//  SalesAgent.h
//  OrderManagement
//
//  Created by Yoshemite on 04/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesAgent : NSObject
-(id)initWithDictionary:(NSDictionary *)_dictSalesAgent;
@property (nonatomic, strong) NSString *strcustomer_group_id;
@property (nonatomic, strong) NSString *stremail;
@property (nonatomic, strong) NSString *strfirstname;
@property (nonatomic, strong) NSString *stris_active;
@property (nonatomic, strong) NSString *strlastname;
@property (nonatomic, strong) NSString *strpassword;
@property (nonatomic, strong) NSString *struser_id;
@property (nonatomic, strong) NSString *strusername;
@end
