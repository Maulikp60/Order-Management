//
//  OMUpdateTaskVC.h
//  OrderManagement
//
//  Created by MAC on 09/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMUpdateTaskVC : UIViewController <UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *lbl_Delete;
    __weak IBOutlet UILabel *lbl_TaskName;
    __weak IBOutlet UITableView *tbl_TaskList;
    
}
@end
