//
//  StorageSprite.m
//  GreedFamily
//
//  Created by 赵 苹果 on 12-4-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Storage.h"
#import "GameBackgroundLayer.h"
#import "SimpleAudioEngine.h"
#import "Helper.h"
#import "Food.h"
#import "GameMainScene.h"
#import "LandAnimal.h"
#import "Bag.h"
#import "TouchCatchLayer.h"
#import "NoBodyObjectsLayer.h"

@interface Storage (PrivateMethods)
-(id)initWithCapacity:(int)capacity Play:(int)PlayID;
-(void)moveFood;
-(void)reduceFood:(int)count Turn:(int)turn;
-(void)oneSecondCheckMax:(ccTime)delta;
-(void)combineMain:(int)totalNum;
-(void)checkCombineFood;
-(void)checkLastCombineFood;
-(int)doCombineFoodLoop;
-(void)checkMax;
@end

@implementation Storage
@synthesize sprite = _sprite;

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
}

+(id)createStorage:(int)storageCapacity Play:(int)playID
{
    return [[[self alloc] initWithCapacity:storageCapacity Play:playID] autorelease];
}

-(id)initWithCapacity:(int)capacity Play:(int)playID
{
    if ((self = [super init]))
    {
        storageID = playID;
        myGameScore = [GameScore createGameScore:playID];
        [self addChild:myGameScore z:1 tag:-3 ];  
        //[self registerWithTouchDispatcher];
        gamelevel= [GameMainScene sharedMainScene].sceneNum;
        storageCapacity = capacity;
        CCSpriteBatchNode* batch = [[GameBackgroundLayer sharedGameBackgroundLayer] getSpriteBatch];
        _sprite = [CCSprite spriteWithSpriteFrameName:@"storage.png"];
        //先不可见，后续再去掉或替换图片
        _sprite.visible = NO;
        //CGSize screenSize = [[CCDirector sharedDirector] winSize];
        //change size by diff version by manue
        _sprite.position = [GameMainScene sharedMainScene].storagePos;
        if (2 == playID) 
        {
            CGPoint distance = CGPointMake(240, 0);
            _sprite.position = ccpAdd(_sprite.position, distance);
        }
        [batch addChild:_sprite];
        
        counter = 0;
        nowScoreTime = 0;
        lastScoreTime = 0;
        //[self initScores];
        
        foodArray = [[CCArray alloc] initWithCapacity:storageCapacity];
        combinArray = (int *)malloc(storageCapacity*sizeof(int));
        canCombine = NO;
        
        continuousConbineFlag = 0;
        
        //gameScore *instanceOfgameScore = [gameScore sharedgameScore];
        
        
        //[self scheduleUpdate];
        
        //处理最外面的球球
        //[self schedule:@selector(oneSecondCheckMax:) interval:1];
        
        //实时计算得分
        //得分在触摸时进行计算 
        //实现一个函数 关卡结束时进行调用
        //[self schedule:@selector(updateGameScore:) interval:0.5];
        
        //计算两次消球的时间间隔
        [self schedule:@selector(gameTimeUpdate:) interval:1];
        [self schedule:@selector(getScoreUpdate:) interval:0.1];

        
    }
    
    return self;
}

//炸掉仓库
-(void)bombStorage
{
    int num = [foodArray count];
    for (int i=0;i < num; i++) 
    {
        [self reduceFood:i Turn:i];
    }
}

