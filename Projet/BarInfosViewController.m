//
//  BarInfosViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarInfosViewController.h"

@implementation BarInfosViewController
@synthesize infos;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BarInfos.text = self.infos;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
