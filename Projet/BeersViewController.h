//
//  BeersViewController.h
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Beer.h"
#ifndef Projet_BeersViewController_h
#define Projet_BeersViewController_h

@interface BeersViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *beersList;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

#endif
