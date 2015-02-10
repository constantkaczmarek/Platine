//
//  BarCell.h
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BarCell_h
#define Projet_BarCell_h
#import <UIKit/UIKit.h>

@interface BarCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *BarNom;
@property (weak, nonatomic) IBOutlet UIImageView *BarImage;
@property (weak, nonatomic) IBOutlet UILabel *BarDistance;
@property (nonatomic, strong) UIView *line;


@end


#endif
