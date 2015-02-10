//
//  BeersViewController.h
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Beer.h"
#import "Bar.h"
#ifndef Projet_BeersViewController_h
#define Projet_BeersViewController_h
extern const char keyAlert;


@interface BeersViewController : UITableViewController <UISearchDisplayDelegate,UISearchControllerDelegate,UISearchBarDelegate,CLLocationManagerDelegate>


@property (nonatomic) bool *AddingBeer;
@property (retain, nonatomic) Bar *bar;
@property (strong, nonatomic) IBOutlet UITableView *BeersList;
@property (weak, nonatomic) IBOutlet UISearchBar *BeerSearch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BeerRefresh;

@end

#endif
