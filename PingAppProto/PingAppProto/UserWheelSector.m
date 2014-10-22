//
//  UserWheelSector.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/21/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "UserWheelSector.h"

@implementation UserWheelSector

@synthesize minValue, maxValue, midValue, sector;

- (NSString *) description {
    return [NSString stringWithFormat:@"%i | %f, %f, %f", self.sector, self.minValue, self.midValue, self.maxValue];
}

@end
