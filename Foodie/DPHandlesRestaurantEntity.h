//
//  DPHandlesRestaurantEntity.h
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestaurantEntity.h"

@protocol DPHandlesRestaurantEntity <NSObject>

- (void) receiveRestaurantEntity:(RestaurantEntity *)incomingRestaurantEntity;


@end
