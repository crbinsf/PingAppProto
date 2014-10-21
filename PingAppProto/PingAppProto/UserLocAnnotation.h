//
//  UserLocAnnotation.h
//  PingAppProto
//
//  Created by Clarke Bishop on 10/20/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserLocAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)t
           subtitle:(NSString *)subt
             userID:(NSString *)usrID
      andCoordinate:(CLLocationCoordinate2D)coord;
@end
