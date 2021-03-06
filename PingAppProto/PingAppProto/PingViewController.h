//
//  PingViewController.h
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "UserRotaryWheel.h"

@interface PingViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UserRotaryWheelProtocol>

@property (nonatomic, strong) MKMapView *pingMapView;
@property (nonatomic, strong) UIToolbar *mapToolbar;
@property (nonatomic, strong) UIBarButtonItem *btn_startStopPing;
@property (nonatomic, strong) UIBarButtonItem *btn_segmentedControl;
@property (nonatomic, strong) UISegmentedControl *sc_chooseMapType;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *userLocations;

@property (nonatomic, strong) NSTimer *getTimer;
@property (nonatomic, assign) BOOL noUsersAlert;
@property (nonatomic, assign) BOOL centeredOnUser;

@property (nonatomic, strong) UIView *rotaryWheelSelector;
@property (nonatomic, assign) BOOL rotaryWheelVisible;
@property (nonatomic, strong) UserRotaryWheel *userWheel;

@end
