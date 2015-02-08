//
//  BarAddController.m
//  Projet
//
//  Created by Kaczmarek Constant on 25/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeerAddController.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFJSONRequestOperation.h>
#import <AFImageRequestOperation.h>
#import <RestKit/RestKit.h>
#import "Beer.h"
#define keyIp @"http://localhost:8080"

@interface BeerAddController()
{
    NSString *imageName;
    NSString *idRequest;
}

@end


@implementation BeerAddController

#pragma mark - Initialisation de la vue
- (void) viewDidLoad{
    [super viewDidLoad];
    
    //Bordure de l'image et du textview
    self.BeerImage.layer.cornerRadius = 1.0f;
    self.BeerImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.BeerImage.layer.borderWidth = 1.0f;
    
    self.BeerInfos.layer.cornerRadius = 1.0f;
    self.BeerInfos.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.BeerInfos.layer.borderWidth = 1.0f;

    //Désactivation du bouton d'ajout de bière
    [self.BeerAdd setEnabled:FALSE];
    
    //Placeholder textview
    self.BeerInfos.delegate = self;
    self.BeerInfos.text = @"Informations sur la bière";
    self.BeerInfos.textColor = [UIColor lightGrayColor];
    
    //Ajout des actions aux différents boutons
    [self.BeerChoosePhoto addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.BeerAdd addTarget:self action:@selector(addBeer:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Placeholder textview
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Informations sur la bière"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Informations sur la bière";
        textView.textColor = [UIColor lightGrayColor];
    }
}


#pragma mark - Ajout d'une photo
-(IBAction)addPhoto:(id)sender{
    //Ouverture de la librairie de photos
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    [self presentViewController:pickerLibrary animated:true completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *beerImage = image;
    self.BeerImage.image = beerImage;
    
    
    //Configuration de la requête POST sur le serveur
    NSDictionary *params = @{@"file":@"imageName",};
    NSData *imageData = UIImageJPEGRepresentation(beerImage, 0.5);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/createBeer"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    //Ecriture de la requête POST
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@%@",keyIp,@"/createBeer"] parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData){
                      [formData appendPartWithFileData:imageData name:@"file" fileName:@"request.jpg" mimeType:@"image/jpg"];
    }];
    
    //Ecriture des réponses à l'opération
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             //Parse de la réponse du serveur en cas de succès
                                             NSDictionary *resp = JSON;
                                             NSLog(@"%@",[resp objectForKey:@"id"]);
                                             idRequest = [NSString stringWithFormat:@"%@",[resp objectForKey:@"id"]];

                                             //Activation du bouton d'ajout de bière
                                             [self.BeerAdd setTitleColor:[UIColor colorWithRed:167.0/255.0f green:7.0/255.0f blue:20.0/255.0f alpha:1] forState:UIControlStateNormal];
                                             [self.BeerAdd setEnabled:TRUE];

                                             //Notification à l'utilisateur que l'opération est un succès.
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Transfert de l'image réussi." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles: nil];
                                             [alert show];
                                             
                                         }failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON)
                                         {
                                             NSLog(@"request: %@",request);
                                             NSLog(@"Failed: %@",[error localizedDescription]);
                                             
                                             //Notification à l'utilisateur que l'opération est un échec.
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Transfert de l'image échoué." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles: nil];
                                             [alert show];
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         //Affichage dans la console de la progression du transfert
         NSLog(@"Envoie %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
     }];
    
    //Execution de la requête POST
    [httpClient enqueueHTTPRequestOperation:operation];
    
    //Supprimer la vue de la librairie de photo
    [self dismissModalViewControllerAnimated:true];
    
}

#pragma mark - Ajout d'une bière (possible qu'après l'ajout d'une photo)
- (IBAction)addBeer:(id)sender{
    
    
    //Paramètres de la requêtes
    NSDictionary *json = @{@"name": self.BeerNom.text,
                           @"id": idRequest,
                           @"infos": self.BeerInfos.text,
                           @"degree": self.BeerDegre.text,
                           @"type": self.BeerType.text,
                           };
    NSError *erreur = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&erreur];
    
    if (jsonData) {
        NSLog(@"Envoie en cours");
        
        //Configuration de la requête POST
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",keyIp,@"/api/rest/beerRequest/create"]]];
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
          
            //Notification à l'utilisateur que la demande a bien été envoyée au serveur
            alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre demande a bien été enregistrée, nous la traiterons dans les prochains jours." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles:nil, nil];
            [alert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Erreur: %@", error);
            //Notification à l'utilisateur qu'il y a un problème avec le serveur actuellement
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Problème avec le serveur, veuillez réessayer." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles:nil];
            [alert show];
        }];
        [operation start];
        
    } else {
        NSLog(@"Impossible de sérializer %@: %@", json, erreur);
    }
}

@end