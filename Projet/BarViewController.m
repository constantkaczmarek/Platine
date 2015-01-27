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
#import "BarAvisController.h"
#import "MapViewController.h"
#import "BarBeersViewController.h"
#import "Bar.h"
#import "Avis.h"
#define kKey @"AIzaSyCiKxji5wKw7RDAzKcIWDzTl2eqDv7ilfY"



@implementation BarViewController
@synthesize bar;
@synthesize BarMap;


-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.Title.title = self.bar.nom;
    self.BarImage.image = [UIImage imageNamed:@"bar.jpg"];
    self.BarMap.delegate = self;
    self.BarDistance.text = [NSString stringWithFormat:@"%.0f m",self.bar.distance];
    
    [self loadPhoto];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    
    [self configureRestKit];
    [self loadBar];
}


#pragma mark - Configuration des requêtes REST

- (void)configureRestKit
{
    NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [RKObjectManager sharedManager].HTTPClient = client;

    // setup object mappings
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    
    [barMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"id",
                                                     @"place_id": @"placeid",
                                                     @"name": @"nom",
                                                     @"icon": @"icon",
                                                     @"photos": @"photo",
                                                     //@"types": @"type",
                                                     @"vicinity": @"address",
                                                     @"formatted_phone_number": @"tel",
                                                     @"geometry.location.lat": @"lat",
                                                     @"geometry.location.lng": @"lng",
                                                     @"user_ratings_total": @"nbrating",
                                                     @"rating":@"rating",
                                                     @"reviews":@"avis",
                                                     @"website":@"site",
                                                     @"opening_hours.weekday_text":@"opening",
                                                     @"opening_hours.open_now":@"open_now",
                                                     @"opening_hours.periods":@"periods",
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
                                                  self.BarRating.text =  [NSString stringWithFormat:@"%@ sur %@ avis",self.bar.rating,self.bar.nbrating];
                                                  self.BarTel.text = self.bar.tel;
                                                  self.BarAdresse.text = self.bar.address;
                                                  self.BarSite.text = self.bar.site;
                                               
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
    

    if([[segue identifier] isEqualToString:@"barBeersSegue"]){
        BarBeersViewController *bivc = [segue destinationViewController];
        bivc.bar = self.bar;
    }
    else if([[segue identifier] isEqualToString:@"barAvisSegue"]){
        BarAvisController *bac = [segue destinationViewController];
        bac.bar = self.bar;
    }
    else if([[segue identifier] isEqualToString:@"mapSegue"]){
        MapViewController *mp = [segue destinationViewController];
        mp.bar = self.bar;
    }
    
}



@end