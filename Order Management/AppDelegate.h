//
//  AppDelegate.h
//  Order Management
//
//  Created by MAC on 21/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DatabaseManager.h"
#import "OAuthConsumer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
}
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic,strong) OAConsumer* consumer;
@property (nonatomic,strong) NSString *callback;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSString  *AcceessToken;
@property (nonatomic,strong) NSString  *AcceessSecret;

@property (nonatomic, strong) NSString *CustomerID;
@property (nonatomic) BOOL isEdit;
@property (nonatomic) DatabaseManager *databaseManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+(AppDelegate *)getDelegate;


@end

