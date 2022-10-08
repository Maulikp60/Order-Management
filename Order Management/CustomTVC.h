//
//  CustomTVC.h
//  Order Management
//
//  Created by MAC on 30/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_CategoryTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SKU;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Color;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Size;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SleeveLength;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OtherAttribute;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Price;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Quantity;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ProductName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OrderID;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OrderDate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_BillTo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OrderTotal;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Total;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CustomerName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Date;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ActivityLog;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OutOfStock;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CommentStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CommentDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnObj_Information;
@property (weak, nonatomic) IBOutlet UIButton *btn_ObjPlus;
@property (weak, nonatomic) IBOutlet UIButton *btn_ObjMinus;
@property (weak, nonatomic) IBOutlet UIButton *btn_ObjDeleteProduct;
@property (weak, nonatomic) IBOutlet UIButton *btn_ObjViewPdf;
@property (weak, nonatomic) IBOutlet UIButton *btn_ViewOrder;
@property (weak, nonatomic) IBOutlet UIButton *btn_Status;
@property (weak, nonatomic) IBOutlet UIButton *btn_ObjProductMainMenu;
@property (weak, nonatomic) IBOutlet UIButton *btn_Check;

@property (weak, nonatomic) IBOutlet UITextView *txt_EditTask;

@property (weak, nonatomic) IBOutlet UIImageView *img_Product;

@property (weak, nonatomic) IBOutlet UIView *View_Attribute;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View_SuperTableHeightConsrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_ColorWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_SizeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_SleeveWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_OtherAttributeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_priceattributewidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_skuattributewidth;

@end
