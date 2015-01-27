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
    UIRefreshControl *refreshControl;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    barsCache = [[NSCache alloc] init];
    
    
    //Geolocalisation et chargement des bars
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
    

    self.navigationItem.title = @"Bars";
    [self loadBars];
    
    
    //Action refresh
    self.refreshBar.target = self;
    self.refreshBar.action = @selector(refresh:);

}

- (IBAction)refresh:(id)sender{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    [self loadBars];
    
}

#pragma mark - Configuration de la table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BarCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    } else {
        return _bars.count;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    
    // Configuration de la cellule
    Bar *bar = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView){
        [self.searchDisplayController.searchResultsTableView registerClass:[BarCell class] forCellReuseIdentifier:@"MyIdentifier"];
        bar = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        bar = [_bars objectAtIndex:indexPath.row];
    }
    
    /*dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: bar.icon]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.BarImage.image = [UIImage imageWithData: data];
        });
    });*/
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: bar.icon]];
        if ( bar.photo == nil ){
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.BarImage.image = [UIImage imageWithData: data];
            });
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPhoto:bar :cell];
        });
    });
    
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
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nom contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[_bars filteredArrayUsingPredicate:predicate]];
   
    return YES;
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
    
    for (Bar* b in _bars) {
        
        CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) b.lat) longitude:((CLLocationDegrees)b.lng)];
        CLLocationDistance d = [barLocation distanceFromLocation:locationManager.location];
        b.distance = d;
    }
    
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    _bars = [_bars sortedArrayUsingDescriptors:descriptor];
    
    [self.tableView reloadData];
}


#pragma mark - Configuration des requêtes REST


- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    [RKObjectManager sharedManager].HTTPClient = client;
    
    // setup object mappings
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
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"nearbysearch/json"
                                                                                           keyPath:@"results"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBars
{
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
    
    locationManager = [[CLLocationManager alloc] init];

    [locationManager startUpdatingLocation];
    
    NSString *loc = [NSString stringWithFormat:@"%f,%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    //NSString *loc = [NSString stringWithFormat:@"%f,%f",50.6353821,3.0651736];
    NSString *key = kKey;
    
    NSDictionary *queryParams = @{@"location" : loc,
                                  @"radius" : @"500",
                                  @"types" : @"bar",
                                  //@"name" : @"Lille",
                                  @"key" : key};
    
    //méthode asynchrone à cet endroit la
    
    [[RKObjectManager sharedManager] getObjectsAtPath: @"nearbysearch/json"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _bars = mappingResult.array;
                                                  
                                                  
                                                  if(barsCache == nil){
                                                      [barsCache setObject: _bars forKey: @"listBars"];
                                                      NSLog(@"cache rempli");
                                                  }else if(_bars.count == 0 && barsCache!= nil){
                                                      _bars = [barsCache objectForKey:@"listBars"];
                                                      NSLog([NSString stringWithFormat:@"%lu ",(unsigned long)_bars.count]);
                                                      [self sortBarsByDistance];
                                                  }
  
                                                  for (Bar *b in [barsCache objectForKey:@"listBars"]) {
                                                      NSLog(@"tesrt");
                                                      NSLog(b.nom);
                                                  }
                                                  
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
                                                  [self sortBarsByDistance];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no bar?': %@", error);
                                                  [indicator stopAnimating];
                                              }];

}

- (void)loadPhoto:(Bar *)bar:(BarCell *)barcell
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
    
}

#pragma mark - Transmission du bar


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        NSInteger selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        bvc.bar = [_bars objectAtIndex:selectedIndex];
    }
}


@end