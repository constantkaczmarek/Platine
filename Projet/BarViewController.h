//
//  BarViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 06/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BarViewController_h
#define Projet_BarViewController_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Bar.h"

@interface BarViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>
{
}

@property (strong, nonatomic) Bar *bar;

@property (weak, nonatomic) IBOutlet UILabel *BarDistance;
@property (weak, nonatomic) IBOutlet UILabel *BarAdresse;
@property (weak, nonatomic) IBOutlet UITextView *BarTel;
@property (weak, nonatomic) IBOutlet UINavigationItem *Title;
@property (weak, nonatomic) IBOutlet UIImageView *BarImage;
@property (weak, nonatomic) IBOutlet UILabel *BarRating;
@property (weak, nonatomic) IBOutlet UILabel *BarSite;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *BarTelButton;
@property (weak, nonatomic) IBOutlet UIButton *BarAdresseButton;
@property (weak, nonatomic) IBOutlet UIButton *BarSiteButton;
@property (weak, nonatomic) IBOutlet UIButton *BarBeers;
@property (weak, nonatomic) IBOutlet UIButton *BarAvis;
@property (weak, nonatomic) IBOutlet UIButton *BarMap;
@property (weak, nonatomic) IBOutlet UIView *WhiteRect;


@end

#endif
