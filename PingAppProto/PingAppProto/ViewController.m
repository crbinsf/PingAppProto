//
//  ViewController.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface ViewController ()

- (void)_registerNewUser;

@end

@implementation ViewController

@synthesize tf_fname, tf_lname, tf_email;
@synthesize btn_register;
@synthesize pingController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:27.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    // First name
    self.tf_fname = [[UITextField alloc] init];
    self.tf_fname.delegate = self;
    self.tf_fname.placeholder = @"First Name";
    self.tf_fname.backgroundColor = [UIColor whiteColor];
    self.tf_fname.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tf_fname.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.tf_fname];
    
    // Last name
    self.tf_lname = [[UITextField alloc] init];
    self.tf_lname.delegate = self;
    self.tf_lname.placeholder = @"Last Name";
    self.tf_lname.backgroundColor = [UIColor whiteColor];
    self.tf_lname.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tf_lname.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.tf_lname];
    
    // Email address
    self.tf_email = [[UITextField alloc] init];
    self.tf_email.delegate = self;
    self.tf_email.placeholder = @"Email Address";
    self.tf_email.backgroundColor = [UIColor whiteColor];
    self.tf_email.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tf_email.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.tf_email];
    
    // Register button
    self.btn_register = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_register setTitle:@"Register" forState:UIControlStateNormal];
    self.btn_register.backgroundColor = [UIColor whiteColor];
    [self.btn_register setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btn_register addTarget:self action:@selector(_registerNewUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_register];
    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect tf_fnameRect = self.tf_fname.frame;
    tf_fnameRect.origin.x = 20;
    tf_fnameRect.origin.y = 40;
    tf_fnameRect.size.width = self.view.bounds.size.width - 40;
    tf_fnameRect.size.height = 44;
    self.tf_fname.frame = tf_fnameRect;
    
    CGRect tf_lnameRect = tf_fnameRect;
    tf_lnameRect.origin.y = tf_fnameRect.origin.y + 44 + 10;
    self.tf_lname.frame = tf_lnameRect;
    
    CGRect tf_emailRect = tf_lnameRect;
    tf_emailRect.origin.y = tf_lnameRect.origin.y + 44 + 10;
    self.tf_email.frame = tf_emailRect;
    
    CGRect btn_registerRect = self.btn_register.frame;
    btn_registerRect.size.width = 80;
    btn_registerRect.size.height = 44;
    btn_registerRect.origin.x = self.view.bounds.size.width / 2 - btn_registerRect.size.width / 2;
    btn_registerRect.origin.y = tf_emailRect.origin.y + 44 + 10;
    self.btn_register.frame = btn_registerRect;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - New User Reg Methods

- (void)_registerNewUser {
    
    if ([self.tf_fname.text length] > 0 &&
        [self.tf_lname.text length] > 0 &&
        [self.tf_email.text length] > 0) {
        PFObject *user = [PFObject objectWithClassName:kPingUser];
        user[kPingUser_fName] = self.tf_fname.text;
        user[kPingUser_lName] = self.tf_lname.text;
        user[kPingUser_email] = self.tf_email.text;
        // these fields are empty until tracking location
        // Included here because Parse lazily creates the PingUser class if it
        // does not yet exist
        user[kPingUser_lat] = @"";
        user[kPingUser_lon] = @"";
        user[kPingUser_time] = @"";
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // First, grab the object ID and store in user defaults - this
                // will allow the app to know that registration was successful,
                // and identify the user when updating location in the app.
                [[NSUserDefaults standardUserDefaults] setValue:[user objectId] forKey:kRegisteredUserID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // push to next controller
                NSLog(@"%@", [user description]);
                
                // Push next view controller
                self.pingController = [[PingViewController alloc] init];
                [self presentViewController:self.pingController animated:YES completion:nil];
            } else {
                // something went wrong, eval error and present info to user
            }
        }];
        
    } else {
        // Present alert that all fields must be filled in to register
        // unless user chooses to log in using facebook or twitter.
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Here's the thing..."
                                                                            message:@"We need all the fields to be filled in for you to proceed."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       // Reset responder so that cursor is in the empty text field
                                       if ([self.tf_fname.text length] <= 0)
                                           [self.tf_fname becomeFirstResponder];
                                       else if ([self.tf_lname.text length] <= 0)
                                           [self.tf_lname becomeFirstResponder];
                                       else if ([self.tf_email.text length] <= 0)
                                           [self.tf_email becomeFirstResponder];
                                       else // In the event something crazy has happened...
                                           [self.tf_fname becomeFirstResponder];
                                       
                                       [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        [errorAlert addAction:okAction];
        [self presentViewController:errorAlert animated:YES completion:nil];
    }

}

#pragma mark -
#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = NO;
    
    if ([self.tf_fname isFirstResponder]) {
        [self.tf_lname becomeFirstResponder];
    } else if ([self.tf_lname isFirstResponder]) {
        [self.tf_email becomeFirstResponder];
    } else if ([self.tf_email isFirstResponder]) {
        [self.tf_email resignFirstResponder];
        // Also, trigger registration action
        [self _registerNewUser];
    }
    
    return result;
}

@end
