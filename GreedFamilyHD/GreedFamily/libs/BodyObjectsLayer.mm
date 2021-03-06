//
//  BodyObjectsLayer.m
//  GreedFamily
//
//  Created by 赵 苹果 on 12-4-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "BodyObjectsLayer.h"
#import "Helper.h"
#import "FlyEntity.h"
#import "CandyCache.h"
#import "CandyEntity.h"
#import "GameMainScene.h"
#import "PropertyCache.h"

@interface BodyObjectsLayer (PrivateMethods)
-(void) initBox2dWorld;

@end

@implementation BodyObjectsLayer
@synthesize world = _world;
/*屏幕尺寸*/
static CGRect screenRect;

/*创造一个半单例，让其他类可以很方便访问scene*/
static BodyObjectsLayer *instanceOfBodyObjectsLayer;
+(BodyObjectsLayer *)sharedBodyObjectsLayer
{
    NSAssert(nil != instanceOfBodyObjectsLayer, @"BodyObjectsLayer instance not yet initialized!");
    
    return instanceOfBodyObjectsLayer;
}

+(id)CreateBodyObjectsLayer
{
	return [[[self alloc] init] autorelease];
}

-(id)init
{
    if ((self = [super init]))
    {
        instanceOfBodyObjectsLayer = self;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
        
        [self initBox2dWorld];
        
        
        FlyEntity* flyAnimal = [FlyEntity flyAnimal:self.world];
        [self addChild:flyAnimal z:-1 tag:FlyEntityTag];

        CandyCache* candyCache = [CandyCache cache:self.world];
        [self addChild:candyCache z:-1 tag:CandyCacheTag];
        
        PropertyCache* propertyCache = [PropertyCache propCache:self.world];
        [self addChild:propertyCache z:-1 tag:PropCacheTag];
        
        [self scheduleUpdate];
    }
    
    return self;
}

//初始化四个边框
//还需要完善底部
-(void) initBox2dWorld
{
	// Construct a world object, which will hold and simulate the rigid bodies.
    //这里不需要加重力
	b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
	bool allowBodiesToSleep = true;
	_world = new b2World(gravity, allowBodiesToSleep);
    
    contactListener = new ContactListener();
	_world->SetContactListener(contactListener);
    
	// Define the static container body, which will provide the collisions at screen borders.
	b2BodyDef containerBodyDef;
	b2Body* containerBody = self.world->CreateBody(&containerBodyDef);
	
	// for the ground body we'll need these values
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float widthInMeters = (screenSize.width - 32) / PTM_RATIO;
	float heightInMeters = screenSize.height / PTM_RATIO;
	b2Vec2 lowerLeftCorner = b2Vec2(0, 60/PTM_RATIO);
	b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 60/PTM_RATIO);
	b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
	b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
	
	// Create the screen box' sides by using a polygon assigning each side individually.
	b2PolygonShape screenBoxShape;
	int density = 1;
    b2FixtureDef fixtureDef;
    //fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 0.3; //密度 
    fixtureDef.friction = 0.6    ; //摩擦力
    fixtureDef.restitution = 0 ;  //弹性系数 复原
	    
    // bottom
    screenBoxShape.SetAsEdge(lowerLeftCorner, lowerRightCorner);
    containerBody->CreateFixture(&screenBoxShape, density);
    //containerBody->CreateFixture(&fixtureDef);
    
    // top
    screenBoxShape.SetAsEdge(upperLeftCorner, upperRightCorner);
    containerBody->CreateFixture(&screenBoxShape, density);
    
    // left side
    screenBoxShape.SetAsEdge(upperLeftCorner, lowerLeftCorner);
    containerBody->CreateFixture(&screenBoxShape, density);
    
    // right side
    screenBoxShape.SetAsEdge(upperRightCorner, lowerRightCorner);
    containerBody->CreateFixture(&screenBoxShape, density);
    
}

+(CGRect) screenRect
{
	return screenRect;
}

-(FlyEntity*) flyAnimal
{
	CCNode* node = [self getChildByTag:FlyEntityTag];
	NSAssert([node isKindOfClass:[FlyEntity class]], @"node is not a FlyEntity!");
	return (FlyEntity*)node;
}

-(PropertyCache*) getPropertyCache
{
	CCNode* node = [self getChildByTag:PropCacheTag];
	NSAssert([node isKindOfClass:[PropertyCache class]], @"node is not a PropertyCache!");
	return (PropertyCache *)node;
}

+(void)addDownForth:(CGPoint)curPosition forceOut:(b2Vec2 *)force
{
    CGPoint positionNew = CGPointMake(0, -10);
    
    b2Vec2 bodyPos = [Helper toMeters:positionNew];
    
    *force = bodyPos;
    
}

