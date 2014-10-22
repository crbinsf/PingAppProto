//
//  PingViewController.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "PingViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "UserLocAnnotation.h"

@interface PingViewController ()

- (void)_startStopPing;
- (void)_mapTypeSelected;
- (void)_getUsersLocationData;
- (void)_showAlertWithTitle:(NSString *)title message:(NSString *)message;

- (void)_initialStartOfLocationServices;
- (void)_updateUserLocationWithData:(CLLocation *)currLocation;

- (void)_zoomToFitMapAnnotationsWithSelectedUser:(PFObject *)selectedUser;

@end

@implementation PingViewController

@synthesize pingMapView;
@synthesize locationManager;
@synthesize btn_startStopPing;
@synthesize btn_segmentedControl;
@synthesize mapToolbar;
@synthesize sc_chooseMapType;
@synthesize getTimer;
@synthesize noUsersAlert;
@synthesize centeredOnUser;
@synthesize rotaryWheelSelector;
@synthesize rotaryWheelVisible;
@synthesize userLocations;

@synthesize userWheel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.centeredOnUser = NO;
    self.rotaryWheelVisible = NO;
    
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:27.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    
    // CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 10.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // MapView
    self.pingMapView = [[MKMapView alloc] init];
    self.pingMapView.delegate = self;
    self.pingMapView.mapType = MKMapTypeStandard;
    [self.view addSubview:self.pingMapView];
    
    // Toolbar
    self.mapToolbar = [[UIToolbar alloc] init];
    
    // Start / Stop Ping Bar Button Item
    NSString *pingTitle = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPingLocationOn]) {
        // User left app with Start Ping active
        pingTitle = @"Stop Ping";
    } else {
        // User left app with Stop Ping active
        pingTitle = @"Start Ping";
    }
    
    self.btn_startStopPing = [[UIBarButtonItem alloc] initWithTitle:pingTitle
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(_startStopPing)];

    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:self
                                                                                       action:nil];
    
    NSArray *segItemsArray = [NSArray arrayWithObjects:@"Standard", @"Hybrid", @"Satellite", nil];
    self.sc_chooseMapType = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    self.sc_chooseMapType.selectedSegmentIndex = 0;
    [self.sc_chooseMapType addTarget:self
                              action:@selector(_mapTypeSelected)
                    forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:self.sc_chooseMapType];
    //self.btn_segmentedControl = [[UIBarButtonItem alloc] initWithCustomView:self.sc_chooseMapType];

    NSArray *barItems = [NSArray arrayWithObjects:self.btn_startStopPing, flexibleSpaceItem, segmentedItem, nil];
    [self.mapToolbar setItems:barItems];
    
    [self.view addSubview:self.mapToolbar];
    
    self.rotaryWheelSelector = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *arrowUpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowUp.png"]];
    arrowUpImageView.center = self.rotaryWheelSelector.center;
    arrowUpImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
    [arrowUpImageView addGestureRecognizer:tap];
    
    [self.rotaryWheelSelector setBackgroundColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.3f]];
    [self.rotaryWheelSelector addSubview:arrowUpImageView];
    
    [self.view addSubview:self.rotaryWheelSelector];
    
    self.userWheel = [[UserRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)
                                                andDelegate:self
                                               withSections:4];
    [self.view addSubview:self.userWheel];
    
    // Get list of PingUserLocation objects - add as annotations on map
    
    self.userLocations = [NSMutableArray array];
    [self _getUsersLocationData];
    
    // set up time fired event to retrieve list of location objects
    // in method used, use logic to determine if a user is 'inactive'
    // (haven't moved in 10 minutes) or 'offline' (haven't moved in 30 minutes)
    self.getTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(callGetUserLocationsAfterInterval:) userInfo:nil repeats:YES];
    
    // Since there may be some lag between the user allowing location services
    // and location services being started - give the user some time...
    [self performSelector:@selector(_initialStartOfLocationServices) withObject:nil afterDelay:5];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Re initiailize when the view appears
    self.noUsersAlert = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect mapRect = self.pingMapView.frame;
    mapRect.origin.x = 0;
    mapRect.origin.y = 40;
    mapRect.size.width = self.view.bounds.size.width;
    mapRect.size.height = self.view.bounds.size.height - 84; // empty space at top + toolbar height
    self.pingMapView.frame = mapRect;
    
    CGRect toolbarRect = self.mapToolbar.frame;
    toolbarRect.origin.x = 0;
    toolbarRect.origin.y = self.view.bounds.size.height - 44;
    toolbarRect.size.width = self.view.bounds.size.width;
    toolbarRect.size.height = 44;
    self.mapToolbar.frame = toolbarRect;
    
    CGRect rotaryWheelRect = CGRectZero;
    
    if (self.rotaryWheelVisible) {
        rotaryWheelRect = CGRectMake(self.view.bounds.size.width / 2 - self.userWheel.frame.size.width / 2,
                                     self.view.bounds.size.height / 2 - self.userWheel.frame.size.height / 2,
                                     self.userWheel.frame.size.width,
                                     self.userWheel.frame.size.height);
    } else {
        rotaryWheelRect = CGRectMake(self.view.bounds.size.width / 2 - self.userWheel.frame.size.width / 2,
                                     self.view.bounds.size.height + 10,
                                     self.userWheel.frame.size.width,
                                     self.userWheel.frame.size.height);
    }
    self.userWheel.frame = rotaryWheelRect;
    
    CGRect wheelSelectionRect = CGRectZero;
    if (self.rotaryWheelVisible) {
        wheelSelectionRect = CGRectMake(self.view.bounds.size.width / 2 - self.rotaryWheelSelector.frame.size.width / 2,
                                        self.view.bounds.size.height + 10,
                                        self.rotaryWheelSelector.frame.size.width,
                                        self.rotaryWheelSelector.frame.size.height);
    } else {
        wheelSelectionRect = CGRectMake(self.view.bounds.size.width / 2 - self.rotaryWheelSelector.frame.size.width / 2,
                                        self.view.bounds.size.height - 74,
                                        self.rotaryWheelSelector.frame.size.width,
                                        self.rotaryWheelSelector.frame.size.height);
    }
    self.rotaryWheelSelector.frame = wheelSelectionRect;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Private Methods

