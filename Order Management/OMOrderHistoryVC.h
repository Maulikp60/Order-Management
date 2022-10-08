//
//  OMOrderHistoryVC.h
//  Order Management
//
//  Created by MAC on 13/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperVC.h"
@interface OMOrderHistoryVC : SuperVC
{
    __weak IBOutlet UITableView *tbl_ViewOrder;
    __weak IBOutlet UILabel *lbl_ProductSum;
    __weak IBOutlet UITextView *tv_Comment;
    __weak IBOutlet UIButton *btn_ObjOpernOrder;
    __weak IBOutlet UILabel *lbl_Size;
    __weak IBOutlet UILabel *lbl_SleeveLength;
    __weak IBOutlet UILabel *lbl_Other;
    __weak IBOutlet UILabel *lbl_Color;
    __weak IBOutlet UITableView *tbl_CommentList;
    __weak IBOutlet UILabel *lbl_OrderID;
    __weak IBOutlet UIView *view_CommentList;
    
    __weak IBOutlet UILabel *lbl_Total;
    __weak IBOutlet UILabel *lbl_CommentHistory;
    __weak IBOutlet UILabel *lbl_Price;
    __weak IBOutlet UILabel *lbl_Sku;
    __weak IBOutlet UILabel *lbl_Quantity;
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_OrderComments;
    __weak IBOutlet UIButton *btnObj_MainMenu;
    __weak IBOutlet UIButton *btnObj_OrderList;
    
}

@property (strong,nonatomic) NSString *Order_ID,*Customer_Name,*Order_Status,*Customer_ID;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSize_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSleeve_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblOther_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblColor_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblView_Width;
@end
