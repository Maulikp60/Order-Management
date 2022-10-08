//
//  LoadingView.h
//  BudgetApp
//
//  Created by sarfaraj on 27/12/13.
//  Copyright (c) 2013 Sufalam 4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView{
    
    __weak IBOutlet UILabel *lblLoading;
    __weak IBOutlet UIActivityIndicatorView *activity;
}
+(id)loadingView;
-(void)startLoadingInView:(UIView *)view;
-(void)startLoadingWithSavingTextInView:(UIView *)view;
-(void)startLoadingWithMessage:(NSString *)message inView:(UIView *)view;
-(void)stopLoading;
-(void)changeLoadingMessage:(NSString *)message;
@end
