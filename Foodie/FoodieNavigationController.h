//
//  FoodieNavigationController.h
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHandlesMOC.h"

@interface FoodieNavigationController : UINavigationController <DPHandlesMOC>

- (void) receiveMOC:(NSManagedObjectContext *)incomingMOC;

@end
