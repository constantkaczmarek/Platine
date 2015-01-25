//
//  BeerViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 14/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BeerViewController.h"
#import "BarViewController.h"
#import "BarCell.h"
#import "Bar.h"

@interface BeerViewController()
{
    NSArray *bars;
    NSMutableArray *sortedBars;
    CLLocation *currentLocation;
    UITextField *noteField;

}
@end


@implementation BeerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.BeerInfos.text = self.beer.infos;
    self.BeerImage.image = [UIImage imageNamed:@"bar_icon.jpg"];
    self.title = self.beer.nom;
    self.BeerDegre.text = self.beer.degre;
    self.BeerRating.text = self.beer.rating;
    
    [self configureRestKit];
    locationManager = [[CLLocationManager alloc] init];
    
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        [locationManager requestAlwaysAuthorization];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        currentLocation = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)locationManager.location.coordinate.latitude longitude:(CLLocationDegrees)locationManager.location.coordinate.longitude];
    }

    [self loadBars];
    [self.BeerNoter addTarget:self action:@selector(addNote:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Ajout d'une note

- (IBAction)addNote:(id)sender{
    
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:self.beer.nom message:@"Confirmer l'ajout de la bière ? \n\n\n" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Noter", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSString *note = [alertView textFieldAtIndex:0].text;
        [self sendNote:self.beer :note];
    }
}

- (void) sendNote:(Beer *)beer:(NSString *)note{
    
    
    NSUUID *id_unique = [[UIDevice currentDevice] identifierForVendor];
    NSString *deviceId = [id_unique UUIDString];
    
    NSDictionary *json = @{@"idMac": deviceId,@"note":note,@"idBeer":self.beer.id};
    
    NSError *erreur = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&erreur];

    if (jsonData) {
        NSLog(@"Envoie en cours");
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:8080/api/rest/rating/addVote"]];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:nil
                                                          parameters:json];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Print the response body in text
            NSLog(@"Réponse: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre (nouvelle) note a bien été prise en compte." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
            [alert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Erreur: %@", error);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Problème avec le serveur, veuillez réessayer." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        [operation start];
        
    } else {
        NSLog(@"Impossible de sérializer %@: %@", json, erreur);
    }
    
}


#pragma mark - Configuration de la tableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BarCell *cell = [self.BeerTableView dequeueReusableCellWithIdentifier:@"BeerBarCell" forIndexPath:indexPath];
    
    Bar *bar = [bars objectAtIndex:indexPath.row];
    
    cell.BarNom.text = bar.nom;
    cell.BarDistance.text = [NSString stringWithFormat:@"%.0f m",bar.distance];
    cell.BarImage.image = [UIImage imageNamed:@"bar.jpg"];
        
    return cell;
    
}

#pragma mark - Configuration de la géolocalistion

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager requestAlwaysAuthorization];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    locationManager = locations.lastObject;
    if(locationManager == nil){
        [locationManager startUpdatingLocation];
    }
    
}

- (void)sortBarsByDistance
{
    
    for (Bar* b in bars) {
        CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) b.lat) longitude:((CLLocationDegrees)b.lng)];
        CLLocationDistance d = [barLocation distanceFromLocation:currentLocation];
        b.distance = d;
    }
    
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    bars = [bars sortedArrayUsingDescriptors:descriptor];
    
    [self.BeerTableView reloadData];
}


#pragma mark - Configuration des requêtes REST


- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:8080/api/rest"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    [RKObjectManager sharedManager].HTTPClient = client;
    
    // setup object mappings
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{
                                                     @"placeId": @"id",
                                                     @"name": @"nom",
                                                     @"rating":@"rating",
                                                     @"lat": @"lat",
                                                     @"lng": @"lng",
                                                    }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"barsForBeer"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBars
{
    
    // NSString *loc = [NSString stringWithFormat:@"%f,%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    
    NSDictionary *queryParams = @{@"id" : self.beer.id,
                                 };
    
    [[RKObjectManager sharedManager] getObjectsAtPath: @"barsForBeer"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  bars = mappingResult.array;
                                                  self.BeerDegre.text = self.beer.degre;
                                                  self.BeerRating.text = self.beer.rating;
                                                  [self sortBarsByDistance];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no bar?': %@", error);
                                              }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"beerBarSegue"]){
        NSInteger selectedIndex =  [[self.BeerTableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        bvc.bar = [bars objectAtIndex:selectedIndex];
    }
}

@end