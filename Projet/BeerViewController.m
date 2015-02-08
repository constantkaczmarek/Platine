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
#define keyIp @"http://localhost:8080"


@interface BeerViewController()
{
    NSArray *bars;
    NSMutableArray *sortedBars;
    CLLocation *currentLocation;
    UITextField *noteField;

}
@end


@implementation BeerViewController

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Chargement de la photo de la bière en asynchrone
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPhoto];
        });
    });
    
    //Affectation des informations aux différents composants de la vue
    self.BeerInfos.text = self.beer.infos;
    self.title = self.beer.nom;
    self.BeerDegre.text = self.beer.degre;
    self.BeerRating.text = self.beer.rating;
    
    [self configureRestKit];
    
    //Configuration et récupération de la position actuelle
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;

    //Autorisation de géolocaliser l'utilisateur
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [locationManager requestAlwaysAuthorization];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        //Mise à jour de la localisation de l'utilisateur
        [locationManager startUpdatingLocation];
        currentLocation = [[CLLocation alloc] initWithLatitude:50.6353821 longitude:3.0651736];
    }

    //Chargement des bars associés à la bière
    [self loadBars];
    
    //Ajout de l'action noter une bière
    [self.BeerNoter addTarget:self action:@selector(addNote:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Ajout d'une note

- (IBAction)addNote:(id)sender{
    
    //Alerte permettant d'ajouter une note à la bière
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:self.beer.nom message:@"Inscrivez votre note ci-dessous. \n\n\n" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Noter", nil];
    
    //Ajout d'un champs pour inscrire la note
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Si clique sur bouton noter, envoie de la note au serveur
    if (buttonIndex==1) {
        NSString *note = [alertView textFieldAtIndex:0].text;
        [self sendNote:self.beer :note];
    }
}

- (void) sendNote:(Beer *)beer:(NSString *)note{
    
    //Récupération d'un identifiant unique pour ne pas noter pluieurs fois la même bière
    NSUUID *id_unique = [[UIDevice currentDevice] identifierForVendor];
    NSString *deviceId = [id_unique UUIDString];
    
    
    //Paramètres de la requête
    NSDictionary *json = @{@"idMac": deviceId,@"note":note,@"idBeer":self.beer.id};
    NSError *erreur = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&erreur];

    if (jsonData) {
        //Configuration de la requête POST
        NSLog(@"Envoie en cours");
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest/rating/addVote"]]];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:nil
                                                          parameters:json];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        //Réponses à la requête
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Réponse: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

            //Notification à l'utilisateur
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre (nouvelle) note a bien été prise en compte." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
            [alert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Erreur: %@", error);
            //Notification à l'utilisateur de l'échec de l'utilisateur
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Problème avec le serveur, veuillez réessayer." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        [operation start];
        
    } else {
        NSLog(@"Impossible de sérializer %@: %@", json, erreur);
    }
}


#pragma mark - Configuration de la tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configuration des cellules de la tableview des bars
    BarCell *cell = [self.BeerTableView dequeueReusableCellWithIdentifier:@"BeerBarCell" forIndexPath:indexPath];
    
    Bar *bar = [bars objectAtIndex:indexPath.row];
    
    //Affectation des données aux composants de la cellule
    cell.BarNom.text = bar.nom;
    cell.BarDistance.text = [NSString stringWithFormat:@"%.0f m",bar.distance];
    cell.BarImage.image = [UIImage imageNamed:@"Bar_fake.jpg"];
        
    return cell;
    
}

#pragma mark - Configuration de la géolocalistion

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //Paramètres de récupération de la position de l'utilisateur
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
    //Calcul de la distance entre la position de l'utilisateur et chaque bar
    for (Bar* b in bars) {
        CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) b.lat) longitude:((CLLocationDegrees)b.lng)];
        CLLocationDistance d = [barLocation distanceFromLocation:currentLocation];
        b.distance = d;
    }
    
    //Tri des bars selon la distance
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    bars = [bars sortedArrayUsingDescriptors:descriptor];
    
    //Rechargement de la tableview
    [self.BeerTableView reloadData];
}


#pragma mark - Configuration des requêtes REST
- (void)configureRestKit
{
    // Initialisation de restkit
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [RKObjectManager sharedManager].HTTPClient = client;
    
    //Configuration du mapping de la réponse du serveur afin de récupérer un tableau d'objets bars
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{
                                                     @"placeId": @"id",
                                                     @"name": @"nom",
                                                     @"rating":@"rating",
                                                     @"lat": @"lat",
                                                     @"lng": @"lng",
                                                     @"photos.photo_reference": @"photo",
                                                    }];
    
    //Création de la réponse configurée avec le mapping
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"barsForBeer"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    //Ajout de la description de la réponse au manager de requêtes restkit
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBars
{
    
    // NSString *loc = [NSString stringWithFormat:@"%f,%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    
    //Configuration des paramètres
    NSDictionary *queryParams = @{@"id" : self.beer.id,};
    
    //Exécution de la requête et récupération des bières
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

/*- (void)loadPhoto:(Bar *)bar:(BarCell *)barcell
{
    
    NSString *maxwith= @"150";
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&photoreference=%@&key=%@",maxwith,bar.photo.firstObject,kKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                               barcell.BarImage.image = image;
                                                                                               
                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               NSLog(@"%@", [error localizedDescription]);
                                                                                           }];
    
    [operation start];
    
}*/

- (void)loadPhoto{
    
    //Configuration des paramètres de la requête
    NSString *url = [NSString stringWithFormat:@"%@%@",keyIp,self.beer.img];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    //Configuration des réponses de la requête
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
     
        self.BeerImage.image = image;
     
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     NSLog(@"%@", [error localizedDescription]);
     }];
    
    //Exécution de la requête
    [operation start];
    
}


#pragma mark - Transmission du bar
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"beerBarSegue"]){
        NSInteger selectedIndex =  [[self.BeerTableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        bvc.bar = [bars objectAtIndex:selectedIndex];
    }
}

@end