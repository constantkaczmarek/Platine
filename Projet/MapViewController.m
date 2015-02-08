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

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

-(void) viewDidLoad{
    
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation de géolocaliser l'utilisateur
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //Ajout d'une annotation représentant le bar sur la mapview
    [self.BarMap addAnnotation:self.bar];
    [self.BarMap showAnnotations:@[self.bar] animated:YES];

}

-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Configuration de la géolocalistion

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //Mise à jour de la mapview selon les coordonnées de l'utilisateur
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 300, 300);
    [self.BarMap setRegion:[mapView regionThatFits:region] animated:YES];
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //Paramètres de récupération de la position de l'utilisateur quand autorisation
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    self.locationManager = locations.lastObject;
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //Autorisation de montrer la position de l'utilisateur sur la mapview
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.BarMap setShowsUserLocation:YES];
    }
}

@end