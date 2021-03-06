//
//  BarAvisController.m
//  Projet
//
//  Created by Kaczmarek Constant on 06/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarAvisController.h"
#import "AvisCell.h"

@interface BarAvisController()
{
    CGFloat widthOfMyTextBox;
}

@end

@implementation BarAvisController

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Avis";
    widthOfMyTextBox = 250;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Configuration de la tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bar.avis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configuration de la prototypeCell
    AvisCell *cell = [self.AvisTable dequeueReusableCellWithIdentifier:@"AvisCell" forIndexPath:indexPath];
    
    //Affectation des informations aux différents composants de la vue
    NSDictionary *avis =[self.bar.avis objectAtIndex:indexPath.row];
    
    cell.AvisAuteur.text = avis[@"author_name"];
    cell.AvisTexte.text = avis[@"text"];
    NSString *noteAvis = avis[@"rating"];
    [cell.AvisNote setStars:noteAvis.intValue callbackBlock:^(NSNumber *newRating)
     { NSLog(@"didChangeRating: %@",newRating);
     }];
   
    /*CGFloat rowHeight = [self heightForText:cell.AvisAuteur.text];
    cell.AvisAuteur.frame = CGRectMake(0, 0, 300, rowHeight);*/
    
    return cell;

}

@end