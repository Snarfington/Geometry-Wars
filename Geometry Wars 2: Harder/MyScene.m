//
//  MyScene.m
//  Geometry Wars 2: Harder
//
//  Created by block7 on 5/14/14.
//  Copyright (c) 2014 block7. All rights reserved.
//

#import "MyScene.h"
#import "DPad.h"

static const CGFloat kPlayerMovementSpeed = 400.0f;

@interface MyScene() <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKNode *world;
@property (nonatomic) SKNode *hud;
@property (nonatomic) DPad *dPad;
@property (nonatomic) SKTextureAtlas *spriteAtlas;
@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) BOOL isExitingLevel;
@property (nonatomic) NSArray *playerIdleAnimationFrames;
@property (nonatomic) NSUInteger playerAnimationID; // 0 = idle; 1 = walk
@end

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}




@implementation MyScene

- (id)initWithSize:(CGSize)size
{
    if (( self = [super initWithSize:size] ))
    {
        self.backgroundColor = [SKColor blackColor];
        
        // Add a node for the world - this is where sprites and tiles are added
        self.world = [SKNode node];
        
        // Load the atlas that contains the sprites
        self.spriteAtlas = [SKTextureAtlas atlasNamed:@"sprites"];
        
        // Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin
                                       .y, self.frame.size.width, 1);
        SKNode* bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        //[self addChild:bottom];
        
        bottom.physicsBody.categoryBitMask = bottomCategory;
        
        // Create a player node
        self.player = [SKSpriteNode spriteNodeWithTexture:[self.spriteAtlas textureNamed:@"player"]];
        self.player.position = CGPointMake(250.0f, 200.0f);
        self.player.physicsBody.allowsRotation = NO;
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.texture.size];
        self.player.physicsBody.categoryBitMask = CollisionTypePlayer;
        self.player.physicsBody.collisionBitMask = bottomCategory;
       
        [self.world addChild:self.player];
        
        // Create a node for the HUD - this is where the DPad to control the player sprite will be added
        self.hud = [SKNode node];
        
        // Create the DPads
        self.dPad = [[DPad alloc] initWithRect:CGRectMake(0, 0, 64.0f, 64.0f)];
        self.dPad.position = CGPointMake(64.0f / 4, 64.0f / 4);
        self.dPad.numberOfDirections = 24;
        self.dPad.deadRadius = 8.0f;
        
        [self.hud addChild:self.dPad];
        
        // Add the world and hud nodes to the scene
        [self addChild:self.world];
        [self addChild:self.hud];
        
        // Initialize physics
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

- (void) update:(CFTimeInterval)currentTime
{
    // Calculate the time since last update
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    
    if ( timeSinceLast > 1 )
    {
        timeSinceLast = 1.0f / 60.0f;
        self.lastUpdateTimeInterval = currentTime;
    }

    // Poll the DPad
    CGPoint playerVelocity = self.isExitingLevel ? CGPointZero : self.dPad.velocity;
    
    // Update player sprite position and orientation based on DPad input
    
    //Movement
    self.player.position = CGPointMake(self.player.position.x + playerVelocity.x * timeSinceLast * kPlayerMovementSpeed, self.player.position.y + playerVelocity.y * timeSinceLast * kPlayerMovementSpeed);
    
    
    if (playerVelocity.x != 0.0f)
    {
        self.player.xScale = (playerVelocity.x > 0.0f) ? -1.0f : 1.0f;
    }
}


- (void) didSimulatePhysics
{
    self.player.zRotation = 0.0f;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    CGPoint offset = rwSub(location, projectile.position);
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    
}

@end