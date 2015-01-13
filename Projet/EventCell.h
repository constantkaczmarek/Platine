//
//  EventCell.h
//  Projet
//
//  Created by Kaczmarek Constant on 06/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_EventCell_h
#define Projet_EventCell_h
#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *EventUrl;
@property (weak, nonatomic) IBOutlet UILabel *EventSummary;

@end

#endif
