//
//  ArrayToDicConvert.h
//  Order Management
//
//  Created by MAC on 02/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayToDicConvert : NSObject
-(NSMutableArray *)ProductShortDetail : (NSMutableArray *)ProductArray;
-(NSDictionary *)ProductLongDetail: (NSMutableArray *)ProductArray;
@end
