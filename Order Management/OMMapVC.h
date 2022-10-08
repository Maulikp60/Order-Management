//
//  OMMapVC.h
//  OrderManagement
//
//  Created by MAC on 02/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SuperVC.h"
@interface OMMapVC : SuperVC
{
    __weak IBOutlet MKMapView *map;
}
@end
