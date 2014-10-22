//
//  UserRotaryWheel.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/21/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "UserRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>

@interface UserRotaryWheel ()

- (void)_drawWheel;
- (float)_calculateDistanceFromCenter:(CGPoint)point;
- (void)_buildSectorsEven;
- (void)_buildSectorsOdd;
- (UIImageView *)_getSectorByValue:(int)value;

@end

static float deltaAngle;
static float minAlphavalue = 0.6;
static float maxAlphavalue = 1.0;

@implementation UserRotaryWheel

@synthesize delegate, container, numberOfSections;
@synthesize startTransform;
@synthesize sectors;
@synthesize currentSector;

- (id)initWithFrame:(CGRect)frame
        andDelegate:(id)del
       withSections:(int)sectionsNumber {
    
    if ((self = [super initWithFrame:frame])) {
        self.numberOfSections = sectionsNumber;
        self.delegate = del;
        [self _drawWheel];
        self.currentSector = 0;
        /*[NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(rotate)
                                       userInfo:nil
                                        repeats:YES];*/
    }
    return self;
    
}

- (void)_drawWheel {
    container = [[UIView alloc] initWithFrame:self.frame];
    
    CGFloat angleSize = 2*M_PI/numberOfSections;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    bg.image = [UIImage imageNamed:@"BackgroundCircle.png"];
    [self addSubview:bg];

    
    for (int i = 0; i < numberOfSections; i++) {
        UIImageView *im = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PieShape.png"]];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        CGPoint layerPos = CGPointZero;
        switch (i) {
            case 0:
                layerPos = CGPointMake(100, 50);
                break;
            case 1:
                layerPos = CGPointMake(150, 100);
                break;
            case 2:
                layerPos = CGPointMake(100, 150);
                break;
            case 3:
                layerPos = CGPointMake(50, 100);
                break;
            default:
                break;
        }
        //CGPoint layerPos = CGPointMake(container.bounds.size.width/2.0-container.frame.origin.x,
        //                               container.bounds.size.height/2.0-container.frame.origin.y);
        im.layer.position = layerPos;
        im.transform = CGAffineTransformMakeRotation(angleSize*i);
        im.alpha = minAlphavalue;
        im.tag = i;
        if (i == 0) {
            im.alpha = maxAlphavalue;
        }
        
        UILabel *imLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 40)];
        imLabel.backgroundColor = [UIColor clearColor];
        imLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        imLabel.textColor = [UIColor whiteColor];
        imLabel.text = [NSString stringWithFormat:@"%i", i + 1]; // show '1' through ...
        //imLabel.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        // 5
        //imLabel.layer.position = CGPointMake(container.bounds.size.width/2.0,
        //                                container.bounds.size.height/2.0);
        //imLabel.transform = CGAffineTransformMakeRotation(angleSize * i);
        //imLabel.tag = i;
        // 6
        [im addSubview:imLabel];
        [container addSubview:im];

    }
    
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    mask.image =[UIImage imageNamed:@"CircleButton.png"] ;
    mask.center = self.center;
    mask.center = CGPointMake(mask.center.x, mask.center.y+3);
    mask.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
    [mask addGestureRecognizer:tap];
    [self addSubview:mask];
    
    sectors = [NSMutableArray arrayWithCapacity:numberOfSections];
    if (numberOfSections % 2 == 0) {
        [self _buildSectorsEven];
    } else {
        [self _buildSectorsOdd];
    }
    
    /*if ([self.delegate respondsToSelector:@selector(userRotaryWheelDidChangeValue:)]) {
        [self.delegate userRotaryWheelDidChangeValue:[NSString stringWithFormat:@"%i", self.currentSector]];
    }*/

}

