//
//  BarsViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 30/11/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BarsViewController.h"
#import "BarCell.h"
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
#import <ActionSheetPicker-3.0/ActionSheetDistancePicker.h>
#define kKey @"AIzaSyCiKxji5wKw7RDAzKcIWDzTl2eqDv7ilfY"


@interface BarsViewController()
{
    NSMutableArray *bars;
    NSMutableArray *sortedBars;
    NSMutableArray *searchResults;
    CLLocation *currentLocation;
    NSArray *_bars;
    UIActivityIndicatorView *indicator;
    NSCache *barsCache;
    NSString *distance;
    NSArray *listeDistance;
    NSString *pathJson;
    NSString *nameSearch;
    bool byName;
    bool isFilt;
    //UIRefreshControl *refreshControl;
}

@end


@implementation BarsViewController
@synthesize searchBar;
@synthesize listBars;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Bars";

    //Initialisation du cache
    barsCache = [[NSCache alloc] init];
    
    //Liste des distances possibles dans le tri des distances
    distance = @"500";
    listeDistance = [NSArray arrayWithObjects:@"500",@"1000",@"5000",nil];
    
    //Recherche par nom désactivée
    byName = false;
    
    //Geolocalisation et chargement des bars
    [self configureRestKit];
    locationManager = [[CLLocationManager alloc] init];
    
    //Autorisation de géolocaliser l'utilisateur
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {

        [locationManager requestAlwaysAuthorization];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        //Mise à jour de la localisation de l'utilisateur
        [locationManager startUpdatingLocation];
        currentLocation = [[CLLocation alloc] initWithLatitude:50.6353821 longitude:3.0651736];
    }
    
    //Mode recherche
    isFilt = false;

    //Chargement des bars
    [self loadBars];
    
    
    //Action refresh
    self.refreshBar.target = self;
    self.refreshBar.action = @selector(refresh:);
    
    //Action changer distance
    self.changeDistance.target = self;
    self.changeDistance.action = @selector(changeDistance:);

}


#pragma actions boutons
- (IBAction)refresh:(id)sender{
    byName = false;
    
    //Recalcul de la positon de l'utilisateur
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    
    //Rechargement des bars
    [self configureRestKit];
    [self loadBars];
}

- (IBAction)changeDistance:(id)sender{
    
    //Recalcul de la positon de l'utilisateur
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    
    //Affichage du UIPIicker permettant de changer la distance utilisée dans le tri de distance
    [ActionSheetStringPicker showPickerWithTitle:@"Distance (m)"
                                            rows:listeDistance
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           distance = selectedValue;
                                           [self loadBars];
                                       }
                                     cancelBlock:nil
                                          origin:sender];
}

-(IBAction)searchNameBar:(id)sender{
    
    //Recherche par nom activée
    byName = true;
    nameSearch = self.searchBar.text;
    self.searchDisplayController.active = NO;
    [self configureRestKit];
    [self loadBars];
}

#pragma configuration de la table view
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 83.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Nombre de cellules selon si c'est la tableview des recherches ou la tableview de base
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        //Création du bouton de recherche de bar par nom si aucun résultats
        if(searchResults.count == 0){
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(searchNameBar:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Rechercher par nom" forState:UIControlStateNormal];
            button.tintColor = [UIColor colorWithRed:167.0/255.0f green:7.0/255.0f blue:20.0/255.0f alpha:1];
            button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
            self.searchDisplayController.searchResultsTableView.backgroundView = button;
            self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        isFilt=true;
        return searchResults.count;
    } else {
        isFilt=false;
        return _bars.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configuration de la prototype Cell
    BarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    
    Bar *bar = nil;

    //Bar sélectionné selon si c'est la tableview des recherches ou la tableview de base
    if (tableView == self.searchDisplayController.searchResultsTableView){
        [self.searchDisplayController.searchResultsTableView registerClass:[BarCell class] forCellReuseIdentifier:@"MyIdentifier"];
        bar = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        bar = [_bars objectAtIndex:indexPath.row];
    }
    
    if([bar.nom isEqualToString:@"Circus"]){
        cell.BarImage.image = [UIImage imageNamed:@"Bar_fake.jpg"];
        
    }else {
        //Affectation de l'icone du bar
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: bar.icon]];
            //Si il n'y a pas de photos, affichage de l'icone de base de google
            if ( bar.photo == nil ){
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.BarImage.image = [UIImage imageWithData: data];
                });
            }
            //Sinon affichage de la photo du bar en minuscule
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadPhoto:bar :cell];
            });
        });

    }
    
    //Affectation des différents composants de la cellule
    cell.BarNom.text = bar.nom;
    cell.BarDistance.text = [NSString stringWithFormat:@"%.0f m",bar.getDistance];
    
    return cell;
}


