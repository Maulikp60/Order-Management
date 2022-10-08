//
//  OMProductDetail.h
//  Order Management
//
//  Created by MAC on 02/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperVC.h"
#import "DropDownListView.h"
@interface OMProductDetail : SuperVC <kDropDownListViewDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>{
    
    DropDownListView * Dropobj;
    __weak IBOutlet UIImageView *img_Main;
    __weak IBOutlet UICollectionView *clv_ImgList;
    __weak IBOutlet UICollectionView *clv_CrosssellProduct;
    __weak IBOutlet UILabel *lbl_Sku;
    __weak IBOutlet UILabel *lbl_ProductName;
    __weak IBOutlet UITextView *txt_ProductDescription;
    __weak IBOutlet UITableView *tbl_OtherProduct;
    __weak IBOutlet UITableView *tbl_CustomerList;
    __weak IBOutlet UIView *view_Blur;
    __weak IBOutlet UIImageView *img_Blur;
    __weak IBOutlet UIView *obj_ViewSuperAttribute;
    __weak IBOutlet UIView *view_Customer;
    __weak IBOutlet UISearchBar *search_bar;
    __weak IBOutlet UILabel *lbl_LastAttribute;
    __weak IBOutlet UILabel *lbl_Sleeve;
    __weak IBOutlet UILabel *lbl_Size;
    __weak IBOutlet UILabel *lbl_Color;
    __weak IBOutlet UILabel *lbl_Quantity;
    __weak IBOutlet UILabel *lbl_Price;
    __weak IBOutlet UIButton *btn_ObjBlur;
    __weak IBOutlet UIButton *btn_ObjLeftSwipe;
    __weak IBOutlet UIButton *btn_ObjRightSwipe;
    
    __weak IBOutlet UILabel *lbl_Crossellproduct;
}
@property(strong,nonatomic) NSString *ProductId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SuPerAttributeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeaderViewWidthConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblWidthConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblColorWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSizeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSleevewidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblOtherWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPriceWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgmainWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSkuwidth;

@end
