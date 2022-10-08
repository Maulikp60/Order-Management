//
//  OMMapVC.m
//  OrderManagement
//
//  Created by MAC on 02/02/16.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "OMMapVC.h"
#import "DatabaseManager.h"

@interface OMMapVC ()<MKMapViewDelegate>
{
    DatabaseManager *objDatabaseManager;
    NSMutableArray *arr_MapData;
    NSMutableArray *arrcount;
}
@end

@implementation OMMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    objDatabaseManager = [[DatabaseManager alloc]initwithDBName:@"Order Management System"];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Map";
    arr_MapData = [[objDatabaseManager Getlocation] mutableCopy];
    arrcount = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3", nil];
    [self initViews];
    
    [self addAllPins];
}
-(void)initViews
{
    map.delegate = self;
    map.showsUserLocation = YES;
    
    MKCoordinateRegion region = map.region;
    
    //region.center = CLLocationCoordinate2DMake(12.9752297537231, 80.2313079833984);
    
    region.span.longitudeDelta /= 1.0; // Bigger the value, closer the map view
    region.span.latitudeDelta /= 1.0;
    [map setRegion:region animated:NO]; // Choose if you want animate or not
    
}


-(void)addAllPins
{
    map.delegate=self;
    
    
//    NSMutableArray *arrCoordinateStr = [[NSMutableArray alloc] initWithCapacity:arr_MapData.count];
//    for (int i = 0; i <arr_MapData.count; i++) {
//        [arrCoordinateStr addObject:arr_MapData[i][@"latitude"],arr_MapData[i][@"longitude"]];
//    }
////    [arrCoordinateStr addObject:@"22.3,73.2"];
////    [arrCoordinateStr addObject:@"22.3, 70.78"];
////    [arrCoordinateStr addObject:@"12.9788103103638, 80.2412414550781"];
//    
    for(int i = 0; i < arr_MapData.count; i++)
    {
        [self addPinWithTitle:arr_MapData[i][@"firstname"] AndCoordinate:arr_MapData[i][@"latitude"] :arr_MapData[i][@"longitude"]];
    }
}

-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)latitude :(NSString *)longitude
{
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    
    // clear out any white space
   
    
    double latitude1 = [latitude doubleValue];
    double longitude1 = [longitude doubleValue];
    
    // setup the map pin with all data and add to map view
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude1, longitude1);
    
    mapPin.title = title;
    mapPin.coordinate = coordinate;
    
    [map addAnnotation:mapPin];
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    if (!pinView)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                         reuseIdentifier:SFAnnotationIdentifier];
        UIImage *flagImage = [UIImage imageNamed:@"Mapannonation"];
        // You may need to resize the image here.
        annotationView.image = flagImage;

        [pinView setValue:@"abc" forKey:@"title"];
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
//         [annotationView canShowCallout];
        
    }
    return pinView;
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view {

}
@end