#pragma mark - Configuration de la recherche dans la table view

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    searchResults = [_bars copy];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    searchResults = nil;
    isFilt = false;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //Utilisation d'un prédicat pour rechercher les noms des bar contenant le/les lettres inscrites dans la barre de recherche
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nom contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[_bars filteredArrayUsingPredicate:predicate]];
   
    return YES;
}


#pragma mark - Configuration de la géolocalistion

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //Paramètres de récupération de la position de l'utilisateur quand autorisation
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
    
    //NSString *loc = [NSString stringWithFormat:@"%f,%f",50.6277520,3.0569518];
    //CLLocation *loc = [[CLLocation alloc]initWithLatitude:50.6277520 longitude:3.0569518];
 
    //Calcul de la distance entre la position de l'utilisateur et chaque bar
    for (Bar* b in _bars) {
        CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) b.lat) longitude:((CLLocationDegrees)b.lng)];
        CLLocationDistance d = [barLocation distanceFromLocation:locationManager.location];
        b.distance = d;
    }
    
    /*NSMutableArray *ba = [NSMutableArray arrayWithArray:_bars];
    
    Bar *b = [[Bar alloc] init];
    b.nom = @"Circus";
    b.distance = 100;
    b.id = @"ChIJDSF01ITVwkcRRBMkZm-IoeU";
    
    [ba addObject:b];
   
    
    Bar *b1 = [[Bar alloc] init];
    b1.nom = @"Pub Mac Ewan's";
    b1.distance = 200;
    b1.id = @"ChIJWzlxLpvVwkcRFYOUkbc7xnU";
    b.photo = [NSArray arrayWithObjects:@"CnRnAAAAR55VY6-Y4Ww2ETLeD6MloHMBbgSam48WpuD_kK3Kc-Dtf1vk4j4wk6G3QnPFAmI_om8p8cpMAEV5Tdrou_0P_699tdk0yUZSSyKRUnXUT0j7IW3ACQQia6aTVRKyoiMDQ9MzzmkAjwiJ2IZmqD9cyxIQJgaifKpO-YfFJWAup_K9BRoUjZPWBPNsuyVFWdyQZysPG88TYCg", nil] ;
    
    [ba addObject:b1];*/
    
    //Tri des bars selon la distance
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    _bars = [_bars sortedArrayUsingDescriptors:descriptor];
    
    //Rechargement de la tableview
    [self.tableView reloadData];
}


#pragma mark - Configuration des requêtes REST

