//
//  Bar.h
//  Projet
//
//  Created by Kaczmarek Constant on 03/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_Bar_h
#define Projet_Bar_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Bar : NSObject <MKAnnotation>

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *infos;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *tel;
@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *rating;
@property (nonatomic, retain) NSString *nbrating;
@property (nonatomic, retain) NSString *test;
@property (nonatomic, retain) NSArray *type;
@property (nonatomic, retain) NSArray *photo;
@property (nonatomic,retain) NSArray *events;
@property (nonatomic,retain) NSArray *avis;
@property (nonatomic) double distance;


@property (nonatomic) double  lat;
@property (nonatomic) double  lng;

- (void)initBiere;
- (double) getDistance;
- (void) setDistance:(double)distance;

-(void)calculDistance:(CLLocation *)start;
//-(NSComparisonResult)compare:(Bar *)otherObject;

@end


#endif