//消除同一种颜色的球
//add by liujin at 7.19 
-(void)combinTheSameTypeNew
{
    int nowcount = [foodArray count];
    int left_index = 0;
    int right_index = nowcount -1;    
    int temp = 0;
    Food *nowFood = nil;    
    
    while(1)
    {
        right_index = [foodArray count]-1;
        if (right_index < 1)
        {
            return;
        }
        
        if (left_index==right_index)
        {
            nowFood = [foodArray objectAtIndex:right_index];                    
            foodInStorage[nowFood.foodType]++;            
            //删除right_index;
            //[[foodArray objectAtIndex:right_index] mySprite].visible = NO;
            id actionScale = [CCScaleBy actionWithDuration:2]; 
            [[[foodArray objectAtIndex:right_index] mySprite] runAction:actionScale];
  
            
            //闪烁特效
            CCParticleSystem* system;
            system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"land_crystal.plist"];
            system.positionType = kCCPositionTypeFree;
            system.autoRemoveOnFinish = YES;
            system.position = [[foodArray objectAtIndex:right_index] mySprite].position;
            [self addChild:system];
            
            [foodArray removeObjectAtIndex:right_index]; 
            currentCount--;      
            temp++;
            //得分音效
            [[GameMainScene sharedMainScene] playAudio:GetScore];

            
            break;
        }
        while(left_index<right_index)
        {
            if ([[foodArray objectAtIndex:right_index] foodType] == [[foodArray objectAtIndex:left_index] foodType]) 
            {
                nowFood = [foodArray objectAtIndex:right_index]; 
                //Food *delFood = [foodArray objectAtIndex:left_index]; 
                foodInStorage[nowFood.foodType]++;
                //[[foodArray objectAtIndex:left_index] mySprite].visible = NO;
                id actionScale = [CCScaleBy actionWithDuration:2]; 
                [[[foodArray objectAtIndex:left_index] mySprite] runAction:actionScale];
                [foodArray removeObjectAtIndex:left_index]; 
                //闪烁特效
                CCParticleSystem* system;
                system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"land_crystal.plist"];
                system.positionType = kCCPositionTypeFree;
                system.autoRemoveOnFinish = YES;
                system.position = [[foodArray objectAtIndex:left_index] mySprite].position;
                [self addChild:system];
                //[foodArray removeObjectAtIndex:left_index]; 
                currentCount--; 
                temp++;
                [self moveFood];

                break;
            }
            else
            {
                left_index++;
            }
            
        }
        
    }//end while
    
    //GameScore *instanceOfgameScore = [GameScore sharedgameScore];     
    

    
    [myGameScore calculateConsistentCombineScore:gamelevel
                                      oneTimeScoreNumber:temp
                                                foodType:nowFood.foodType
                                                  Cheese:foodInStorage[2]
                                                   Candy:foodInStorage[1]
                                                   Apple:foodInStorage[0]
                                               DelayTime:0]; 
    
    [self combineBallNew];
    
}



-(void)addFoodToStorage:(int)foodType
{
    if (currentCount >= storageCapacity) 
    {
        CCLOG(@"storage is alread full!\n");
        return;
    }
    //糖果类型应该小于3   0  1  2 
    if (foodType < 3)
    {
        Food * food = [[Food alloc]initWithStorage:self Type:foodType Count:currentCount StorageID:storageID];
        [foodArray insertObject:food atIndex:currentCount];
        currentCount++;
        
        [food release];
        
        //检查是否达到最大
        [self checkMax];
    }
    //辣椒
    else if (6 == foodType)
    {
        Bag *bag = nil;
        CCLOG(@"oh yah!!!!!!!\n");
        if (1 == storageID) 
        {
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBag];

        }
        else
        {
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBagPlay2];

        }
        [bag addPepper];
    }
    //冰块
    else if (5 == foodType)
    {
        LandAnimal *landAnimal = nil;
        CCLOG(@"cold!!!!!!!\n");
        if (1 == storageID) 
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimal];
        }
        else
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimalPlay2];
        }
        [landAnimal decreaseSpeed];
    }
    //黑炸弹
    else if (4 == foodType)
    {
        LandAnimal *landAnimal = nil;
        CCLOG(@"oh no!!!!!!!\n");
        if (1 == storageID) 
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimal];
        }
        else
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimalPlay2];
        }
        [landAnimal bombed];
        [self bombStorage];
    }
    //水晶球
    else if (3 == foodType)
    {
        LandAnimal *landAnimal = nil;
        Bag *bag = nil;
        CCLOG(@"cool!!!!!!!\n");
        if (1 == storageID) 
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimal];
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBag];
        }
        else
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimalPlay2];
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBagPlay2];
        }
        [landAnimal getCrystal];
        [bag addCrystal];       
    }
    //反向球
    else if (7 == foodType)
    {
        Bag *bag = nil;
	LandAnimal *landAnimal = nil;
        CCLOG(@"cool!!!!!!!\n");
        if (1 == storageID) 
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimal];
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBag];
        }
        else
        {
            landAnimal = [[NoBodyObjectsLayer sharedNoBodyObjectsLayer]  getLandAnimalPlay2];
            bag = [[TouchCatchLayer sharedTouchCatchLayer] getBagPlay2];
        }
        [bag addSmoke];
    }
}

