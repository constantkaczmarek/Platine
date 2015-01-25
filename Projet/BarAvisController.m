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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Avis";
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bar.avis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AvisCell *cell = [self.AvisTable dequeueReusableCellWithIdentifier:@"AvisCell" forIndexPath:indexPath];
    
    NSDictionary *avis =[self.bar.avis objectAtIndex:indexPath.row];
    
    cell.AvisAuteur.text = avis[@"author_name"];
    cell.AvisText.text = avis[@"text"];
    cell.AvisRating.text = [NSString stringWithFormat:@"%@",avis[@"rating"]];
    
    return cell;

}

@end