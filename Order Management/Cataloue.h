//
//  Cataloue.h
//  Order Management
//
//  Created by MAC on 01/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cataloue : NSObject
@property (nonatomic, strong)NSString *CategoryID;
@property (nonatomic, strong)NSString *categoryImg;
-(id)initWithWebDictionary:(NSMutableArray *)_dict;

@end
