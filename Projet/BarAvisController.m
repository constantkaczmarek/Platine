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

@implementation BarAvisController

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Avis";
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Configuration de la tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bar.avis.count;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *avis =[self.bar.avis objectAtIndex:indexPath.row];
    NSString *labelText = avis[@"text"];
    return [self heightForText:labelText];
}

- (CGFloat)heightForText:(NSString *)bodyText
{
    UIFont *cellFont = [UIFont systemFontOfSize:13];
    CGSize constraintSize = CGSizeMake(300, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = labelSize.height + 10;
    return height;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configuration de la prototypeCell
    AvisCell *cell = [self.AvisTable dequeueReusableCellWithIdentifier:@"AvisCell" forIndexPath:indexPath];
    
    //Affectation des informations aux différents composants de la vue
    NSDictionary *avis =[self.bar.avis objectAtIndex:indexPath.row];
    
    cell.AvisAuteur.text = avis[@"author_name"];
    cell.AvisText.text = avis[@"text"];
    cell.AvisRating.text = [NSString stringWithFormat:@"%@",avis[@"rating"]];
    
    /*CGFloat rowHeight = [self heightForText:cell.AvisAuteur.text];
    cell.AvisAuteur.frame = CGRectMake(0, 0, 300, rowHeight);*/
    
    return cell;

}

@end