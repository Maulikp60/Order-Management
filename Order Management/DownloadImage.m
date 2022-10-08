//
//  DownloadImage.m
//  Order Management
//
//  Created by MAC on 31/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "DownloadImage.h"
#import "DBManager.h"
//http://csvihara.ddns.net/shop/media/catalog/category/plp-w-newarrivals_1.jpg
@implementation DownloadImage
{
    DBManager *dbManager;
    NSMutableArray *arr_AllImage,*arr_DownloadedImage,*arr_RemainImage,*arr_AllImageName,*arr_AllCategoryImage,*arr_DownloadCategoryImage,*arr_RemainCategoryImage;
}
-(void)DownloadBackgroundImage{
    [self DownloadCategoryImage];
    
}
-(void)DownloadCategoryImage{
    
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    // Here  Get All imaage name from Local Database
    NSMutableArray *arr_Result = [[[NSArray alloc] initWithArray:[dbManager GetAllCategoryImage]]mutableCopy];
    arr_AllCategoryImage  = [[NSMutableArray alloc]init];
    for (int i = 0; i <arr_Result.count; i++) {
        [arr_AllCategoryImage addObject:[[arr_Result objectAtIndex:i] objectAtIndex:0]];
    }
    //Here Get Path of local or document Directry in ios
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Get All file from local document Directory
    arr_DownloadCategoryImage = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil] mutableCopy];
    //Remove .sqllite file from all file
    [arr_DownloadCategoryImage removeObject:@"Order Management System.sqlite"];
    
    //    NSLog(@"files array %@", arr_DownloadedImage);
    //Compare Database image and download image
    NSMutableSet* set1 = [NSMutableSet setWithArray:arr_AllCategoryImage];
    NSMutableSet* set2 = [NSMutableSet setWithArray:arr_DownloadCategoryImage];
    //this will give you only the obejcts that are in both sets
    [set1 minusSet:set2];
    NSMutableArray* result = [[set1 allObjects] mutableCopy];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:@"None" forKey:@"Download_Type"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (result.count > 0) {
            for (int i = 0; i <result.count; i++) {
                [userdefault setObject:@"CategoryImage" forKey:@"Download_Type"];
                //Download Background image
                NSString *ImagePath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,[result objectAtIndex:i]];
                NSData *data = [NSData dataWithContentsOfURL :[NSURL URLWithString:[NSString stringWithFormat:@"%@/media/catalog/category/%@",[userdefault objectForKey:@"StoreURL"],[result objectAtIndex:i]]]];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[result objectAtIndex:i]];
                [data writeToFile:filePath atomically:YES];
                //                NSLog(@"%@",ImagePath);
            }
            [self DownloadProductImage];
        }else{
            [self DownloadProductImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI
        });
    });
    
}
-(void)DownloadProductImage{
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    // Here  Get All imaage name from Local Database
    arr_AllImage  = [[[NSArray alloc] initWithArray:[dbManager GetAllImage]]mutableCopy];
    [arr_AllImage addObjectsFromArray:[[[NSArray alloc] initWithArray:[dbManager GetAllMedia]]mutableCopy]];
    arr_AllImageName = [[NSMutableArray alloc]init];
    for (int i = 0; i < arr_AllImage.count; i++) {
        //Change Image name from Special chater replcae '/' to '!'
        [arr_AllImageName addObject:[[[arr_AllImage objectAtIndex:i]objectAtIndex:0] stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
    }
    //Here Get Path of local or document Directry in ios
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Get All file from local document Directory
    arr_DownloadedImage = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil] mutableCopy];
    //Remove .sqllite file from all file
    [arr_DownloadedImage removeObject:@"Order Management System.sqlite"];
    
    //    NSLog(@"files array %@", arr_DownloadedImage);
    //Compare Database image and download image
    NSMutableSet* set1 = [NSMutableSet setWithArray:arr_AllImageName];
    NSMutableSet* set2 = [NSMutableSet setWithArray:arr_DownloadedImage];
    //this will give you only the obejcts that are in both sets
    [set1 minusSet:set2];
    NSMutableArray* result = [[set1 allObjects] mutableCopy];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (result.count > 0) {
            for (int i = 0; i <result.count; i++) {
                [userdefault setObject:@"ProductImage" forKey:@"Download_Type"];
                //Download Background image
                NSString *ImagePath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,[result objectAtIndex:i]];
                NSString *fileName = [result objectAtIndex:i];
                fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"!"];
                //                NSLog(@"%@",[NSString stringWithFormat:@"%@/media/catalog/product%@",[userdefault objectForKey:@"StoreURL"],[[result objectAtIndex:i]stringByReplacingOccurrencesOfString:@"!" withString:@"/"]]);
                
                NSData *data = [NSData dataWithContentsOfURL :[NSURL URLWithString:[NSString stringWithFormat:@"%@/media/catalog/product%@",[userdefault objectForKey:@"StoreURL"],[[result objectAtIndex:i]stringByReplacingOccurrencesOfString:@"!" withString:@"/"]]]];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                [data writeToFile:filePath atomically:YES];
                //                NSLog(@"%@",ImagePath);
                if (i+1 == result.count) {
                    [userdefault setObject:@"None" forKey:@"Download_Type"];
                }
            }
        }else{
            [userdefault setObject:@"None" forKey:@"Download_Type"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI
        });
    });
}
-(void)insertalldata{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr_RemainQuery = [[NSMutableArray alloc] init];
    [userDefault setObject:arr_RemainQuery forKey:@"arr_RemainQuery"];
    
//    NSData *CustomerData = [userDefault objectForKey:@"CustomerInformation"];
//    NSDictionary *customer_dic = [NSKeyedUnarchiver unarchiveObjectWithData:CustomerData];
//    [self DownloadCustomer:customer_dic];
    
//        NSData *OrderData = [userDefault objectForKey:@"OrderInformation"];
//        NSDictionary *order_dic = [NSKeyedUnarchiver unarchiveObjectWithData:OrderData];
//        [self DownloadOrder:order_dic];
//
    NSData *productData = [userDefault objectForKey:@"ProductInformation"];
    NSDictionary *product_dic = [NSKeyedUnarchiver unarchiveObjectWithData:productData];
    [self DownloadProduct:product_dic];
}
-(void)DownloadCustomer :(NSDictionary *)json{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *CustomerArray= [json allKeys];
    for (int i =0 ; i <CustomerArray.count; i ++) {
        NSLog(@"customer insert %d of %lu",i,(unsigned long)CustomerArray.count);
        NSString *strCustomerID;
        strCustomerID =[CustomerArray objectAtIndex:i];
        NSDictionary *dict = [json valueForKey:[CustomerArray objectAtIndex:i]];
        NSMutableDictionary *DictionaryCustomer = [dict mutableCopy];
        [dbManager InsertCustomerMasterFirstsync:@"Customer_Master" :DictionaryCustomer :@"false" :@"false" :strCustomerID];
        if (i+1 == CustomerArray.count) {
            NSData *productData = [userDefault objectForKey:@"ProductInformation"];
            NSDictionary *product_dic = [NSKeyedUnarchiver unarchiveObjectWithData:productData];
            [self DownloadProduct:product_dic];
        }
    }
}
-(void)DownloadProduct :(NSDictionary *)json{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *ProductArray= [json allKeys];
        for (int i =0 ; i <ProductArray.count; i ++) {
            NSLog(@"prdocut no%d",i);
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            NSDictionary *dic = [json valueForKey:[ProductArray objectAtIndex:i]];
            NSString *message = [NSString stringWithFormat:@"creating %d / %lu products",i+1,(unsigned long)ProductArray.count];
            [userDefault setObject: [dbManager GetValue:[userDefault objectForKey:@"Language"] :message] forKey:@"Download_Product"];
            
            //            [userDefault setObject:message forKey:@"Download_Product"];
            [dbManager InsertProduct:@"Product_Master":dic];
            if (i+1 == ProductArray.count) {
                [userDefault setObject:@"1" forKey:@"Product"];
               
                NSData *OrderData = [userDefault objectForKey:@"OrderInformation"];
                NSDictionary *order_dic = [NSKeyedUnarchiver unarchiveObjectWithData:OrderData];
                [self DownloadOrder:order_dic];
            }
        }
    });
}

-(void)DownloadOrder :(NSDictionary *)json{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *OrderArray= [json allKeys];
        if (OrderArray.count == 0) {
            [userDefault setObject:@"" forKey:@"Download_Product"];
            [userDefault setBool:false forKey:@"completefirstsync"];
        }
        for (int i =0 ; i <OrderArray.count; i ++) {
            NSLog(@"order no%d",i);
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            NSDictionary *dic = [json valueForKey:[OrderArray objectAtIndex:i]];
            NSString *message = [NSString stringWithFormat:@"creating %d / %lu orders",i+1,(unsigned long)OrderArray.count];
            [userDefault setObject: [dbManager GetValue:[userDefault objectForKey:@"Language"] :message] forKey:@"Download_Product"];
            [dbManager InsertSyncedOrder:@"Order_Master":dic];
            if (i+1 == OrderArray.count) {
                [userDefault setObject:@"" forKey:@"Download_Product"];
                [userDefault setBool:false forKey:@"completefirstsync"];
//                NSData *productData = [userDefault objectForKey:@"ProductInformation"];
//                NSDictionary *product_dic = [NSKeyedUnarchiver unarchiveObjectWithData:productData];
//                [self DownloadProduct:product_dic];
            }
        }
    });
    
}


@end