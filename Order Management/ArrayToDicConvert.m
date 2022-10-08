//
//  ArrayToDicConvert.m
//  Order Management
//
//  Created by MAC on 02/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "ArrayToDicConvert.h"

@implementation ArrayToDicConvert
-(NSArray *)ProductShortDetail : (NSArray *)ProductArray{
    NSMutableArray *arr_id = [[NSMutableArray alloc] init];
    NSMutableArray *arr_Product = [[NSMutableArray alloc] init];
    for (int i = 0; i < ProductArray.count; i++) {
        if ([arr_id containsObject:[[ProductArray objectAtIndex:i]objectAtIndex:0]]) {
            NSMutableDictionary *dic = [arr_Product lastObject];
            [dic setObject:[[ProductArray objectAtIndex:i]objectAtIndex:2] forKey:[[ProductArray objectAtIndex:i]objectAtIndex:1]];
            [arr_Product removeLastObject];
            [arr_Product addObject:dic];
            
        }else{
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[ProductArray objectAtIndex:i] objectAtIndex:0], @"entity_id", nil];
            [dictionary setObject:[[ProductArray objectAtIndex:i]objectAtIndex:2] forKey:[[ProductArray objectAtIndex:i]objectAtIndex:1]];
            [arr_id addObject:[[ProductArray objectAtIndex:i] objectAtIndex:0]];
            [arr_Product addObject:dictionary];
        }
    }
    return arr_Product;
}
-(NSDictionary *)ProductLongDetail: (NSMutableArray *)ProductArray{
    NSMutableDictionary *MainDic = [[NSMutableDictionary alloc]init];
    for (int i =  0; i < ProductArray.count; i++) {
        NSDictionary *SubDic = [[NSMutableDictionary alloc]init];
        [SubDic setValue:ProductArray[i][2] forKey:@"value_id"];
        [SubDic setValue:ProductArray[i][3] forKey:@"value"];
        [MainDic setValue:SubDic forKey:ProductArray[i][1]];
    }
    return MainDic;
}
@end
