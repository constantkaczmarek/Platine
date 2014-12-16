//
//  BeersViewController.m
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeersViewController.h"

@interface BeersViewController ()
{
    NSMutableArray *beers;
    NSMutableArray *tampon;
    NSMutableArray *tampon2;
}
@end

@implementation BeersViewController
@synthesize beersList;
@synthesize searchBar;


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
    beers = [NSMutableArray array];
    tampon = [NSMutableArray array];
    
    Beer *b1 = [[Beer alloc] init];
    b1.nom = @"Leffe";
    b1.type = @"Blonde";
    b1.infos = @"Trop bonne";
    b1.prix = 3.5;
    [beers addObject:b1];
    
    Beer *b2 = [[Beer alloc] init];
    b2.nom = @"1664";
    b2.type = @"Brune";
    b2.infos = @"Moins bonne";
    b2.prix = 4;
    [beers addObject:b2];
    
    Beer *b3 = [[Beer alloc] init];
    b3.nom = @"Rince cochon";
    b3.type = @"Rousse";
    b3.infos = @"Meilleure";
    b3.prix = 4.5;
    [beers addObject:b3];
    
    [tampon addObjectsFromArray:beers];
    
    self.navigationItem.title = @"Bières";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [beers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"beerItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    Beer *b = [beers objectAtIndex:indexPath.row];
    cell.textLabel.text = b.nom;
    cell.detailTextLabel.text = b.type;
    cell.imageView.image = [UIImage imageNamed:@"bar_icon.jpg"];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    tampon2 = [[NSMutableArray alloc] init];
    [tampon2 addObjectsFromArray:tampon];
    [beers removeAllObjects];
    if([searchText isEqualToString:@""])
    {
        [beers removeAllObjects];
        [beers addObjectsFromArray:tampon]; // Restitution des données originales
        return;
    }
    
    for(Beer *b in tampon2)
    {
        NSString *test = b.nom;
        NSRange r = [test rangeOfString:searchText];
        if(r.location != NSNotFound)
        {
            if(r.location== 0)
                [beers addObject:b];
        }
    }
}

@end