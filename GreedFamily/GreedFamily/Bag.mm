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
@implementation Bag
@synthesize sprite = _sprite;
//-(void) registerWithTouchDispatcher
//{
//    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
//}

-(void)callTimePepper: (ccTime) dt
{
    CCProgressTimer*timeTmp=(CCProgressTimer*)[self getChildByTag:pepperTimeTag];
    timeTmp.percentage++;  
    if(timeTmp.percentage>=100)
    {  
        [pepperPropMenu setIsEnabled:YES];
        timeTmp.percentage=0;  
        [self unschedule:_cmd];
        
        //[self unschedule:@selector(callTimeCrystal:)]; 
    }   
    
}

-(void)callTimeCrystal: (ccTime) dt
{
    CCProgressTimer*timeTmp=(CCProgressTimer*)[self getChildByTag:crystalTimeTag];
    timeTmp.percentage++;  
    if(timeTmp.percentage>=100)
    {  
        [crystalPropMenu setIsEnabled:YES];
        timeTmp.percentage=0;  
        [self unschedule:_cmd];
        
        //[self unschedule:@selector(callTimeCrystal:)]; 
    }   
    
}

-(void)callTimeSmoke: (ccTime) dt
{
    CCProgressTimer*timeTmp=(CCProgressTimer*)[self getChildByTag:smokeTimeTag];
    timeTmp.percentage++;  
    if(timeTmp.percentage>=100)
    {  
        [smokePropMenu setIsEnabled:YES];
        timeTmp.percentage=0;  
        [self unschedule:_cmd];
        
        //[self unschedule:@selector(callTimeCrystal:)]; 
    }   
    
}

-(void)onPepper:(id)sender
{
    if (0 >= pepperNum) 
    {
        return;
    }
    CCLOG(@"hot!!!!!!!!\n");
    [[LandAnimal sharedLandAnimal] increaseSpeed];
    pepperNum--;
    if (0 == pepperNum) 
    {
        //消失动画
        pepperMenu.visible = NO;
    } 
    else
    {
        [pepperPropMenu setIsEnabled:NO];
        [self schedule:@selector(callTimePepper:) interval:0.1];
    }
    [pepperLabel setString:[NSString stringWithFormat:@"x%i", pepperNum]];
    
}

-(void)onCrystal:(id)sender
{
    if (0 >= crystalNum)
    {
        return;
    }
    Storage *storage = [[TouchCatchLayer sharedTouchCatchLayer] getStorage];

    //[storage combinTheSameType];
    [storage combinTheSameTypeNew]; 
    crystalNum--;
    if (0 == crystalNum) 
    {
        //消失动画
        crystalMenu.visible = NO;
    } 
    else
    {
        [crystalPropMenu setIsEnabled:NO];
        [self schedule:@selector(callTimeCrystal:) interval:0.1];
    }

    [crystalLabel setString:[NSString stringWithFormat:@"x%i", crystalNum]];
    
}

