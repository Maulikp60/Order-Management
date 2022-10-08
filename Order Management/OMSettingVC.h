//
//  OMSettingVC.h
//  Order Management
//
//  Created by MAC on 18/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"
#import "SuperVC.h"

@interface OMSettingVC : SuperVC <UIAlertViewDelegate,kDropDownListViewDelegate>{
    __weak IBOutlet UIButton *btn_ObjWifi;
    __weak IBOutlet UIButton *btn_ObjData;
    __weak IBOutlet UISwitch *Obj_SwitchFrequency;
    DropDownListView * Dropobj;
    __weak IBOutlet UITextField *txt_Password;
    __weak IBOutlet UITextField *txt_Email;
    __weak IBOutlet UIButton *obj_Language;
    __weak IBOutlet UIButton *btn_ObjSave;
    __weak IBOutlet UILabel *lbl_Password;
    __weak IBOutlet UILabel *lbl_Email;
    __weak IBOutlet UIButton *btn_ObjReset;
    __weak IBOutlet UILabel *lbl_Wifi;
    __weak IBOutlet UILabel *lbl_AutomaticFrequncy;
    __weak IBOutlet UILabel *lbl_Language;
    __weak IBOutlet UILabel *lbl_Data;
    __weak IBOutlet UIButton *btn_objProductPrice;
    __weak IBOutlet UIButton *btn_objsku;
    
    __weak IBOutlet UILabel *lbl_Showsku;
    __weak IBOutlet UILabel *lbl_ShowProduct;
}
@end
