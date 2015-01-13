//
//  BarInfosViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BarInfosViewController_h
#define Projet_BarInfosViewController_h


#import <UIKit/UIKit.h>
#import "Bar.h"

@interface BarInfosViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) Bar *bar;

@property (weak, nonatomic) IBOutlet UILabel *BarTel;
@property (weak, nonatomic) IBOutlet UILabel *BarAdress;
@property (weak, nonatomic) IBOutlet UITableView *BarEvents;


@end


#endif
