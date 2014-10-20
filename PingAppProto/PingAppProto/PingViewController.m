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

@interface PingViewController ()

- (void)_startStopPing;
- (void)_mapTypeSelected;

@end

@implementation PingViewController

@synthesize pingMapView;
@synthesize locationManager;
@synthesize btn_startStopPing;
@synthesize btn_segmentedControl;
@synthesize mapToolbar;
@synthesize sc_chooseMapType;

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
    }
    
    self.pingMapView = [[MKMapView alloc] init];
    self.pingMapView.delegate = self;
    self.pingMapView.mapType = MKMapTypeStandard;
    self.pingMapView.showsUserLocation = YES;
    [self.view addSubview:self.pingMapView];
    
    self.mapToolbar = [[UIToolbar alloc] init];
    
    // Start / Stop Ping Bar Button Item
    NSString *pingTitle = @"";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserLocID] != nil)
        pingTitle = @"Stop Ping";
    else
        pingTitle = @"Start Ping";
    
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
    
    
    // set up time fired event to retrieve list of location objects
    // in method used, use logic to determine if a user is 'inactive'
    // (haven't moved in 10 minutes) or 'offline' (haven't moved in 30 minutes)
    
    
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
    } else {
        self.btn_startStopPing.title = @"Start Ping";
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

#pragma mark -
#pragma mark - MKMapView Delegate methods


#pragma mark -
#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // Get the most recent location update
    CLLocation *currentLocation = [locations objectAtIndex:[locations count] - 1];
    // Take location returned and submit to web service
    PFObject *userLocationObject = [PFObject objectWithClassName:kPingUserLocation];
    userLocationObject[kPingUsrLoc_lat] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    userLocationObject[kPingUsrLoc_lon] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:currentLocation.timestamp
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    userLocationObject[kPingUsrLoc_time] = dateString;
    
    [userLocationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // First, grab the object ID and store in user defaults - this
            // will allow the app to know that registration was successful,
            // and identify the user when updating location in the app.
            [[NSUserDefaults standardUserDefaults] setValue:[userLocationObject objectId] forKey:kUserLocID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // push to next controller
            NSLog(@"%@", [userLocationObject description]);
            
            // Update map with user's new location?
            
            
        } else {
            // something went wrong, eval error and present info to user
        }
    }];

    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    // something went wrong, what do we do with this?
    
}

@end