//消去消球后调用的函数
-(void)reduceFood:(int)count Turn:(int)turn
{
    //[[foodArray objectAtIndex:(count - turn)] mySprite].visible = NO;
    //    [foodArray removeObjectAtIndex:count];
    id actionScale = [CCScaleBy actionWithDuration:2];    
    [[[foodArray objectAtIndex:(count - turn)] mySprite] runAction:actionScale];
    //爆炸特效
    CCParticleSystem* system;
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"land_bomb.plist"];
    system.positionType = kCCPositionTypeFree;
    system.autoRemoveOnFinish = YES;
    system.position = [[foodArray objectAtIndex:(count - turn)] mySprite].position;
    [self addChild:system];
    
    
    [foodArray removeObjectAtIndex:(count - turn)];
    currentCount--;
}

//检查是否能消
//通过外层的三个球是否相同
-(void)checkLastCombineFood
{
    int n = [foodArray count];
    
    if (n < 3) 
    {
        self.sprite.visible = NO;
        canCombine = NO;
        return;
    }
    
    Food * curFood = nil;
    Food * leftFood = nil;
    Food *leftmostFood= nil;
    leftmostFood = [foodArray objectAtIndex:n-3];
    leftFood = [foodArray objectAtIndex:n-2];
    if (leftFood.foodType != leftmostFood.foodType)
    {
        self.sprite.visible = NO;
        canCombine = NO;
        return;
    }
    curFood = [foodArray objectAtIndex:n-1];
    if (curFood.foodType == leftFood.foodType) 
    {
        if (!canCombine)
        {
            //[[SimpleAudioEngine sharedEngine] playEffect:@"needtouch.caf"];
            [[GameMainScene sharedMainScene] playAudio:NeedTouch];
            
        }
        canCombine = YES;
//        id ac0 = [CCShow action];
//        id ac1 = [CCBlink actionWithDuration:1 blinks:2]; 
//        id ac2 = [CCToggleVisibility action]; 
//        [self.sprite
//         runAction:[CCSequence actions:ac0, ac1, ac2, nil]]; 
        CCParticleSystem* system;
        system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"sparkle.plist"];
        system.positionType = kCCPositionTypeFree;
        system.autoRemoveOnFinish = YES;
        system.position = self.sprite.position;
        [self addChild:system];
        
    }
    else
    {
        self.sprite.visible = NO;
        canCombine = NO;
    }
    
    return;
}

-(void)moveFood
{
    Food *curFood = nil;
    for (int i=0;i < storageCapacity; i++)
    {
        if ( i >= [foodArray count])
        {
            break;
        }
        
        curFood = [foodArray objectAtIndex:i];
        if (nil == curFood) 
        {
            continue;
        }
        
        float widthPer = [curFood.mySprite contentSize].width * curFood.mySprite.scaleX;
        float highPer = [curFood.mySprite contentSize].height * curFood.mySprite.scaleY;
        
        CGPoint moveToPosition = CGPointMake(i * widthPer + widthPer * 0.5, highPer * 0.5);
        if (2 == storageID) 
        {   
            //change size by diff version query
            CGPoint distance = CGPointMake(240, 0);
            moveToPosition = ccpAdd(distance, moveToPosition);
        }
       
        
        
        if (!__CGPointEqualToPoint(curFood.mySprite.position, moveToPosition))
        {
            //            CCAction *moveAction = [CCSequence actions:
            //                                    [CCMoveTo actionWithDuration:2 position:moveToPosition],
            //                                    nil
            //                                    ];
            //            
            //            [curFood runAction:moveAction];
            
            
            CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:moveToPosition]; 
            CCEaseInOut* ease = [CCEaseInOut actionWithAction:move rate:4];
            [curFood.mySprite runAction:ease];
            
            //curFood.mySprite.position = moveToPosition;
        }
        
        //        if (nil == curFood)
        //        {
        //            for (int j = i + 1; j < storageCapacity; j++) 
        //            {
        //                moveFood = [foodArray objectAtIndex:j];
        //                
        //                if (nil == moveFood) 
        //                {
        //                    continue;
        //                }
        //                [foodArray insertObject:moveFood atIndex:i];
        //                [foodArray removeObjectAtIndex:j];
        //                //action
        //                CGPoint moveToPosition = CGPointMake(i * 32 + 16, 20);
        //                CCAction *moveAction = [CCSequence actions:
        //                                   [CCMoveTo actionWithDuration:0.5 position:moveToPosition],
        //                                   nil
        //                                   ];
        //                
        //                [moveFood runAction:moveAction];
        //            }
        //        }
        //        
        //
        //        
    }
    
    
}

