//
//  UserLocAnnotation.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/20/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "UserLocAnnotation.h"

@implementation UserLocAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize userID = _userID;
@synthesize coordinate = _coordinate;

- (id)initWithTitle:(NSString *)t
           subtitle:(NSString *)subt
             userID:(NSString *)usrID
      andCoordinate:(CLLocationCoordinate2D)coord {

    self = [super init];
    if (self) {
        _title = t;
        _subtitle = subt;
        _userID = usrID;
        _coordinate = coord;
        
    }
    
    return  self;
}


@end
