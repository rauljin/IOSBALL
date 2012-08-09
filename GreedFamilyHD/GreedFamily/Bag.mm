//
//  Bag.m
//  GreedFamily
//
//  Created by 赵 苹果 on 12-4-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Bag.h"
#import "GameBackgroundLayer.h"
#import "Helper.h"
#import "BodyObjectsLayer.h"
#import "PropertyCache.h"
#import "LandAnimal.h"
//#import "Storage.h"
#import "TouchCatchLayer.h"
#import "GameMainScene.h"
#import "NoBodyObjectsLayer.h"
@implementation Bag
@synthesize sprite = _sprite;
//-(void) registerWithTouchDispatcher
//{
//    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
//}


-(void)onPepper:(id)sender
{
    if (0 >= pepperNum) 
    {
        return;
    }
    CCLOG(@"hot!!!!!!!!\n");
    if (1 == bagID) 
    {
        [[[NoBodyObjectsLayer sharedNoBodyObjectsLayer] getLandAnimal] increaseSpeed];
    }
    else
    {
        [[[NoBodyObjectsLayer sharedNoBodyObjectsLayer] getLandAnimalPlay2] increaseSpeed];
    }
    pepperNum--;
    if (0 == pepperNum) 
    {
        //消失动画
        pepperMenu.visible = NO;
    } 

    [pepperLabel setString:[NSString stringWithFormat:@"x%i", pepperNum]];
    
}

-(void)onCrystal:(id)sender
{
    if (0 >= crystalNum)
    {
        return;
    }
    Storage *storage = nil;

    if (1 == bagID) 
    {
        storage = [[TouchCatchLayer sharedTouchCatchLayer] getStorage];

    }
    else
    {
        storage = [[TouchCatchLayer sharedTouchCatchLayer] getStoragePlay2];
    }
    //[storage combinTheSameType];
    [storage combinTheSameTypeNew]; 
    crystalNum--;
    if (0 == crystalNum) 
    {
        //消失动画
        crystalMenu.visible = NO;
    } 

    [crystalLabel setString:[NSString stringWithFormat:@"x%i", crystalNum]];
    
}

+(id)createBag:(int)playID
{
    return [[[self alloc] initWithPlayID:playID] autorelease];
}

-(id)initWithPlayID:(int)playID
{
    if ((self = [super init]))
    {

        pepperNum = 0;
        crystalNum = 0;
        bagID = playID;
        
        CCSprite *pepperProp1 = [CCSprite spriteWithSpriteFrameName:@"pepper-.png"];
        CCSprite *pepperProp2 = [CCSprite spriteWithSpriteFrameName:@"pepper-.png"];    
        CCMenuItemSprite *pepperPropMenu = [CCMenuItemSprite itemFromNormalSprite:pepperProp1 
                                                                   selectedSprite:pepperProp2 
                                                                           target:self 
                                                                         selector:@selector(onPepper:)];
        //change size by diff version manual
        pepperPropMenu.scaleX=(30)/[pepperProp1 contentSize].width; //按照像素定制图片宽高
        pepperPropMenu.scaleY=(30)/[pepperProp1 contentSize].height;
        pepperLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
        
        pepperLabel.anchorPoint = CGPointMake(-3, 0.5);
        pepperLabel.scale = 0.4;
        [pepperPropMenu addChild:pepperLabel z:1];
        pepperMenu = [CCMenu menuWithItems:pepperPropMenu,nil];
        //change size by diff version
        if (1 == bagID) 
        {
            pepperMenu.position = [GameMainScene sharedMainScene].pepperMenuPos;
        }
        else
        {
            pepperMenu.position = [GameMainScene sharedMainScene].pepperMenuPlay2Pos;
        }

        pepperMenu.visible = NO;
        [self addChild:pepperMenu z:-2];
        
        CCSprite *crystalProp1 = [CCSprite spriteWithSpriteFrameName:@"crystallball.png"];
        CCSprite *crystalProp2 = [CCSprite spriteWithSpriteFrameName:@"crystallball.png"];    
        CCMenuItemSprite *crystalPropMenu = [CCMenuItemSprite itemFromNormalSprite:crystalProp1 
                                                                   selectedSprite:crystalProp2 
                                                                           target:self 
                                                                         selector:@selector(onCrystal:)];
        crystalPropMenu.scaleX=(35)/[crystalProp1 contentSize].width; //按照像素定制图片宽高
        crystalPropMenu.scaleY=(35)/[crystalProp1 contentSize].height;

        crystalLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
        crystalLabel.anchorPoint = CGPointMake(-3, 0.5);
        crystalLabel.scale = 0.4;
        [crystalPropMenu addChild:crystalLabel z:1];
        crystalMenu = [CCMenu menuWithItems:crystalPropMenu,nil];
        //change size by diff version
        CGPoint distance = CGPointMake(60, 0);
        crystalMenu.position = ccpAdd(distance, pepperMenu.position);
        crystalMenu.visible = NO;
        [self addChild:crystalMenu z:-2];
//        timeTmp.type=kCCProgressTimerTypeRadialCW;//进度条的显示样式  
//        timeTmp.percentage = 0; //当前进度       
//        timeTmp.position = ccp(200, 200);         
//        
//        
//        timeTmp = [CCProgressTimer progressWithFile:@"cd.png"];
//
//        [self addChild:timeTmp];
//
//
//        int mPercentage = 100;  
//        [timeTmp setPercentage:mPercentage];
//        [timeTmp setPercentage:(100-mPercentage++)];

    
    }
    
    return self;
}

