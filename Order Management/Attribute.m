//
//  Attribute.m
//  Order Management
//
//  Created by MAC on 30/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "Attribute.h"

@implementation Attribute

-(id)initWithWebDict:(NSDictionary *)dict{
    self =    [super init];
    if (self){
        self.attributeA_id = [dict objectForKey:@"attribute_id"];
        
        return self;
    }
    return nil;
}
-(id)initWithLocalDBDict:(NSDictionary *)dict{
    self =    [super init];
    if (self){
        self.attributeA_id = [dict objectForKey:@"attribute_id"];
        
        return self;
    }
    return nil;
}

@end
