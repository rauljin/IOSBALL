//
//  CandyCache.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "CandyCache.h"
#import "CandyEntity.h"
#import "Box2D.h"
#import "LoadingScene.h"
#import "GameMainScene.h"
#import "BodyObjectsLayer.h"

@interface CandyCache (PrivateMethods)
-(void)initEnemiesWithWorld:(b2World *)world;
-(id)initWithWorld:(b2World *)world;
-(void)initFstScenecache:(b2World *)world;
-(void)initScdScenecache:(b2World *)world;
-(void)initThrdScenecache:(b2World *)world;
-(void)initFreeScene:(b2World *)world;
-(id)defineBall:(b2World *)world Type:(int)ballType Pos:(CGPoint)startPos Dynamic:(BOOL)isDynamicBody Tag:(int)taget;
@end


@implementation CandyCache

+(id) cache:(b2World *)world
{
	return [[[self alloc] initWithWorld:world] autorelease];
}


-(id)initWithWorld:(b2World *)world 
{
	if ((self = [super init]))
	{
		// get any image from the Texture Atlas we're using
		//CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster-a.png"];
		//batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
		//[self addChild:batch];
		
		[self initEnemiesWithWorld:world];

	}
	
	return self;    
}


//创造糖果库
-(void) initCandyBank:(b2World *)world
{
    //创造糖果库数组，一个二维数组
    candyBank = [[CCArray alloc] initWithCapacity:BallType_MAX];
    
    CGPoint startPos = CGPointMake(-100, -100);
    //创建每一种糖果类型
	for (int i = 0; i < BallType_MAX; i++)
	{
		//现在每一种创建5个
		int capacity = 5;

		
		// no alloc needed since the candybank array will retain anything added to it
		CCArray* candiesOfType = [CCArray arrayWithCapacity:capacity];
		[candyBank addObject:candiesOfType];
	}

    //初始化每一种糖果
    for (int i = 0; i < BallType_MAX; i++)
	{
		CCArray* candiesOfType = [candyBank objectAtIndex:i];
		int numEnemiesOfType = [candiesOfType capacity];
		
		for (int j = 0; j < numEnemiesOfType; j++)
		{
            CandyEntity *candy = [self defineBall:world Type:i Pos:startPos Dynamic:YES Tag:1];
            [candiesOfType addObject: candy];
		}
	}
    
    return;
}

-(void) initEnemiesWithWorld:(b2World *)world 
{
    /*初始化糖果库*/
    [self initCandyBank:world];
    /*获取关卡号*/
    int order = [GameMainScene sharedMainScene].sceneNum;
    
    [self initFreeScene:world];
    
    return;
    
    
    //自由关
    switch (order) {
        case TargetSceneFstScene:
            [self initFstScenecache:world];
            break;
        case TargetSceneScdScene:
            [self initScdScenecache:world];
            break;
        case TargetSceneThrdScene:
            [self initThrdScenecache:world];
            break;
        default:
            NSAssert1(nil, @"unsupported TargetScene %i", order);
            break;
    }
}


-(id)defineBall:(b2World *)world Type:(int)ballType Pos:(CGPoint)startPos Dynamic:(BOOL)isDynamicBody Tag:(int)taget
{
    //结构体  定义糖果的各种属性
    CandyParam cacheParam = {0};
    
    //firstcacheParam.initialHitPoints = 4;
    //球的初始位置    
    cacheParam.startPos=CGPoint(startPos);

    cacheParam.isDynamicBody = isDynamicBody;

    //球的类型
    cacheParam.ballType = ballType;
    
    CandyEntity* cache = [CandyEntity CandyWithParam:cacheParam World:world];
    cache.sprite.visible = NO;
    [self addChild:cache z:1 tag:taget];
    
    return cache;
    //[candies addObject:cache];
}

-(void)spawnCandyOfType:(int)candyType
{
    srandom(time(NULL));
    CCArray* candyOfType = [candyBank objectAtIndex:candyType];
	
	CandyEntity* candy;
	CCARRAY_FOREACH(candyOfType, candy)
    {
        if (NO == candy.sprite.visible)
        {
            CCLOG(@"spawn candy type %i", candyType);
            int enterPosition = random() % 5;
            [candy spawn:enterPosition]; 
            
            return;
        }
    }
    
    return;
}

