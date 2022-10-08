//
//  OMOrderVC.h
//  Order Management
//
//  Created by MAC on 13/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"
#import "SuperVC.h"
@interface OMOrderVC : SuperVC <UIAlertViewDelegate,kDropDownListViewDelegate>
{
    DropDownListView * Dropobj;
    __weak IBOutlet UITableView *tbl_AllOrder;
    __weak IBOutlet UIButton *btn_ObjStatus;
    __weak IBOutlet UIButton *btnSync;
    __weak IBOutlet UILabel *lbl_ID;
    __weak IBOutlet UILabel *lbl_Status;
    __weak IBOutlet UILabel *lbl_Action;
    __weak IBOutlet UILabel *lbl_Total;
    __weak IBOutlet UILabel *lbl_BillTo;
    __weak IBOutlet UILabel *lbl_OrderDate;
    __weak IBOutlet UILabel *lbl_OrderStatus;
    NSMutableArray *arrcustID,*arrcustIDCopy;

}
@end
