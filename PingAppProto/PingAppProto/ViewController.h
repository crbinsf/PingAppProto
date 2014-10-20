//
//  ViewController.h
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PingViewController.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tf_fname;
@property (nonatomic, strong) UITextField *tf_lname;
@property (nonatomic, strong) UITextField *tf_email;

@property (nonatomic, strong) UIButton *btn_register;

@property (nonatomic, strong) PingViewController *pingController;

@end

