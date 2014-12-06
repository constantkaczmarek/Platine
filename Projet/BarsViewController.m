//
//  BarsViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 30/11/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarsViewController.h"

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
    [bars addObject:@"Le Havre"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configuration de la cellule
    NSString *cellValue = [bars objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
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
    
      for(NSString *name in tampon2)
          {
                NSRange r = [name rangeOfString:searchText];
            if(r.location != NSNotFound)
                    {
                          if(r.location== 0)
                                [bars addObject:name];
                        }
              }
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        NSInteger selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        BarViewController *bvc = [segue destinationViewController];
        
    
    }
}


@end