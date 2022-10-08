//
//  OMContactUSVC.h
//  Order Management
//
//  Created by MAC on 18/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMContactUSVC : UIViewController
{
    __weak IBOutlet UITextField *txt_Name;
    __weak IBOutlet UITextField *txt_Email;
    __weak IBOutlet UITextField *txt_Phone;
    __weak IBOutlet UITextView *tv_Message;
    
    __weak IBOutlet UIButton *btnObj_Send;
    __weak IBOutlet UILabel *lbl_SendMessage;
}
@end
