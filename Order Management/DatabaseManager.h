//
//  DatabaseManager.h
//  Order Management
//
//  Created by Yoshemite on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sqlite.h"

@interface DatabaseManager : NSObject
@property (nonatomic, strong) Sqlite *objsqlite;

-(id)initwithDBName :(NSString *)databaseName;

-(NSArray *)getCustomerList :(NSString *)Search_Text;
-(NSArray *)getCustomerAddress:(NSString *)CustomerID;
-(NSArray *)GetCountry;
-(NSArray *)GetColuntryName :(NSString *)Code;
-(NSArray *)GetColuntryCode :(NSString *)Name;
-(NSArray *)GetCustGroup;
-(NSArray *)GetGroupID :(NSString *)Name;
-(NSArray *)getCustomer :(NSString *)CustomerID;
-(NSArray *)GetAllRecordPlace :(NSString *)Record_Type :(NSString *)Client_ID;
-(NSArray *)GetParticularOrderList :(NSString *)OrderID;
-(NSArray *)GetCustomerName :(NSString *)Customer_ID;
-(NSArray *)GetAttributeName :(NSArray *)Attribute_Id;
-(NSArray *)GetAttributeDetail :(NSString *)EntityID :(NSString *)Attribute_ID;
-(NSArray *)getUpadtedCustomer;
-(NSArray *)getNewCustomer;
-(NSArray *)GetGroupName :(NSString *)ID;
-(NSArray *)GetGroupPrice :(NSString *)Group_ID;
-(NSArray *)Getlocation;
-(NSArray *)GetActivityLog;
-(NSArray *)GetTaskListDic;
-(NSArray *)GetCategory : (NSString *)level :(NSString *)parentId;
-(NSArray *)GetCustomerDetailBysearch :(NSString *)Search;
-(NSArray *)GetSortOrder :(NSString *)AttributeCode;
-(NSArray *)GetCommentSyncedOrder :(NSString *)Order_ID;
-(NSArray *)GetLanguageList;
//A
-(NSArray *)getselceAgent;
-(NSArray *)GetsalesAgent;
-(NSArray *)GetsalesAgentID :(NSString *)Name;
-(NSArray *)GetMediaGallery  :(NSString *)Entity_ID;
-(NSDictionary *)GetProductLongDetailImage :(NSString *)Product_ID;
-(NSDictionary *)GetDeatilsell :(NSString*)ProductID;
-(NSDictionary *)GetDeatilsellImage :(NSString*)ProductID;
-(void)set_DefaultShaping :(NSString *)custID;
-(void)set_DefaultShapingAddress:(NSString *)addressId;
-(void)set_Defaultbilling :(NSString *)custID;
-(void)set_DefaultbillingAddress:(NSString *)addressId;
-(void)DeleteTask :(NSString *)rowId;
-(void)updateCommentInOrder:(NSString *)comment;
-(void)UpdateTask :(NSString *)Comment :(NSString *)rowId;
-(NSArray *)getProductlistInCurrentOrder;
-(NSArray *)getdefaultCustomerGroup;

@end
