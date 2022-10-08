//
//  DownloadImage.h
//  Order Management
//
//  Created by MAC on 31/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadImage : NSObject
-(void)DownloadBackgroundImage;
-(void)insertalldata;
-(void)DownloadProduct :(NSDictionary *)json;
-(void)DownloadOrder :(NSDictionary *)json;
-(void)DownloadCustomer :(NSDictionary *)json;

@end
