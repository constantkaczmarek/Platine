//
//  BeersViewController.m
//  Projet
//
//  Created by Alan Flament on 10/12/2014.
//  Copyright (c) 2014 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeersViewController.h"
#import "BeerViewController.h"
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import "Beer.h"
#import "BeerCell.h"
#define keyBeer @"cb4d603e5f9ce85509872034fb3667e2"
#define keyIp @"http://localhost:8080"

@interface BeersViewController ()
{
    NSArray *beers;
    NSArray *searchResults;
    bool addBeerMode;
    NSString *beerMode;
    UIActivityIndicatorView *indicator;
    bool isFilt;
    CLLocationManager* locationManager;

}
@end

const char keyAlert;

@implementation BeersViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialisation de la vue lorsqu'elle est chargée

/*-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:TRUE];
    [self viewDidLoad];
}*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Mode recherche
    isFilt = false;
    
    //Initialisation des variables selon le mode de la vue et du chemin de la requête
    //Affichage de toute les bières ou affichage des bières non associées au bar auquel on veut ajouter une bière
    if(self.bar){
        addBeerMode = true;
        beerMode = @"beersNotInPlaceId";

    }else{
        addBeerMode = false;
        beerMode = @"beers";
    }
    
    self.navigationItem.title = @"Bières";
    
    //Récupération du location manager des bières
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    //Chargement des bières
    [self configureRestKit];
    [self loadBeers];
    
    //Ajout de l'action de refresh de la page
    self.BeerRefresh.target = self;
    self.BeerRefresh.action = @selector(refresh:);
    
    
}

- (IBAction)refresh:(id)sender{
    [self loadBeers];
}

#pragma mark - Configuration de la tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Nombre de cellules selon si c'est la tableview des recherches ou la tableview de base
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //Mode recherche
        isFilt = true;
        return searchResults.count;
    }else{
        isFilt = false;
        return beers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configuration de la prototype Cell
    BeerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BeerCell" forIndexPath:indexPath];
    Beer *beer = nil;
    
    //Bière sélectionnée selon si c'est la tableview des recherches ou la tableview de base
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        beer = [searchResults objectAtIndex:indexPath.row];
    } else {
        beer = [beers objectAtIndex:indexPath.row];
    }
    
    //Chargement des icones en mode asynchrone
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPhoto:beer :cell];
        });
    });
    
    
    //Si la vue est en mode ajout de bière, ajout d'un bouton d'ajout à droite
    if (addBeerMode) {
        UIButton *addBar = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addBar.frame = CGRectMake(200.0f, 5.0f, 75.0f, 30.0f);
        [addBar setTitle:@"+" forState:UIControlStateNormal];
        [addBar setTintColor:[UIColor colorWithRed:167.0/255.0f green:7.0/255.0f blue:20.0/255.0f alpha:1]];
        [addBar addTarget:self action:@selector(addBar:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addBar;
    }
    
    //Affectation des champs de la cellule
    cell.BeerNom.text = beer.nom;
    cell.BeerRating.text= beer.type;
    return cell;
}

#pragma mark - Récupération de la localisation précédemment calculé


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //Paramètres de récupération de la position de l'utilisateur
    locationManager = locations.lastObject;
}

#pragma mark - Ajout d'une bière à un bar
- (IBAction)addBar:(id)sender
{
    //Récupération de la bière à ajouté selon le point où se trouve le bouton activé
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Beer* beer = [beers objectAtIndex:[indexPath row]];
    
    //Demande à l'utilisateur si il veut ajouter cette bière
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:beer.nom message:@"Confirmer l'ajout de la bière ? \n\n\n" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    
    //Association de la bière sélectionnée à la notification
    objc_setAssociatedObject(alert, &keyAlert, beer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0){
        return;
    }
    if (buttonIndex == 1) {
        //Récupération de la bière associé à la notification si appuie sur le bouton "Oui"
        Beer *beer = objc_getAssociatedObject(alertView, &keyAlert);
        [self addBeerToBar:beer :self.bar];
    }
}

- (void) addBeerToBar:(Beer *)beer:(Bar *)bar{
    
   //Paramètres de la requête
    NSDictionary *json = @{@"placeId": bar.placeid,@"beerId":beer.id};
    NSError *erreur = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&erreur];
    
    if (jsonData) {
        NSLog(@"Envoie en cours");
        //Configuration de la requête POST
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest/request/create"]]];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:nil
                                                          parameters:json];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        //Réponses à la requête
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            UIAlertView *alert = nil;
            
            //Si la demande a déjà été effectuée, annulation de l'opération et notification à l'utilisateur
            if([response isEqualToString:@"false"]){
                alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"La demande a déjà été faite" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                //Notification que la demande a été enregistrée
                alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre demande a bien été enregistrée, nous la traiterons dans les prochains jours." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Erreur: %@", error);
            //Notification qu'il y a eu un problème avec le serveur
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Problème avec le serveur, veuillez réessayer." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        [operation start];
        
    } else {
        NSLog(@"Impossible de sérializer %@: %@", json, erreur);
    }
}


#pragma mark - Charger bières
- (void)configureRestKit
{
    
    //Initialisation de Reskit
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest"]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [RKObjectManager sharedManager].HTTPClient = client;

    //Configuration du mapping de la réponse du serveur afin de récupérer un tableau d'objets bières
    RKObjectMapping *beerMapping = [RKObjectMapping mappingForClass:[Beer class]];
    [beerMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"id",
                                                     @"name": @"nom",
                                                     @"icon":@"icon",
                                                     @"img":@"img",
                                                     @"infos": @"infos",
                                                     @"rating":@"rating",
                                                     @"degree":@"degre",
                                                     @"type":@"type",
                                                     @"bars": @"bars",
                                                     }];
    
    //Création de la réponse configuré avec le mapping
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:beerMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:beerMode
                                                                                           keyPath:@""
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    //Ajout de la description de la réponse au manager de requête restkit
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)loadBeers
{
    //Spinner lors du chargement
    UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 40, (self.view.frame.size.height/2) - 40, 80, 80)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.backgroundColor = [UIColor blackColor];
    [indicator layer].cornerRadius = 8.0;
    [indicator layer].masksToBounds = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    
    //Configuration des paramètres de la requête selon le mode
    NSDictionary *queryParams = nil;
    if(addBeerMode){
        queryParams= @{@"placeId":self.bar.placeid};
    }
    
    //Exécution de la requête et récupération des bières
    [[RKObjectManager sharedManager] getObjectsAtPath: beerMode
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  beers = mappingResult.array;
                                                  [indicator stopAnimating];
                                                  //Affichage d'aucun résultats disponibles
                                                  if (!beers){
                                                      UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                                                      
                                                      messageLabel.text = @"Aucune données disponibles. Veuillez rééssayer.";
                                                      messageLabel.textColor = [UIColor blackColor];
                                                      messageLabel.numberOfLines = 0;
                                                      messageLabel.textAlignment = NSTextAlignmentCenter;
                                                      messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
                                                      [messageLabel sizeToFit];
                                                      
                                                      self.tableView.backgroundView = messageLabel;
                                                      self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                                  }
                                                  [self.BeersList reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no beers?': %@", error);
                                                  [indicator stopAnimating];
                                              }];
    
}

- (void)loadPhoto:(Beer *)beer:(BeerCell *)beercell
{
    //Configuration des paramètres de la requête
    NSString *url = [NSString stringWithFormat:@"%@%@",keyIp,beer.icon];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //Configuration des réponses de la requête
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                               beercell.BeerImage.image = image;
                                                                                               
                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               NSLog(@"%@", [error localizedDescription]);
                                                                                           }];
    //Exécution de la requête
    [operation start];
}


#pragma mark - Configuration de la recherche dans la table view

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    searchResults = [beers copy];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    searchResults = nil;
    isFilt = false;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //Utilisation d'un prédicat pour rechercher les noms des bières contenant le/les lettres inscrites dans la barre de recherche
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nom contains[c] %@", searchString];
    searchResults = [NSMutableArray arrayWithArray:[beers filteredArrayUsingPredicate:predicate]];
    
    return YES;
}


#pragma mark - Transmission de la bière

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Initialisation de la vue de détail de la bière en transmettant la bière de la tableview recherche ou de la table view originale si séléction d'une prototypecell
    if([[segue identifier] isEqualToString:@"detailBeerSegue"]){
        NSInteger selectedIndex;
        if(isFilt){
            selectedIndex =  [[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] row];
        }else
        {
            selectedIndex =  [[self.tableView indexPathForSelectedRow] row];
        }
        BeerViewController *bvc = [segue destinationViewController];
        
        if(isFilt){
        bvc.beer = [searchResults objectAtIndex:selectedIndex];
        bvc.currentLocation = locationManager.location;
            self.searchDisplayController.active = NO;

        }else{
            bvc.beer = [beers objectAtIndex:selectedIndex];
            bvc.currentLocation = locationManager.location;
            bvc.latitude = locationManager.location.coordinate.latitude;
            bvc.longitude = locationManager.location.coordinate.longitude;
        }
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //Désactivation du changement de vue si nous sommes en mode ajout de bière à un bar
    if([identifier isEqualToString:@"detailBeerSegue"]){
        if (addBeerMode) {
            return false;
        } else {
            return true;
        }
    }else
        return false;
}



@end