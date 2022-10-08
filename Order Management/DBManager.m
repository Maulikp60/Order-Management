//
//  DBManager.m
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "Attribute.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface DBManager()
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
@end

@implementation DBManager

#pragma mark - Initialization

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        NSLog(@"path %@",self.documentsDirectory);
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}
#pragma mark - Private method implementation
-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    // Set the database file path.
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // Check if the query is non-executable.
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            }
            else {
                // This is the case of an executable query (insert, update, ...).
                
                // Execute the query.
                if (sqlite3_step(compiledStatement)) {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    // NSLog(@"Query succeess");
                }
                else {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }
        else {
            // In the database cannot be opened then show the error message on the debugger.
            //            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
            NSLog(@"%s", query);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayOfImages = [[userDefaults objectForKey:@"arr_RemainQuery"] mutableCopy];
            NSString *str = [[NSString alloc] initWithUTF8String:query];
            if ([str containsString:@"insert into"]) {
                [arrayOfImages addObject:str];
                [userDefaults setObject:arrayOfImages forKey:@"arr_RemainQuery"];
                [userDefaults synchronize];
            }else{
                
            }
            
            // Use 'yourArray' to repopulate your UITableView
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
}
-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

#pragma mark -Delete All Country Data
-(void)DeleteCountry{
    NSString *queryDeleteCountry = [NSString stringWithFormat:@"DELETE from Country"];
    [self runQuery:[queryDeleteCountry UTF8String] isQueryExecutable:YES];
}

#pragma mark - Delete Group
-(void)DeleteGroup{
    NSString *queryDeleteGroup = [NSString stringWithFormat:@"DELETE from CustGroups"];
    [self runQuery:[queryDeleteGroup UTF8String] isQueryExecutable:YES];
}
#pragma mark - Execute Remain query
-(void)QueryExecute :(NSString *)Query{
    [self runQuery:[Query UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create Country Table
-(void)CreateCountry:(NSString *)Tablename{
    NSString *queryCreateCoutnry = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "code VARCHAR,"
                                     "iso2code VARCHAR,"
                                     "iso3code VARCHAR,"
                                     "name VARCHAR)",Tablename];
    [self runQuery:[queryCreateCoutnry UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create Product Master Table
-(void)CreateProductMaster:(NSString *)Tablename{
    NSString *queryCreateProdcutMaster = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "associated_products VARCHAR,"
                                     "attribute_set_id VARCHAR,"
                                     "backorders VARCHAR, "
                                     "category_ids VARCHAR, "
                                     "created_at VARCHAR,"
                                     "entity_id VARCHAR,"
                                     "entity_type_id VARCHAR,"
                                     "group_price_changed VARCHAR,"
                                     "has_options VARCHAR,"
                                     "is_available VARCHAR,"
                                     "required_options VARCHAR,"
                                     "sku VARCHAR,"
                                     "status VARCHAR,"
                                     "is_in_stock VARCHAR,"
                                     "stock_qty VARCHAR,"
                                     "store_ids VARCHAR,"
                                     "tier_price_changed VARCHAR,"
                                     "type_id VARCHAR,"
                                     "updated_at VARCHAR,"
                                     "website_ids VARCHAR)",Tablename];
    [self runQuery:[queryCreateProdcutMaster UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create Attribute Master Table
-(void)CreateAttributeMaster :(NSString *)Tablename{
    NSString *queryCreateAttributeMaster = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "attribute_id VARCHAR,"
                                     "attribute_code VARCHAR,"
                                     "frontend_input VARCHAR, "
                                     "frontend_label VARCHAR, "
                                     "is_required VARCHAR,"
                                     "is_user_defined VARCHAR,"
                                     "apply_to VARCHAR,"
                                     "position VARCHAR)",Tablename];
    [self runQuery:[queryCreateAttributeMaster UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create Category Master Table
-(void)CreateCategoryMaster:(NSString *)Tablename{
    NSString *CategoriesTableQuery = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                      "entity_id VARCHAR,"
                                      "entity_type_id VARCHAR,"
                                      "attribute_set_id VARCHAR,"
                                      "parent_id VARCHAR,"
                                      "created_at VARCHAR,"
                                      "updated_at VARCHAR,"
                                      "path VARCHAR,"
                                      "position VARCHAR,"
                                      "level VARCHAR,"
                                      "children_count VARCHAR,"
                                      "is_active VARCHAR,"
                                      "description VARCHAR,"
                                      "meta_keywords VARCHAR,"
                                      "meta_description VARCHAR,"
                                      "custom_layout_update VARCHAR,"
                                      "available_sort_by VARCHAR,"
                                      "landing_page VARCHAR,"
                                      "is_anchor VARCHAR,"
                                      "include_in_menu VARCHAR,"
                                      "custom_use_parent_settings VARCHAR,"
                                      "custom_apply_to_products VARCHAR,"
                                      "name VARCHAR,"
                                      "url_key VARCHAR,"
                                      "image VARCHAR,"
                                      "meta_title VARCHAR,"
                                      "display_mode VARCHAR,"
                                      "url_path VARCHAR,"
                                      "custom_design VARCHAR,"
                                      "page_layout VARCHAR,"
                                      "thumbnail VARCHAR,"
                                      "custom_design_from VARCHAR,"
                                      "custom_design_to VARCHAR,"
                                      "filter_price_range VARCHAR)",@"Category_Master"];
    [self runQuery:[CategoriesTableQuery UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create Customer Master
-(void)CreateCustomerMaster:(NSString *)Tablename{
    NSString *QueryCreateCustomerMaster = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "Customer_id VARCHAR,"
                                     "attribute_set_id VARCHAR,"
                                     "created_at VARCHAR,"
                                     "created_in VARCHAR, "
                                     "default_billing VARCHAR, "
                                     "default_shipping VARCHAR,"
                                     "disable_auto_group_change VARCHAR,"
                                     "dob VARCHAR,"
                                     "email VARCHAR,"
                                     "entity_id VARCHAR,"
                                     "entity_type_id VARCHAR,"
                                     "firstname VARCHAR,"
                                     "gender VARCHAR,"
                                     "group_id VARCHAR,"
                                     "increment_id VARCHAR,"
                                     "is_active VARCHAR,"
                                     "lastname VARCHAR,"
                                     "middlename VARCHAR,"
                                     "password_hash VARCHAR,"
                                     "reward_update_notification VARCHAR,"
                                     "reward_warning_notification VARCHAR,"
                                     "sales_agent_id VARCHAR,"
                                     "store_id VARCHAR,"
                                     "suffix VARCHAR,"
                                     "taxvat VARCHAR,"
                                     "updated_at VARCHAR,"
                                     "website_id VARCHAR,"
                                     "isNew VARCHAR,"
                                     "isUpdate VARCHAR)",Tablename];
    [self runQuery:[QueryCreateCustomerMaster UTF8String] isQueryExecutable:YES];
}

#pragma mark - Create CustomerAddress Table
-(void)CreateCustomerAddress:(NSString *)Tablename{
    NSString *queryCreateCustomerAddress = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "attribute_set_id VARCHAR,"
                                     "city VARCHAR,"
                                     "company VARCHAR,"
                                     "country VARCHAR,"
                                     "created_at VARCHAR, "
                                     "customer_id VARCHAR, "
                                     "default_billing VARCHAR,"
                                     "default_shipping VARCHAR,"
                                     "entity_id VARCHAR,"
                                     "entity_type_id VARCHAR,"
                                     "fax VARCHAR,"
                                     "firstname VARCHAR,"
                                     "increment_id VARCHAR,"
                                     "is_active VARCHAR,"
                                     "lastname VARCHAR,"
                                     "middlename VARCHAR,"
                                     "parent_id VARCHAR,"
                                     "postcode VARCHAR,"
                                     "region VARCHAR,"
                                     "street VARCHAR,"
                                     "telephone VARCHAR,"
                                     "updated_at VARCHAR,"
                                     "isNew VARCHAR,"
                                     "isUpdate VARCHAR)",Tablename];
    [self runQuery:[queryCreateCustomerAddress UTF8String] isQueryExecutable:YES];
}

#pragma mark - Insert Sales Agent Data
-(void)InsertSalesAgent :(NSDictionary *)SalesDic{
    NSMutableArray *Arr_SalesAgent = SalesDic[@"items"];
    for (int i =0 ; i <Arr_SalesAgent.count; i ++) {
        NSDictionary *dic = Arr_SalesAgent[i];
        NSString *query_InsertSalesAgent = [NSString stringWithFormat:@"insert into Sales_AgentMaster values('%@','%@','%@','%@','%@','%@','%@')",
                                           [dic objectForKey:@"customer_group_id"],
                                           [dic objectForKey:@"email"],
                                           [dic objectForKey:@"firstname"],
                                           [dic objectForKey:@"lastname"],
                                           [dic objectForKey:@"user_id"],
                                           [dic objectForKey:@"username"],
                                           [dic objectForKey:@"is_active"]];
        [self runQuery:[query_InsertSalesAgent UTF8String] isQueryExecutable:YES];
        
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"1" forKey:@"SalesAgent"];
}

#pragma mark - Insert in language master
-(void)InsertLanguage :(NSString *)Language :(NSString *)Key :(NSString *)Value{
    NSString *query_InsertLanguage = [NSString stringWithFormat:@"insert into Language_Master values('%@','%@','%@')",
                                      Language,
                                      Key,
                                      Value];
    [self runQuery:[query_InsertLanguage UTF8String] isQueryExecutable:YES];
}
#pragma mark - Insert Country Table
-(void)InsertCountry :(NSString *)Tablename :(NSDictionary *)CountryArray{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"Country"]  isEqual: @"1"]) {
        
    }else{
        NSDictionary *dic = CountryArray;
        NSString *query_InsertCountry = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@')",Tablename,
                                           [dic objectForKey:@"code"],
                                           [dic objectForKey:@"iso2code"],
                                           [dic objectForKey:@"iso3code"],
                                           [dic objectForKey:@"name"]];
        [self runQuery:[query_InsertCountry UTF8String] isQueryExecutable:YES];
    }
    //    [userDefault setObject:@"1" forKey:@"Country"];
}

#pragma mark - Insert In Attribute Master Table
-(void)InsertAttributes :(NSString *)Tablename :(NSDictionary *)AttributeDic{
    NSString *str;
    NSDictionary *dic = AttributeDic;
    if ([[dic objectForKey:@"apply_to"]  count] == 0) {
        str = @"";
    }else{
        str =  [[dic objectForKey:@"apply_to"] componentsJoinedByString:@","];
    }
    NSString *query_DeleteAttribute = [NSString stringWithFormat:@"delete from '%@' where attribute_id = '%@'",Tablename,
                                       [dic objectForKey:@"attribute_id"]];
    [self runQuery:[query_DeleteAttribute UTF8String] isQueryExecutable:YES];
    
    if([[dic objectForKey:@"frontend_label"]  isKindOfClass:[NSString class]]){
        NSString *query_InsertAttribute = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@')",
                                           Tablename,
                                           [dic objectForKey:@"attribute_id"],
                                           [dic objectForKey:@"attribute_code"],
                                           [dic objectForKey:@"frontend_input"],
                                           [[dic objectForKey:@"frontend_label"] stringByReplacingOccurrencesOfString:@"'"withString:@"''"],
                                           [dic objectForKey:@"is_required"],
                                           [dic objectForKey:@"is_user_defined"],
                                           str,
                                           [dic objectForKey:@"position"]];
        [self runQuery:[query_InsertAttribute UTF8String] isQueryExecutable:YES];
    }else{
        NSString *query_InsertAttribute = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@')",
                                           Tablename,
                                           [dic objectForKey:@"attribute_id"],
                                           [dic objectForKey:@"attribute_code"],
                                           [dic objectForKey:@"frontend_input"],
                                           [dic objectForKey:@"frontend_label"],
                                           [dic objectForKey:@"is_required"],
                                           [dic objectForKey:@"is_user_defined"],
                                           str,
                                           [dic objectForKey:@"position"]];
        [self runQuery:[query_InsertAttribute UTF8String] isQueryExecutable:YES];
    }
    if ([dic objectForKey:@"options"] == nil) {
        
    }else{
        NSString *query_DeleteAttribute = [NSString stringWithFormat:@"delete from AttributeOption_Master where attribute_id = '%@'",
                                           [dic objectForKey:@"attribute_id"]];
        [self runQuery:[query_DeleteAttribute UTF8String] isQueryExecutable:YES];
        
        NSMutableArray *arr_options = [dic objectForKey:@"options"];
        
        NSLog(@"%lu",(unsigned long)arr_options.count);
        for (int n = 0; n < arr_options.count; n++) {
            NSString *query_InsertAttribute = [NSString stringWithFormat:@"insert into AttributeOption_Master values('%@','%@','%@','%@')",
                                               arr_options[n][@"option_id"],
                                               arr_options[n][@"sort_order"],
                                               arr_options[n][@"value"],
                                               [dic objectForKey:@"attribute_id"]];
            [self runQuery:[query_InsertAttribute UTF8String] isQueryExecutable:YES];
            
            
            NSString *query_UpdateProduct = [NSString stringWithFormat:@"update Product_Attribute_Master set value = '%@' where attribute_code = '%@' and value_id = '%@'",
                                             arr_options[n][@"value"],
                                             [dic objectForKey:@"attribute_code"],
                                             arr_options[n][@"option_id"]];
            [self runQuery:[query_UpdateProduct UTF8String] isQueryExecutable:YES];
            
        }
    }
}

#pragma mark - Insert Product Master Table
-(void)InsertProduct :(NSString *)Tablename :(NSDictionary *)ProductsDic{
    NSMutableArray *arr_ProductID = [[self GetProductID] mutableCopy];
    NSMutableArray *arr_ProductID_Price_Master = [[self GetProductID_Price_Master] mutableCopy];
    NSMutableArray *arr_ProductID_Media_Master = [[self GetProductID_Media_Master] mutableCopy];
    NSDictionary *dic = ProductsDic;
    NSString *str_AssociatedProduct,*str_Backorders,*str_Category_ids,*str_Store_ids,*str_Website_ids,*str_SuperAttribute,*str_cross_sell_product_ids;
    if ([[dic objectForKey:@"associated_products"]  count] == 0) {
        str_AssociatedProduct = @"";
    }else{
        str_AssociatedProduct =  [[dic objectForKey:@"associated_products"] componentsJoinedByString:@","];
    }
    if ([[dic allKeys] containsObject:@"backorders"]) {
        str_Backorders = [dic objectForKey:@"backorders"];
    }else{
        str_Backorders = @"";
    }
    if ([[dic objectForKey:@"category_ids"]  count] == 0) {
        str_Category_ids = @"";
    }else{
        str_Category_ids =  [NSString stringWithFormat:@",%@,",[[dic objectForKey:@"category_ids"] componentsJoinedByString:@","]];
        
    }
    if ([[dic objectForKey:@"store_ids"]  count] == 0) {
        str_Store_ids = @"";
    }else{
        str_Store_ids =  [[dic objectForKey:@"store_ids"] componentsJoinedByString:@","];
    }
    if ([[dic objectForKey:@"website_ids"]  count] == 0) {
        str_Website_ids = @"";
    }else{
        str_Website_ids =  [[dic objectForKey:@"website_ids"] componentsJoinedByString:@","];
    }
    if ([[dic objectForKey:@"attributes"] objectForKey:@"super_attributes"] == nil) {
        str_SuperAttribute = @"";
    }else{
        str_SuperAttribute = [[[[dic objectForKey:@"attributes"] objectForKey:@"super_attributes"] objectForKey:@"id"] componentsJoinedByString:@","];
    }
    if ([arr_ProductID containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteProduct = [NSString stringWithFormat:@"Delete from '%@' where entity_id ='%@'",Tablename,[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteProduct UTF8String] isQueryExecutable:YES];
    }
    NSMutableArray *arr_cross_sell_product_ids = [[NSMutableArray alloc] init];
    arr_cross_sell_product_ids = [dic objectForKey:@"cross_sell_product_ids"];
    if (arr_cross_sell_product_ids.count>0) {
        str_cross_sell_product_ids = [arr_cross_sell_product_ids componentsJoinedByString:@","];
    }else{
        str_cross_sell_product_ids = @"";
    }
    NSString *query_InsertProduct = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                     Tablename,
                                     str_AssociatedProduct,
                                     [dic objectForKey:@"attribute_set_id"],
                                     str_Backorders,
                                     str_Category_ids,
                                     [dic objectForKey:@"created_at"],
                                     [dic objectForKey:@"entity_id"],
                                     [dic objectForKey:@"entity_type_id"],
                                     [dic objectForKey:@"group_price_changed"],
                                     [dic objectForKey:@"has_options"] ,
                                     [dic objectForKey:@"is_available"],
                                     [dic objectForKey:@"required_options"],
                                     [dic objectForKey:@"sku"],
                                     [dic objectForKey:@"status"],
                                     [[dic objectForKey:@"stock_item"] objectForKey:@"is_in_stock"],
                                     [dic objectForKey:@"stock_qty"],
                                     str_Store_ids,
                                     [dic objectForKey:@"tier_price_changed"],
                                     [dic objectForKey:@"type_id"],
                                     [dic objectForKey:@"updated_at"],
                                     str_Website_ids,
                                     str_SuperAttribute,
                                     str_cross_sell_product_ids];
    // Run the query and indicate that is executable.
    [self runQuery:[query_InsertProduct UTF8String] isQueryExecutable:YES];
#pragma mark - Insert Price Master Table
    if ([arr_ProductID_Price_Master containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteProduct_Price_Master = [NSString stringWithFormat:@"Delete from Price_Master where entity_id ='%@'",[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteProduct_Price_Master UTF8String] isQueryExecutable:YES];
        // NSLog(@"%@",query_DeleteProduct_Price_Master);
    }
    if ([[dic objectForKey:@"tier_price"]count] > 0) {
        for (int i = 0  ; i < [[dic objectForKey:@"tier_price"]count]; i++) {
            NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                               @"Price_Master",
                                               [dic objectForKey:@"entity_id"],
                                               @"tier_price",
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"all_groups"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"cust_group"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"price"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"price_id"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"price_qty"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"website_id"],
                                               [[[dic objectForKey:@"tier_price"] objectAtIndex:i] objectForKey:@"website_price"]];
            // Run the query and indicate that is executable.
            [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
            
        }
    }else{
        
    }
    if ([[dic objectForKey:@"group_price"]count] > 0) {
        for (int i = 0  ; i < [[dic objectForKey:@"group_price"]count]; i++) {
            NSString *query_InsertGroupPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                                @"Price_Master",
                                                [dic objectForKey:@"entity_id"],
                                                @"group_price",
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"all_groups"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"cust_group"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"price"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"price_id"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"price_qty"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"website_id"],
                                                [[[dic objectForKey:@"group_price"] objectAtIndex:i] objectForKey:@"website_price"]];
            // Run the query and indicate that is executable.
            [self runQuery:[query_InsertGroupPrice UTF8String] isQueryExecutable:YES];
        }
        
    }else{
        
    }
#pragma mark - Insert Media Gallery  Master Table
    NSArray *AttributeArray= [[dic objectForKey:@"attributes"] allKeys];
    if ([arr_ProductID containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteProduct = [NSString stringWithFormat:@"Delete from Product_Attribute_Master where entity_id ='%@'",[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteProduct UTF8String] isQueryExecutable:YES];
        
    }
    for (int i =0 ; i <AttributeArray.count; i++) {
        NSString *attribute_Name = [AttributeArray objectAtIndex:i];
        if ([attribute_Name  isEqual: @"options"] || [attribute_Name isEqual:@"super_attributes"]) {
            
        }else if ([attribute_Name  isEqual: @"media_gallery"]){
            if ([arr_ProductID_Media_Master containsObject:[dic objectForKey:@"entity_id"]]) {
                NSString *query_DeleteProduct_Media_Master = [NSString stringWithFormat:@"Delete from MediaGallery_Master where entity_id ='%@'",[dic objectForKey:@"entity_id"]];
                [self runQuery:[query_DeleteProduct_Media_Master UTF8String] isQueryExecutable:YES];
                
            }
            
            for (int i = 0; i < [[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] count]; i++) {
                
                NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                                   @"MediaGallery_Master",
                                                   [dic objectForKey:@"entity_id"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"disabled"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"disabled_default"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"file"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"label"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"label_default"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"position"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"position_default"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"product_id"],
                                                   [[[[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]objectForKey:@"images"] objectAtIndex:i] objectForKey:@"value_id"]];
                // Run the query and indicate that is executable.
                [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
                
            }
        }
        else{
            if ([[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value"] isKindOfClass:[NSString class]]) {
                
                NSString *strValue = [[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value"]stringByReplacingOccurrencesOfString:@"'"withString:@"''"];
                
                if ([[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"] isKindOfClass:[NSString class]]){
                    NSString *strValueKey = [[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"'"withString:@"''"];
                    NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@')",
                                                       @"Product_Attribute_Master",
                                                       [dic objectForKey:@"entity_id"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"attribute_code"],
                                                       [strValue stringByReplacingOccurrencesOfString:@","withString:@""],
                                                       [strValueKey stringByReplacingOccurrencesOfString:@","withString:@""]];
                    // Run the query and indicate that is executable.
                    [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
                    
                }else{
                    
                    NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@')",
                                                       @"Product_Attribute_Master",
                                                       [dic objectForKey:@"entity_id"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"attribute_code"],
                                                       [strValue stringByReplacingOccurrencesOfString:@","withString:@""],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]];
                    // Run the query and indicate that is executable.
                    [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
                    
                }
            }else{
                if ([[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"] isKindOfClass:[NSString class]]){
                    NSString *strValueKey = [[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]stringByReplacingOccurrencesOfString:@"'"withString:@"''"];
                    NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@')",
                                                       @"Product_Attribute_Master",
                                                       [dic objectForKey:@"entity_id"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"attribute_code"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value"],
                                                       [strValueKey stringByReplacingOccurrencesOfString:@","withString:@""]];
                    // Run the query and indicate that is executable.
                    [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
                    
                }else{
                    NSString *query_InsertTierPrice = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@')",
                                                       @"Product_Attribute_Master",
                                                       [dic objectForKey:@"entity_id"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"attribute_code"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value"],
                                                       [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"]];
                    // Run the query and indicate that is executable.
                    [self runQuery:[query_InsertTierPrice UTF8String] isQueryExecutable:YES];
                    
                }
            }
            // NSString * value = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value"]];
            
            //                NSString * value_id = [[[dic objectForKey:@"attributes"] objectForKey:attribute_Name] objectForKey:@"value_id"];
            //                NSLog(@"%@",value_id);
            //                if (value_id == (id)[NSNull null] || value_id.length == 0 ) {
            //
            //                }else{
            //                    [value_id stringByReplacingOccurrencesOfString:@"" withString:@"'"];
            //                }
            
        }
    }
    
    
}

#pragma mark - Insert Category Master Table
-(void)InsertCategory :(NSString *)Tablename :(NSDictionary *)CategoryDic{
    NSDictionary *dic = CategoryDic;
    NSMutableArray *arr_CatId =  [[self GetCategoryId]mutableCopy];
    if ([arr_CatId containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteProduct = [NSString stringWithFormat:@"Delete from '%@' where entity_id ='%@'",Tablename,[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteProduct UTF8String] isQueryExecutable:YES];
    }
    NSString *query_InsertCateegory = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                       Tablename,
                                       [dic objectForKey:@"entity_id"],
                                       [dic objectForKey:@"entity_type_id"],
                                       [dic objectForKey:@"attribute_set_id"],
                                       [dic objectForKey:@"parent_id"],
                                       [dic objectForKey:@"created_at"],
                                       [dic objectForKey:@"updated_at"],
                                       [dic objectForKey:@"path"],
                                       [dic objectForKey:@"position"],
                                       [dic objectForKey:@"level"],
                                       [dic objectForKey:@"children_count"],
                                       [dic objectForKey:@"is_active"],
                                       [dic objectForKey:@"description"],
                                       [dic objectForKey:@"meta_keywords"],
                                       [dic objectForKey:@"meta_description"],
                                       [dic objectForKey:@"custom_layout_update"],
                                       [dic objectForKey:@"available_sort_by"],
                                       [dic objectForKey:@"landing_page"],
                                       [dic objectForKey:@"is_anchor"],
                                       [dic objectForKey:@"include_in_menu"],
                                       [dic objectForKey:@"custom_use_parent_settings"],
                                       [dic objectForKey:@"custom_apply_to_products"],
                                       [dic objectForKey:@"name"],
                                       [dic objectForKey:@"url_key"],
                                       [dic objectForKey:@"image"],
                                       [dic objectForKey:@"meta_title"],
                                       [dic objectForKey:@"display_mode"],
                                       [dic objectForKey:@"url_path"],
                                       [dic objectForKey:@"custom_design"],
                                       [dic objectForKey:@"page_layout"],
                                       [dic objectForKey:@"thumbnail"],
                                       [dic objectForKey:@"custom_design_from"],
                                       [dic objectForKey:@"custom_design_to"],
                                       [dic objectForKey:@"filter_price_range"]];
    [self runQuery:[query_InsertCateegory UTF8String] isQueryExecutable:YES];
}

#pragma mark - Insert In Order Master
-(void)InsertSyncedOrder :(NSString *)Tablename :(NSDictionary *)OrderDic{
    NSMutableArray *arr_OrderID = [[self GetOrderIDAll] mutableCopy];
    NSMutableArray *arr_CommentOrderID = [[self GetOrderIDAll_Comment] mutableCopy];
    NSString *Grand_Total,*Base_Price,*qty_shipped;
    NSDictionary *dic = OrderDic;
    if ([arr_OrderID containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteProduct_Price_Master = [NSString stringWithFormat:@"Delete from Order_Master  where Order_Id ='%@'",[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteProduct_Price_Master UTF8String] isQueryExecutable:YES];
    }
    if ([arr_CommentOrderID containsObject:[dic objectForKey:@"entity_id"]]) {
        NSString *query_DeleteCommentID = [NSString stringWithFormat:@"Delete from Comment_Master  where Order_Id ='%@'",[dic objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteCommentID UTF8String] isQueryExecutable:YES];
    }
    
    Grand_Total = [dic objectForKey:@"base_grand_total"];
    NSMutableArray *Arr_Comments = [dic objectForKey:@"order_comments"];
    for (int j = 0; j <Arr_Comments.count; j++) {
        NSString *str_Comment;
        if ([[Arr_Comments[j] objectForKey:@"comment"]  isKindOfClass:[NSString class]]) {
            str_Comment = [[Arr_Comments[j] objectForKey:@"comment"]stringByReplacingOccurrencesOfString:@"'"withString:@"!!"];
        }else{
            str_Comment = @"";
        }
        NSString *query_InsertComment = [NSString stringWithFormat:@"insert into Comment_Master values('%@','%@','%@','%@','%@','%@')",
                                         str_Comment,
                                         [Arr_Comments[j] objectForKey:@"created_at"],
                                         [Arr_Comments[j] objectForKey:@"is_customer_notified"],
                                         [Arr_Comments[j] objectForKey:@"is_visible_on_front"],
                                         [Arr_Comments[j] objectForKey:@"status"],
                                         [dic objectForKey:@"entity_id"]];
        [self runQuery:[query_InsertComment UTF8String] isQueryExecutable:YES];
    }
    
    NSMutableArray *Arr = [dic objectForKey:@"order_items"];
    
    for (int i = 0 ; i <Arr.count ; i++) {
        if ([[[Arr objectAtIndex:i] valueForKey:@"attributes"]valueForKey:@"attributes_info"] == nil) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"]; //// here set format of date which is in your output date (means above str with format)
            
            NSDate *date = [dateFormatter dateFromString: [dic objectForKey:@"created_at"]]; // here you can fetch date from string with define format
            
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];// here set format which you want...
            NSString *superAttribute = @"";
            NSString *comment;
            if ([[[[dic objectForKey:@"order_comments"] objectAtIndex:0]objectForKey:@"comment"] isKindOfClass:[NSString class]]) {
                comment = [[[[dic objectForKey:@"order_comments"] objectAtIndex:0]objectForKey:@"comment"] stringByReplacingOccurrencesOfString:@"'"withString:@"!!"];
            }else{
                comment = @"";
            }
            if ([[[[Arr objectAtIndex:i] valueForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"super_attribute"] == nil) {
                Base_Price = Arr[i][@"base_price"];
                qty_shipped = Arr[i][@"qty_shipped"];
                NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
                NSString *query_InsertOrder = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','','%@','%@','%@','%@')",
                                               Tablename,
                                               [Arr[i] objectForKey:@"product_entity_id"],
                                               [[[Arr[i] objectForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"qty"],
                                               [dic objectForKey:@"customer_id"],
                                               [dic objectForKey:@"entity_id"],
                                               convertedString,
                                               [dic objectForKey:@"status"],
                                               comment,
                                               [[[Arr[i] objectForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"product"],
                                               Base_Price,
                                               Grand_Total,
                                               qty_shipped];
                [self runQuery:[query_InsertOrder UTF8String] isQueryExecutable:YES];
            }else{
                superAttribute = [[[[[[Arr objectAtIndex:i] valueForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"super_attribute"] allKeys] componentsJoinedByString:@","];
                NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
                NSString *query_InsertOrder = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                               Tablename,
                                               [Arr[i] objectForKey:@"product_entity_id"],
                                               [[[Arr[i] objectForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"qty"],
                                               [dic objectForKey:@"customer_id"],
                                               [dic objectForKey:@"entity_id"],
                                               convertedString,
                                               [dic objectForKey:@"status"],
                                               comment,
                                               superAttribute,
                                               [[[Arr[i] objectForKey:@"attributes"] objectForKey:@"info_buyRequest"] objectForKey:@"product"],
                                               Base_Price,
                                               Grand_Total,
                                               qty_shipped];
                [self runQuery:[query_InsertOrder UTF8String] isQueryExecutable:YES];
            }
        }else{
            Base_Price = Arr[i][@"base_price"];
            qty_shipped = Arr[i][@"qty_shipped"];
        }
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"1" forKey:@"Order"];
}

#pragma mark - Insert In Customer Master
-(void)InsertCustomerMaster :(NSString *)Tablename :(NSDictionary *)CustomerDic : (NSString *)new :(NSString *)Update{
    NSArray *CustomerArray= [CustomerDic allKeys];
    for (int i =0 ; i <CustomerArray.count; i ++) {
//        NSLog(@"customer insert %d of %lu",i,(unsigned long)CustomerArray.count);
        NSString *strCustomerID;
        NSDictionary *dict = [CustomerDic valueForKey:[CustomerArray objectAtIndex:i]];
        NSMutableDictionary *Dictionary = [dict mutableCopy];
        
        for (NSString *key in [dict allKeys]) {
            if ([dict[key] isEqual:[NSNull null]]) {
                Dictionary[key] = @" ";//or [NSNull null] or whatever value you want to change it to
            }
        }
        dict = [Dictionary copy];
        NSMutableArray *arr_CustomerID_Master = [[self GetCustomersID_Master] mutableCopy];
        if ([arr_CustomerID_Master containsObject:[dict objectForKey:@"entity_id"]]) {
            NSString *query_DeleteCustomer = [NSString stringWithFormat:@"Delete from Customer_Master where entity_id ='%@'",[dict objectForKey:@"entity_id"]];
            [self runQuery:[query_DeleteCustomer UTF8String] isQueryExecutable:YES];
        }
        NSDictionary *AddressDict =  [dict objectForKey:@"addresses"];
        //[self InsertCustomersAddress:@"CustomerAddress":AddressDict];
        [self InsertCustomersAddress:@"CustomerAddress" :AddressDict :@"false" :@"false"];
        
        strCustomerID =[CustomerArray objectAtIndex:i];
        NSString *latitudde = @"0",*longitude = @"0";
        //        NSString*strdefault_billing = [AddressDict objectForKey:@"default_billing"];
        //     //   NSString *str = [strdefault_billing objectForKey:@"postcode"];
        
        if (AddressDict.count> 0) {
            if ([[AddressDict objectForKey:[dict objectForKey:@"default_billing"]] objectForKey:@"postcode"] == nil){
                
            }else{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@",[[AddressDict objectForKey:[dict objectForKey:@"default_billing"]] objectForKey:@"postcode"]]]];
                [request setHTTPMethod:@"POST"];
                NSError *err;
                NSURLResponse *response;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                if (dict == nil) {
                    
                }else{
                    if ([[dict objectForKey:@"results"] count]>0) {
                        latitudde=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
                        longitude=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
                        
                    }
                }
                
            }
        }
        NSString *query_InsertCustomerMaster = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                                Tablename,
                                                strCustomerID,
                                                [dict objectForKey:@"attribute_set_id"],
                                                [dict objectForKey:@"created_at"],
                                                [dict objectForKey:@"created_in"],
                                                [dict objectForKey:@"default_billing"],
                                                [dict objectForKey:@"default_shipping"],
                                                [dict objectForKey:@"disable_auto_group_change"],
                                                [dict objectForKey:@"dob"],
                                                [dict objectForKey:@"email"],
                                                [dict objectForKey:@"entity_id"],
                                                [dict objectForKey:@"entity_type_id"],
                                                [dict objectForKey:@"firstname"],
                                                [dict objectForKey:@"gender"],
                                                [dict objectForKey:@"group_id"],
                                                [dict objectForKey:@"increment_id"],
                                                [dict objectForKey:@"is_active"],
                                                [dict objectForKey:@"lastname"],
                                                [dict objectForKey:@"middlename"],
                                                [dict objectForKey:@"password_hash"],
                                                [dict objectForKey:@"reward_update_notification"],
                                                [dict objectForKey:@"reward_warning_notification"],
                                                [dict objectForKey:@"sales_agent_id"],
                                                [dict objectForKey:@"store_id"],
                                                [dict objectForKey:@"suffix"],
                                                [dict objectForKey:@"taxvat"],
                                                [dict objectForKey:@"updated_at"],
                                                [dict objectForKey:@"website_id"],
                                                new,Update,
                                                latitudde,
                                                longitude];
        [self runQuery:[query_InsertCustomerMaster UTF8String] isQueryExecutable:YES];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"1" forKey:@"Customer_Master"];
}

#pragma mark - Insert In Customer Master again
-(void)InsertCustomerMasterFirstsync :(NSString *)Tablename :(NSDictionary *)CustomerDic : (NSString *)new :(NSString *)Update :(NSString *)strCustomerID1{
    //    NSArray *CustomerArray= [CustomerDic allKeys];
    //    for (int i =0 ; i <CustomerArray.count; i ++) {
            NSLog(@"customer insert %@ ",strCustomerID1);
    NSString *strCustomerID;
    //        NSDictionary *dict = [CustomerDic valueForKey:[CustomerArray objectAtIndex:i]];
    NSDictionary *dict = CustomerDic;
    NSMutableDictionary *Dictionary = [dict mutableCopy];
    
    for (NSString *key in [dict allKeys]) {
        if ([dict[key] isEqual:[NSNull null]]) {
            Dictionary[key] = @" ";//or [NSNull null] or whatever value you want to change it to
        }
    }
    dict = [Dictionary copy];
    NSMutableArray *arr_CustomerID_Master = [[self GetCustomersID_Master] mutableCopy];
    if ([arr_CustomerID_Master containsObject:[dict objectForKey:@"entity_id"]]) {
        NSString *query_DeleteCustomer = [NSString stringWithFormat:@"Delete from Customer_Master where entity_id ='%@'",[dict objectForKey:@"entity_id"]];
        [self runQuery:[query_DeleteCustomer UTF8String] isQueryExecutable:YES];
    }
    NSDictionary *AddressDict =  [dict objectForKey:@"addresses"];
    //[self InsertCustomersAddress:@"CustomerAddress":AddressDict];
    [self InsertCustomersAddress:@"CustomerAddress" :AddressDict :@"false" :@"false"];
    
    strCustomerID =strCustomerID1;
    NSString *latitudde = @"0",*longitude = @"0";
    //        NSString*strdefault_billing = [AddressDict objectForKey:@"default_billing"];
    //     //   NSString *str = [strdefault_billing objectForKey:@"postcode"];
    
    if (AddressDict.count> 0) {
        if ([[AddressDict objectForKey:[dict objectForKey:@"default_billing"]] objectForKey:@"postcode"] == nil){
            
        }else{
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@",[[AddressDict objectForKey:[dict objectForKey:@"default_billing"]] objectForKey:@"postcode"]]]];
            [request setHTTPMethod:@"POST"];
            NSError *err;
            NSURLResponse *response;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            if (dict == nil) {
                
            }else{
                if ([[dict objectForKey:@"results"] count]>0) {
                    latitudde=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
                    longitude=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
                    
                }
            }
            
        }
    }
    NSString *query_InsertCustomerMaster = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                            Tablename,
                                            strCustomerID,
                                            [dict objectForKey:@"attribute_set_id"],
                                            [dict objectForKey:@"created_at"],
                                            [dict objectForKey:@"created_in"],
                                            [dict objectForKey:@"default_billing"],
                                            [dict objectForKey:@"default_shipping"],
                                            [dict objectForKey:@"disable_auto_group_change"],
                                            [dict objectForKey:@"dob"],
                                            [dict objectForKey:@"email"],
                                            [dict objectForKey:@"entity_id"],
                                            [dict objectForKey:@"entity_type_id"],
                                            [dict objectForKey:@"firstname"],
                                            [dict objectForKey:@"gender"],
                                            [dict objectForKey:@"group_id"],
                                            [dict objectForKey:@"increment_id"],
                                            [dict objectForKey:@"is_active"],
                                            [dict objectForKey:@"lastname"],
                                            [dict objectForKey:@"middlename"],
                                            [dict objectForKey:@"password_hash"],
                                            [dict objectForKey:@"reward_update_notification"],
                                            [dict objectForKey:@"reward_warning_notification"],
                                            [dict objectForKey:@"sales_agent_id"],
                                            [dict objectForKey:@"store_id"],
                                            [dict objectForKey:@"suffix"],
                                            [dict objectForKey:@"taxvat"],
                                            [dict objectForKey:@"updated_at"],
                                            [dict objectForKey:@"website_id"],
                                            new,Update,
                                            latitudde,
                                            longitude];
    [self runQuery:[query_InsertCustomerMaster UTF8String] isQueryExecutable:YES];
    //    }
    //    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    [userDefault setObject:@"1" forKey:@"Customer_Master"];
}

#pragma  mark - Insert INTO Customers Address
-(void)InsertCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update{
    NSArray *AddressesArray;
    if (Addresses.count>0) {
        AddressesArray= [Addresses allKeys];
    }
    for (int i =0 ; i <AddressesArray.count; i ++) {
        NSDictionary *dic = [Addresses valueForKey:[AddressesArray objectAtIndex:i]];
        NSMutableDictionary *Dictionary = [dic mutableCopy];
        for (NSString *key in [dic allKeys]) {
            if ([dic[key] isEqual:[NSNull null]]) {
                Dictionary[key] = @" ";//or [NSNull null] or whatever value you want to change it to
            }
        }
        dic = [Dictionary copy];
        NSMutableArray *arr_Entityid_Address = [[self GetEntityID_CustomerAddress] mutableCopy];
        if ([arr_Entityid_Address containsObject:[dic objectForKey:@"entity_id"]]) {
            NSString *query_Delete_Address = [NSString stringWithFormat:@"Delete from CustomerAddress where entity_id ='%@'",[dic objectForKey:@"entity_id"]];
            [self runQuery:[query_Delete_Address UTF8String] isQueryExecutable:YES];
        }
        NSString *query_InsertCustomersAddress = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                                  Tablename,
                                                  [dic objectForKey:@"attribute_set_id"],
                                                  [dic objectForKey:@"city"],
                                                  [dic objectForKey:@"company"],
                                                  [dic objectForKey:@"country_id"],
                                                  [dic objectForKey:@"created_at"],
                                                  [dic objectForKey:@"customer_id"],
                                                  [dic objectForKey:@"default_billing"],
                                                  [dic objectForKey:@"default_shipping"],
                                                  [dic objectForKey:@"entity_id"],
                                                  [dic objectForKey:@"entity_type_id"],
                                                  [dic objectForKey:@"fax"],
                                                  [dic objectForKey:@"firstname"],
                                                  [dic objectForKey:@"increment_id"],
                                                  [dic objectForKey:@"is_active"],
                                                  [dic objectForKey:@"lastname"],
                                                  [dic objectForKey:@"middlename"],
                                                  [dic objectForKey:@"parent_id"],
                                                  [dic objectForKey:@"postcode"],
                                                  [dic objectForKey:@"region"],
                                                  [dic objectForKey:@"street"],
                                                  [dic objectForKey:@"telephone"],
                                                  [dic objectForKey:@"updated_at"],
                                                  newdata,Update ];
        [self runQuery:[query_InsertCustomersAddress UTF8String] isQueryExecutable:YES];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"1" forKey:@"Customer_Master"];
}

#pragma mark - Get Sales Agent Name From AgentId
-(NSString *)GetSalesName : (NSString *)GetSalesID{
    NSString *GetSalesAgentName  = [NSString stringWithFormat:@"SELECT firstname ,lastname FROM Sales_AgentMaster where user_id = '%@'",GetSalesID];
    [self runQuery:[GetSalesAgentName UTF8String] isQueryExecutable:NO];
    if (self.arrResults == nil || self.arrResults.count == 0){
        return @"";
    }
    NSString *Str = [NSString stringWithFormat:@"%@ %@",[[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0],[[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:1]];
    return Str;
}

#pragma mark - Get Category From Parent Id
-(NSArray *)GetCategory : (NSString *)level :(NSString *)parentId{
    NSString *query_Category;
    if ([level  isEqual: @"2"]) {
        query_Category = [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master where level = '%@'",level];
    }else{
        query_Category= [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master where level = '%@' and parent_id = '%@'",level,parentId];
    }
    // query_Category = [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master order by level"];
    [self runQuery:[query_Category UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get Side Menu Category order by level
-(NSArray *)GetSideMenuCategory{
    NSString *query_SideMenuCategory = [NSString stringWithFormat:@"SELECT entity_id ,name, thumbnail ,parent_id, level ,position ,children_count ,path FROM Category_Master order by level"];
    [self runQuery:[query_SideMenuCategory UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get All Side Menu Category
-(NSArray *)GetCategoryId{
    NSString *query_SideMenuCategory = [NSString stringWithFormat:@"SELECT entity_id FROM Category_Master"];
    [self runQuery:[query_SideMenuCategory UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_CatID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_CatID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_CatID;
}

#pragma mark - Get All Image
-(NSArray *)GetAllImage{
    NSString *query_AllImage = [NSString stringWithFormat:@"SELECT DISTINCT value_id FROM Product_Attribute_Master where  value_id like '%%.jpg'or  value_id like '%%.png' or  value_id like '%%.jpeg'"];
    [self runQuery:[query_AllImage UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get All Media
-(NSArray *)GetAllMedia{
    NSString *query_AllMedia = [NSString stringWithFormat:@"SELECT DISTINCT file FROM MediaGallery_Master where  file like '%%.jpg'or  file like '%%.png' or  file like '%%.jpeg' or  file like '%%.gif'"];
    [self runQuery:[query_AllMedia UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get All Category Image
-(NSArray *)GetAllCategoryImage{
    NSString *query_AllCategoryImage = [NSString stringWithFormat:@"SELECT DISTINCT thumbnail FROM Category_Master where  thumbnail like '%%.jpg'or  thumbnail like '%%.png' or  thumbnail like '%%.jpeg'"];
    [self runQuery:[query_AllCategoryImage UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get Product Short Detail from Category Id
-(NSArray *)GetProductShortDetail :(NSString *)Cat_ID{
    NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT entity_id,attribute_code ,value_id FROM Product_Attribute_Master where ( attribute_code  = 'name' or  attribute_code  = 'sku' or  attribute_code  = 'small_image' or attribute_code  = 'short_description') and entity_id in (SELECT entity_id FROM Product_Master where  category_ids like '%%,%@,%%')and entity_id in( SELECT entity_id FROM   Product_Attribute_Master  WHERE (attribute_code  = 'visibility' and value_id != 1)) and entity_id in( SELECT entity_id FROM   Product_Attribute_Master  WHERE (attribute_code  = 'status' and value_id != 2))",Cat_ID];
    [self runQuery:[query_ShortProductDetail UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get Product Short Detail from search
-(NSArray *)GetProductShortDetailSearch :(NSString *)Search{
    NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT entity_id,attribute_code ,value_id FROM Product_Attribute_Master where (attribute_code  = 'name' or  attribute_code  = 'sku' or  attribute_code  = 'small_image' or attribute_code  = 'short_description') and entity_id in( SELECT entity_id FROM   Product_Attribute_Master  WHERE (attribute_code  = 'visibility' and value_id != 1)) and entity_id in( SELECT entity_id FROM   Product_Attribute_Master  WHERE (attribute_code  = 'status' and value_id != 2)) and entity_id  in( SELECT entity_id FROM   Product_Attribute_Master  WHERE (attribute_code  = 'name' and value_id like  '%%%@%%') or (attribute_code  = 'sku' and value_id like  '%%%@%%'))",Search,Search];
    [self runQuery:[query_ShortProductDetail UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Get Attribute Id
-(NSArray *)GetAttributeID{
    NSString *query_AttribureId = [NSString stringWithFormat:@"SELECT attribute_id FROM Attribute_Master"];
    [self runQuery:[query_AttribureId UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_AttributeID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_AttributeID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_AttributeID;
}

#pragma mark - Get Product Id
-(NSArray *)GetProductID{
    NSString *query_ProductId_From_Product_Master = [NSString stringWithFormat:@"SELECT entity_id FROM Product_Master"];
    [self runQuery:[query_ProductId_From_Product_Master UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID;
}

#pragma mark - Get All Order Id
-(NSArray *)GetOrderIDAll{
    NSString *query_ProductId_From_Product_Master = [NSString stringWithFormat:@"SELECT distinct Order_Id FROM Order_Master"];
    [self runQuery:[query_ProductId_From_Product_Master UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID;
}

#pragma mark - Get Order Id From comment
-(NSArray *)GetOrderIDAll_Comment{
    NSString *query_ProductId_From_Product_Master = [NSString stringWithFormat:@"SELECT distinct Order_Id FROM Comment_Master"];
    [self runQuery:[query_ProductId_From_Product_Master UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID;
}

#pragma mark - Get Product Id From Price_Master
-(NSArray *)GetProductID_Price_Master{
    NSString *query_ProductId_From_Price_Master = [NSString stringWithFormat:@"SELECT entity_id FROM Price_Master"];
    [self runQuery:[query_ProductId_From_Price_Master UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID_Price_Master = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID_Price_Master addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID_Price_Master;
}

#pragma mark - Get Product Id From Media_Master
-(NSArray *)GetProductID_Media_Master{
    NSString *query_ProductId_From_MediaMaster = [NSString stringWithFormat:@"SELECT entity_id FROM MediaGallery_Master"];
    [self runQuery:[query_ProductId_From_MediaMaster UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID_Media_Master = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID_Media_Master addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID_Media_Master;
}

#pragma mark - Insert Task
-(void)InsertTask :(NSString *)TaskDescription{
    NSString *query_InsertTask = [NSString stringWithFormat:@"insert into TaskList values('%@','0')",TaskDescription];
    [self runQuery:[query_InsertTask UTF8String] isQueryExecutable:YES];
}

#pragma mark - Get All Task
-(NSArray *)GetTaskList{
    NSString *query_GetTaskList = [NSString stringWithFormat:@"SELECT rowid,* From TaskList"];
    [self runQuery:[query_GetTaskList UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark - Update Task
-(void)Update_Task :(NSString *)row_Id :(NSString *)Status{
    NSString *query_UpdateTask = [NSString stringWithFormat:@"Update TaskList set Status = '%@' where rowid = '%@'",Status,row_Id];
    [self runQuery:[query_UpdateTask UTF8String] isQueryExecutable:NO];
}

#pragma mark - Delete Record
-(void)DeleteRecord : (id)jsonParse{
    //    for (int i = 0;  i < DeleteDic.count; i++) {
    id json = [NSJSONSerialization JSONObjectWithData:[[jsonParse objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *DeleteKey =[json objectForKey:@"entity_id"];
    if ([[jsonParse objectForKey:@"table_name"]  isEqual: @"categories"]) {
        NSString *query_UpdateTask = [NSString stringWithFormat:@"Delete from Category_Master where entity_id = '%@'",DeleteKey];
        [self runQuery:[query_UpdateTask UTF8String] isQueryExecutable:NO];
    }else if ([[jsonParse objectForKey:@"table_name"]  isEqual: @"products"]) {
        NSString *query_DeleteProduct = [NSString stringWithFormat:@"Delete from Product_Master where entity_id ='%@'",DeleteKey];
        [self runQuery:[query_DeleteProduct UTF8String] isQueryExecutable:YES];
        
        NSString *query_DeleteProduct_Price_Master = [NSString stringWithFormat:@"Delete from Price_Master where entity_id ='%@'",DeleteKey];
        [self runQuery:[query_DeleteProduct_Price_Master UTF8String] isQueryExecutable:YES];
        
        NSString *query_DeleteProduct_Attribute = [NSString stringWithFormat:@"Delete from Product_Attribute_Master where entity_id ='%@'",DeleteKey];
        [self runQuery:[query_DeleteProduct_Attribute UTF8String] isQueryExecutable:YES];
    }else{
        
    }
    //    }
}

#pragma mark - Get Product Long Description
-(NSArray *)GetProductLongDetail :(NSString *)Product_ID{
    //NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT entity_id,attribute_code ,value_id,value FROM Product_Attribute_Master where  (attribute_code  = 'name' or  attribute_code  = 'sku' or  attribute_code  = 'small_image' or attribute_code  = 'short_description') and  entity_id = '%@'",Product_ID];
    NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT entity_id,attribute_code ,value_id,value FROM Product_Attribute_Master where entity_id = '%@'",Product_ID];
    [self runQuery:[query_ShortProductDetail UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrResults;
}

#pragma mark InsertTemporyAddress
-(void)InsertTempCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update{
    NSArray *AddressesArray= [Addresses allKeys];
    for (int i =0 ; i <AddressesArray.count; i ++) {
        NSDictionary *dic = [Addresses valueForKey:[AddressesArray objectAtIndex:i]];
        NSMutableDictionary *Dictionary = [dic mutableCopy];
        for (NSString *key in [dic allKeys]) {
            if ([dic[key] isEqual:[NSNull null]]) {
                Dictionary[key] = @" ";//or [NSNull null] or whatever value you want to change it to
            }
        }
        dic = [Dictionary copy];
        
        NSString *query_InsertCustomersAddress = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                                                  Tablename,
                                                  @"",
                                                  [dic objectForKey:@"city"],
                                                  [dic objectForKey:@"company"],
                                                  [dic objectForKey:@"country"],
                                                  @"",
                                                  [dic objectForKey:@"entity_id"],
                                                  [dic objectForKey:@"default_billing"],
                                                  [dic objectForKey:@"default_shipping"],
                                                  [dic objectForKey:@"entity_id"],
                                                  @"",
                                                  [dic objectForKey:@"fax"],
                                                  [dic objectForKey:@"firstname"],
                                                  @"",
                                                  @"",
                                                  [dic objectForKey:@"lastname"],
                                                  [dic objectForKey:@"middlename"],
                                                  [dic objectForKey:@"parent_id"],
                                                  [dic objectForKey:@"postcode"],
                                                  [dic objectForKey:@"region"],
                                                  [dic objectForKey:@"street"],
                                                  [dic objectForKey:@"telephone"],
                                                  @"",
                                                  newdata,Update ];
        [self runQuery:[query_InsertCustomersAddress UTF8String] isQueryExecutable:YES];
    }
}

#pragma mark - Insert Order
-(void)InsertOrder : (NSMutableArray *)ArrOrder :(NSString *)Status :(NSString *)Comment :(NSString *)SuperAttributeID :(NSString *)Parent_ID :(NSString *)Base_Price :(NSString *)Grand_Total{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *arrGetAllRecord = [self GetAllOrderRecordId];
    for (int i = 0; i < ArrOrder.count; i++) {
        if ([arrGetAllRecord containsObject:[[ArrOrder objectAtIndex:i] objectForKey:@"entity_id"]]) {
            NSString *query_DeleteOrder = [NSString stringWithFormat:@"Delete from Order_Master where Product_Id = '%@' and Customer_Id = '%@' and Order_Id = '%@'",
                                           [[ArrOrder objectAtIndex:i] objectForKey:@"entity_id"],[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];
            [self runQuery:[query_DeleteOrder UTF8String] isQueryExecutable:YES];
        }
        Comment = [Comment stringByReplacingOccurrencesOfString:@"'" withString:@"!!"];
        NSString *total = [NSString stringWithFormat:@"%f",[[[ArrOrder objectAtIndex:i] objectForKey:@"base_Price"] floatValue]*[[[ArrOrder objectAtIndex:i] objectForKey:@"Quantity"]integerValue]];
        NSString *query_InsertOrder = [NSString stringWithFormat:@"insert into Order_Master values('%@','%@','%@','%@','','%@','%@','%@','%@','%@','%@','0')",
                                       [[ArrOrder objectAtIndex:i] objectForKey:@"entity_id"],
                                       [[ArrOrder objectAtIndex:i] objectForKey:@"Quantity"],
                                       [userDefault objectForKey:@"Customer_Id"],
                                       [userDefault objectForKey:@"Order_Id"],
                                       Status,
                                       Comment,
                                       SuperAttributeID,
                                       Parent_ID,
                                       [[ArrOrder objectAtIndex:i] objectForKey:@"base_Price"],
                                       total];
        [self runQuery:[query_InsertOrder UTF8String] isQueryExecutable:YES];
    }
}

#pragma mark - Get All Product From Order Id & Customer Id
-(NSArray *)GetAllOrderRecordId{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_GetAllRecord = [NSString stringWithFormat:@"SELECT Product_Id FROM Order_Master where Customer_Id = '%@' and Order_Id = '%@'",[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_GetAllRecord UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_ProductID = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_ProductID addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_ProductID;
}

#pragma mark - Get Cart From Current Order Id
-(NSArray *)GetCartFromOrder{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_GetAllRecord = [NSString stringWithFormat:@"SELECT Product_Id,Quantity,Parent_ID FROM Order_Master where Quantity != 0 and Order_Id = '%@'",[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_GetAllRecord UTF8String] isQueryExecutable:NO];
    return  (NSArray *)self.arrResults;
}

#pragma mark - Get Cart From Order Id
-(NSArray *)GetCartFromOrder :(NSString *)Order_ID{
    NSString *query_GetAllRecord = [NSString stringWithFormat:@"SELECT Product_Id,Quantity,Base_Price,Grand_Total,Status,qty_shipped FROM Order_Master where Quantity != 0 and Order_Id = '%@'",Order_ID];
    [self runQuery:[query_GetAllRecord UTF8String] isQueryExecutable:NO];
    return  (NSArray *)self.arrResults;
}

#pragma mark - Update Product from Order id and product id
-(void)Update_Product : (NSString *)ProductID : (NSString *)Quantity :(NSString *)Status :(NSString *)Comment{
    Comment = [Comment stringByReplacingOccurrencesOfString:@"'" withString:@"!!"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_UpdateProduct = [NSString stringWithFormat:@"Update Order_Master set Quantity = '%@', Status = '%@', Comment = '%@'where Product_Id = '%@' and Customer_Id = '%@' and Order_Id = '%@' ",Quantity,Status,Comment,ProductID,[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_UpdateProduct UTF8String] isQueryExecutable:NO];
}

#pragma mark -Delete Null Order
-(void)DeleteOrderNull{
    NSString *query_GetMaxOrderId = [NSString stringWithFormat:@"delete from Order_Master where Order_Id = '(null)'"];
    [self runQuery:[query_GetMaxOrderId UTF8String] isQueryExecutable:NO];
}

#pragma mark - Delete Order from order Id
-(void)DeleteOrder{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_UpdateProduct = [NSString stringWithFormat:@"delete from Order_Master where Customer_Id = '%@' and Order_Id = '%@' ",[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];//and Status = 'Cart'
    [self runQuery:[query_UpdateProduct UTF8String] isQueryExecutable:NO];
}

#pragma mark - Saved order with status change
-(void)SavedOrder :(NSString *)Status{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_UpdateProduct = [NSString stringWithFormat:@"Update Order_Master set Status = '%@',Order_Date = '%@' where Customer_Id = '%@' and Order_Id = '%@'",Status,dateString,[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_UpdateProduct UTF8String] isQueryExecutable:NO];
}

#pragma mark - Get Order Status
-(BOOL)CheckOrderStatus{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_CheckOrderStatus = [NSString stringWithFormat:@"select Status from Order_Master where Order_Id = '%@'",[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_CheckOrderStatus UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        if ([[[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0]  isEqual: @"Cart"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}
#pragma mark - Get Email Status
-(BOOL)CheckEmailStatus :(NSString *)Email{
    NSString *query_CheckEmailStatus = [NSString stringWithFormat:@"SELECT * FROM Customer_Master where email = '%@'",Email];
    [self runQuery:[query_CheckEmailStatus UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - Get parent level from product Id
-(NSString *)GetSuperLevel :(NSString *)Product_ID{
    NSString *query_Getsuperlevel = [NSString stringWithFormat:@"SELECT parent_id FROM Category_Master where  entity_id = '%@'",Product_ID];
    [self runQuery:[query_Getsuperlevel UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return self.arrResults[0][0];
    }else{
        return @"0";
    }
}
#pragma mark - Get Parent level name
-(NSString *)GetSuperLevelName :(NSString *)Product_ID{
    NSString *query_ShortProductDetail = [NSString stringWithFormat:@"SELECT name FROM Category_Master where  entity_id = '%@'",Product_ID];
    [self runQuery:[query_ShortProductDetail UTF8String] isQueryExecutable:NO];
    return self.arrResults[0][0];
}
#pragma mark - Get Customer Id From Price_Master
-(NSArray *)GetCustomersID_Master{
    NSString *query_CustomerId_From_Customers_Master = [NSString stringWithFormat:@"SELECT entity_id FROM Customer_Master"];
    [self runQuery:[query_CustomerId_From_Customers_Master UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_CustomerID_Price_Master = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_CustomerID_Price_Master addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_CustomerID_Price_Master;
}

#pragma mark - Insert Into Customer Groups Table
-(void)InsertCustGroups :(NSString *)Tablename :(NSMutableArray *)CustGroupsArray{
    [self DeleteGroup];
    NSMutableArray *arr =[CustGroupsArray valueForKey:@"items"];
    for (int i =0 ; i <arr.count; i ++) {
        NSDictionary *dic = [arr objectAtIndex:i];
        NSString *query_Customer_Group = [NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@')",Tablename,
                                          [dic objectForKey:@"customer_group_code"],
                                          [dic objectForKey:@"customer_group_id"],
                                          [dic objectForKey:@"tax_class_id"]];
        [self runQuery:[query_Customer_Group UTF8String] isQueryExecutable:YES];
        
    }
}

#pragma mark - Create Customer Gropus Table
-(void)CreateCustGroups:(NSString *)Tablename{
    NSString *charsTableNameQuery = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@("
                                     "customer_group_code VARCHAR,"
                                     "customer_group_id VARCHAR,"
                                     "tax_class_id VARCHAR)",Tablename];
    [self runQuery:[charsTableNameQuery UTF8String] isQueryExecutable:YES];
}

#pragma mark - Clear Attribute Master
-(void)ClearAttribute_Master{
    NSString *query_ClearAttribute_Master = [NSString stringWithFormat:@"DELETE FROM Attribute_Master"];
    [self runQuery:[query_ClearAttribute_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Category Master
-(void)ClearCategory_Master{
    NSString *query_ClearCategory_Master = [NSString stringWithFormat:@"DELETE FROM Category_Master"];
    [self runQuery:[query_ClearCategory_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Country
-(void)ClearCountry{
    NSString *query_ClearCountry = [NSString stringWithFormat:@"DELETE FROM Country"];
    [self runQuery:[query_ClearCountry UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Customer Groups
-(void)ClearCustGroups{
    NSString *query_ClearCustGroups = [NSString stringWithFormat:@"DELETE FROM CustGroups"];
    [self runQuery:[query_ClearCustGroups UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Customer Adreess
-(void)ClearCustomerAddress{
    NSString *query_ClearCustomerAddress = [NSString stringWithFormat:@"DELETE FROM CustomerAddress"];
    [self runQuery:[query_ClearCustomerAddress UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Customer Master
-(void)ClearCustomer_Master{
    NSString *query_ClearCustomer_Master = [NSString stringWithFormat:@"DELETE FROM Customer_Master"];
    [self runQuery:[query_ClearCustomer_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Media Gallery Master
-(void)ClearMediaGallery_Master{
    NSString *query_ClearMediaGallery_Master = [NSString stringWithFormat:@"DELETE FROM MediaGallery_Master"];
    [self runQuery:[query_ClearMediaGallery_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Order Master
-(void)ClearOrder_Master{
    NSString *query_ClearOrder_Master = [NSString stringWithFormat:@"DELETE FROM Order_Master"];
    [self runQuery:[query_ClearOrder_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Price Master
-(void)ClearPrice_Master{
    NSString *query_ClearPrice_Master = [NSString stringWithFormat:@"DELETE FROM Price_Master"];
    [self runQuery:[query_ClearPrice_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Attribute Master
-(void)ClearProduct_Attribute_Master{
    NSString *query_ClearProduct_Attribute_Master = [NSString stringWithFormat:@"DELETE FROM Product_Attribute_Master"];
    [self runQuery:[query_ClearProduct_Attribute_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Product Master
-(void)ClearProduct_Master{
    NSString *query_ClearProduct_Master = [NSString stringWithFormat:@"DELETE FROM Product_Master"];
    [self runQuery:[query_ClearProduct_Master UTF8String] isQueryExecutable:NO];
}
#pragma mark - Clear Language Master
-(void)ClearLanguageMaster{
    NSString *query_ClearStore_Master = [NSString stringWithFormat:@"DELETE FROM Language_Master"];
    [self runQuery:[query_ClearStore_Master UTF8String] isQueryExecutable:NO];
}
#pragma mark - Clear Store Master
-(void)ClearStore_Master{
    NSString *query_ClearStore_Master = [NSString stringWithFormat:@"DELETE FROM Store_Master"];
    [self runQuery:[query_ClearStore_Master UTF8String] isQueryExecutable:NO];
}

#pragma makr - Clear Activity Log
-(void)ClearActivitylog{
    NSString *query_ClearTaskList = [NSString stringWithFormat:@"DELETE FROM Activitylog_Master"];
    [self runQuery:[query_ClearTaskList UTF8String] isQueryExecutable:NO];
}
-(void)clearSalesAgent{
    NSString *query_ClearTaskList = [NSString stringWithFormat:@"DELETE FROM Sales_AgentMaster"];
    [self runQuery:[query_ClearTaskList UTF8String] isQueryExecutable:NO];
}
#pragma mark - Clear Task List
-(void)ClearTaskList{
    NSString *query_ClearTaskList = [NSString stringWithFormat:@"DELETE FROM TaskList"];
    [self runQuery:[query_ClearTaskList UTF8String] isQueryExecutable:NO];
}

#pragma mark - Clear Website Master
-(void)ClearWebsite_Master{
    NSString *query_ClearWebsite_Master = [NSString stringWithFormat:@"DELETE FROM Website_Master"];
    [self runQuery:[query_ClearWebsite_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark DeleteLocalUpdateCustomer
-(void)Delete_Customer:(NSString *)CustID{
    NSString *query_Delete_Customer = [NSString stringWithFormat:@"Delete from Customer_Master where Customer_id ='%@'",CustID];
    [self runQuery:[query_Delete_Customer UTF8String] isQueryExecutable:YES];
}

#pragma mark - Update Order ID
-(void)UpdateOrderID :(NSString *)Order_ID_Old :(NSString *)Order_Id_New :(NSString *)Grand_Total{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    NSString *query_ClearWebsite_Master = [NSString stringWithFormat:@"Update Order_Master set Order_Id = '%@',Order_Date = '%@', Status = 'synced',Grand_Total = '%@' where Order_Id ='%@'",Order_Id_New,dateString,Grand_Total,Order_ID_Old];
    [self runQuery:[query_ClearWebsite_Master UTF8String] isQueryExecutable:NO];
}

#pragma mark - Insert Activity Log
-(void)InsertActivityLog :(NSString *)Date :(NSString *)Name{
    NSString *query_ACtivitylog = [NSString stringWithFormat:@"insert into Activitylog_Master values ('%@','%@')",Date,Name];
    [self runQuery:[query_ACtivitylog UTF8String] isQueryExecutable:YES];
}

#pragma mark DeleteCustomerGroup
-(void)Delete_Customer_Group{
    NSString *query_Delete_Customer_Group = [NSString stringWithFormat:@"Delete from CustGroups"];
    [self runQuery:[query_Delete_Customer_Group UTF8String] isQueryExecutable:YES];
}

#pragma mark DeleteLocalUpdateCustomer
-(void)Delete_Local_Update_Customer{
    NSString *query_Delete_Local_Update_Customer = [NSString stringWithFormat:@"Delete from Customer_Master where isUpdate ='true'"];
    [self runQuery:[query_Delete_Local_Update_Customer UTF8String] isQueryExecutable:YES];
}

#pragma mark DeleteLocalAddNewCustomer
-(void)Delete_Local_Add_NewCustomer :(NSString *)CustID{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from Customer_Master where isNew ='true' AND Customer_id ='%@'",CustID];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}

#pragma  mark -Delete Local New Customer
-(void)Delete_Local_Add_NewCustomer{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from Customer_Master where isNew ='true'"];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}

#pragma mark - Check New Customer Created Offline
-(BOOL)isNewCustomerCreatedInOffline{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"select * from Customer_Master where isNew ='true'"];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 1){
        return true;
    }else{
        return  false;
    }
}

#pragma mark - Delete From Customer Master
-(void)Delete_Local_Update_NewCustomer :(NSString *)CustID{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from Customer_Master where isUpdate ='true' AND Customer_id ='%@'",CustID];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}

#pragma mark - Check update Customer is avaliable
-(BOOL)isUpdateCustomerCreatedInOffline{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"select * from Customer_Master where isUpdate ='true'"];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 1){
        return true;
    }else{
        return  false;
    }
}
#pragma mark - CheckAddressExit
-(BOOL)CheckAddressExit :(NSString *)AddressId{
    NSString *query_CheckOrderStatus = [NSString stringWithFormat:@"SELECT * FROM CustomerAddress WHERE entity_id = '%@'",AddressId];
    [self runQuery:[query_CheckOrderStatus UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark Delete_Local_Update_Customer_Address
-(void)Delete_Local_Add_CustomerAddress :(NSString *)CustID{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from CustomerAddress where customer_id ='%@'",CustID];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}
#pragma mark - Delete From CustomerAddress
-(void)Delete_Local_Update_CustomerAddress :(NSString *)CustID{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from CustomerAddress where isUpdate ='true' AND parent_id ='%@'",CustID];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}
#pragma mark - CheckEditCustomerEmailStatus
-(BOOL)CheckEditCustomerEmailStatus :(NSString *)Email : (NSString *)Cust_id{
    NSString *query_CheckOrderStatus = [NSString stringWithFormat:@"SELECT * FROM Customer_Master where email = '%@' and Customer_id != '%@'",Email,Cust_id];
    [self runQuery:[query_CheckOrderStatus UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark Delete_Add_NewCustomer
-(void)Delete_Local_Add_NewCustomerAddress:(NSString *)CustID{
    NSString *query_Delete_Local_Add_NewCustomer = [NSString stringWithFormat:@"Delete from CustomerAddress where Customer_id ='%@'",CustID];
    [self runQuery:[query_Delete_Local_Add_NewCustomer UTF8String] isQueryExecutable:YES];
}

#pragma mark - Get Entityid From CustomerAddress
-(NSArray *)GetEntityID_CustomerAddress{
    NSString *query_Entityid_From_CustomersAddress = [NSString stringWithFormat:@"SELECT entity_id FROM CustomerAddress"];
    [self runQuery:[query_Entityid_From_CustomersAddress UTF8String] isQueryExecutable:NO];
    NSMutableArray *arr_CustomerID_Price_Master = [[NSMutableArray alloc]init];
    for (int i =0; i <self.arrResults.count; i++) {
        [arr_CustomerID_Price_Master addObject:[[self.arrResults objectAtIndex:i] objectAtIndex:0]];
    }
    return  arr_CustomerID_Price_Master;
}

#pragma mark - Update Customer Addrress
-(void)UpdateCustomersAddress :(NSString *)Tablename :(NSDictionary *)Addresses :(NSString *)newdata :(NSString *)Update{
    NSArray *AddressesArray= [Addresses allKeys];
    for (int i =0 ; i <AddressesArray.count; i ++) {
        NSDictionary *dic = [Addresses valueForKey:[AddressesArray objectAtIndex:i]];
        NSMutableDictionary *Dictionary = [dic mutableCopy];
        for (NSString *key in [dic allKeys]) {
            if ([dic[key] isEqual:[NSNull null]]) {
                Dictionary[key] = @" ";//or [NSNull null] or whatever value you want to change it to
            }
        }
        dic = [Dictionary copy];
        NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET city = '%@', company = '%@', country = '%@', default_billing = '%@', default_shipping = '%@',fax = '%@' ,firstname = '%@' , lastname = '%@' ,postcode = '%@',region = '%@', street = '%@',telephone = '%@' ,isNew = '%@' ,isUpdate = '%@' WHERE entity_id = %@"
                           ,Tablename,
                           [dic objectForKey:@"city"],
                           [dic objectForKey:@"company"],
                           [dic objectForKey:@"country"],
                           [dic objectForKey:@"default_billing"],
                           [dic objectForKey:@"default_shipping"],
                           [dic objectForKey:@"fax"],
                           [dic objectForKey:@"firstname"],
                           [dic objectForKey:@"lastname"],
                           [dic objectForKey:@"postcode"],
                           //[dic objectForKey:@"prefix"],
                           [dic objectForKey:@"region"],
                           [dic objectForKey:@"street"],
                           //[dic objectForKey:@"suffix"],
                           [dic objectForKey:@"telephone"],
                           newdata,Update,
                           [dic objectForKey:@"entity_id"]];
        [self runQuery:[query UTF8String] isQueryExecutable:YES];
    }
}

#pragma mark - Get All Attribute Of One Record (EX : Size,Color)
-(NSString *)GetAttributeIDFromOrder: (NSString *)Order_ID{
    NSString *query_Last_AddressID = [NSString stringWithFormat:@"SELECT GROUP_CONCAT(Attribute_id) FROM Order_Master where Order_Id = '%@'  AND Quantity !=0 ",Order_ID];
    [self runQuery:[query_Last_AddressID UTF8String] isQueryExecutable:NO];
    if (self.arrResults == nil || self.arrResults.count == 0) {
        return @"";
    }
    return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
}

#pragma mark - Get Customer Group
-(NSString *)GetCustomerGroup :(NSString *)ClientID{
    NSString *query_Last_AddressID = [NSString stringWithFormat:@"select group_id from Customer_Master where Customer_id = '%@'",ClientID];
    [self runQuery:[query_Last_AddressID UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else{
        return @"0";
    }
    
}

#pragma mark - Get Price From Customer Group and Entity Id
-(NSString *)GetPrice : (NSString *)EntityID :(NSString *)GroupId{
    NSString *query_Last_AddressID = [NSString stringWithFormat:@"select price from Price_Master where cust_group = %@ and entity_id = '%@'",GroupId,EntityID];
    [self runQuery:[query_Last_AddressID UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
        
    }else{
        return @"0";
    }
}

#pragma mark - Get Customer id from order ID
-(NSString *)GetcustomerId : (NSString *)Order_ID{
    NSString *query_GetCustomerId = [NSString stringWithFormat:@"select Customer_Id from Order_Master where Order_Id = '%@'",Order_ID];
    [self runQuery:[query_GetCustomerId UTF8String] isQueryExecutable:NO];
    return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
}

#pragma mark - Get Quantity Total From order ID
-(NSString *)GetQuantity : (NSString *)Order_ID{
    NSString *query_GetQuantitySum = [NSString stringWithFormat:@"SELECT sum(Quantity) FROM Order_Master where Order_Id = '%@'",Order_ID];
    [self runQuery:[query_GetQuantitySum UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else{
        return @"0";
    }
}

#pragma mark  - Get Customer Name From Customer ID
-(NSString *)GetCustomerName : (NSString *)CustomerID {
    NSString *query_GetCustomerName = [NSString stringWithFormat:@"SELECT firstname  FROM Customer_Master where Customer_Id = '%@'",CustomerID];
    [self runQuery:[query_GetCustomerName UTF8String] isQueryExecutable:NO];
    return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
}

#pragma mark - Get Last_AddressID
-(NSString *)Get_Last_AddressID{
    NSString *query_Last_AddressID = [NSString stringWithFormat:@"SELECT entity_id FROM CustomerAddress ORDER BY entity_id DESC LIMIT 1"];
    [self runQuery:[query_Last_AddressID UTF8String] isQueryExecutable:NO];
    return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
}

#pragma mark - Get Last_CustomerID
-(NSString *)Get_Last_CustomerID{
    //    NSString *query_Last_CustomerID = [NSString stringWithFormat:@"SELECT entity_id FROM Customer_Master ORDER BY entity_id DESC LIMIT 1"];
    NSString *query_Last_CustomerID = [NSString stringWithFormat:@"SELECT entity_id FROM Customer_Master ORDER BY  CAST (entity_id AS INTEGER)  DESC LIMIT 1"];
    [self runQuery:[query_Last_CustomerID UTF8String] isQueryExecutable:NO];
    return (NSString *)self.arrResults[0][0];
}
//AA
#pragma makr - Get Defaultbilling
-(NSString *)GetDefaultbilling :(NSString *)CustomerID{
    NSString *query = [NSString stringWithFormat:@"SELECT postcode FROM CustomerAddress where default_billing = '1' AND parent_id = '%@'",CustomerID];
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return @"0";
    }
}
-(NSString *)GetCode :(NSString *)Attribute{
    NSString *query = [NSString stringWithFormat:@"SELECT frontend_label FROM Attribute_Master where attribute_code = '%@'",Attribute];
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return @"0";
    }
}
//AA
#pragma makr - Get Defaultshipping
-(NSString *)GetDefaultshipping :(NSString *)CustomerID{
    NSString *query = [NSString stringWithFormat:@"SELECT postcode FROM CustomerAddress where default_shipping = '1' AND parent_id = '%@'",CustomerID];
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return @"0";
    }
}
#pragma mark Get Attribute Id from Product ID
-(NSString *)GetAttributeID :(NSString *)Product_Id{
    NSString *query = [NSString stringWithFormat:@"SELECT super_attribure FROM Product_Master where entity_id = '%@' limit 1",Product_Id];
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return  [[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0];
}

#pragma mark - Get Single order Status From Order id
-(NSString *)GetStatusFromOrder :(NSString *)Order_Id{
    NSString *query_GetStatusFromOrderId = [NSString stringWithFormat:@"select Status from Order_Master where Order_Id = '%@'",Order_Id];
    [self runQuery:[query_GetStatusFromOrderId UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return  [[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0];
    }else{
        return @"Cart";
    }
}

#pragma mark - Get Comment from OrderId
-(NSString *)GetCommentFromOrder :(NSString *)Order_Id{
    [self DeleteComment];
    NSString *query_GetCommentFromOrderId = [NSString stringWithFormat:@"select Comment from Order_Master where Order_Id = '%@'",Order_Id];
    [self runQuery:[query_GetCommentFromOrderId UTF8String] isQueryExecutable:NO];
    if (self.arrResults == nil || self.arrResults.count == 0)
        return @"";
    return  [[[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0]stringByReplacingOccurrencesOfString:@"!!"withString:@"'"];
}
#pragma mark - Update Order Null Comment
-(void)DeleteComment{
    NSString *query_UpdateNullComment = [NSString stringWithFormat:@"update Order_Master set Comment = ''  where Comment = '<null>'"];
    [self runQuery:[query_UpdateNullComment UTF8String] isQueryExecutable:NO];
}
#pragma mark - Get product Qunatity From product
-(NSString *)GetAllOrderRecord :(NSString *)Prodcut_Id{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *query_GetAllRecord = [NSString stringWithFormat:@"SELECT Quantity FROM Order_Master where Product_Id = '%@' and Customer_Id = '%@' and Order_Id = '%@'",Prodcut_Id,[userDefault objectForKey:@"Customer_Id"],[userDefault objectForKey:@"Order_Id"]];
    [self runQuery:[query_GetAllRecord UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return [[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0];
    }else{
        return @"0";
    }
}

#pragma mark - Get Maximum Order ID
-(NSString *)GetMaxOrderID{
    [self DeleteOrderNull];
    NSString *query_GetMaxOrderId = [NSString stringWithFormat:@"select Order_Id from Order_Master where Order_Id = (SELECT max (Order_Id) FROM Order_Master) limit 1"];
    [self runQuery:[query_GetMaxOrderId UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[NSString stringWithFormat:@"%d",[[[self.arrResults objectAtIndex:0]objectAtIndex:0]intValue] + 500];
    }else{
        return @"1";
    }
}
-(NSArray *)GetDetailofCrossSellProduct :(NSString *)ProductID{
    NSString *query_GetDetailCrossSellProduct = [NSString stringWithFormat:@"SELECT value_id FROM Product_Attribute_Master where entity_id ='%@' and  (attribute_code = 'name'  or attribute_code = 'small_image')",ProductID];
    [self runQuery:[query_GetDetailCrossSellProduct UTF8String] isQueryExecutable:NO];
//    if (self.arrResults.count > 0) {
        return self.arrResults;
//    }else{
//        return ;
//    }
}
-(BOOL)CheckVisibleproduct :(NSString *)ProductId{
    NSString *query_CheckVisibleProduct = [NSString stringWithFormat:@"SELECT value_id FROM Product_Attribute_Master where entity_id ='%@' and  attribute_code = 'visibility'",ProductId];
    [self runQuery:[query_CheckVisibleProduct UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count >0) {
        NSString *str_status = [[(NSArray *)self.arrResults objectAtIndex:0] objectAtIndex:0];
        if ([str_status  isEqual: @"1"]) {
            return false;
        }else{
            return true;
        }
    }else{
        return false;
    }
}
#pragma mark - Get Associated Product From Main Product
-(NSString *)GetAssociatedProduct :(NSString *)Product_Id{
    NSString *query_GetAssociatedProduct = [NSString stringWithFormat:@"SELECT associated_products FROM Product_Master where entity_id = '%@'",Product_Id];
    [self runQuery:[query_GetAssociatedProduct UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0){
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else{
        return @"";
    }
}
#pragma mark - Get Cross sell Product From Main Product
-(NSString *)GetCrosssellProduct :(NSString *)Product_Id{
    NSString *query_GetCrossSellProduct = [NSString stringWithFormat:@"SELECT cross_sell_product_ids FROM Product_Master where entity_id = '%@'",Product_Id];
    [self runQuery:[query_GetCrossSellProduct UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0){
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else{
        return @"";
    }
}
#pragma mark - Get Maximum Level of Category
-(NSString *)GetMaxLevel{
    NSString *query_GetMaxLevel = [NSString stringWithFormat:@"SELECT MAX(level) FROM Category_Master"];
    [self runQuery:[query_GetMaxLevel UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return @"0";
    }
}
#pragma mark - Update Customer Id in Order Master
-(void)UpdateCustomerId :(NSString *)OldCustomerID :(NSString *)NewCustomerId{
    NSString *query_UpdateCustomerId = [NSString stringWithFormat:@"update Order_Master set Customer_Id = '%@' where Customer_Id =  '%@'",NewCustomerId,OldCustomerID];
    [self runQuery:[query_UpdateCustomerId UTF8String] isQueryExecutable:NO];
}
#pragma mark - Get Language Word
-(NSString *)GetValue :(NSString *)Language :(NSString *)Key{
    NSString *query_GetLaunageWord = [NSString stringWithFormat:@"SELECT value FROM Language_Master where Language = '%@' and key = '%@'",Language,Key];
    [self runQuery:[query_GetLaunageWord UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return Key;
    }
}
#pragma mark - Update Null Value
-(void)DeleteNull{
    [self DeleteNullDegfaultBilling];
    [self DeleteNullDegfaultShipping];
    [self DeleteNullmiddlename];
    [self DeleteNullpasswordhash];
    [self DeleteNullRewardupdatenotification];
    [self DeleteNullRewardwarningnotification];
    [self DeleteNullsuffix];
    [self DeleteNulltaxvat];
    [self DeleteNullcompany];
    [self DeleteNullcountry];
    [self DeleteNulldefaultshippingaddress];
    [self DeleteNulldefaultbillingaddress];
    [self DeleteNullfax];
    [self DeleteNullmiddlenameAddress];
    [self DeleteNullregion];
    [self DeleteNullstreet];
}
#pragma mark - Update Null Default Billing
-(void)DeleteNullDegfaultBilling{
    NSString *query_UpdateNullBilling = @"update Customer_Master set default_billing = '' where default_billing = '(null)'";
    [self runQuery:[query_UpdateNullBilling UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Default Shipping
-(void)DeleteNullDegfaultShipping{
    NSString *query_UpdateNullDefaultshipping = @"update Customer_Master set default_shipping = '' where default_shipping = '(null)'";
    [self runQuery:[query_UpdateNullDefaultshipping UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Middle Name
-(void)DeleteNullmiddlename{
    NSString *query_UpdateNullMiddleName = @"update Customer_Master set middlename = '' where middlename = '(null)'";
    [self runQuery:[query_UpdateNullMiddleName UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Password Hash
-(void)DeleteNullpasswordhash{
    NSString *query_UpdateNullPasswordHash = @"update Customer_Master set password_hash = '' where password_hash = '(null)'";
    [self runQuery:[query_UpdateNullPasswordHash UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null reward update notification
-(void)DeleteNullRewardupdatenotification{
    NSString *query_UpdateNullrewardupdate = @"update Customer_Master set reward_update_notification = '' where reward_update_notification = '(null)'";
    [self runQuery:[query_UpdateNullrewardupdate UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Reward warning notification
-(void)DeleteNullRewardwarningnotification{
    NSString *query_UpdateNullRewardwarning = @"update Customer_Master set reward_warning_notification = '' where reward_warning_notification = '(null)'";
    [self runQuery:[query_UpdateNullRewardwarning UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Suffix
-(void)DeleteNullsuffix{
    NSString *query_UpdateNullSuffix = @"update Customer_Master set suffix = '' where suffix = '(null)'";
    [self runQuery:[query_UpdateNullSuffix UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Taxvat
-(void)DeleteNulltaxvat{
    NSString *query_UpdateNulltaxvat = @"update Customer_Master set taxvat = '' where taxvat = '(null)'";
    [self runQuery:[query_UpdateNulltaxvat UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null company
-(void)DeleteNullcompany{
    NSString *query_UpdateNullcompany = @"update CustomerAddress set company = '' where company = '(null)'";
    [self runQuery:[query_UpdateNullcompany UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Country
-(void)DeleteNullcountry{
    NSString *query_UpdateNullcoutry = @"update CustomerAddress set country = '' where country = '(null)'";
    [self runQuery:[query_UpdateNullcoutry UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Default shipping address
-(void)DeleteNulldefaultshippingaddress{
    NSString *query_defaultshippingaddress = @"update CustomerAddress set default_shipping = '' where default_shipping = '(null)'";
    [self runQuery:[query_defaultshippingaddress UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Customer Billing Adress
-(void)DeleteNulldefaultbillingaddress{
    NSString *query_UpdateCustomerDefaultBillingAdreess = @"update CustomerAddress set default_billing = '' where default_billing = '(null)'";
    [self runQuery:[query_UpdateCustomerDefaultBillingAdreess UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Fax
-(void)DeleteNullfax{
    NSString *query_UpdateFax = @"update CustomerAddress set fax = '' where fax = '(null)'";
    [self runQuery:[query_UpdateFax UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Middle name address
-(void)DeleteNullmiddlenameAddress{
    NSString *query_UpdateMiddleNameAddress = @"update CustomerAddress set middlename = '' where middlename = '(null)'";
    [self runQuery:[query_UpdateMiddleNameAddress UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null Region
-(void)DeleteNullregion{
    NSString *query_UpdateRegion = @"update CustomerAddress set region = '' where region = '(null)'";
    [self runQuery:[query_UpdateRegion UTF8String] isQueryExecutable:NO];
}
#pragma mark - Update Null street
-(void)DeleteNullstreet{
    NSString *query_UpdateStreet = @"update CustomerAddress set street = '' where street = '(null)'";
    [self runQuery:[query_UpdateStreet UTF8String] isQueryExecutable:NO];
}
#pragma mark - Grnad total for unsynced order
-(NSString *)GetGrandTotal :(NSString *)OrderId{
    NSString *query_GetGrandTotal = [NSString stringWithFormat:@"SELECT SUM(Grand_Total)  from Order_Master where Order_Id = '%@'",OrderId];
    [self runQuery:[query_GetGrandTotal UTF8String] isQueryExecutable:NO];
    if (self.arrResults.count > 0) {
        return (NSString *)[[self.arrResults objectAtIndex:0]objectAtIndex:0];
    }else {
        return @"0";
    }
}
@end