//
//  BarViewController.h
//  Projet
//
//  Created by Kaczmarek Constant on 06/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BarViewController_h
#define Projet_BarViewController_h

#import <UIKit/UIKit.h>
#import "Bar.h"

@interface BarViewController : UIViewController

@property (strong, nonatomic) Bar *bar;

@property (weak, nonatomic) IBOutlet UINavigationItem *Title;
@property (weak, nonatomic) IBOutlet UIImageView *BarImage;
@property (weak, nonatomic) IBOutlet UILabel *BarDistance;
@end

#endif