//触摸引发的消球
//added by rauljin at 7.17
-(void)combineBallNew
{
    int counter_flag = 0;
    CCLOG(@"Into combineBallNew\n\n");
    
    int nowcount = [foodArray count];
    if(nowcount < 3 )
    {
        return;
    }    
    CCLOG(@"nowcount:%d",nowcount);
    
    Food *nowFood = nil;
    
    int left_index = nowcount - 3;
    int mid_index = nowcount -2;
    int right_index = nowcount -1;
    int temp = 2;
    int consisFlag = 0;
    int delayTime = 0;
    //if (!canCombine) {
    //    return;
    //}
    while(1)
    {
        delayTime += 2;
        counter_flag++;
        //CCLOG(@"while 1 hahaha\n");
        right_index = [foodArray count] -1;
        mid_index = [foodArray count] -2;
        left_index= [foodArray count] -3;       
        temp = 2;
        //CCLOG(@"right_index is %d",right_index);
        if (right_index < 2 || counter_flag>30)
        {

            break;
        }
        
        
        while(left_index>=0)
        {
            //CCLOG(@"while left_index\n");
            counter_flag++;    
            if([[foodArray objectAtIndex:right_index] foodType] == [[foodArray objectAtIndex:mid_index] foodType] 
               && [[foodArray objectAtIndex:left_index] foodType] ==[[foodArray objectAtIndex:mid_index] foodType])            
            {
                temp = temp + 1;
                if (left_index == 0)
                {
                    if (temp>=3)
                    {
                        CCLOG(@"这次消去的水果个数为 %d",temp);
                        nowFood = [foodArray objectAtIndex:left_index];    
                        foodInStorage[nowFood.foodType] += temp;
                        
                        //调用一次性消球 得分函数         
                        //GameScore *instanceOfgameScore = [GameScore sharedgameScore];     
                        
                        [myGameScore calculateConsistentCombineScore:gamelevel
                                                          oneTimeScoreNumber:temp
                                                                    foodType:nowFood.foodType
                                                                      Cheese:foodInStorage[2]
                                                                       Candy:foodInStorage[1]
                                                                       Apple:foodInStorage[0]
                                                                   DelayTime:delayTime];      
                        
                        
                        consisFlag ++;
                        while (temp>0)
                        { 
                            id ac1 = [CCScaleBy actionWithDuration:0.5 scale:1.5*nowFood.scaleX]; 
                            id ac2 = [CCScaleBy actionWithDuration:2];
                            [[[foodArray objectAtIndex:left_index] mySprite] 
                             runAction:[CCSequence actions:ac1, ac2, nil]]; 
//                            [[[foodArray objectAtIndex:left_index] mySprite] runAction:actionScale];
                            //闪烁特效
                            CCParticleSystem* system;
                            system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"shootingstars.plist"];
                            system.positionType = kCCPositionTypeFree;
                            system.autoRemoveOnFinish = YES;
                            system.position = [[foodArray objectAtIndex:left_index] mySprite].position;
                            [self addChild:system];
                            //[[foodArray objectAtIndex:left_index] mySprite].visible = NO;
                            [foodArray removeObjectAtIndex:left_index];
                            temp --;
                            currentCount--;
                            [self moveFood];
                        }
                        
                        //得分音效
                        [[GameMainScene sharedMainScene] playAudio:GetScore];

                    }
                    break;
                    
                }
                
                left_index--;
                mid_index--;
            }
            
            else
            {
                if (temp>=3)
                {
                    CCLOG(@"这次消去的水果个数为 %d",temp);
                    consisFlag++;
                    nowFood = [foodArray objectAtIndex:mid_index];    
                    foodInStorage[nowFood.foodType] += temp;                
                    
                    //调用一次性消球 得分函数         
                    //GameScore *instanceOfgameScore = [GameScore sharedgameScore];     
                    
                    [myGameScore calculateConsistentCombineScore:gamelevel
                                                      oneTimeScoreNumber:temp
                                                                foodType:nowFood.foodType
                                                                  Cheese:foodInStorage[2]
                                                                   Candy:foodInStorage[1]
                                                                   Apple:foodInStorage[0]
                                                               DelayTime:delayTime]; 
                    
                    
                    while (temp>0) 
                    {
                        id ac1 = [CCScaleBy actionWithDuration:0.5 scale:1.5*nowFood.scaleX]; 
                        id ac2 = [CCScaleBy actionWithDuration:2]; 
                        [[[foodArray objectAtIndex:mid_index] mySprite] 
                         runAction:[CCSequence actions:ac1, ac2, nil]]; 
                        //闪烁特效
                        CCParticleSystem* system;
                        system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"shootingstars.plist"];
                        system.positionType = kCCPositionTypeFree;
                        system.autoRemoveOnFinish = YES;
                        system.position = [[foodArray objectAtIndex:mid_index] mySprite].position;
                        [self addChild:system];
                        //[[foodArray objectAtIndex:mid_index] mySprite].visible = NO;
                        [foodArray removeObjectAtIndex:mid_index];
                        temp--;
                        currentCount--;
                        [self moveFood];
                    }
                    
                    //得分音效
                    [[GameMainScene sharedMainScene] playAudio:GetScore];
                    break;
                }
                left_index--;
                mid_index--;
                right_index--;
            }
            
        }
        
    }   
    
    CCLOG(@"consisFlag is %d",consisFlag);
    if (consisFlag>0)
    {    
        //调用连续消球 得分函数         
        //GameScore *instanceOfgameScore = [GameScore sharedgameScore];     
        [myGameScore calculateContinuousCombineAward:consisFlag myLevel:gamelevel];            
    }
    
    [self moveFood];
    
}