-(void)onSmoke:(id)sender
{
    if (0 >= smokeNum)
    {
        return;
    }
    //烟雾特效
    CCParticleSystem* system;
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke2.plist"];
    system.positionType = kCCPositionTypeGrouped;
    system.autoRemoveOnFinish = YES;
    //system.position = self.sprite.position;
    [self addChild:system];

    [[LandAnimal sharedLandAnimal] reverseDirection];
    smokeNum--;
    if (0 == smokeNum) 
    {
        //消失动画
        smokeMenu.visible = NO;
    } 
    else
    {
        [smokePropMenu setIsEnabled:NO];
        [self schedule:@selector(callTimeSmoke:) interval:0.1];
    }
    [smokeLabel setString:[NSString stringWithFormat:@"x%i", smokeNum]];
    
}
-(id)init
{
    if ((self = [super init]))
    {
        //[self registerWithTouchDispatcher];
        
//        CCSpriteBatchNode* batch = [[GameBackgroundLayer sharedGameBackgroundLayer] getSpriteBatch];
//        _sprite = [CCSprite spriteWithSpriteFrameName:@"bag_background.png"];
//        CGSize screenSize = [[CCDirector sharedDirector] winSize];
//        _sprite.position = CGPointMake(464, screenSize.height / 2);
//        [batch addChild:_sprite z:-3];
        //CGSize screenSize = [[CCDirector sharedDirector] winSize];
        pepperNum = 0;
        crystalNum = 0;
        

        
        CCSprite *pepperProp1 = [CCSprite spriteWithSpriteFrameName:@"pepper-.png"];
        CCSprite *pepperProp2 = [CCSprite spriteWithSpriteFrameName:@"pepper-.png"];    
        pepperPropMenu = [CCMenuItemSprite itemFromNormalSprite:pepperProp1 
                                                                   selectedSprite:pepperProp2 
                                                                           target:self 
                                                                         selector:@selector(onPepper:)];
        pepperPropMenu.scaleX=(25)/[pepperProp1 contentSize].width; //按照像素定制图片宽高
        pepperPropMenu.scaleY=(25)/[pepperProp1 contentSize].height;
        pepperLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
        
        pepperLabel.anchorPoint = CGPointMake(-3, 0.2);
        pepperLabel.scale = 0.4;
        [pepperPropMenu addChild:pepperLabel z:1];
        pepperMenu = [CCMenu menuWithItems:pepperPropMenu,nil];
        //change size by diff version
        pepperMenu.position = [GameMainScene sharedMainScene].pepperMenuPos;
        pepperMenu.visible = NO;
        [self addChild:pepperMenu z:-2 ];
        CCProgressTimer *timePepper = [CCProgressTimer progressWithFile:@"cd.png"];
        timePepper.type=kCCProgressTimerTypeRadialCW;//进度条的显示样式  
        timePepper.percentage = 0; //当前进度       
        timePepper.position = pepperMenu.position; 
        [self addChild:timePepper z:-1 tag:pepperTimeTag];
        
        
        CCSprite *crystalProp1 = [CCSprite spriteWithSpriteFrameName:@"crystallball.png"];
        CCSprite *crystalProp2 = [CCSprite spriteWithSpriteFrameName:@"crystallball.png"];    
        crystalPropMenu = [CCMenuItemSprite itemFromNormalSprite:crystalProp1 
                                                                   selectedSprite:crystalProp2 
                                                                           target:self 
                                                                         selector:@selector(onCrystal:)];
        crystalPropMenu.scaleX=(25)/[crystalProp1 contentSize].width; //按照像素定制图片宽高
        crystalPropMenu.scaleY=(25)/[crystalProp1 contentSize].height;

        crystalLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
        crystalLabel.anchorPoint = CGPointMake(-3, 0.2);
        crystalLabel.scale = 0.4;
        [crystalPropMenu addChild:crystalLabel z:1];
        crystalMenu = [CCMenu menuWithItems:crystalPropMenu,nil];
        //change size by diff version
        CGPoint distance = CGPointMake(40, 0);
        crystalMenu.position = ccpAdd(distance, [GameMainScene sharedMainScene].pepperMenuPos);
        crystalMenu.visible = NO;
        [self addChild:crystalMenu z:-2];
        CCProgressTimer *timeCrystal = [CCProgressTimer progressWithFile:@"cd.png"];
        timeCrystal.type=kCCProgressTimerTypeRadialCW;//进度条的显示样式  
        timeCrystal.percentage = 0; //当前进度       
        timeCrystal.position = crystalMenu.position; 
        [self addChild:timeCrystal z:-1 tag:crystalTimeTag];
        
        
        CCSprite *smokeProp1 = [CCSprite spriteWithSpriteFrameName:@"cake.png"];
        CCSprite *smokeProp2 = [CCSprite spriteWithSpriteFrameName:@"cake.png"];    
        smokePropMenu = [CCMenuItemSprite itemFromNormalSprite:smokeProp1 
                                                  selectedSprite:smokeProp2 
                                                          target:self 
                                                        selector:@selector(onSmoke:)];
        smokePropMenu.scaleX=(25)/[smokeProp1 contentSize].width; //按照像素定制图片宽高
        smokePropMenu.scaleY=(25)/[smokeProp1 contentSize].height;
        
        smokeLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
        smokeLabel.anchorPoint = CGPointMake(-3, 0.2);
        smokeLabel.scale = 0.25;
        [smokePropMenu addChild:smokeLabel z:1];
        smokeMenu = [CCMenu menuWithItems:smokePropMenu,nil];
        //change size by diff version
        CGPoint distance2 = CGPointMake(80, 0);
        smokeMenu.position = ccpAdd(distance2, [GameMainScene sharedMainScene].pepperMenuPos);

        smokeMenu.visible = NO;
        [self addChild:smokeMenu z:-2];
        CCProgressTimer *timeSmoke = [CCProgressTimer progressWithFile:@"cd.png"];
        timeSmoke.type=kCCProgressTimerTypeRadialCW;//进度条的显示样式  
        timeSmoke.percentage = 0; //当前进度       
        timeSmoke.position = smokeMenu.position; 
        [self addChild:timeSmoke z:-1 tag:smokeTimeTag];

    }
    
    return self;
}

-(void)addPepper
{
    if (0 == pepperNum) 
    {
        //出现动画
        //change size by diff version
        CGPoint distance1 = CGPointMake(0, 0);
        CGPoint distance2 = CGPointMake(0, -30);
        CGPoint moveToPosition = ccpAdd(distance1, [GameMainScene sharedMainScene].pepperMenuPos);
        pepperMenu.position = ccpAdd(distance2, moveToPosition);
    
        pepperMenu.visible = YES;
        CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:moveToPosition]; 
        CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:2];
        [pepperMenu runAction:ease];

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
        CGPoint distance1 = CGPointMake(40, 0);
        CGPoint distance2 = CGPointMake(0, -30);
        CGPoint moveToPosition = ccpAdd(distance1, [GameMainScene sharedMainScene].pepperMenuPos);
        crystalMenu.position = ccpAdd(distance2, moveToPosition);
        
        crystalMenu.visible = YES;
        CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:moveToPosition]; 
        CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:2];
        [crystalMenu runAction:ease];

    }
    crystalNum++;
    [crystalLabel setString:[NSString stringWithFormat:@"x%i", crystalNum]];
}

-(void)addSmoke
{
    if (0 == smokeNum) 
    {
        //出现动画
        //change size by diff version
        CGPoint distance1 = CGPointMake(80, 0);
        CGPoint distance2 = CGPointMake(0, -30);
        CGPoint moveToPosition = ccpAdd(distance1, [GameMainScene sharedMainScene].pepperMenuPos);
        smokeMenu.position = ccpAdd(distance2, moveToPosition);
        smokeMenu.visible = YES;
        CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:moveToPosition]; 
        CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:2];
        [smokeMenu runAction:ease];

    }
    smokeNum++;
    [smokeLabel setString:[NSString stringWithFormat:@"x%i", smokeNum]];
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
