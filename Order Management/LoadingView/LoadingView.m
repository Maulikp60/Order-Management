//
//  LoadingView.m
//  BudgetApp
//
//  Created by sarfaraj on 27/12/13.
//  Copyright (c) 2013 Sufalam 4. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}
+(id)loadingView{
    LoadingView *loadingView = [[[NSBundle mainBundle]  loadNibNamed:@"LoadingView" owner:nil options:nil] lastObject];
    if ([loadingView isKindOfClass:[LoadingView class]]) {
        loadingView.layer.cornerRadius = 10;
        loadingView.layer.masksToBounds = YES;
        return loadingView;
    } else{
        return nil;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)startLoadingInView:(UIView *)view;{
    lblLoading.text = @"Loading...";
    self.center = view.center;
    [activity startAnimating];
    [view addSubview:self];
}
-(void)startLoadingWithSavingTextInView:(UIView *)view;{
    lblLoading.text = @"Saving...";
    self.center = view.center;
    [activity startAnimating];
    [view addSubview:self];
}
-(void)startLoadingWithMessage:(NSString *)message inView:(UIView *)view;{
    lblLoading.text = message;
    self.center = view.center;
    [activity startAnimating];
    [view addSubview:self];
}
-(void)changeLoadingMessage:(NSString *)message{
    lblLoading.text = message;
}

-(void)stopLoading;{
    [activity stopAnimating];
    [self removeFromSuperview];
}
@end
