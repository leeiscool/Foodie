//
//  FoodieTableViewController.h
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHandlesMOC.h"
#import "DPHandlesRestaurantEntity.h"

@interface FoodieTableViewController : UITableViewController <DPHandlesMOC,DPHandlesRestaurantEntity>

- (void) receiveMOC:(NSManagedObjectContext *)incomingMOC;
- (void) receiveRestaurantEntity:(RestaurantEntity *) incomingRestaurantEntity;

@end
