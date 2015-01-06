//
//  BarViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 06/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RKRequestDescriptor.h>
#import "BarViewController.h"
#import "BarInfosViewController.h"
#import "Bar.h"
#define kKey @"AIzaSyCw-xTK5uQbecItdG-rQf9TuwPsYSPqjDY"


@implementation BarViewController
@synthesize bar;
@synthesize BarMap;


-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.Title.title = self.bar.nom;
    self.BarImage.image = [UIImage imageNamed:@"bar.jpg"];
    self.BarMap.delegate = self;
    
    [self loadPhoto];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self configureRestKit];
    [self loadBar];

    [self.BarMap addAnnotation:self.bar];
    //[self.BarMap showAnnotations:@[self.bar] animated:YES];

    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    //Calcul de la distance
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) self.bar.lat) longitude:((CLLocationDegrees)self.bar.lng)];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];

    self.bar.distance = distance;
    self.BarDistance.text = [NSString stringWithFormat: @"%.0f m",self.bar.distance];
    
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


#pragma mark - Configuration des requêtes REST

- (void)configureRestKit
{
    // setup object mappings
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"id",
                                                     @"name": @"nom",
                                                     @"icon": @"icon",
                                                     @"photos": @"photo",
                                                     //@"types": @"type",
                                                     @"formatted_address": @"address",
                                                     @"formatted_phone_number": @"tel",
                                                     @"geometry.location.lat": @"lat",
                                                     @"geometry.location.lng": @"lng",
                                                     
                                                     }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"details/json"
                                                                                           keyPath:@"result"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];


    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBar
{

    NSString *key = kKey;
    NSDictionary *queryParams = @{@"placeid" : self.bar.id,
                                  @"key" : key};
    
    [[RKObjectManager sharedManager] getObjectsAtPath: @"details/json"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.bar = mappingResult.firstObject;
                                                  self.BarAdress.text = self.bar.address;

                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no bar?': %@", error);
                                              }];
}


- (void)loadPhoto
{
 
    NSString *maxwith= @"400";
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&photoreference=%@&key=%@",maxwith,self.bar.photo.firstObject,kKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                self.BarImage.image = image;
                                                                                
                                                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                NSLog(@"%@", [error localizedDescription]);
                                                                            }];
    
    [operation start];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"barInfosSegue"]){
        BarInfosViewController *bivc = [segue destinationViewController];
        bivc.infos = self.bar.infos;
        
    }
}



@end