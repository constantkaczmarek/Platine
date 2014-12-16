//
//  BarInfosViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BarInfosViewController.h"
#import "RKTweet.h"
#import "Venue.h"
#import "Bar.h"

#define kCLIENTID @"X150WG12SBRQXWTSVFVO14UNAAD2QMWNLTSYGGZTRBCJERDT"
#define kCLIENTSECRET @"1NVLTGHELTF3NEINUF5MWL0OY400T3VFTDXP52HHLM3DIYOW"
#define kKey @"AIzaSyCw-xTK5uQbecItdG-rQf9TuwPsYSPqjDY"

@interface BarInfosViewController()
{
    NSArray* _bars;
    NSArray* _venues;
}

@end


@implementation BarInfosViewController
@synthesize infos;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BarInfos.text = self.infos;
    
 /*  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTweet class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"name":   @"username",
                                                  }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+Sydney&key=AIzaSyBbfdBnjleHJ1HJNGliQ5ydaCDhTTY44OU"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"The public timeline Tweets: %@", [result array]);
    } failure:nil];
    [operation start];
*/
    [self configureRestKit];
    [self loadVenues];
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{
                                                       @"name": @"nom",
                                                       @"types" : @"type",
                                                       
                                                       }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"nearbysearch/json"
                                                keyPath:@"results"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    /*NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];*/
}

- (void)loadVenues
{
    NSString *loc = [NSString stringWithFormat:@"%f,%f",50.6353821,3.0651736]; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    NSString *key = kKey;
    
    NSDictionary *queryParams = @{@"location" : loc,
                                  @"radius" : @"500",
                                  @"types" : @"bar|cafe",
                                  @"name" : @"Lille",
                                  @"key" : key};
    

    [[RKObjectManager sharedManager] getObjectsAtPath: @"nearbysearch/json"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _bars = mappingResult.array;
                                                  for (Bar* b in _bars) {
                                                      NSLog(@"%@",b.nom);
                                                  }
                                                  
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];

    
    
    /*NSString *latLon = @"37.33,-122.03"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : @"4bf58dd8d48988d1e0931735",
                                  @"v" : @"20140118"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  for (Bar* b in _bars) {
                                                      NSLog(@"%@",b.nom);
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];*/
    }


@end
