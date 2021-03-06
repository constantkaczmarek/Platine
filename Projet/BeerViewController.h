//
//  BeerViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 14/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BeerViewController_h
#define Projet_BeerViewController_h
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Beer.h"
#import "DXStarRatingView.h"
#import "BarsViewController.h"


@interface BeerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager* locationManager;
}

@property (retain, nonatomic) Beer *beer;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (weak, nonatomic) IBOutlet UIImageView *BeerImage;
@property (weak, nonatomic) IBOutlet UITableView *BeerTableView;
@property (weak, nonatomic) IBOutlet UITextView *BeerInfos;
@property (weak, nonatomic) IBOutlet UILabel *BeerRating;
@property (weak, nonatomic) IBOutlet UILabel *BeerDegre;
@property (weak, nonatomic) IBOutlet UIButton *BeerNoter;
@property (weak, nonatomic) IBOutlet UILabel *BeerType;
@property (weak, nonatomic) IBOutlet DXStarRatingView *RatingBar;

@end

#endif
