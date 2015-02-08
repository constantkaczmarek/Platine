//
//  Bar.m
//  Projet
//
//  Created by Kaczmarek Constant on 03/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bar.h"

@interface Bar()
{
    NSMutableArray *bieres;
}
@end

@implementation Bar
@synthesize distance;


#pragma mark - Configuration de l'annotation du bar sur la mapview

- (NSString *)title {
    return self.nom;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"Note : %@", self.rating];
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D newCoordinate;
    
    newCoordinate.latitude = self.lat;
    newCoordinate.longitude = self.lng;
    
    return newCoordinate;
}

-(double)getDistance{
    return distance;
}


#pragma mark - Calcul de la distance entre le bar et une autre position

-(void)calculDistance:(CLLocation *)start{
    
    CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) self.lat) longitude:((CLLocationDegrees)self.lng)];
    CLLocationDistance d = [barLocation distanceFromLocation:start];
    distance = d;
}


@end