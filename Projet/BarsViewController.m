//
//  BarsViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 30/11/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarsViewController.h"
#import "BarCell.h"

@interface BarsViewController()
{
    NSMutableArray *bars;
    NSMutableArray *sortedBars;
    NSMutableArray *searchResults;
    CLLocationCoordinate2D currentLocalisation;
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
    bars = [NSMutableArray array];
    
    //Geolocalisation
    locationManager = [[CLLocationManager alloc] init];
    // Autorisation
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    }

    
    Bar *b = [[Bar alloc] init];
    
    b.nom = @"Spotilight";
    b.infos = @"Trop cool";
    b.address = @"Trop bien";
    b.lat = 50.6353821;
    b.lng = 3.0651736;
    [b calculDistance:locationManager.location];
    [bars addObject:b];
    
    Bar *b1 = [[Bar alloc] init];

    b1.nom = @"Plage";
    b1.infos = @"Trop cool";
    b1.address = @"Trop bien la plage";
    b1.lat = 50.6346472;
    b1.lng = 3.0646157;
    [b1 calculDistance:locationManager.location];
    [bars addObject:b1];
    
    
    Bar *b2 = [[Bar alloc] init];
    b2.nom = @"L'irlandais";
    b2.infos = @"Trop cool";
    b2.address = @"Trop bien l'irlandais";
    b2.lat = 50.6361987;
    b2.lng = 3.0654311;
    [b2 calculDistance:locationManager.location];
    [bars addObject:b2];
    
    Bar *b3 = [[Bar alloc] init];
    b3.nom = @"Razorback";
    b3.infos = @"Trop cool";
    b3.address = @"Trop bien l'irlandais";
    b3.lat = 50.6371241;
    b3.lng = 3.0658173;
    [b3 calculDistance:locationManager.location];
    [bars addObject:b3];
    
    /*
    [bars addObject:@"Spotlight"];
    [bars addObject:@"La plage"];
    [bars addObject:@"L'irlandais"];
    [bars addObject:@"Scotland"];
    [bars addObject:@"Razorback"];
    [bars addObject:@"Tchouka"];
    [bars addObject:@"SMILE"];
     
    [bars addObject:@"Magazine"];
    [bars addObject:@"Privilège"];
    [bars addObject:@"L'eden"];
    [bars addObject:@"Le Havre"];*/
    
    
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    NSArray *sortedBar = [bars sortedArrayUsingDescriptors:descriptor];

    sortedBars = [NSMutableArray array];
    [sortedBars addObjectsFromArray:sortedBar];

    
    self.navigationItem.title = @"Bars";
    
   }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    } else {
        return sortedBars.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];

    // Configuration de la cellule
    
    Bar *bar = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        bar = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        bar = [sortedBars objectAtIndex:indexPath.row];
    }
   
    cell.BarImage.image = [UIImage imageNamed:@"bar_icon.jpg"];
    cell.BarNom.text = bar.nom;
    cell.BarDistance.text = [NSString stringWithFormat:@"%.0f m",bar.getDistance];
    
    return cell;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    searchResults = [sortedBars copy];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    searchResults = nil;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nom contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[sortedBars filteredArrayUsingPredicate:predicate]];
   
    return YES;
}


//Géolocalisation
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager requestAlwaysAuthorization];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    locationManager = locations.lastObject;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        NSInteger selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        bvc.bar = [sortedBars objectAtIndex:selectedIndex];
    }
}


@end