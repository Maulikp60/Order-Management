//
//  Attribute.h
//  Order Management
//
//  Created by MAC on 30/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attribute : NSObject

@property NSString *attributeA_id;
-(id)initWithWebDict:(NSDictionary *)dict;
@end