-(CCArray * )getScoreByLevel:(int)level
{
    CCLOG(@"INTO getScoreByLevel\n\n");
    CCArray *LevelScore;
    //GameScore *instanceOfgameScore = [GameScore sharedgameScore];
    LevelScore = [myGameScore calculateScoreWhenGameIsOver:level timestamp:counter];
    
    //int addscore = (int)[LevelScore objectAtIndex:1];
    //CCLOG(@"addscore is %d\n\n",addscore);
    return LevelScore;
}

-(void)updateScores
{
    [cheeseScoreLabel setString:[NSString stringWithFormat:@"x%i", foodInStorage[2]]];
    [candyScoreLabel setString:[NSString stringWithFormat:@"x%i", foodInStorage[1]]];
    [appleScoreLabel setString:[NSString stringWithFormat:@"x%i", foodInStorage[0]]];
    
}

-(void)getScoreUpdate:(ccTime)delta
{
    [self checkLastCombineFood];
    
    if (needUpdateScore)
    {
        [self updateScores];
        needUpdateScore = NO;
    }
    
}

-(void)checkMax
{
    if (currentCount == storageCapacity)
    {
        id actionScale = [CCScaleBy actionWithDuration:2];    
        [[[foodArray objectAtIndex:0] mySprite] runAction:actionScale];
        [foodArray removeObjectAtIndex:0];
        currentCount--;
        [self moveFood];
    }
}

//简单计数  
-(void)gameTimeUpdate:(ccTime)delta
{
    //CCLOG(@"counter is %d",counter);
    counter++;
    return;
}

-(int)getStarNumber:(int)levle
{

    return levle;

}


-(bool) isTouchForPlay1:(CGPoint)touchLocation
{
    //change size by diff version manual
    CGRect rec = CGRectMake(0, 0, 200, 30);
    return CGRectContainsPoint(rec, touchLocation);
}

