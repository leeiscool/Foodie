//
//  FoodieViewController.h
//  Foodie
//
//  Created by WangYing on 3/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHandlesMOC.h"
#import "DPHandlesRestaurantEntity.h"

@interface FoodieViewController : UIViewController <DPHandlesMOC>

- (void) receiveMOC:(NSManagedObjectContext *)incomingMOC;

@end

