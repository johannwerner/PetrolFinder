//
//  DetailViewController.h
//  NearestPetrolObc
//
//  Created by Johann Werner on 2014/08/31.
//  Copyright (c) 2014 Johann Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Station;
@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) Station *station;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