-(bool) isTouchForPlay2:(CGPoint)touchLocation
{
    //change size by diff version manual
    CGRect rec = CGRectMake(240, 0, 200, 30);
    return CGRectContainsPoint(rec, touchLocation);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [Helper locationFromTouch:touch];
    bool isTouchHandled = NO;
    if (1 == storageID) 
    {
        isTouchHandled = [self isTouchForPlay1:location];
    } 
    else
    {
        isTouchHandled = [self isTouchForPlay2:location];
    }
    
    
    if (isTouchHandled)
    {
        _sprite.color = ccRED;
        
        //judge time reward by manual opetation
        if(canCombine) 
        {
            //first time score
            if (lastScoreTime == 0) 
            {
                lastScoreTime = counter;
                nowScoreTime = counter;
            }
            else
            {
                nowScoreTime = counter;
                CCLOG(@"nowScoreTime is %d",nowScoreTime);
                CCLOG(@"lastScoreTime is %d",lastScoreTime);
                if ((nowScoreTime-lastScoreTime)<timeReward)
                {
                    //调用时间奖励 得分函数         
                    //GameScore *instanceOfgameScore = [GameScore sharedgameScore];     
                    [myGameScore calculateTimeAward:gamelevel];
                    
                    //
                }    
                lastScoreTime = counter;
            }    
            //调用消球函数
            //[self combineMain:0];
            [self combineBallNew];               
        } //end if   
     
    } //end of if 
    
    return isTouchHandled;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	_sprite.color = ccYELLOW;
    
    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	_sprite.color = ccWHITE;
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
    [foodArray release];
    free(combinArray);
	[super dealloc];
}

//-(void)checkCombineFood
//{
//    if (canCombine)
//    {
//        return;
//    }
//    for (int i=0;i < storageCapacity; i++)
//    {
//        if ( i >= [foodArray count])
//        {
//            break;
//        }
//        if (i>1) 
//        {
//            Food * curFood = nil;
//            Food * leftFood = nil;
//			Food *leftmostFood= nil;
//            leftmostFood = [foodArray objectAtIndex:i-2];
//            leftFood = [foodArray objectAtIndex:i-1];
//            if (leftFood.foodType != leftmostFood.foodType)
//            {
//                continue;
//            }
//            curFood = [foodArray objectAtIndex:i];
//            if (curFood.foodType == leftFood.foodType) 
//            {
//                canCombine = YES;
//                //可以消求音效
//                [[SimpleAudioEngine sharedEngine] playEffect:@"needtouch.caf"];
//                break;
//            }
//        }
//    }
//    
//    
//}
//


//触摸引发的消球 
//-(void)combineMain:(int)totalCount
//{
//    CCLOG(@"Into combineMain /n/n/n");
//    //同类型的球消了多少个 
//    int timesPerTouch = 0;
//    //int totalCount = 0;
//    //可以连续消
//    while (canCombine) 
//    {
//        timesPerTouch++;
//        timesOfOneTouch++;
//        [self doMyCombineFood];
//    }
//    
//    if (timesOfOneTouch < timesPerTouch) 
//    {
//        timesOfOneTouch = timesPerTouch;
//    }
//    
//    if (numbersOfOneTime < totalCount)
//    {
//        numbersOfOneTime = totalCount;
//    }
//}

////add by lj at 6.20
////根据触摸引起的消球 
////计算得分
//-(void)doMyCombineFood
//{
//    CCLOG(@"Into doMyCombineFood");
//    //continuousConbineFlag 一次消了多少个球
//    continuousConbineFlag = 0;
//    while([self doCombineFoodLoop])
//    {
//        continuousConbineFlag++;
//    }
//    
//    //连续消球的奖励得分
//    //即最右边的糖果消掉，左边的糖果还能消除的情况 
//    if (continuousConbineFlag > 1)
//    {
//        CCLOG(@"连续消球的次数 %d\n",continuousConbineFlag);
//        //连续消球的次数 = continuousConbineFlag -1
//        //调用连续消球的奖励得分函数
//        
//        //调用一次性消球 得分函数         
//        gameScore *instanceOfgameScore = [gameScore sharedgameScore];     
//        [instanceOfgameScore calculateContinuousCombineAward:continuousConbineFlag myLevel:gamelevel];        
//    }
//    
//    [self moveFood];
//    
//    canCombine = FALSE;
//}