- (void)_startStopPing {
    if ([self.btn_startStopPing.title isEqualToString:@"Start Ping"]) {
        self.btn_startStopPing.title = @"Stop Ping";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPingLocationOn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.locationManager location] != nil) {
            NSLog(@"Location available, updating user record!");
            [self _updateUserLocationWithData:[self.locationManager location]];
        }
    } else {
        self.btn_startStopPing.title = @"Start Ping";
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPingLocationOn];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)_mapTypeSelected {
    switch (self.sc_chooseMapType.selectedSegmentIndex) {
        case 0:
            self.pingMapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.pingMapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.pingMapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}

- (void)_getUsersLocationData {
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if (authStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        if (self.pingMapView.showsUserLocation == NO) {
            self.pingMapView.showsUserLocation = YES;
            [self.locationManager startUpdatingLocation];
        }
    }
    
    // Get User Objects
    
    NSLog(@"Trying to get users!");
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kRegisteredUserID];
    PFQuery *usersQuery = [PFQuery queryWithClassName:kPingUser];
    [usersQuery whereKey:@"objectId" notEqualTo:userID];
    
    NSArray *usersArray = [usersQuery findObjects];
    
    if ([usersArray count] > 0) {
        // first, remove existing annotations
        for (id <MKAnnotation> annotation in self.pingMapView.annotations) {
            if ([annotation isKindOfClass:[UserLocAnnotation class]]) {
                [self.pingMapView removeAnnotation:annotation];
            }
        }
        
        if ([self.userLocations count] > 0) {
            [self.userLocations removeAllObjects];
        }
        
        NSMutableArray *toBeAdded = [NSMutableArray array];
        
        // loop through objects and create map annotations
        for (PFObject *user in usersArray) {
            if ([user[kPingUser_lat] length] > 0 &&
                [user[kPingUser_lon] length] > 0 &&
                [user[kPingUser_time] length] > 0) {
                
                [self.userLocations addObject:user];
                // Determine the user status based on timestamp of last
                // location update
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
                
                NSDate *coordDate = [dateFormatter dateFromString:user[kPingUser_time]];
                NSTimeInterval distanceBtwDates = [coordDate timeIntervalSinceNow];
                
                double secondsInAMinute = 60;
                NSInteger minutesBetweenDates = distanceBtwDates / secondsInAMinute;
                
                NSString *status = @"Online";
                
                if (minutesBetweenDates >= 30 &&
                    minutesBetweenDates <= 60) {
                    status = @"Idle";
                } else if (minutesBetweenDates > 60) {
                    status =  @"Offline";
                }
                
                
                CLLocationCoordinate2D tempCoord;
                tempCoord.latitude = [user[kPingUser_lat] doubleValue];
                tempCoord.longitude = [user[kPingUser_lon] doubleValue];
                UserLocAnnotation *tempAnnotation = [[UserLocAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", user[kPingUser_fName], user[kPingUser_lName]]
                                                                                    subtitle:status
                                                                                      userID:[user objectId]
                                                                               andCoordinate:tempCoord];
                
                [toBeAdded addObject:tempAnnotation];

            }
        }
        
        if ([toBeAdded count] <= 0 &&
            !self.noUsersAlert) {
            self.noUsersAlert = YES;
            [self _showAlertWithTitle:@"Bummer..." message:@"Nobody else is using the app yet! Check back soon..."];
        } else if ([toBeAdded count] > 0) {
            [self.pingMapView addAnnotations:toBeAdded];
        }
        

    } else {
        if (!self.noUsersAlert) {
            // Don't spam the user with this message - only show once per session (if applicable)
            self.noUsersAlert = YES;
            [self _showAlertWithTitle:@"Bummer..." message:@"Nobody else is using the app yet! Check back soon..."];
        }
    }
    
}

- (void)_initialStartOfLocationServices {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if (authStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        self.pingMapView.showsUserLocation = YES;
    } else {
        // Show alert that app really does need the user's location, and that
        // it can be allowed from device settings
        [self _showAlertWithTitle:@"Here's the thing..."
                          message:@"We need location services enabled to show you your friends location relative to yours. Location services for the app can be enabled in the device settings."];
        
    }

}

- (void)_updateUserLocationWithData:(CLLocation *)currLocation {
    // Update existing registered user record
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kRegisteredUserID];
    PFQuery *query = [PFQuery queryWithClassName:kPingUser];
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:userID block:^(PFObject *updUserRecord, NSError *error) {
        if (!error) {
            // Now, update with new location data
            updUserRecord[kPingUser_lat] = [NSString stringWithFormat:@"%f", currLocation.coordinate.latitude];
            updUserRecord[kPingUser_lon] = [NSString stringWithFormat:@"%f", currLocation.coordinate.longitude];
            NSString *dateString = [NSDateFormatter localizedStringFromDate:currLocation.timestamp
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterFullStyle];
            
            updUserRecord[kPingUser_time] = dateString;
            [updUserRecord saveInBackground];
        }
        
    }];

}

