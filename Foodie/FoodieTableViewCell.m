//
//  FoodieTableViewCell.m
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import "FoodieTableViewCell.h"


@implementation FoodieTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setInternalFields:(RestaurantEntity *)incomingRestaurantEntity{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    self.imageOutline.image = [UIImage imageWithData: incomingRestaurantEntity.restaurantPic];
    
    self.restaurantTitleLabel.text = incomingRestaurantEntity.restaurantTitle;
    
    self.restaurantDetailsLabel.text = incomingRestaurantEntity.restaurantDetails;
    
    self.restaurantRateLabel.text = [NSString stringWithFormat:@"Rate: %@", incomingRestaurantEntity.restaurantRate];
    
    self.localRestaurantEntity = incomingRestaurantEntity;
}

@end
