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
    NSMutableArray *tampon;
    NSMutableArray *tampon2;
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
    tampon = [NSMutableArray array];
    
    Bar *b = [[Bar alloc] init];
    
    b.nom = @"Spotilight";
    b.infos = @"Trop cool";
    b.address = @"Trop bien";
    b.lat = 50.6353821;
    b.lng = 3.0651736;
    [bars addObject:b];
    
    Bar *b1 = [[Bar alloc] init];

    b1.nom = @"Plage";
    b1.infos = @"Trop cool";
    b1.address = @"Trop bien";
    [bars addObject:b1];
    
    
    Bar *b2 = [[Bar alloc] init];
    b2.nom = @"L'irlandais";
    b2.infos = @"Trop cool";
    b2.address = @"Trop bien";
    [bars addObject:b2];
    
    Bar *b3 = [[Bar alloc] init];
    b3.nom = @"Razorback";
    b3.infos = @"Trop cool";
    b3.address = @"Trop bien";
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
    [tampon addObjectsFromArray:bars];
    
    self.navigationItem.title = @"Bars";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bars count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //même que paramètre Identifier du Prototype Cells dans MainStoryboard.storyboard
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    static NSString *CellIdentifier = @"MyIdentifier";
    BarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
              cell = [[BarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configuration de la cellule
    Bar *cellValue = [bars objectAtIndex:indexPath.row];
    //self.BarNom.text = cellValue.nom;
    cell.BarImage.image = [UIImage imageNamed:@"bar_icon.jpg"];
    cell.BarNom.text = cellValue.nom;
    cell.BarDistance.text = [NSString stringWithFormat:@"2 km"];
    //cell.imageView.image = [UIImage imageNamed:@"bar_icon.jpg"];
    return cell;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    tampon2 = [[NSMutableArray alloc] init];
    [tampon2 addObjectsFromArray:tampon];
    
    [bars removeAllObjects];
     if([searchText isEqualToString:@""])
          {
                [bars removeAllObjects];
                [bars addObjectsFromArray:tampon]; // Restitution des données originales
                return;
              }
    
      for(Bar *b in tampon2)
          {
                NSRange r = [b.nom rangeOfString:searchText];
            if(r.location != NSNotFound)
                    {
                          if(r.location== 0)
                                [bars addObject:b];
                        }
              }
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        NSInteger selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        bvc.bar = [bars objectAtIndex:selectedIndex];
    
    }
}


@end