-(void)addPepper
{
    if (0 == pepperNum) 
    {
        //出现动画
        //change size by diff version
        CGPoint moveToPosition = [GameMainScene sharedMainScene].pepperMenuPos;
        CGPoint distance = CGPointMake(0, -50);
        pepperMenu.position = ccpAdd(moveToPosition, distance);
        pepperMenu.visible = YES;
        CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:moveToPosition]; 
        CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:2];
        [pepperMenu runAction:ease];
        //pepperMenu.position = moveToPosition;
    }
    pepperNum++;
    [pepperLabel setString:[NSString stringWithFormat:@"x%i", pepperNum]];
}

-(void)addCrystal
{
    if (0 == crystalNum) 
    {
        //出现动画
        //change size by diff version
        CGPoint distance = CGPointMake(60, 0);
        CGPoint moveToPosition;
        if (1 == bagID) 
        {
            moveToPosition = ccpAdd(distance, [GameMainScene sharedMainScene].pepperMenuPos);
        }
        else
        {
            moveToPosition = ccpAdd(distance, [GameMainScene sharedMainScene].pepperMenuPlay2Pos);
        }
        CGPoint distance2 = CGPointMake(0, -50);
        crystalMenu.position = ccpAdd(moveToPosition, distance2);
        crystalMenu.visible = YES;
        CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:moveToPosition]; 
        CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:2];
        [crystalMenu runAction:ease];
        //crystalMenu.position = moveToPosition;
    }
    crystalNum++;
    [crystalLabel setString:[NSString stringWithFormat:@"x%i", crystalNum]];
}


-(void)update:(ccTime)delta
{
    timeTmp.percentage++;  
    if(timeTmp.percentage>=100)
    {  
        timeTmp.percentage=0;  
    } 
}

//
//-(bool) isTouchForMe:(CGPoint)touchLocation
//{
//    
//    return CGRectContainsPoint([self.sprite boundingBox], touchLocation);
//}
//
//
//-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGPoint location = [Helper locationFromTouch:touch];
//    bool isTouchHandled = [self isTouchForMe:location]; 
//    if (isTouchHandled)
//    {
////        _sprite.color = ccRED;
////        static int i = 0;
////        i += CCRANDOM_0_1()*10;
////        int tag = i % 3;
////        PropertyCache *thePropCache = [[BodyObjectsLayer sharedBodyObjectsLayer] getPropertyCache];
////        b2World *theworld = [BodyObjectsLayer sharedBodyObjectsLayer].world;
////        [thePropCache addOneProperty:tag World:theworld Tag:tag];
//        CCLOG(@"adsf");
//    }
//    return isTouchHandled;
//}
//
//-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	//_sprite.color = ccYELLOW;
//    
//    
//}
//
//-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	//_sprite.color = ccWHITE;
//}
//
//
//#pragma mark Layer - Callbacks
//-(void) onEnter
//{
//    [self registerWithTouchDispatcher];
//	// then iterate over all the children
//	[super onEnter];
//}
//
//// issue #624.
//// Can't register mouse, touches here because of #issue #1018, and #1021
//-(void) onEnterTransitionDidFinish
//{	
//	[super onEnterTransitionDidFinish];
//}
//
//-(void) onExit
//{
//    
//    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
//	
//	[super onExit];
//}

-(void) dealloc
{
    //[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}


@end
