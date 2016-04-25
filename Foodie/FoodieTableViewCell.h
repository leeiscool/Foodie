//
//  FoodieTableViewCell.h
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantEntity.h"


@interface FoodieTableViewCell : UITableViewCell
@property (strong,nonatomic) RestaurantEntity *localRestaurantEntity;
@property (weak, nonatomic) IBOutlet UILabel *restaurantTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutline;
@property (weak, nonatomic) IBOutlet UILabel *restaurantRateLabel;

- (void) setInternalFields:(RestaurantEntity *)incomingRestaurantEntity;



@end
