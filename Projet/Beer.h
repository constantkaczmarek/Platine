//
//  Beer.h
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_Beer_h
#define Projet_Beer_h

#import <UIKit/UIKit.h>

@interface Beer : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *img;
@property (nonatomic, retain) NSString *degre;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *rating;
@property (nonatomic, retain) NSString *infos;
@property (nonatomic, retain) NSArray *bars;

@end


#endif
