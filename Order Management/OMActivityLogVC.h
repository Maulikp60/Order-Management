//
//  OMActivityLogVC.h
//  OrderManagement
//
//  Created by MAC on 05/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMActivityLogVC : UIViewController
{
    __weak IBOutlet UITableView *tbl_ActivityLog;
    
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_Date;
}
@end
