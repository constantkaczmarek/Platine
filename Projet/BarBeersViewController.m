//
//  BarBeersViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 14/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarBeersViewController.h"
#import "BeerViewController.h"
#import "BeersViewController.h"
#import "BeerCell.h"
#import <RestKit/RestKit.h>
#define keyIp @"http://localhost:8080"


@interface BarBeersViewController()
{
    NSArray *beers;
    bool addBeerMode;
}

@end

@implementation BarBeersViewController

- (void) viewDidLoad{
    [super viewDidLoad];
  
    self.title = self.bar.nom;
    //self.title = @"Circus";
    [self configureRestKit];
    [self loadBeers];
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - configuration de la tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return beers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BarBeerCell" forIndexPath:indexPath];
    
    Beer *beer = nil;
   
    beer = [beers objectAtIndex:indexPath.row];
    
    
    cell.BeerNom.text = beer.nom;
    cell.BeerRating.text = beer.rating;
    //cell.BeerImage.image = [UIImage imageNamed:@"bar_icon.jpg"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPhoto:beer :cell];
        });
    });
    
    
    return cell;
}



#pragma mark - Charger bières
- (void)configureRestKit
{
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [RKObjectManager sharedManager].HTTPClient = client;
    RKObjectMapping *beerMapping = [RKObjectMapping mappingForClass:[Beer class]];
    [beerMapping addAttributeMappingsFromDictionary:@{
                                                      @"id": @"id",
                                                      @"name": @"nom",
                                                      @"icon":@"icon",
                                                      @"rating":@"rating",
                                                      @"infos": @"infos",
                                                      }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:beerMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"beersForPlaceId"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBeers
{
    NSDictionary *queryParams = @{@"placeId" : self.bar.placeid,};
    
    [[RKObjectManager sharedManager] getObjectsAtPath: @"beersForPlaceId"
                                           parameters: queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  beers = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no beers?': %@", error);
                                              }];
    
}

- (void)loadPhoto:(Beer *)beer:(BeerCell *)beercell
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",keyIp,beer.icon];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
     
     AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
     imageProcessingBlock:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
     beercell.BeerImage.image = image;
     
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     NSLog(@"%@", [error localizedDescription]);
     }];
     
     [operation start];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSInteger selectedIndex;
    
    if([[segue identifier] isEqualToString:@"detailBarBeerSegue"]){
        selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BeerViewController *bvc = [segue destinationViewController];
        bvc.beer = [beers objectAtIndex:selectedIndex];
    }else if([[segue identifier] isEqualToString:@"beersToAdd"]){
            selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
            BeersViewController *bvc = [segue destinationViewController];
            bvc.bar = self.bar;
        }
    
}


@end