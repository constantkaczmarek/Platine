//
//  BeerCell.h
//  Projet
//
//  Created by Kaczmarek Constant on 17/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BeerCell_h
#define Projet_BeerCell_h
#import <UIKit/UIKit.h>

@interface BeerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *BeerImage;
@property (weak, nonatomic) IBOutlet UILabel *BeerNom;
@property (weak, nonatomic) IBOutlet UILabel *BeerRating;

@end

#endif
