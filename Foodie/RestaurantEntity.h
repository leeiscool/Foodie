//
//  RestaurantEntity.h
//  Foodie
//
//  Created by WangYing on 2/26/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RestaurantEntity : NSManagedObject

@property (nonatomic, retain) NSString * restaurantDetails;
@property (nonatomic, retain) NSDate * restaurantDueDate;
@property (nonatomic, retain) NSData * restaurantPic;
@property (nonatomic, retain) NSString * restaurantRate;
@property (nonatomic, retain) NSString * restaurantTitle;

@end
