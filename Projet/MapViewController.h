//
//  MapViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 13/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_MapViewController_h
#define Projet_MapViewController_h
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Bar.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) Bar *bar;
@property (weak, nonatomic) IBOutlet MKMapView *BarMap;
@property (strong, nonatomic) CLLocationManager *locationManager;



@end


#endif
