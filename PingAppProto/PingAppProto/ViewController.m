//
//  ViewController.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tf_fname, tf_lname, tf_email;
@synthesize btn_register;
@synthesize regView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blueColor];
}

/*- (void)loadView {
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor clearColor];
    
    self.view = contentView;
    
    self.regView = [[UIView alloc] initWithFrame:applicationFrame];
    [self.regView setBackgroundColor:[UIColor blueColor]];
    
    [self.view addSubview:self.regView];
    

}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
