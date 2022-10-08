//
//  CustomCVC.h
//  Order Management
//
//  Created by MAC on 01/01/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCVC : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_Catgory;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CategoryName;
@property (weak, nonatomic) IBOutlet UIImageView *img_Product;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Sku;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ProductName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ShortDescription;
@property (weak, nonatomic) IBOutlet UIImageView *img_TaskProgress;
@property (weak, nonatomic) IBOutlet UIImageView *img_Task;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Task;
@property (weak, nonatomic) IBOutlet UIView *view_ProductDescription;

@property (weak, nonatomic) IBOutlet UIImageView *imgTick;
@property (weak, nonatomic) IBOutlet UILabel *lblQuantity;

@end
