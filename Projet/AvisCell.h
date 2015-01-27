//
//  AvisCell.h
//  Projet
//
//  Created by Kaczmarek Constant on 06/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_AvisCell_h
#define Projet_AvisCell_h

#import <UIKit/UIKit.h>

@interface AvisCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *AvisAuteur;
@property (weak, nonatomic) IBOutlet UITextView *AvisText;
@property (weak, nonatomic) IBOutlet UILabel *AvisTime;
@property (weak, nonatomic) IBOutlet UILabel *AvisRating;

@end

#endif