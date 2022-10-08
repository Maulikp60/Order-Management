//
//  Cataloue.m
//  Order Management
//
//  Created by MAC on 01/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "Cataloue.h"

@implementation Cataloue
@synthesize CategoryID,categoryImg;

-(id)initWithWebDictionary:(NSMutableArray *)_dict
{
    self = [super init];
    CategoryID = _dict[0];
    categoryImg = _dict[1];
    return self;
}
@end