-(void)randomSpawnCandy:(ccTime)delta
{
    srandom(time(NULL));
    int candyType = random() % 3;
    [self spawnCandyOfType:candyType];
    
    return;
}

-(void)initFreeScene:(b2World *)world
{
    int spawnFrequency = 5;
		
    [self schedule:@selector(randomSpawnCandy:) interval:spawnFrequency];
    
    return;
}

-(void)initFstScenecache:(b2World *)world
{
    cacheNum = 1;
    candies = [[CCArray alloc] initWithCapacity:cacheNum];
	CGRect screenRect = [BodyObjectsLayer screenRect];

    //球出来的位置     
    CGPoint startPos1=CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
    
    [self defineBall:world Type:BallTypeRandomBall Pos:startPos1 Dynamic:YES Tag:1];

    //添加场景的粒子效果
	// remove any previous particle FX
//    [self removeChildByTag:1 cleanup:YES];    
//    
//    CCParticleSystem* system;    
//    system = [CCParticleRain node];    
//    
//    [self addChild:system z:1 tag:15];       
    
}




-(void)initScdScenecache:(b2World *)world
{
    
    cacheNum = 2;
    candies = [[CCArray alloc] initWithCapacity:cacheNum];
	CGRect screenRect = [BodyObjectsLayer screenRect];
    
    CGPoint startPos1=CGPointMake(screenRect.size.width / 2, screenRect.size.height / 4);
    [self defineBall:world Type:BallTypeRandomBall Pos:startPos1 Dynamic:YES Tag:1];
    
    CGPoint startPos2=CGPointMake(screenRect.size.width / 4, screenRect.size.height / 4);
    [self defineBall:world Type:BallTypeKillerBall Pos:startPos2 Dynamic:YES Tag:2];

    //添加场景的粒子效果
	// remove any previous particle FX
//    [self removeChildByTag:1 cleanup:YES];    
//    
//    CCParticleSystem* system;    
//    system = [CCParticleSnow node];  
//    
//    [self addChild:system z:1 tag:15];       
    
    
    
    
}

-(void)initThrdScenecache:(b2World *)world
{
    cacheNum = 5;
    candies = [[CCArray alloc] initWithCapacity:cacheNum];
	CGRect screenRect = [BodyObjectsLayer screenRect];
    
    CGPoint startPos1=CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
    [self defineBall:world Type:BallTypeBalloom Pos:startPos1 Dynamic:YES Tag:1];
    
    CGPoint startPos2=CGPointMake(screenRect.size.width / 4 * 3, screenRect.size.height / 4 * 3);
    [self defineBall:world Type:BallTypeKillerBall Pos:startPos2 Dynamic:YES Tag:2];
    
    CGPoint startPos3=CGPointMake(screenRect.size.width / 4, screenRect.size.height / 4);
    [self defineBall:world Type:BallTypeRandomBall Pos:startPos3 Dynamic:YES Tag:3];   
    
    CGPoint startPos4=CGPointMake(screenRect.size.width / 4 * 3, screenRect.size.height / 4);
    [self defineBall:world Type:BallTypeKillerBall Pos:startPos4 Dynamic:YES Tag:4];
    
    CGPoint startPos5=CGPointMake(screenRect.size.width / 4 * 3, screenRect.size.height / 4 * 3);
    [self defineBall:world Type:BallTypeKillerBall Pos:startPos5 Dynamic:YES Tag:5];
    
    CGPoint startPos6=CGPointMake(screenRect.size.width / 8 * 3, screenRect.size.height / 8 * 3);
    [self defineBall:world Type:BallTypeKillerBall Pos:startPos6 Dynamic:YES Tag:6];
    
    //添加场景的粒子效果
	// remove any previous particle FX
//    [self removeChildByTag:1 cleanup:YES];    
//    
//    CCParticleSystem* system;    
//    system = [CCParticleGalaxy node];
//    
//    [self addChild:system z:1 tag:15]; 
    
    
}

-(void) dealloc
{
	[candies release];
    [candyBank release];
	[super dealloc];
}


@end