-(void)configureRestKit{

    // Initialisation de restkit
    NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place"];
    pathJson = @"nearbysearch/json";
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [RKObjectManager sharedManager].HTTPClient = client;
    
    //Configuration du mapping de la réponse du serveur afin de récupérer un tableau d'objets bars
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{
                                                     @"place_id": @"id",
                                                     @"name": @"nom",
                                                     @"icon": @"icon",
                                                     @"types": @"type",
                                                     @"geometry.location.lat": @"lat",
                                                     @"geometry.location.lng": @"lng",
                                                     @"photos.photo_reference": @"photo",
                                                     }];
    
    //Création de la réponse configurée avec le mapping
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:pathJson
                                                                                           keyPath:@"results"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    //Ajout de la description de la réponse au manager de requêtes restkit
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBars
{
    //Titre de la vue selon le mode
    if(byName){
        self.title = [NSString stringWithFormat:@"Resultat de \"%@\"",nameSearch];
    }else{
        self.title = @"Bars";
    }
    
    //Spinner lors du chargement
    UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 40, (self.view.frame.size.height/2) - 40, 80, 80)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.backgroundColor = [UIColor blackColor];
    [indicator layer].cornerRadius = 2.0;
    [indicator layer].masksToBounds = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    
    //Recalcule du location manager
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    
    //NSString *loc = [NSString stringWithFormat:@"%f,%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    
    //Configuration des paramètres selon le mode
    NSString *loc = [NSString stringWithFormat:@"%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    NSString *key = kKey;
    NSDictionary *queryParams = nil;
    
    if (byName) {
        queryParams= @{@"name" : nameSearch,
                       @"types":@"bar",
                       @"location":loc,
                       @"radius":@"10000",
                       @"key" : key};
    }else {
        queryParams= @{@"location" : loc,
                       @"radius" :distance,
                       @"types" : @"bar",
                       //@"name" : @"Lille",
                       @"key" : key};
    }
    
    //Exécution de la requête et récupération des bars
    [[RKObjectManager sharedManager] getObjectsAtPath: pathJson
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _bars = mappingResult.array;
                                                  

                                                  //Remplissage du cache
                                                  if(barsCache == nil){
                                                      [barsCache setObject: _bars forKey: @"listBars"];
                                                      NSLog(@"cache rempli");
                                                  }else if(_bars.count == 0 && barsCache!= nil){
                                                      _bars = [barsCache objectForKey:@"listBars"];
                                                      [self sortBarsByDistance];
                                                  }
                                                  
                                                  //Création du bouton de recherche par nom si aucun résultats
                                                  if (!_bars){
                                                      UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                                                      
                                                      messageLabel.text = @"Aucune données disponibles. Veuillez rééssayer.";
                                                      messageLabel.textColor = [UIColor blackColor];
                                                      messageLabel.numberOfLines = 0;
                                                      messageLabel.textAlignment = NSTextAlignmentCenter;
                                                      messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
                                                      [messageLabel sizeToFit];
                                                      
                                                      self.tableView.backgroundView = messageLabel;
                                                      self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                                  }
                                                  
                                                  [indicator stopAnimating];
                                                  //Tri par distance
                                                  [self sortBarsByDistance];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no bar?': %@", error);
                                                  [indicator stopAnimating];
                                              }];

}

- (void)loadPhoto:(Bar *)bar:(BarCell *)barcell
{
    
    //Configuration des paramètres de la requête
    NSString *maxwith= @"150";
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%@&photoreference=%@&key=%@",maxwith,bar.photo.firstObject,kKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //Configuration des réponses de la requête
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                               barcell.BarImage.image = image;
                                                                                               
                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               NSLog(@"%@", [error localizedDescription]);
                                                                                           }];
    //Exécution de la requête
    [operation start];
    
}

#pragma mark - Transmission du bar


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Initialisation de la vue de détail du bar en transmettant le bar de la tableview recherche ou de la table view originale si séléction d'une prototypecell
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        NSInteger selectedIndex;
        if(isFilt){
            selectedIndex =  [[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] row];
        }else
        {
            selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        }
        BarViewController *bvc = [segue destinationViewController];
        if(isFilt){
            bvc.bar = [searchResults objectAtIndex:selectedIndex];
            self.searchDisplayController.active = NO;
            
        }else{
            bvc.bar = [_bars objectAtIndex:selectedIndex];
        }
    }
}


@end