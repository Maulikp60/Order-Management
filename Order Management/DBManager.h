//
//  DBManager.h
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DBManager : NSObject<CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;



-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(void)executeQuery:(NSString *)Tablename;

-(void)CreateProductMaster:(NSString *)Tablename;
-(void)CreateCategoryMaster:(NSString *)Tablename;
-(void)CreateCustomerMaster:(NSString *)Tablename;
-(void)CreateCustomerAddress:(NSString *)Tablename;
-(void)CreateCountry:(NSString *)Tablename;
-(void)CreateCustGroups:(NSString *)Tablename;
-(void)CreateAttributeMaster :(NSString *)Tablename;

-(void)InsertCustomerMaster :(NSString *)Tablename :(NSDictionary *)CustomerDic : (NSString *)newdata :(NSString *)Update;
-(void)InsertCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update;
-(void)InsertTempCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update;
-(void)InsertAttributes :(NSString *)Tablename :(NSDictionary *)AttributeDic;
-(void)InsertProduct :(NSString *)Tablename :(NSDictionary *)ProductsDic;
-(void)InsertCategory :(NSString *)Tablename :(NSDictionary *)CategoryDic;
-(void)InsertSyncedOrder :(NSString *)Tablename :(NSDictionary *)OrderDic;
-(void)InsertTask :(NSString *)TaskDescription;
-(void)InsertOrder : (NSMutableArray *)ArrOrder :(NSString *)Status :(NSString *)Comment :(NSString *)SuperAttributeID :(NSString *)Parent_ID :(NSString *)Base_Price :(NSString *)Grand_Total;
-(void)InsertCountry :(NSString *)Tablename :(NSDictionary *)CountryArray;
-(void)InsertCustGroups :(NSString *)Tablename :(NSMutableArray *)CustGroupsArray;
-(void)InsertActivityLog :(NSString *)Date :(NSString *)Name;
-(void)InsertSalesAgent :(NSDictionary *)SalesDic;
-(void)InsertLanguage :(NSString *)Language :(NSString *)Key :(NSString *)Value;

-(void)DeleteOrder;
-(void)DeleteCountry;
-(void)DeleteGroup;
//-(void)DeleteRecord : (NSMutableArray *)DeleteDic;
-(void)DeleteRecord : (id)jsonParse;
-(void)Delete_Local_Update_Customer;
-(void)Delete_Local_Add_NewCustomer :(NSString *)CustID;
-(void)Delete_Local_Add_NewCustomer;
-(void)Delete_Local_Add_CustomerAddress:(NSString *)CustID;
-(void)Delete_Local_Add_NewCustomerAddress:(NSString *)CustID;
-(void)Delete_Customer_Group;
-(void)Delete_Customer:(NSString *)CustID;
-(void)ClearAttribute_Master;
-(void)ClearCategory_Master;
-(void)ClearCountry;
-(void)ClearCustGroups;
-(void)ClearCustomerAddress;
-(void)ClearCustomer_Master;
-(void)ClearMediaGallery_Master;
-(void)ClearOrder_Master;
-(void)ClearPrice_Master;
-(void)ClearLanguageMaster;
-(void)ClearProduct_Attribute_Master;
-(void)ClearProduct_Master;
-(void)ClearStore_Master;
-(void)ClearTaskList;
-(void)ClearWebsite_Master;
-(void)Delete_Local_Update_NewCustomer :(NSString *)CustID;
-(void)ClearActivitylog;
-(void)clearSalesAgent;
-(void)Update_Task :(NSString *)row_Id :(NSString *)Status;
-(void)Update_Product : (NSString *)ProductID : (NSString *)Quantity : (NSString *)Status :(NSString *)Comment;
-(void)UpdateOrderID :(NSString *)Order_ID_Old :(NSString *)Order_Id_New :(NSString *)Grand_Total;
-(void)UpdateCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update;
-(void)UpdateCustomerId :(NSString *)OldCustomerID :(NSString *)NewCustomerId;
-(void)SavedOrder :(NSString *)Status;
-(void)DeleteNull;
-(void)QueryExecute :(NSString *)Query;
-(void)InsertCustomerMasterFirstsync :(NSString *)Tablename :(NSDictionary *)CustomerDic : (NSString *)new :(NSString *)Update :(NSString *)strCustomerID1;

-(BOOL)CheckOrderStatus;
-(BOOL)isNewCustomerCreatedInOffline;
-(BOOL)isUpdateCustomerCreatedInOffline;
-(BOOL)CheckEmailStatus :(NSString *)Email;
-(BOOL)CheckVisibleproduct :(NSString *)ProductId;
-(BOOL)CheckAddressExit :(NSString *)AddressId;//
-(BOOL)CheckEditCustomerEmailStatus :(NSString *)Email : (NSString *)Cust_id;//
-(void)Delete_Local_Update_CustomerAddress :(NSString *)CustID;//

-(NSString *)GetValue :(NSString *)Language :(NSString *)Key;
-(NSString *)GetSuperLevel :(NSString *)Product_ID;
-(NSString *)GetSuperLevelName :(NSString *)Product_ID;
-(NSString *)GetStatusFromOrder :(NSString *)Order_Id;
-(NSString *)GetCommentFromOrder :(NSString *)Order_Id;
-(NSString *)GetAllOrderRecord :(NSString *)Prodcut_Id;
-(NSString *)GetMaxOrderID;
-(NSString *)GetAttributeID :(NSString *)Product_Id;
-(NSString *)GetAssociatedProduct :(NSString *)Product_Id;
-(NSString *)GetCrosssellProduct :(NSString *)Product_Id;
-(NSString *)GetMaxLevel;
-(NSString *)Get_Last_CustomerID;
-(NSString *)Get_Last_AddressID;
-(NSString *)GetCustomerGroup :(NSString *)ClientID;
-(NSString *)GetPrice : (NSString *)EntityID :(NSString *)GroupId;
-(NSString *)GetcustomerId : (NSString *)Order_ID;
-(NSString *)GetQuantity : (NSString *)Order_ID;
-(NSString *)GetCustomerName : (NSString *)CustomerID;
-(NSString *)GetAttributeIDFromOrder: (NSString *)Order_ID;
-(NSString *)GetSalesName : (NSString *)GetSalesID;
-(NSString *)GetCode :(NSString *)Attribute;
-(NSString *)GetDefaultbilling :(NSString *)CustomerID;
-(NSString *)GetDefaultshipping :(NSString *)CustomerID;
-(NSString *)GetGrandTotal :(NSString *)OrderId;
-(NSArray *)GetDetailofCrossSellProduct :(NSString *)ProductID;
-(NSArray *)GetCartFromOrder :(NSString *)Order_ID;
-(NSArray *)GetTaskList;
-(NSArray *)GetCategory : (NSString *)level :(NSString *)parentId;
-(NSArray *)GetProductShortDetailSearch :(NSString *)Search;
-(NSArray *)GetSideMenuCategory;
-(NSArray *)GetAllImage;
-(NSArray *)GetAllMedia;
-(NSArray *)GetAllCategoryImage;
-(NSArray *)GetProductShortDetail :(NSString *)Cat_ID;
-(NSArray *)GetProductLongDetail :(NSString *)Product_ID;
-(NSArray *)GetCartFromOrder;
-(NSArray *)GetCustomersID_Master;
-(NSArray *)GetEntityID_CustomerAddress;
-(NSArray *)Getlocation;

@end