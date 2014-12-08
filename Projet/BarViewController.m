//
//  BarViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 06/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarViewController.h"
#import "BarInfosViewController.h"
#import "Bar.h"

@interface BarViewController()
{
    Bar *bar;
}
@end

@implementation BarViewController
@synthesize bar;


-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.Title.title = self.bar.nom;
    self.BarImage.image = [UIImage imageNamed:@"bar.jpg"];
    self.BarDistance.text = [NSString stringWithFormat: @"%.2f km",self.bar.distance];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"barInfosSegue"]){
        BarInfosViewController *bivc = [segue destinationViewController];
        bivc.infos = self.bar.infos;
        
    }
}

@end