//判断游戏是否结束  
-(void) update:(ccTime)delta
{
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
    //CCLOG(@"int哦 here");
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	self.world->Step(timeStep, velocityIterations, positionIterations);
	
	// for each body, get its assigned BodyNode and update the sprite's position
    int bodysize=0;
    int deadenemycnt=0;
	for (b2Body* body = self.world->GetBodyList(); body != nil; body = body->GetNext())
	{
        bodysize++;
		Entity* bodyNode = (Entity *)body->GetUserData();
		if (bodyNode != NULL && bodyNode.sprite != nil)
		{
			// update the sprite's position to where their physics bodies are
            //bodysize++;
			bodyNode.sprite.position = [Helper toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			bodyNode.sprite.rotation = -(CC_RADIANS_TO_DEGREES(angle));
            
            if (bodyNode.hitPoints <= 0)
            {
                if([bodyNode isKindOfClass:[FlyEntity class]])
                {
                    CCLOG(@"haha");
                    // add the labels shown during game over
                    /*    
                    CGSize screenSize = [[CCDirector sharedDirector] winSize];
                    
                    CCLabelTTF *gameOver = [CCLabelTTF labelWithString:@"GAME OVER!" fontName:@"Marker Felt" fontSize:60];
                    gameOver.position = CGPointMake(screenSize.width / 2, screenSize.height / 3);
                    [self addChild:gameOver z:100 tag:100];
                    [GameMainScene sharedMainScene].isGameOver = YES;
                    
                    return;
                     */
                }
                //add by jin at 5.27
                else if ([bodyNode isKindOfClass:[CandyEntity class]])
                {
                    //持续的给Candy加向下的力
                    
                    CCLOG(@"Into here ！糖果的血为0");
                    //b2Vec2 bodyPos = bodyNode.body->GetWorldCenter();
                    //CCLOG("x=%d, y=%f\n", bodyPos.y0);

                    //if (bodyPos.y<=0)
                    //{    
                    //    CCLOG(@"haha");
                    //}    
                    
                    //CGPoint bodyPosition = [Helper toPixels:bodyPos];
                    //CGPoint newposition = CGPointMake(0, 0);
                    //b2Vec2 fingerPos = [Helper toMeters:newposition];
                    
                    //b2Vec2 bodyToFinger = fingerPos - bodyPos;
                    //b2Vec2 bodyToFinger = fingerPos;
                    
                    
                    // "Real" gravity falls off by the square over distance. Feel free to try it this way:
                    //float distance = bodyToFinger.Normalize();
                    //float distanceSquared = distance * distance;
                    //b2Vec2 force = ((1.0f / distanceSquared) * 20.0f) * bodyToFinger;
                    
                    //b2Vec2 force = 30.0f * bodyToFinger;
                    //body->SetTransform([Helper toMeters:positionNew], 0);
                    
                    //bodyNode.body->ApplyForce(force, bodyNode.body->GetWorldCenter());
                    
                    //bodyNode.hitPoints=0;
                    CandyEntity* candyNode = (CandyEntity*)bodyNode;
                    candyNode.changeTheForth;
                    
                }   
                
                
                else
                {
                    CCLOG(@"其实是到这来了");
                    //奇怪没到上面去
                    
                    b2Vec2 bodyPos = bodyNode.body->GetWorldCenter();                    
                    CGPoint newposition = CGPointMake(0, 0);
                    b2Vec2 fingerPos = [Helper toMeters:newposition];
                    
                    b2Vec2 bodyToFinger = fingerPos - bodyPos;
                    
                    b2Vec2 force = 30.0f * bodyToFinger;
                    //body->SetTransform([Helper toMeters:positionNew], 0);
                    
                    bodyNode.body->ApplyForce(force, bodyNode.body->GetWorldCenter());                    
                    
                    deadenemycnt++;
                }
                
                /*
                CGPoint positionNew = CGPointMake(-100, -100);
                bodyNode.body->SetTransform([Helper toMeters:positionNew], 0);
                */
                
                /*
                bodyNode.sprite.visible = NO;
                */
                
                //[bodyNode removeBody];
            } 
		}
	}
    /*
    if(deadenemycnt>=bodysize-2){
        [GameMainScene sharedMainScene].isGamePass = YES;
    }
    */
}
-(void) dealloc
{
	//delete self.world;
	//world = NULL;
	
    delete contactListener;
	contactListener = NULL;
    
    instanceOfBodyObjectsLayer = nil;   
    
    [super dealloc];
    

}

@end