- (void)rotate {
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -1.57);
    container.transform = t;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 1 - Get touch position
    CGPoint touchPoint = [touch locationInView:self];
    // 1.1 - Get the distance from the center
    float dist = [self _calculateDistanceFromCenter:touchPoint];
    // 1.2 - Filter out touches too close to the center
    if (dist < 40 || dist > 100)
    {
        // forcing a tap to be on the ferrule
        NSLog(@"ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    
    // 2 - Calculate distance from center
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    // 3 - Calculate arctangent value
    deltaAngle = atan2(dy,dx);
    // 4 - Save current transform
    startTransform = container.transform;
    // 5 - Set current sector's alpha value to the minimum value
    UIImageView *im = [self _getSectorByValue:currentSector];
    im.alpha = minAlphavalue;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    NSLog(@"rad is %f", radians);
    
    CGPoint pt = [touch locationInView:self];
    float dist = [self _calculateDistanceFromCenter:pt];
    // 1.2 - Filter out touches too close to the center
    if (dist < 40 || dist > 100)
    {
        // forcing a tap to be on the ferrule
        NSLog(@"ignoring tap (%f,%f)", pt.x, pt.y);
        return NO;
    }

    float dx = pt.x  - container.center.x;
    float dy = pt.y  - container.center.y;
    float ang = atan2(dy,dx);
    float angleDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(startTransform, -angleDifference);
    return YES;
}

- (float)_calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

- (void)_buildSectorsOdd {
    // 1 - Define sector length
    CGFloat fanWidth = M_PI*2/numberOfSections;
    // 2 - Set initial midpoint
    CGFloat mid = 0;
    // 3 - Iterate through all sectors
    for (int i = 0; i < numberOfSections; i++) {
        UserWheelSector *sector = [[UserWheelSector alloc] init];
        // 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        mid -= fanWidth;
        if (sector.minValue < - M_PI) {
            mid = -mid;
            mid -= fanWidth;
        }
        // 5 - Add sector to array
        [sectors addObject:sector];
        NSLog(@"cl is %@", sector);
    }
}

- (void)_buildSectorsEven {
    // 1 - Define sector length
    CGFloat fanWidth = M_PI*2/numberOfSections;
    // 2 - Set initial midpoint
    CGFloat mid = 0;
    // 3 - Iterate through all sectors
    for (int i = 0; i < numberOfSections; i++) {
        UserWheelSector *sector = [[UserWheelSector alloc] init];
        // 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        if (sector.maxValue-fanWidth < - M_PI) {
            mid = M_PI;
            sector.midValue = mid;
            sector.minValue = fabsf(sector.maxValue);
            
        }
        mid -= fanWidth;
        NSLog(@"cl is %@", sector);
        // 5 - Add sector to array
        [sectors addObject:sector];
    }
}

- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    // 1 - Get current container rotation in radians
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    // 2 - Initialize new value
    CGFloat newVal = 0.0;
    // 3 - Iterate through all the sectors
    for (UserWheelSector *s in sectors) {
        // 4 - Check for anomaly (occurs with even number of sectors)
        if (s.minValue > 0 && s.maxValue < 0) {
            if (s.maxValue > radians || s.minValue < radians) {
                // 5 - Find the quadrant (positive or negative)
                if (radians > 0) {
                    newVal = radians - M_PI;
                } else {
                    newVal = M_PI + radians;
                }
                currentSector = s.sector;
            }
        }
        // 6 - All non-anomalous cases
        else if (radians > s.minValue && radians < s.maxValue) {
            newVal = radians - s.midValue;
            currentSector = s.sector;
        }
    }
    // 7 - Set up animation for final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    [UIView commitAnimations];
    
    // 10 - Highlight selected sector
    UIImageView *im = [self _getSectorByValue:currentSector];
    im.alpha = maxAlphavalue;

    /*if ([self.delegate respondsToSelector:@selector(userRotaryWheelDidChangeValue:)]) {
        [self.delegate userRotaryWheelDidChangeValue:[NSString stringWithFormat:@"%i", self.currentSector]];
    }*/

}

- (UIImageView *)_getSectorByValue:(int)value {
    UIImageView *res;
    NSArray *views = [container subviews];
    for (UIImageView *im in views) {
        if (im.tag == value)
            res = im;
    }
    return res;
}

- (void)imageTapped {
    if ([self.delegate respondsToSelector:@selector(userRotaryWheelDidChangeValue:)]) {
        [self.delegate userRotaryWheelDidChangeValue:[NSString stringWithFormat:@"%i", self.currentSector]];
    }
}

@end
