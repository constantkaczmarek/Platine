//
//  BarViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 06/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarViewController.h"
#import "BarInfosViewController.h"
#import "Bar.h"

@implementation BarViewController
@synthesize bar;
@synthesize BarMap;


-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.Title.title = self.bar.nom;
    self.BarImage.image = [UIImage imageNamed:@"bar.jpg"];
    self.BarMap.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    [self.BarMap addAnnotation:self.bar];
    //[self.BarMap showAnnotations:@[self.bar] animated:YES];
    
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{

    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) self.bar.lat) longitude:((CLLocationDegrees)self.bar.lng)];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];

    self.BarDistance.text = [NSString stringWithFormat: @"%.0f m",distance];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.BarMap setRegion:[self.BarMap regionThatFits:region] animated:YES];
    
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

/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [mapView setRegion:region animated:YES];
}
*/


/*
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views

{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    [mv setRegion:region animated:YES];
}*/


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"barInfosSegue"]){
        BarInfosViewController *bivc = [segue destinationViewController];
        bivc.infos = self.bar.infos;
        
    }
}

@end