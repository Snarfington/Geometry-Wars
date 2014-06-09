//
//  DPad.h
//  Geometry Wars 2: Harder
//
//  Created by block7 on 5/29/14.
//  Copyright (c) 2014 block7. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DPad : SKNode

@property (nonatomic) CGPoint stickPosition;
@property (nonatomic, readonly) CGFloat degrees;
@property (nonatomic, readonly) CGPoint velocity;
@property (nonatomic, assign) BOOL autoCenter;
@property (nonatomic, assign) BOOL isDPad;
@property (nonatomic, assign) BOOL hasDeadzone;     // Turns deadzone on/off for joystick, always YES if isDPad == YES
@property (nonatomic, assign) NSUInteger numberOfDirections;    // Only used when isDPad == YES

@property (nonatomic, assign) CGFloat joystickRadius;
@property (nonatomic, assign) CGFloat thumbRadius;
@property (nonatomic, assign) CGFloat deadRadius;   // Size of deadzone in joystick (how far you must move before input starts). Automatically set is isDPad == YES

- (instancetype) initWithRect:(CGRect)rect;

@end
