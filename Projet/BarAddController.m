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

@interface BeerAddController()
{
    NSString *imageName;
    NSString *idRequest;
}

@end


@implementation BeerAddController

- (void) viewDidLoad{
    [super viewDidLoad];
    [self.BeerAdd setEnabled:FALSE];
    [self.BeerChoosePhoto addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.BeerAdd addTarget:self action:@selector(addBeer:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


-(IBAction)addPhoto:(id)sender{
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    [self presentViewController:pickerLibrary animated:true completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *beerImage = image;
    self.BeerImage.image = beerImage;
    
    //[self addImage:beerImage];

    NSDictionary *params = @{@"file":@"imageName",};
    
    NSData *imageData = UIImageJPEGRepresentation(beerImage, 0.5);
    
    /*[params setObject:@"myUserName" forKey:@"username"];
    [params setObject:@"1234" forKey:@"password"];*/
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://172.20.10.4:8080/createBeer"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:nil parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData){
                      [formData appendPartWithFileData:imageData name:@"file" fileName:@"request.jpg" mimeType:@"image/jpg"];
    }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             NSDictionary *resp = JSON;
                                             NSLog(@"%@",[resp objectForKey:@"id"]);
                                             idRequest = [NSString stringWithFormat:@"%@",[resp objectForKey:@"id"]];

                                             [self.BeerAdd setEnabled:TRUE];
                                             
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Transfet de l'image en cours." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles: nil];
                                             [alert show];
                                             
                                         }failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON)
                                         {
                                             NSLog(@"request: %@",request);
                                             NSLog(@"Failed: %@",[error localizedDescription]);
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         NSLog(@"Envoie %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
     }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
    
    
    [self dismissModalViewControllerAnimated:true];
    
}

- (IBAction)addBeer:(id)sender{
    
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
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://172.19.158.13:8080/api/rest/beerRequest/create"]];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:nil
                                                          parameters:json];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            UIAlertView *alert = nil;
          
            alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Votre demande a bien été enregistrée, nous la traiterons dans les prochains jours." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles:nil, nil];
            [alert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Erreur: %@", error);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Informations" message:@"Problème avec le serveur, veuillez réessayer." delegate:self cancelButtonTitle:@"Fermer" otherButtonTitles:nil];
            [alert show];
        }];
        [operation start];
        
    } else {
        NSLog(@"Impossible de sérializer %@: %@", json, erreur);
    }
    
}

@end