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
{
    double distance;
}

@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *infos;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *rating;


@property (nonatomic) double  lat;
@property (nonatomic) double  lng;

- (void)initBiere;
- (double) getDistance;
- (void) setDistance:(double)distance;

-(void)calculDistance:(CLLocation *)start;
//-(NSComparisonResult)compare:(Bar *)otherObject;

@end


#endif
