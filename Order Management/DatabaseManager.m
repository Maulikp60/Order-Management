//
//  DatabaseManager.m
//  Order Management
//
//  Created by Yoshemite on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager
-(id)initwithDBName :(NSString *)databaseName
{
    //    if (self = [super init]){
    id _self = [super init];
    NSString *path = [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *orignalpath = [NSHomeDirectory() stringByAppendingString:@"/Documents/Order Management System.sqlite"];
    if ([filemanager fileExistsAtPath:orignalpath] == NO) {
        [filemanager copyItemAtPath:path toPath:orignalpath error:nil];
    }
    else{
    }
    _objsqlite = [[Sqlite alloc]init];
    if ([_objsqlite open:orignalpath] == true) {
        NSLog(@"DB Open");
    }
    else{
        NSLog(@"error");
    }
    
    return _self;
}
-(void)DeleteTask :(NSString *)rowId{
    NSString *query = [NSString stringWithFormat:@"delete from TaskList WHERE rowid = '%@'",rowId];
    [_objsqlite executeNonQuery:query];
}
-(void)updateCommentInOrder:(NSString *)comment{
    comment = [comment stringByReplacingOccurrencesOfString:@"'" withString:@"!!"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query = [NSString stringWithFormat:@"UPDATE Order_Master SET Comment = '%@' WHERE Order_Id = '%@'",comment,[userDefault objectForKey:@"Order_Id"]];
    [_objsqlite executeNonQuery:query];
}
-(NSDictionary *)GetProductLongDetailImage :(NSString *)Product_ID{
    
    NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT entity_id,attribute_code ,value_id FROM Product_Attribute_Master where (attribute_code  = 'image') and entity_id = '%@'",Product_ID];
    NSArray *arrCustomers = [_objsqlite executeQuery:query_ShortProductDetail];
    return [arrCustomers objectAtIndex:0];
}
-(NSDictionary *)GetDeatilsell :(NSString*)ProductID{
   NSString *query_GetMaxOrderId = [NSString stringWithFormat:@"SELECT value_id FROM Product_Attribute_Master where entity_id ='%@' and  attribute_code = 'name'",ProductID];
    NSArray *arrCustomers = [_objsqlite executeQuery:query_GetMaxOrderId];
    return [arrCustomers objectAtIndex:0];
}

#pragma mark - Get Detail of cross sell product
-(NSDictionary *)GetDeatilsellImage :(NSString*)ProductID{
    NSString *query_GetMaxOrderId = [NSString stringWithFormat:@"SELECT value_id FROM Product_Attribute_Master where entity_id ='%@' and  attribute_code = 'small_image'",ProductID];
    NSArray *arrCustomers = [_objsqlite executeQuery:query_GetMaxOrderId];
    if (arrCustomers.count > 0) {
        return [arrCustomers objectAtIndex:0];
    }else{
        NSDictionary *dic;
        return dic;
    }
}

#pragma mark - Update Task
-(void)UpdateTask :(NSString *)Comment :(NSString *)rowId{
    NSString *query = [NSString stringWithFormat:@"UPDATE TaskList SET TaskName = '%@' WHERE rowid = '%@'",Comment,rowId];
    [_objsqlite executeNonQuery:query];
}
#pragma mark - Get All Task
-(NSArray *)GetTaskListDic{
    NSString *query_GetTaskList = [NSString stringWithFormat:@"SELECT rowid,* From TaskList"];
    NSArray *arrTaskList = [_objsqlite executeQuery:query_GetTaskList];
    return arrTaskList;
}
#pragma mark - Get Category From Parent Id
-(NSArray *)GetCategory : (NSString *)level :(NSString *)parentId{
    NSString *query_Category;
    if ([level  isEqual: @"2"]) {
        query_Category = [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master where level = '%@' and  is_active = '1' ",level];
    }else{
        query_Category= [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master where level = '%@' and parent_id = '%@' and is_active = '1' ",level,parentId];
    }
    return (NSArray *)[_objsqlite executeQuery:query_Category];
}

#pragma mark - Get product list in current order
-(NSArray *)getProductlistInCurrentOrder{
    //NSString *query = @"SELECT * From Customer_Master ORDER BY firstname  COLLATE NOCASE";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query = [NSString stringWithFormat:@"SELECT Product_Id,Quantity,Parent_ID FROM Order_Master where Quantity != 0 and Order_Id = '%@'",[userDefault objectForKey:@"Order_Id"]];
    NSArray *arrCustomers = [_objsqlite executeQuery:query];
    return arrCustomers;
}
#pragma mark - Get Customer list
-(NSArray *)getCustomerList :(NSString *)Search_Text{
    [self DeleteDummyCustomer];
    //NSString *query = @"SELECT * From Customer_Master ORDER BY firstname  COLLATE NOCASE";
    NSString *query = [NSString stringWithFormat:@"SELECT * From Customer_Master  where firstname like '%%%@%%' ORDER BY firstname  COLLATE NOCASE",Search_Text];
    NSArray *arrCustomers = [_objsqlite executeQuery:query];
    return arrCustomers;
}

#pragma mark - Delete Customer with null email
-(void)DeleteDummyCustomer{
    NSString *query = [NSString stringWithFormat:@"delete  FROM Customer_Master where email = '(null)'"];
    [_objsqlite executeNonQuery:query];
}

#pragma mark - Get Customer Detail From Custmor Id
-(NSArray *)getCustomer :(NSString *)CustomerID{
    NSString *query = [NSString stringWithFormat:@"SELECT * From Customer_Master where Customer_id = '%@'",CustomerID];
    NSArray *Customers = [_objsqlite executeQuery:query];
    return Customers;
}

#pragma mark - Get All Country
-(NSArray *)GetCountry{
    NSString *query = @"SELECT * From Country order by name";
    NSArray *arrCountry = [_objsqlite executeQuery:query];
    return arrCountry;
}

#pragma mark Get Coustmern Address From Customer ID
-(NSArray *)getCustomerAddress:(NSString *)CustomerID{
    NSString *query_Customer_Address = [NSString stringWithFormat:@"SELECT attribute_set_id,city,company,country,created_at,customer_id,default_billing,default_shipping,entity_id,entity_type_id,fax,firstname,increment_id,is_active,lastname,middlename,parent_id,postcode,region,street,telephone,updated_at FROM CustomerAddress where parent_id = '%@'",CustomerID];
    NSArray *arrCustomersAddress = [_objsqlite executeQuery:query_Customer_Address];
    // NSLog(@"Address List %@",arrCustomersAddress);
    return arrCustomersAddress;
}

#pragma mark GetCountryName
-(NSArray *)GetColuntryName :(NSString *)Code{
    NSString *query = [NSString stringWithFormat:@"SELECT name FROM country where code = '%@'",Code];
    NSArray *country = [_objsqlite executeQuery:query];
    return country;
}
#pragma mark - Get Media Gallery
-(NSArray *)GetMediaGallery  :(NSString *)Entity_ID{
    NSString *query = [NSString stringWithFormat:@"SELECT FILE,POSITION FROM MediaGallery_Master where entity_id = '%@'",Entity_ID];
    NSArray *country = [_objsqlite executeQuery:query];
    return country;
}

#pragma MARK   - Get Activity Log
-(NSArray *)GetActivityLog{
    NSString *query = [NSString stringWithFormat:@"select rowid,* from Activitylog_Master ORDER BY rowid desc"];
    NSArray *country = [_objsqlite executeQuery:query];
    return country;
}

#pragma mark GetCustomerDetailBysearch
-(NSArray *)GetCustomerDetailBysearch :(NSString *)Search{
    NSString *query = [NSString stringWithFormat:@"SELECT * from Customer_Master where firstname like '%%%@%%'",Search];
    NSArray *customer = [_objsqlite executeQuery:query];
    return customer;
}

#pragma mark GetAllRecordPlace
-(NSArray *)GetAllRecordPlace :(NSString *)Record_Type :(NSString *)Client_ID{
    if ([Client_ID  isEqual: @"0"]) {
        if ([Record_Type  isEqual: @"GetSyncedRecord"]) {
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname || ' ' || Customer_master.lastname as firstname ,om.Grand_Total Price  FROM Order_master om inner join customer_master on om.customer_id = customer_master.customer_id where om.Status != 'Cart' and om.Status != 'Saved' and om.Status != 'Not Sync' GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc"];
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        }else if ([Record_Type  isEqual: @"All"]) {
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname || ' ' || Customer_master.lastname as firstname,SUM((SELECT pa.value_id * om.Quantity FROM Product_Attribute_Master pa  WHERE pa.entity_id = om.Product_id AND pa.attribute_code = 'price'))Price FROM Order_master om left join customer_master on om.customer_id = customer_master.customer_id where om.Status = 'Saved' or om.Status = 'Not Sync'  GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc"];
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        }else if ([Record_Type  isEqual: @"AllPlaceOrder"]) {
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname || ' ' || Customer_master.lastname as firstname,SUM((SELECT pa.value_id * om.Quantity FROM Product_Attribute_Master pa  WHERE pa.entity_id = om.Product_id AND pa.attribute_code = 'price'))Price FROM Order_master om left join customer_master on om.customer_id = customer_master.customer_id where om.Status = 'Not Sync' GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc"];// or om.Status = 'Saved'
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        } else{
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname || ' ' || Customer_master.lastname as firstname,SUM((SELECT pa.value_id * om.Quantity FROM Product_Attribute_Master pa  WHERE pa.entity_id = om.Product_id AND pa.attribute_code = 'price'))Price FROM Order_master om left join customer_master on om.customer_id = customer_master.customer_id where om.Status = '%@'GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc",Record_Type];
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        }
        
    }else{
        if ([Record_Type  isEqual: @"GetSyncedRecord"]) {
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname,om.Grand_Total Price  FROM Order_master om inner join customer_master on om.customer_id = customer_master.customer_id where (om.Status != 'Cart' and om.Status != 'Saved' and om.Status != 'Not Sync') and om.Customer_Id = '%@' GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc",Client_ID];
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        }else{
            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname ,SUM((SELECT pa.value_id * om.Quantity FROM Product_Attribute_Master pa  WHERE pa.entity_id = om.Product_id AND pa.attribute_code = 'price'))Price FROM Order_master om left join customer_master on om.customer_id = customer_master.customer_id where (om.Status = 'Saved' or om.Status = 'Not Sync') and om.Customer_Id = '%@' GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc",Client_ID];
            //            NSString *query_GetAllrecord = [NSString stringWithFormat:@"SELECT om.Order_Id, om.Customer_id , MIN(om.Order_Date) Order_Date,MIN(om.Grand_Total) Grand_Total,MIN(om.Status) Status,Customer_master.firstname ,SUM((SELECT pa.value_id * om.Quantity FROM Product_Attribute_Master pa  WHERE pa.entity_id = om.Product_id AND pa.attribute_code = 'price'))Price FROM Order_master om left join customer_master on om.customer_id = customer_master.customer_id where om.Status = 'Saved' or om.Status = 'Not Sync' and om.Customer_Id = '%@' GROUP BY om.Order_id, om.Customer_id order by om.Order_Id desc",Client_ID];
            NSArray *country = [_objsqlite executeQuery:query_GetAllrecord];
            return country;
        }
    }
}

#pragma mark -Get All location
-(NSArray *)Getlocation{
    NSString *query_GetAllrecordOfOrderID = [NSString stringWithFormat:@"SELECT * FROM Customer_Master where latitude != '0' and longitude != '0'"];
    NSArray *GetAllProduct = [_objsqlite executeQuery:query_GetAllrecordOfOrderID];
    return GetAllProduct;
}
#pragma mark Get Productlist From Order Id
-(NSArray *)GetParticularOrderList :(NSString *)OrderID{
    NSString *query_GetAllrecordOfOrderID = [NSString stringWithFormat:@"SELECT Product_Id as product,Quantity as qty,Attribute_Id,Parent_ID,Base_Price from Order_Master where Order_Id = '%@' and Quantity != 0",OrderID];
    NSArray *GetAllProduct = [_objsqlite executeQuery:query_GetAllrecordOfOrderID];
    return GetAllProduct;
}

#pragma mark Get Customer Group
-(NSArray *)GetCustGroup{
    NSString *query = @"SELECT * From CustGroups";
    NSArray *arrCustGroup = [_objsqlite executeQuery:query];
    return arrCustGroup;
}

#pragma mark Get SalesAgent
-(NSArray *)GetsalesAgent{
    NSString *query = @"SELECT * From Sales_AgentMaster GROUP BY email";
    NSArray *arrsalesAgent = [_objsqlite executeQuery:query];
    return arrsalesAgent;
}

#pragma mark getselceAgent
-(NSArray *)getselceAgent{
    
    NSString *query_GetTaskList = [NSString stringWithFormat:@"SELECT firstname FROM Sales_AgentMaster where rowid = '1'"];
    NSArray *arrTaskList = [_objsqlite executeQuery:query_GetTaskList];
    return arrTaskList;
}

#pragma mark getselceAgent
-(NSArray *)getdefaultCustomerGroup{
    NSString *query_GetTaskList = [NSString stringWithFormat:@"SELECT customer_group_code FROM CustGroups where rowid = '1'"];
    NSArray *arrTaskList = [_objsqlite executeQuery:query_GetTaskList];
    return arrTaskList;
}
#pragma mark Get SalesAgent_ID
-(NSArray *)GetsalesAgentID :(NSString *)Name{
    NSString *query = [NSString stringWithFormat:@"SELECT user_id FROM Sales_AgentMaster where firstname = '%@'",Name];
    NSArray *salesagentid = [_objsqlite executeQuery:query];
    return salesagentid;
}
#pragma mark Get Country Code
-(NSArray *)GetColuntryCode :(NSString *)Name{
    NSString *query = [NSString stringWithFormat:@"SELECT code FROM country where name = '%@'",Name];
    NSArray *countryCode = [_objsqlite executeQuery:query];
    return countryCode;
}
#pragma mark Get Group ID
-(NSArray *)GetGroupID :(NSString *)Name{
    NSString *query = [NSString stringWithFormat:@"SELECT customer_group_id FROM CustGroups where customer_group_code = '%@'",Name];
    NSArray *groupID = [_objsqlite executeQuery:query];
    return groupID;
}

#pragma mark Get Customer Name from CustomerID
-(NSArray *)GetCustomerName :(NSString *)Customer_ID{
    NSString *query = [NSString stringWithFormat:@"SELECT firstname,lastname FROM Customer_Master where Customer_id = '%@'",Customer_ID];
    NSArray *customer_Detail = [_objsqlite executeQuery:query];
    return customer_Detail;
}

#pragma mark Get Attribute Name from Attribute ID
-(NSArray *)GetAttributeName :(NSArray *)Attribute_Id{
    NSMutableArray *arr_AttributeName = [[NSMutableArray alloc]init];
    for (int i = 0; i< Attribute_Id.count; i++) {
        NSString *query = [NSString stringWithFormat:@"SELECT attribute_code FROM Attribute_Master where attribute_id = '%@' limit 1",Attribute_Id[i]];
        NSArray *groupID = [_objsqlite executeQuery:query];
        [arr_AttributeName  addObject:[groupID[0] objectForKey:@"attribute_code"]];
    }
    return arr_AttributeName;
}

-(NSArray *)GetAttributeDetail :(NSString *)EntityID :(NSString *)Attribute_ID{
    NSString *query = [NSString stringWithFormat:@"select * from Product_Attribute_Master where attribute_code like (select attribute_code from  Attribute_Master where attribute_id = '%@' ) and entity_id = '%@' ",Attribute_ID,EntityID];
    NSArray *customer_Detail = [_objsqlite executeQuery:query];
    return customer_Detail;
}
#pragma mark GetGroupName
-(NSArray *)GetGroupName :(NSString *)ID
{
    NSString *query_Get_Customer_GroupName = [NSString stringWithFormat:@"SELECT customer_group_code FROM CustGroups where customer_group_id = '%@'",ID];
    NSArray *groupName = [_objsqlite executeQuery:query_Get_Customer_GroupName];
    return groupName;
}
#pragma mark UpdatedCustomer
-(NSArray *)getUpadtedCustomer
{
    NSString *query_Updated_Customer = [NSString stringWithFormat:@"SELECT * From Customer_Master where isUpdate = 'true'"];
    NSArray *arrUpdateCustomers = [_objsqlite executeQuery:query_Updated_Customer];
    // NSLog(@"Address List %@",arrCustomersAddress);
    return arrUpdateCustomers;
}

#pragma mark GetNewCustomer
-(NSArray *)getNewCustomer
{
    NSString *query_Updated_Customer = [NSString stringWithFormat:@"SELECT * From Customer_Master where isNew = 'true'"];
    NSArray *arrUpdateCustomers = [_objsqlite executeQuery:query_Updated_Customer];
    // NSLog(@"Address List %@",arrCustomersAddress);
    return arrUpdateCustomers;
}

#pragma mark Get Group Price
-(NSArray *)GetGroupPrice :(NSString *)Group_ID{
    NSString *query_Updated_Customer = [NSString stringWithFormat:@"select entity_id,price from Price_Master where cust_group = '%@'",Group_ID];
    NSArray *arrUpdateCustomers = [_objsqlite executeQuery:query_Updated_Customer];
    // NSLog(@"Address List %@",arrCustomersAddress);
    return arrUpdateCustomers;
}

#pragma  mark set 1 selected shippingAddress
-(void)set_DefaultShapingAddress:(NSString *)addressId
{
    NSString *querySetUnselected = [NSString stringWithFormat:@"update CustomerAddress SET  default_shipping = '1' WHERE entity_id='%@'",addressId];
    [_objsqlite executeNonQuery:querySetUnselected];
}
#pragma  mark set 0 selected shippingAddress
-(void)set_DefaultShaping:(NSString *)addressId
{
    NSString *querySetUnselected = [NSString stringWithFormat:@"update CustomerAddress SET  default_shipping = '0' WHERE entity_id='%@'",addressId];
    [_objsqlite executeNonQuery:querySetUnselected];
}


#pragma mark - Update Default Billing Adress
-(void)set_Defaultbilling :(NSString *)custID
{
    NSString *querySetUnselected = [NSString stringWithFormat:@"update CustomerAddress SET  default_billing = '0' WHERE customer_id='%@'",custID ];
    [_objsqlite executeNonQuery:querySetUnselected];
}

#pragma mark - Update Default Billing Adress
-(void)set_DefaultbillingAddress:(NSString *)addressId
{
    NSString *querySetUnselected = [NSString stringWithFormat:@"update CustomerAddress SET  default_billing = '1' WHERE entity_id='%@'",addressId];
    [_objsqlite executeNonQuery:querySetUnselected];
}

#pragma mark - Get Attribute sorting wise
-(NSArray *)GetSortOrder :(NSString *)AttributeCode{
    NSString *query_GetSortOrder = [NSString stringWithFormat:@"SELECT  * FROM AttributeOption_Master WHERE attribute_id = (SELECT  attribute_id FROM Attribute_Master WHERE attribute_code = '%@') ORDER BY cast (sort_order AS INTEGER)",AttributeCode];
    NSArray *arrGetsorting = [_objsqlite executeQuery:query_GetSortOrder];
    return arrGetsorting;
}

#pragma mark - GetComment List
-(NSArray *)GetCommentSyncedOrder :(NSString *)Order_ID{
    NSString *query_GetSortOrder = [NSString stringWithFormat:@"select * from Comment_Master where Order_Id = '%@' and comment != '<null>' and (is_customer_notified != '0' or is_visible_on_front != '0') order by created_at  desc",Order_ID];
    NSArray *arrGetsorting = [_objsqlite executeQuery:query_GetSortOrder];
    return arrGetsorting;
}

#pragma mark - Get All Language list
-(NSArray *)GetLanguageList{
    NSString *query_GetSortOrder = [NSString stringWithFormat:@"SELECT DISTINCT Language FROM Language_Master"];
    NSArray *arrGetsorting = [_objsqlite executeQuery:query_GetSortOrder];
    return arrGetsorting;
}

@end