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

-(void)initBiere{
    
    [bieres addObject:@"Leffe"];
    [bieres addObject:@"Heinek"];
    [bieres addObject:@"Delirium"];
    [bieres addObject:@"et plein d'autres"];

}

@end