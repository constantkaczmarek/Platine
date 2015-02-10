//
//  BeerCell.m
//  Projet
//
//  Created by Kaczmarek Constant on 17/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <QuartzCore/QuartzCore.h>
#import "BeerCell.h"

@implementation BeerCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Mise en forme de l'image d'une cellule bière des tableview
    self.BeerImage.layer.cornerRadius = self.BeerImage.frame.size.height /2;
    self.BeerImage.layer.masksToBounds = YES;
    self.BeerImage.layer.shadowOpacity = .5;
    self.BeerImage.layer.shadowOffset = CGSizeMake(0,0);
    self.BeerImage.layer.shadowRadius = 10;
    self.BeerImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.BeerImage.layer.borderWidth = 0.0f;
    self.backgroundColor = [UIColor clearColor];

    
    /*if(!self.line){
     UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(-1, 92.0, 400, 1)];/// change size as you need.
     separatorLineView.backgroundColor = [UIColor lightGrayColor];// you can also put image here
     [self.contentView addSubview:separatorLineView];
     }*/
    
    
}

@end