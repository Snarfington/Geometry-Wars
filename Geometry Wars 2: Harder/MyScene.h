//
//  MyScene.h
//  Geometry Wars 2: Harder
//

//  Copyright (c) 2014 block7. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(uint32_t, CollisionType)
{
    CollisionTypePlayer     = 0x1 << 0,
    CollisionTypeWall       = 0x1 << 1,
    bottomCategory          = 0x1 << 2,
    projectileCategory      = 0x1 << 4,
};


@interface MyScene : SKScene

@end
