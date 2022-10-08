//
//  SuperVC.m
//  Order Management
//
//  Created by MAC on 29/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import "SuperVC.h"
#import "JMImageCache.h"
#import "DBManager.h"
@interface SuperVC ()
{
    DBManager *dbManager;

}
@end

@implementation SuperVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Order Management System.sqlite"];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *logoURL = [userDefault objectForKey:@"LogoURL"];
    NSURL *url = [NSURL URLWithString:logoURL];
    
   [[JMImageCache sharedCache] imageForURL:url completionBlock:^(UIImage *image) {
       UIImage *imgOriginal =[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
       UIBarButtonItem *barLogo = [[UIBarButtonItem alloc] initWithImage:imgOriginal style:UIBarButtonItemStylePlain target:self action:@selector(action_home)];
       UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithTitle:[dbManager GetValue:[userDefault objectForKey:@"Language"] :@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back)];
       
       self.navigationItem.leftBarButtonItems = @[barBack, barLogo];
       
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)action_home{
    [self.navigationController popToRootViewControllerAnimated:true];
}
-(void)action_Back{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - Navigation Title

-(void)setNavigationTitle:(NSString *)title{
    //    self.navigationItem.title = title;
    UIView *titleView = [[UIView alloc] init];
    titleView.frame = CGRectMake(0, 0, 200.0 , 50.0);//CGRectMake(0, 0, self.view.frame.size.width - 50.0 , 50.0);
    
    UIImageView *imgViewLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"owl"]];
    imgViewLogo.contentMode = UIViewContentModeScaleAspectFit;
    imgViewLogo.frame = CGRectMake(0, 0, 60.0, 50.0);
    
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(imgViewLogo.frame.origin.x +
                                imgViewLogo.frame.size.width + 8,
                                imgViewLogo.frame.origin.y,
                                130, 50.0);
    lblTitle.text = title;
    lblTitle.textColor = [UIColor whiteColor];
    
    [titleView addSubview:imgViewLogo];
    [titleView addSubview:lblTitle];
    self.navigationItem.titleView = titleView;
}

@end
