//
//  OMHomeVC.h
//  Order Management
//
//  Created by MAC on 29/12/15.
//  Copyright © 2015 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperVC.h"
@interface OMHomeVC : SuperVC <UIAlertViewDelegate>
{
    __weak IBOutlet UICollectionView *clv_TaskList;
    __weak IBOutlet UILabel *lbl_CustomerName;
    __weak IBOutlet UIView *view_Task;
    __weak IBOutlet UITextView *txt_ServerComment;
    NSString *strID;
    NSMutableDictionary *DictPostAddress;
    
    __weak IBOutlet UILabel *lbl_Productprocess;
    __weak IBOutlet UILabel *lbl_ImageProcess;
    __weak IBOutlet UILabel *lbl_ObjMap;
    __weak IBOutlet UILabel *lbl_ObjCustomer;
    __weak IBOutlet UILabel *lbl_ObjContactUs;
    __weak IBOutlet UILabel *lbl_ObjCatalog;
    __weak IBOutlet UILabel *lbl_ObjQuickOrder;
    __weak IBOutlet UILabel *lbl_ObjTask;
    __weak IBOutlet UILabel *lbl_ObjOrderHistory;
    
    __weak IBOutlet UIButton *btnObj_UpdateTask;
    __weak IBOutlet UIButton *btnObj_AddTask;
    
    __weak IBOutlet UILabel *lbl_NewTask;
    
    __weak IBOutlet UILabel *lbl_UpdateTask;
     NSMutableArray *arrcustID,*arrcustIDCopy;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblAgentName;
@property BOOL shouldStartSync;
@end