- (void)_zoomToFitMapAnnotationsWithSelectedUser:(PFObject *)selectedUser {
    // Current User Coordinates
    CLLocationCoordinate2D currUserCoord = self.pingMapView.userLocation.coordinate;
    
    // Selected User Coordinates
    CLLocationCoordinate2D tempCoord;
    tempCoord.latitude = [selectedUser[kPingUser_lat] doubleValue];
    tempCoord.longitude = [selectedUser[kPingUser_lon] doubleValue];
    
    MKCoordinateRegion region;
    region.center.latitude = currUserCoord.latitude - (currUserCoord.latitude - tempCoord.latitude) * 0.5;
    region.center.longitude = currUserCoord.longitude + (tempCoord.longitude - currUserCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(currUserCoord.latitude - tempCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(tempCoord.longitude - currUserCoord.longitude) * 1.1;
    
    region = [self.pingMapView regionThatFits:region];
    [self.pingMapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark - NSTimer associated method

- (void)callGetUserLocationsAfterInterval:(NSTimer *)t {
    [self _getUsersLocationData];
}

#pragma mark -
#pragma mark - UIAlertController alert method

- (void)_showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [errorAlert addAction:okAction];
    [self presentViewController:errorAlert animated:YES completion:nil];

}

#pragma mark -
#pragma mark - MKMapView Delegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.centeredOnUser) {
        // Do this only once per session when user is found on the map
        self.centeredOnUser = YES;
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.pingMapView.userLocation.coordinate;
        mapRegion.span = MKCoordinateSpanMake(0.2, 0.2);
        [self.pingMapView setRegion:mapRegion animated:YES];

    }
}

#pragma mark -
#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // First, check to see if user has selected to transmit their location
    // to the web service
    
    NSLog(@"Location updated!");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPingLocationOn]) {
        // Get the most recent location update
        CLLocation *currentLocation = [locations objectAtIndex:[locations count] - 1];
        [self _updateUserLocationWithData:currentLocation];
        

    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    // something went wrong, what do we do with this?
    NSLog(@"Location update failed!");
    NSLog(@"Localized Error Message: %@", [error localizedDescription]);
    
}

