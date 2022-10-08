//
//  Singleton.m
//  PocketRealty
//
//  Created by TISMobile on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Singleton.h"


@implementation Singleton
{
    NSUserDefaults *userdefault;
}
+ (Singleton*) sharedSingleton  {
	static Singleton* theInstance = nil;
	if (theInstance == nil) {
		theInstance = [[self alloc] init];
	}
	return theInstance;
}

- (NSString *) getBaseURL{
    userdefault = [NSUserDefaults standardUserDefaults];
    return[NSString stringWithFormat:@"%@/api/rest/extended/",[userdefault objectForKey:@"StoreURL"]];
}
- (NSString *) getConsumerKey{
    userdefault = [NSUserDefaults standardUserDefaults];
    return[userdefault objectForKey:@"ConsumerKey"];
}
- (NSString *) getConsumerSecret{
    userdefault = [NSUserDefaults standardUserDefaults];
    return[userdefault objectForKey:@"ConsumerSecret"];
}
@end
