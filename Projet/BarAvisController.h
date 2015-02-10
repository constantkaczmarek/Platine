//
//  BarAvisController.h
//  Projet
//
//  Created by Kaczmarek Constant on 06/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BarAvisController_h
#define Projet_BarAvisController_h

#import <UIKit/UIkit.h>
#import "Bar.h"

@interface BarAvisController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (retain,atomic) Bar *bar;
@property (weak, nonatomic) IBOutlet UITableView *AvisTable;

@end


#endif