////判断是否能消除消球 如果能的话消除 并将消球从仓库中去掉
////返回1
////用于主体的调用该方法处理在一次触摸中连续消球的
////并记录连续消球的次数
//
////return  0 没法消除
////return  1 能消除 并且已经消除了（可能存在4个或者5个球连着的情况 也一并消除）
//-(int)doCombineFoodLoop
//{
//    CCLOG(@"Into doCombineFoodLoop /n/n/n");
//    
//    //一次消同类型球的个数
//    int oneTimeScoreNum = 0;
//    
//    int nowcount = [foodArray count];
//    if(nowcount < 3 )
//    {
//        return 0;
//    }    
//    CCLOG(@"nowcount:%d",nowcount);
//    Food * leftFood = nil;
//    Food * midFood = nil;
//    Food *rightFood = nil;    
//    Food *tempFood = nil;
//    rightFood = [foodArray objectAtIndex:nowcount-1];
//    midFood = [foodArray objectAtIndex:nowcount-2];
//    leftFood = [foodArray objectAtIndex:nowcount-3];    
//    
//    if (rightFood.foodType == midFood.foodType && leftFood.foodType==midFood.foodType)    
//    {
//        oneTimeScoreNum = 3;
//        foodInStorage[midFood.foodType] += 3;
//        int j= nowcount -4;
//        if (j>=0)   //存在4个即以上的消球
//        {    
//            CCLOG(@"INTO here !!!!!!!!!!!!!!!!!!!");    
//            tempFood = [foodArray objectAtIndex:j];
//            
//            //左边的等于还在左边的
//            while (j>=0 && (leftFood.foodType == tempFood.foodType)) 
//            {
//                
//                oneTimeScoreNum++;
//                foodInStorage[midFood.foodType] += 1;
//                if((j-1)<0)
//                {
//                    break;
//                }    
//                tempFood = [foodArray objectAtIndex:j-1];
//                //leftFood = tempFood;
//                j--;
//            }   
//            
//        }//end if (j>0)
//        
//        //调用更新糖果个数函数
//        needUpdateScore = YES;
//        
//        [[SimpleAudioEngine sharedEngine] playEffect:@"getscore.caf"];
//        
//        //将球从仓库中去掉
//        //oneTimeScoreNum 该次消掉了多少同类型的球
//        CCLOG(@"该次的消球数为 oneTimeScoreNum %d \n" ,oneTimeScoreNum);
//        for (int x=0;x<oneTimeScoreNum; x++) 
//        {
//            id actionScale = [CCScaleBy actionWithDuration:2]; 
//            [[[foodArray objectAtIndex:(nowcount-x-1)] mySprite] runAction:actionScale];
//            
//            //[[foodArray objectAtIndex:(nowcount-x-1)] mySprite].visible = NO;
//            [foodArray removeObjectAtIndex:(nowcount -x -1)];
//            currentCount--;
//        }
//        
//        //调用一次性消球 得分函数         
//        gameScore *instanceOfgameScore = [gameScore sharedgameScore];     
//        
//        [instanceOfgameScore calculateConsistentCombineScore:gamelevel
//                                          oneTimeScoreNumber:oneTimeScoreNum
//                                                    foodType:rightFood.foodType
//                                                      Cheese:foodInStorage[2]
//                                                       Candy:foodInStorage[1]
//                                                       Apple:foodInStorage[0]];
//        
//        
//        
//        return 1;
//        
//    } //end if
//    
//    else 
//    {
//        //没法消除了
//        CCLOG(@"无法消除了!\n\n");
//        return 0;
//    }
//    
//    
//}


//消除同一种颜色的球
//-(void)combinTheSameType
//{
//    int combineNum = 0;
//    //    BOOL isCombine = NO;
//    int sameTypeCount = 0;
//    Food *lastFood = nil;
//    Food * curFood = nil;
//    int lastType = 0;
//    int a;
//    if ([foodArray count] > 0)
//    {
//        lastFood = [foodArray objectAtIndex:[foodArray count] - 1];
//        lastType = lastFood.foodType;
//    }
//    else
//    {
//        return;
//    }
//    
//    for (int i=0;i < storageCapacity; i++)
//    {
//        if ( i >= [foodArray count])
//        {
//            break;
//        }
//        
//        curFood = [foodArray objectAtIndex:i];
//        if (curFood.foodType == lastFood.foodType) 
//        {
//            sameTypeCount++;
//            foodInStorage[curFood.foodType] += 1;
//            
//            a = i;
//            *(combinArray+combineNum) = a;
//            combineNum++;
//            
//            if (theSameTypeNumOfOneTime < sameTypeCount) 
//            {
//                theSameTypeNumOfOneTime = sameTypeCount;
//            }
//        }
//    }
//    
//    needUpdateScore = YES;
//    [[SimpleAudioEngine sharedEngine] playEffect:@"getscore.caf"];
//    canCombine = YES;
//    
//    int index;
//    for (int i=0;i < combineNum; i++) 
//    {
//        index = *(combinArray + i);
//        [self reduceFood:index Turn:i];
//    }
//    
//    [self moveFood];
//    canCombine = NO;
//    
//    //消完后马上检查，为连续消做准备
//    [self checkCombineFood];
//    
//    [self combineMain:combineNum];
//}

