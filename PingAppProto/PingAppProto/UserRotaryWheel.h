//
//  UserRotaryWheel.h
//  PingAppProto
//
//  Created by Clarke Bishop on 10/21/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserWheelSector.h"

@protocol UserRotaryWheelProtocol;

@interface UserRotaryWheel : UIControl

@property (weak) id <UserRotaryWheelProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *sectors;
@property int currentSector;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber;
- (void)rotate;


@end

@protocol UserRotaryWheelProtocol <NSObject>

- (void)userRotaryWheelDidChangeValue:(NSString *)newValue;

@end