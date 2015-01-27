//
//  BeersViewController.m
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeersViewController.h"
#import "BeerViewController.h"
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import "Beer.h"
#import "BeerCell.h"
#define keyBeer @"cb4d603e5f9ce85509872034fb3667e2"

@interface BeersViewController ()
{
    NSArray *beers;
    NSArray *searchResults;
    bool addBeerMode;
    NSString *beerMode;
    UIActivityIndicatorView *indicator;

}
@end

const char keyAlert;

@implementation BeersViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar.jpg"]];
    self.view.opaque = true;

    
    if(self.bar){
        addBeerMode = true;
        beerMode = @"beersNotInPlaceId";

    }else{
        addBeerMode = false;
        beerMode = @"beers";
    }
    
    
    self.navigationItem.title = @"Bières";
    
    [self configureRestKit];
    [self loadBeers];
    
    self.BeerRefresh.target = self;
    self.BeerRefresh.action = @selector(refresh:);
    
    
}

- (IBAction)refresh:(id)sender{
    [self loadBeers];
}

#pragma mark - Configuration de la tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BeerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(4,5,366,80)];
    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
    whiteRoundedCornerView.layer.masksToBounds = NO;
    //whiteRoundedCornerView.layer.cornerRadius = 3.0;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    whiteRoundedCornerView.layer.shadowOpacity = 0.3;
    [cell.contentView addSubview:whiteRoundedCornerView];
    [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    }else
        return beers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BeerCell" forIndexPath:indexPath];
    
    Beer *beer = nil;
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        beer = [searchResults objectAtIndex:indexPath.row];
    } else {
        beer = [beers objectAtIndex:indexPath.row];
    }
    
    
    if (addBeerMode) {
        UIButton *addBar = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addBar.frame = CGRectMake(200.0f, 5.0f, 75.0f, 30.0f);
        [addBar setTitle:@"+" forState:UIControlStateNormal];
        [addBar addTarget:self action:@selector(addBar:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addBar;
    }
    
    cell.BeerNom.text = beer.nom;
    cell.BeerRating.text= beer.rating;
    cell.BeerImage.image = [UIImage imageNamed:@"bar_icon.jpg"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Beer* beer = [beers objectAtIndex:indexPath.row];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:beer.nom message:@"Confirmer l'ajout de la bière ? \n\n\n" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    
    objc_setAssociatedObject(alert, &keyAlert, beer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [alert show];
}


#pragma mark - Ajout d'une bière à un bar
- (IBAction)addBar:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Beer* beer = [beers objectAtIndex:[indexPath row]];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:beer.nom message:@"Confirmer l'ajout de la bière ? \n\n\n" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    
    objc_setAssociatedObject(alert, &keyAlert, beer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0){
        return;
    }
    if (buttonIndex == 1) {
        Beer *beer = objc_getAssociatedObject(alertView, &keyAlert);
        [self AddBeerToBar:beer :self.bar];
    }
}


- (void) AddBeerToBar:(Beer *)beer:(Bar *)bar{
    
   
    NSDictionary *json = @{@"placeId": bar.placeid,@"beerId":beer.id};
    
    NSError *erreur = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&erreur];
    
    if (jsonData) {
        NSLog(@"Envoie en cours");
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:8080/api/rest/request/create"]];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:nil
                                                          parameters:json];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            UIAlertView *alert = nil;
            
            if([response isEqualToString:@"false"]){
                alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"La demande a déjà été faite" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre demande a bien été enregistrée, nous la traiterons dans les prochains jours." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
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


#pragma mark - Charger bières
- (void)configureRestKit
{
    
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:8080/api/rest"];

    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [RKObjectManager sharedManager].HTTPClient = client;

    RKObjectMapping *beerMapping = [RKObjectMapping mappingForClass:[Beer class]];
    [beerMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"id",
                                                     @"name": @"nom",
                                                     @"infos": @"infos",
                                                     @"rating":@"rating",
                                                     @"degree":@"degre",
                                                     @"bars": @"bars",
                                                     }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:beerMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:beerMode
                                                                                           keyPath:@""
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBeers
{
    //Spinner lors du chargement
    UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 40, (self.view.frame.size.height/2) - 40, 80, 80)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.backgroundColor = [UIColor blackColor];
    [indicator layer].cornerRadius = 8.0;
    [indicator layer].masksToBounds = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    NSDictionary *queryParams = @{};
    
    
    if(addBeerMode){
        queryParams= @{@"placeId":self.bar.placeid};
    }
    
    [[RKObjectManager sharedManager] getObjectsAtPath: beerMode
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  beers = mappingResult.array;
                                                  [indicator stopAnimating];
                                                  [self.BeersList reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no beers?': %@", error);
                                              }];
    
}


#pragma mark - Configuration de la recherche dans la table view

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    searchResults = [beers copy];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    searchResults = nil;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nom contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[beers filteredArrayUsingPredicate:predicate]];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

#pragma mark - Transmission de la bière


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"detailBeerSegue"]){
        NSInteger selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BeerViewController *bvc = [segue destinationViewController];
        bvc.beer = [beers objectAtIndex:selectedIndex];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if([identifier isEqualToString:@"detailBeerSegue"]){
        if (addBeerMode) {
            return false;
        } else {
            return true;
        }
    }else
        return false;
}



@end