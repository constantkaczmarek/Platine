//
//  BarCell.m
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarCell.h"


@implementation BarCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.BarImage.layer.cornerRadius = self.BarImage.frame.size.height /2;
    self.BarImage.layer.masksToBounds = YES;
    self.BarImage.layer.borderWidth = 0;

    /*if(!self.line){
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(-1, 92.0, 400, 1)];/// change size as you need.
        separatorLineView.backgroundColor = [UIColor lightGrayColor];// you can also put image here
        [self.contentView addSubview:separatorLineView];
    }*/

    
}

@end