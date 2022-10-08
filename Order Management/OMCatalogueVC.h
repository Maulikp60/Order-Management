//
//  OMCatalogueVC.h
//  Order Management
//
//  Created by MAC on 30/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperVC.h"
#import "DropDownListView.h"

@interface OMCatalogueVC : SuperVC <UISearchBarDelegate,kDropDownListViewDelegate>
{
    DropDownListView * Dropobj;
    __weak IBOutlet UITableView *tbl_Category;
    __weak IBOutlet UICollectionView *clv_CategoryList;
    __weak IBOutlet UICollectionView *clv_ProductList;
    __weak IBOutlet UILabel *lbl_CatogryStructure;
    
    __weak IBOutlet UIView *view_Header;
    __weak IBOutlet UIView *view_SideMenu;
    __weak IBOutlet UIView *view_Search;
    __weak IBOutlet UISearchBar *search_bar;
    __weak IBOutlet UIButton *btn_ObjSize;
    
    __weak IBOutlet UILabel *lbl_Header;
    
    __weak IBOutlet UILabel *lbl_ProductMenu;
}
@property (strong,nonatomic) NSString *PageDefination;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SideViewWidthtConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeaderViewHeightConstraint;
@end
