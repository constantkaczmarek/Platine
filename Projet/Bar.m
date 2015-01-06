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

-(void)initBiere{
    
    [bieres addObject:@"Leffe"];
    [bieres addObject:@"Heinek"];
    [bieres addObject:@"Delirium"];
    [bieres addObject:@"et plein d'autres"];

}

- (NSString *)title {
    return self.nom;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"infos : %@", self.infos];
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



-(void)calculDistance:(CLLocation *)start{
    
    CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:((CLLocationDegrees) self.lat) longitude:((CLLocationDegrees)self.lng)];
    CLLocationDistance d = [barLocation distanceFromLocation:start];
    distance = d;
}

/*-(NSComparisonResult)compare:(Bar *)otherObject{
    return [self.getDistance compare:otherObject.get];
}*/



@end