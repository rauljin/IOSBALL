//
//  LandCandyEntity.h
//  GreedFamily
//
//  Created by MagicStudio on 12-5-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LandCandyEntity : CCNode {
    //int Balltype;
    //CGPoint position;
    //CGPoint candyVelocity;
    
}
@property (assign, nonatomic) CCSprite* sprite;
@property (assign, nonatomic) int ballType;
@property (assign, nonatomic) CGPoint candyPosition;
@property (assign, nonatomic) CGPoint candyVelocity;
@property (assign, nonatomic) BOOL isDowning;
@property (nonatomic, retain) NSMutableArray *landCandyActionArray;
@property (assign, nonatomic)  CCAction *fallAction;
@property (assign, nonatomic)  int waitinterval;

+(id)CreateLandCandyEntity:(int)balltype Pos:(CGPoint)position BodyVelocity:(CGPoint)bodyVelocity;
@end