////消球 
//-(void)doCombineFood:(int *)totalNum
//{
//    int combineNum = 0;
//    BOOL isCombine = NO;
//    int sameTypeCount = 0;
//    
//    
//    if(!canCombine)
//    {
//        return;
//    }
//    
//    for (int i=0;i < storageCapacity; i++)
//    {
//        if ( i >= [foodArray count])
//        {
//            break;
//        }
//        if (i>1) 
//        {
//            Food * curFood = nil;
//            Food * leftFood = nil;
//			Food *leftmostFood= nil;
//            leftmostFood = [foodArray objectAtIndex:i-2];
//            leftFood = [foodArray objectAtIndex:i-1];
//            if (leftFood.foodType != leftmostFood.foodType)
//            {
//                isCombine = NO;
//                continue;
//            }
//            curFood = [foodArray objectAtIndex:i];
//            if (curFood.foodType == leftFood.foodType) 
//            {
//                int a;
//                if (!isCombine)
//                {
//                    sameTypeCount = 2;
//                    foodInStorage[curFood.foodType] += 2;
//                    a = i - 2;
//                    *(combinArray+combineNum) = a;
//                    combineNum++;
//                    a = i - 1;
//                    *(combinArray+combineNum) = a;
//                    combineNum++;
//                }
//                
//                sameTypeCount++;
//                foodInStorage[curFood.foodType] += 1;
//                
//                a = i;
//                *(combinArray+combineNum) = a;
//                combineNum++;
//                
//                if (theSameTypeNumOfOneTime < sameTypeCount) 
//                {
//                    theSameTypeNumOfOneTime = sameTypeCount;
//                }
//                
//                isCombine = YES;
//                needUpdateScore = YES;
//                [[SimpleAudioEngine sharedEngine] playEffect:@"getscore.caf"];
//            }
//            else
//            {
//                isCombine = NO;
//                continue;
//            }
//            
//        }
//    }
//    
//    
//    if (!canCombine)
//    {
//        return;
//    }
//    
//    *totalNum +=  combineNum;
//    
//    int index;
//    for (int i=0;i < combineNum; i++) 
//    {
//        index = *(combinArray + i);
//        [self reduceFood:index Turn:i];
//    }
//    
//    [self moveFood];
//    canCombine = NO;
//    
//    //消完后马上检查，为连续消做准备
//    [self checkCombineFood];
//    
//}


//-(void)updateGameScore:(ccTime)delta 
//{
//    CCLOG(@"Into updateGameScore!");
//    gameScore *instanceOfgameScore = [gameScore sharedgameScore];
//    /*
//     -(void)calculateGameScore:(int)level TimesofOneTouch:(int)timesofonetouch 
//     NumbersOfOneTime:(int)numbersOfOneTime 
//     TheSameTypeNumOfOneTime:(int)theSameTypeNumOfOneTime
//     Chocolate:(int)choclolatenum
//     Cake:(int)cakenum
//     Circle:(int)circlenum
//     */
//    //一次消的次数 
//    //int timesOfOneTouch;
//    //一次消除的个数（所有类型）
//    //int numbersOfOneTime;
//    //一种类型消除个数
//    //int theSameTypeNumOfOneTime;
//    CCLOG(@"timesOfOneTouch :%d\n",timesOfOneTouch);
//    CCLOG(@"numbersOfOneTime :%d\n",numbersOfOneTime);
//    CCLOG(@"theSameTypeNumOfOneTime q q :%d\n",theSameTypeNumOfOneTime);
//    
//    /*
//    [instanceOfgameScore calculateGameScore:gamelevel 
//                            TimesofOneTouch:timesOfOneTouch 
//                           NumbersOfOneTime:numbersOfOneTime 
//                    TheSameTypeNumOfOneTime:theSameTypeNumOfOneTime 
//                                  Chocolate:foodInStorage[2] 
//                                       Cake:foodInStorage[1] 
//                                     Circle:foodInStorage[0]];
//    */
//}


@end
