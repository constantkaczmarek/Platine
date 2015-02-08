//
//  BarsViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 30/11/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BarViewController.h"
#import "Bar.h"

#ifndef Projet_BarsViewController_h
#define Projet_BarsViewController_h

@interface BarsViewController : UITableViewController <CLLocationManagerDelegate,UISearchDisplayDelegate>
{
    CLLocationManager* locationManager;
}

@property (strong, nonatomic) IBOutlet UITableView *listBars;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeDistance;


@end

#endif
