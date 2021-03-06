//
//  Entity.h
//  ShootEmUp
//
//  Created by Steffen Itterheim on 18.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"
#import "Helper.h"
//#import "Component.h"

typedef enum
{
	PositionOne = 0,
	PositionTwo,
	PositionThree,
    PositionFour,
    PositionFive,
	Position_MAX,
} EnterPosition;

@class Component;

@interface Entity : CCNode 
{
    int initialHitPoints;
	int hitPoints;
}


@property (nonatomic) b2Body* body;
@property (assign, nonatomic) CCSprite* sprite;
@property (nonatomic) int initialHitPoints;
@property (nonatomic) int hitPoints;
@property (nonatomic) CGPoint otherLineSpeed;
@property (assign, nonatomic) CCSprite* cover;
-(void) createBodyInWorld:(b2World*)world bodyDef:(b2BodyDef*)bodyDef fixtureDef:(b2FixtureDef*)fixtureDef spriteFrameName:(NSString*)spriteFrameName;
-(void) createBodyInWorld:(b2World*)world bodyDef:(b2BodyDef*)bodyDef fixtureDef:(b2FixtureDef*)fixtureDef;
-(void)initSprite:(NSString*)spriteFrameName;
-(void) removeSprite;
-(void) removeBody;
-(void) updateBadyPosition:(CGPoint)positionNew;
@end
