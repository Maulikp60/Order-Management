//
//  OMCartVC.h
//  Order Management
//
//  Created by MAC on 08/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperVC.h"
@interface OMCartVC : SuperVC <UIAlertViewDelegate, UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tbl_Cart;
    __weak IBOutlet UILabel *lbl_TotalCart;
    __weak IBOutlet UITextField *tv_Comment;
    __weak IBOutlet UILabel *lbl_Size;
    __weak IBOutlet UILabel *lbl_SleeveLength;
    __weak IBOutlet UILabel *lbl_Other;
    __weak IBOutlet UILabel *lbl_Color;
    
    
    __weak IBOutlet UILabel *lbl_OrderComment;
    __weak IBOutlet UILabel *lbl_Details;
    __weak IBOutlet UILabel *lbl_Price;
    __weak IBOutlet UILabel *lbl_Quantity;
    __weak IBOutlet UILabel *lbl_Sku;
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_Image;
    
    __weak IBOutlet UIButton *btnObj_SaveClose;
    __weak IBOutlet UIButton *btnObj_PlaceOrder;
    __weak IBOutlet UIButton *btnObj_CancelOrder;
    __weak IBOutlet UIButton *btnObj_Save;
}
-(void)PlaceOrder :(NSString *)Comment;
-(void)SaveAndCloseOrder :(NSString *)Comment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSize_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSleeve_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblOther_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblColor_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblView_Width;
@property (nonatomic, assign) BOOL ISOpenOrder;
@end
