//
//  BeerAddController.h
//  Projet
//
//  Created by Kaczmarek Constant on 25/01/2015.
//  Copyright (c) 2015 Kaczmarek Constant. All rights reserved.
//

#ifndef Projet_BeerAddController_h
#define Projet_BeerAddController_h
#import <UIKit/UIKit.h>

@interface BeerAddController : UIViewController <UIImagePickerControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *BeerNom;
@property (weak, nonatomic) IBOutlet UITextField *BeerDegre;
@property (weak, nonatomic) IBOutlet UITextField *BeerType;
@property (weak, nonatomic) IBOutlet UITextView *BeerInfos;
@property (weak, nonatomic) IBOutlet UIButton *BeerChoosePhoto;
@property (weak, nonatomic) IBOutlet UIButton *BeerAdd;
@property (weak, nonatomic) IBOutlet UIImageView *BeerImage;

@end

#endif