#pragma mark - 
#pragma mark - UserRotaryWheelProtocol Methods

- (void)userRotaryWheelDidChangeValue:(NSString *)newValue {
    // Depending on the selection, show the corresponding user
    // relative to this user's location
    
    NSLog(@"New Sector selected is: %@", newValue);
    
    self.rotaryWheelVisible = NO;
    CGRect selectorRect = CGRectMake(self.view.bounds.size.width / 2 - self.rotaryWheelSelector.frame.size.width / 2,
                                     self.view.bounds.size.height - 74,
                                     self.rotaryWheelSelector.frame.size.width,
                                     self.rotaryWheelSelector.frame.size.height);
    CGRect centerWheelRect = CGRectMake(self.view.bounds.size.width / 2 - self.userWheel.frame.size.width / 2,
                                        self.view.bounds.size.height + 10,
                                        self.userWheel.frame.size.width,
                                        self.userWheel.frame.size.height);
    
    [UIView animateWithDuration:0.7 animations:^ {
        self.rotaryWheelSelector.frame = selectorRect;
        self.userWheel.frame = centerWheelRect;
    }];
    
    if ([self.userLocations count] > [newValue intValue]) {
        PFObject *selectedUser = [self.userLocations objectAtIndex:[newValue intValue]];
        [self _zoomToFitMapAnnotationsWithSelectedUser:selectedUser];
    } else if ([self.userLocations count] > 0 &&
               [newValue intValue] > [self.userLocations count]) {
        // Take last in list
        PFObject *selectedUser = [self.userLocations objectAtIndex:[self.userLocations count] - 1];
        [self _zoomToFitMapAnnotationsWithSelectedUser:selectedUser];
    }

}

#pragma mark - 
#pragma mark - Rotary Wheel selection tap event

- (void)imageTapped {
    self.rotaryWheelVisible = YES;
    CGRect selectorRect = CGRectMake(self.view.bounds.size.width / 2 - self.rotaryWheelSelector.frame.size.width / 2,
                                     self.view.bounds.size.height + 10,
                                     self.rotaryWheelSelector.frame.size.width,
                                     self.rotaryWheelSelector.frame.size.height);
    CGRect centerWheelRect = CGRectMake(self.view.bounds.size.width / 2 - self.userWheel.frame.size.width / 2,
                                        self.view.bounds.size.height / 2 - self.userWheel.frame.size.height / 2,
                                        self.userWheel.frame.size.width,
                                        self.userWheel.frame.size.height);
    
    [UIView animateWithDuration:0.7 animations:^ {
        self.rotaryWheelSelector.frame = selectorRect;
        self.userWheel.frame = centerWheelRect;
    }];
}


@end
