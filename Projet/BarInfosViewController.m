//
//  BarInfosViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 07/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BarInfosViewController.h"
#import "Bar.h"
#import "EventCell.h"
#import "Event.h"


@interface BarInfosViewController()
{

}

@end


@implementation BarInfosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BarTel.text = self.bar.tel;
    self.BarAdress.text = self.bar.address;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventCell *cell = [self.BarEvents dequeueReusableCellWithIdentifier:@"TableEvent" forIndexPath:indexPath];
    
    // Configuration de la cellule
    Event *event =[self.bar.events objectAtIndex:indexPath.row];
    
    
    cell.EventUrl.text = event.url;
    cell.EventSummary.text = event.summary;
    //cell.EventUrl.text = @"tata";
    //cell.EventSummary.text = @"hahaha";
    
    return cell;
}

@end
