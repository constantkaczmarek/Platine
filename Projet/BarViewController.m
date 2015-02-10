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


#pragma mark - Initialisation de la vue lorsqu'elle est chargée

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    //Affectation des informations disponibles aux différents composants de la vue
    self.Title.title = self.bar.nom;
    self.BarImage.image = [UIImage imageNamed:@"Bar_fake.jpg"];
    self.BarDistance.text = [NSString stringWithFormat:@"%.0f m",self.bar.distance];
    
    /*
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Autorisation
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
     */
    
    /*
    [self.view addSubview:self.WhiteRect];
    [self.view sendSubviewToBack:self.WhiteRect];
     */
    
    //Chargement des détails du bar
    [self configureRestKit];
    [self loadBar];
}


#pragma mark - Action des différents boutons liés aux informations du bar
-(IBAction)call:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.bar.tel]];
}

-(IBAction)openSite:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.bar.site]];
}

-(IBAction)openAdresse:(id)sender{
    NSString *addressOnMap = self.bar.address;
    NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@",addressOnMap];
    NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Configuration des requêtes REST

- (void)configureRestKit
{
    // Initialisation de restkit
    NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [RKObjectManager sharedManager].HTTPClient = client;

    // setup object mappings
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    
    //Configuration du mapping de la réponse du serveur afin de récupérer un objet bar
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
                                                     @"photos": @"photo",
                                                     }];
    
    
    //Création de la réponse configurée avec le mapping
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"details/json"
                                                                                           keyPath:@"result"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];

    //Ajout de la description de la réponse au manager de requêtes restkit
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBar
{

    //Configuration des paramètres
    NSString *key = kKey;
    NSDictionary *queryParams = @{@"placeid" : self.bar.id,
                                  @"key" : key};
    
    //Exécution de la requête et récupération de l'objet bar
    [[RKObjectManager sharedManager] getObjectsAtPath: @"details/json"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.bar = mappingResult.firstObject;

                                                  [self.BarNote setStars:(int)lroundf(self.bar.rating.floatValue) callbackBlock:^(NSNumber *newRating)
                                                   { NSLog(@"didChangeRating: %@",newRating);
                                                   }];
                                                  
                                                  [self.BarTelButton setTitle:self.bar.tel forState:UIControlStateNormal];
                                                  [self.BarTelButton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
                                                  
                                                  [self.BarSiteButton setTitle:self.bar.site forState:UIControlStateNormal];
                                                  [self.BarSiteButton addTarget:self action:@selector(openSite:) forControlEvents:UIControlEventTouchUpInside];
                                                  
                                                  [self.BarAdresseButton setTitle:self.bar.address forState:UIControlStateNormal];
                                                  [self.BarAdresseButton addTarget:self action:@selector(openAdresse:) forControlEvents:UIControlEventTouchUpInside];
                                                  
                                                  //Chargement de la photo du bar
                                                  [self loadPhoto];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no bar?': %@", error);
                                              }];
}


- (void)loadPhoto
{
 
    //Configuration des paramètres de la requête
    NSString *maxwith= @"400";
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&photoreference=%@&key=%@",maxwith,self.bar.photo.firstObject[@"photo_reference"],kKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //Configuration des réponses de la requête
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                self.BarImage.image = image;
                                                                                
                                                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                NSLog(@"%@", [error localizedDescription]);
                                                                            }];
    //Exécution de la requête
    [operation start];

}


#pragma mark - Transmission de l'objet bar

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    

    //Transmission de l'objet bar selon le bouton cliqué
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