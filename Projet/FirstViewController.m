//
//  FirstViewController.m
//  Projet
//
//  Created by Kaczmarek Constant on 30/11/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
{
    NSMutableArray *bars;
    NSMutableArray *searchResults;
}
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bars = [NSMutableArray array];
    [bars addObject:@"cool"];
    [bars addObject:@"genial"];
    [bars addObject:@"super"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    }
    else{
    return bars.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *nom =nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        nom = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        nom = [bars objectAtIndex:indexPath.row];
    }

   
    cell.textLabel.text = nom;

    return cell;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    searchResults = [bars copy];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    searchResults = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[bars filteredArrayUsingPredicate:resultPredicate]];
    
    return YES;
}


@end
