//
//  Sky.m
//  GreedFamily
//
//  Created by 赵 苹果 on 12-4-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSky.h"
#import "FlyEntity.h"
#import "BodyObjectsLayer.h"
#import "GameMainScene.h"
@implementation GameSky

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(id)init
{
    if ((self = [super init]))
    {
        //[self registerWithTouchDispatcher];
        flyEntity = [[BodyObjectsLayer sharedBodyObjectsLayer] flyAnimal];
        if (YES == [GameMainScene sharedMainScene].isPairPlay)
        {
            flyEntityPlay2 = [[BodyObjectsLayer sharedBodyObjectsLayer] flyAnimalPlay2];
        }
        isMovePlay1 = NO;
        isMovePlay2 = NO;
    }
    return self;
}



-(bool) isTouchForMe:(CGPoint)touchLocation
{
    //随便设置的范围，到时再具体考量
	//change size by diff version manual
    CGRect rec = CGRectMake(0, 0, 1024, 768);
    return CGRectContainsPoint(rec, touchLocation);
}

-(bool) isTouchForPlay1:(CGPoint)touchLocation
{
    //随便设置的范围，到时再具体考量
	//change size by diff version manual
    CGRect rec = CGRectMake(0, 0, 512, 768);
    return CGRectContainsPoint(rec, touchLocation);
}

-(bool) isTouchForPlay2:(CGPoint)touchLocation
{
    //随便设置的范围，到时再具体考量
	//change size by diff version manual
    CGRect rec = CGRectMake(512, 0, 512, 768);
    return CGRectContainsPoint(rec, touchLocation);
}

//方案1：触摸天空触发小鸟移动
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint fingerLocation = [Helper locationFromTouch:touch];
    bool isTouchHandled = NO;
    if (NO == [GameMainScene sharedMainScene].isPairPlay)
    {
        isTouchHandled = [self isTouchForMe:fingerLocation];
        if (isTouchHandled) 
        {
            [flyEntity ccTouchBeganForSky2:touch withEvent:event];
            isMovePlay1 = YES;
        }
    }
    else
    {
        bool isTouchPlay1 = [self isTouchForPlay1:fingerLocation];
        bool isTouchPlay2 = [self isTouchForPlay2:fingerLocation];
        if (isTouchPlay1) 
        {
            [flyEntity ccTouchBeganForSky2:touch withEvent:event];
            isTouchHandled = YES;
            isMovePlay1 = YES;
        }
        else if (isTouchPlay2)
        {
            [flyEntityPlay2 ccTouchBeganForSky2:touch withEvent:event];
            isTouchHandled = YES;
            isMovePlay2 = YES;
        }
        
    }
	return isTouchHandled;
}

//触发移动方案2：触摸小鸟触发移动
//-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    return [flyEntity ccTouchBeganForSky:touch withEvent:event];
//}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (isMovePlay1) 
    {
        [flyEntity ccTouchMovedForSky:touch withEvent:event];
    }
    if (isMovePlay2) 
    {
        [flyEntityPlay2 ccTouchMovedForSky:touch withEvent:event];
    }

     
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (isMovePlay1) 
    {
	
        [flyEntity ccTouchEndedForSky:touch withEvent:event];
        isMovePlay1 = NO;
    }
    else
    {
        [flyEntityPlay2 ccTouchEndedForSky:touch withEvent:event];
        isMovePlay2 = NO;
    }
}



#pragma mark Layer - Callbacks
-(void) onEnter
{
    [self registerWithTouchDispatcher];
	// then iterate over all the children
	[super onEnter];
}

// issue #624.
// Can't register mouse, touches here because of #issue #1018, and #1021
-(void) onEnterTransitionDidFinish
{	
	[super onEnterTransitionDidFinish];
}


-(void) onExit
{

    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super onExit];
}

-(void) dealloc
{
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}
@end
