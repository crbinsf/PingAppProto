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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:27.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        // Show alert that app really does need the user's location, and that
        // it can be allowed from device settings
        [self _showAlertWithTitle:@"Here's the thing..."
                          message:@"We need location services enabled to show you your friends location relative to yours. Location services for the app can be enabled in the device settings."];
    }
    
    self.pingMapView = [[MKMapView alloc] init];
    self.pingMapView.delegate = self;
    self.pingMapView.mapType = MKMapTypeStandard;
    self.pingMapView.showsUserLocation = YES;
    [self.view addSubview:self.pingMapView];
    
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
    
    // Get list of PingUserLocation objects - add as annotations on map
    [self _getUsersLocationData];
    
    // set up time fired event to retrieve list of location objects
    // in method used, use logic to determine if a user is 'inactive'
    // (haven't moved in 10 minutes) or 'offline' (haven't moved in 30 minutes)
    self.getTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(callGetUserLocationsAfterInterval:) userInfo:nil repeats:YES];
    
    
    
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
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPingLocationOn];
    } else {
        self.btn_startStopPing.title = @"Start Ping";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPingLocationOn];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    // Get User Objects
    PFQuery *usersQuery = [PFQuery queryWithClassName:kPingUser];
    [usersQuery whereKey:@"objectID" notEqualTo:kRegisteredUserID];
    
    NSArray *usersArray = [usersQuery findObjects];
    
    if ([usersArray count] > 0) {
        // first, remove existing annotations
        for (id <MKAnnotation> annotation in self.pingMapView.annotations) {
            if ([annotation isKindOfClass:[UserLocAnnotation class]]) {
                [self.pingMapView removeAnnotation:annotation];
            }
        }
        
        // loop through objects and create map annotations
        for (PFObject *user in usersArray) {
            
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
            
            [self.pingMapView addAnnotation:tempAnnotation];
        }

    } else {
        if (!self.noUsersAlert) {
            // Don't spam the user with this message - only show once per session (if applicable)
            self.noUsersAlert = YES;
            [self _showAlertWithTitle:@"Bummer..." message:@"Nobody else is using the app yet! Check back soon..."];
        }
    }
    
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


#pragma mark -
#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // First, check to see if user has selected to transmit their location
    // to the web service
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPingLocationOn]) {
        // Get the most recent location update
        CLLocation *currentLocation = [locations objectAtIndex:[locations count] - 1];
        
        // Update existing registered user record
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kRegisteredUserID];
        PFQuery *query = [PFQuery queryWithClassName:kPingUser];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:userID block:^(PFObject *updUserRecord, NSError *error) {
            if (!error) {
                // Now, update with new location data
                updUserRecord[kPingUser_lat] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
                updUserRecord[kPingUser_lon] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
                NSString *dateString = [NSDateFormatter localizedStringFromDate:currentLocation.timestamp
                                                                      dateStyle:NSDateFormatterShortStyle
                                                                      timeStyle:NSDateFormatterFullStyle];
                
                updUserRecord[kPingUser_time] = dateString;
                [updUserRecord saveInBackground];
            }
            
        }];

    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    // something went wrong, what do we do with this?
    
}

@end
