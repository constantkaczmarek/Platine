//
//  MapViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 13/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapViewController.h"

@implementation MapViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.BarMap addAnnotation:self.bar];
    [self.BarMap showAnnotations:@[self.bar] animated:YES];

}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}




- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    //Calcul de la distance
    /*CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) self.bar.lat) longitude:((CLLocationDegrees)self.bar.lng)];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    
    self.bar.distance = distance;
    NSLog([NSString stringWithFormat:@"%f ahahha",self.bar.distance]);
    self.BarDistance.text = [NSString stringWithFormat: @"%.0f m",self.bar.distance];*/
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.BarMap setRegion:[mapView regionThatFits:region] animated:YES];
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    self.locationManager = locations.lastObject;
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.BarMap setShowsUserLocation:YES];
    }
}

@end