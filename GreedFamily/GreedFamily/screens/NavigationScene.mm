//
//  NavigationScene.m
//  Box2d_test
//
//  Created by 赵 苹果 on 12-3-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
#import "NavigationScene.h"
#import "LevelScene.h"
#import "OptionsScene.h"
#import "GameCenterScene.h"
#import "GameKitHelper.h"
#import "GameScore.h"
#import "CCRadioMenu.h"
#import "GameMainScene.h"
#import "LevelScenePair.h"
#import "RoleScene.h"
#import "SimpleAudioEngine.h"

@interface Navigation
-(void)newGame:(id)sender;
-(void)options:(id)sender;
-(void)gamecenter:(id)sender;
-(void)playAudio:(int)audioType;
@end


@implementation NavigationScene

@synthesize viewType = _viewType;

-(id)initWithNavigationScene
{
    if ((self = [super init])) {
		self.isTouchEnabled = YES;
        CGSize size = [[CCDirector sharedDirector] winSize];

        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"beginscene_default.plist"];
        //set the background pic
		CCSprite * background = [CCSprite spriteWithFile:@"background_begin.jpg"];
        background.scaleX=(size.width)/[background contentSize].width; //按照像素定制图片宽高是控制像素的。
        background.scaleY=(size.height)/[background contentSize].height;
        NSAssert( background != nil, @"background must be non-nil");
		[background setPosition:ccp(size.width / 2, size.height/2)];
		[self addChild:background];
		
        //set logo
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logopic.png"];
        logo.scaleX=(size.width*3/4)/[logo contentSize].width; //按照像素定制图片宽高是控制像素的。
        logo.scaleY=(size.height*1/2)/[logo contentSize].height;
        [self addChild:logo];
        logo.position=CGPointMake(size.width / 2, size.height * 2 / 3 );
        
        //set play 
        CCSprite *play = [CCSprite spriteWithSpriteFrameName:@"playpic.png"];
        play.scaleX=(size.width*1/4)/[play contentSize].width; //按照像素定制图片宽高是控制像素的。
        play.scaleY=(size.height*1/4)/[play contentSize].height;
        CCSprite *play1 = [CCSprite spriteWithSpriteFrameName:@"playpic.png"];
        play1.scaleX=(size.width*0.5)/[play1 contentSize].width; //按照像素定制图片宽高是控制像素的。
        play1.scaleY=(size.height*0.5)/[play1 contentSize].height;
        CCMenuItemSprite *playitem = [CCMenuItemSprite itemFromNormalSprite:play 
                                                              selectedSprite:play1 
                                                                      target:self 
                                                                    selector:@selector(newGame:)];
        CCMenu * playmenu = [CCMenu menuWithItems:playitem, nil];
        [playmenu setPosition:ccp(size.width/2,size.height/2)];
        [self addChild:playmenu];
        
        //set option
        
        CCSprite *option = [CCSprite spriteWithSpriteFrameName:@"optionpic.png"];
        option.scaleX=(40)/[option contentSize].width; //按照像素定制图片宽高是控制像素的。
        option.scaleY=(40)/[option contentSize].height;
        CCSprite *option1 = [CCSprite spriteWithSpriteFrameName:@"optionpic.png"];
        option1.scaleX=(40)/[option1 contentSize].width; //按照像素定制图片宽高是控制像素的。
        option1.scaleY=(40)/[option1 contentSize].height;
        CCMenuItemSprite *optionItem = [CCMenuItemSprite itemFromNormalSprite:option 
                                                              selectedSprite:option1 
                                                                      target:self 
                                                                    selector:@selector(options:)];
        
        CCMenu * optionmenu = [CCMenu menuWithItems:optionItem, nil];
        [optionmenu setPosition:ccp(40,size.height/2)];
        [self addChild:optionmenu];
        
        
        
        
        
        
        
// delete by lyp 2012-9-2        
//        CCLabelTTF *newgameLabel=[CCLabelTTF labelWithString:@"NEW GAME" fontName:@"Marker Felt" fontSize:30];
//        CCLabelTTF *optionsLabel=[CCLabelTTF labelWithString:@"OPTIONS" fontName:@"Marker Felt" fontSize:30];
//        CCLabelTTF *gamecenterLabel=[CCLabelTTF labelWithString:@"Multi Play" fontName:@"Marker Felt" fontSize:30];
//        CCLabelTTF *leaderboardLabel=[CCLabelTTF labelWithString:@"LeaderBoard" fontName:@"Marker Felt" fontSize:30];
//        CCLabelTTF *archievementsLabel=[CCLabelTTF labelWithString:@"Achievements" fontName:@"Marker Felt" fontSize:30];
//
//        CCLabelTTF *pairPlayLabel=[CCLabelTTF labelWithString:@"Pair Play" fontName:@"Marker Felt" fontSize:30];
//		
//		[newgameLabel setColor:ccRED];
//		[optionsLabel setColor:ccRED];
//		[gamecenterLabel setColor:ccRED];
//		
//		CCMenuItemLabel * newgame = [CCMenuItemLabel itemWithLabel:newgameLabel target:self selector:@selector(newGame:)];
//		CCMenuItemLabel * options = [CCMenuItemLabel itemWithLabel:optionsLabel target:self selector:@selector(options:)];
//		CCMenuItemLabel * gamecenter = [CCMenuItemLabel itemWithLabel:gamecenterLabel target:self selector:@selector(connectGameCenter:)];
//        CCMenuItemLabel * leaderboard = [CCMenuItemLabel itemWithLabel:leaderboardLabel target:self selector:@selector(showGameLeaderboard:)];
//		CCMenuItemLabel * archievements = [CCMenuItemLabel itemWithLabel:archievementsLabel target:self selector:@selector(showGameAchievements:)];
// 
//		CCMenuItemLabel * pairPlay = [CCMenuItemLabel itemWithLabel:pairPlayLabel target:self selector:@selector(pairGame:)];
//		CCMenu * menu = [CCMenu menuWithItems:newgame,options,leaderboard,archievements,pairPlay,gamecenter, nil];
//		[menu alignItemsVerticallyWithPadding:10];
//		[self addChild:menu];
//		[menu setPosition:ccp(size.width/2,size.height/2)];

//  set play action
//		[newgame runAction:[CCSequence actions:
//							[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//							[CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],
//							nil]];
//		[options runAction:[CCSequence actions:
//							[CCDelayTime actionWithDuration:0.5],[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//							[CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],
//							nil]];
//		[leaderboard runAction:[CCSequence actions:
//                          [CCDelayTime actionWithDuration:0.9],[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//                          [CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],
//                          nil]];
//        
//        [archievements runAction:[CCSequence actions:
//                               [CCDelayTime actionWithDuration:1],[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//                               [CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],
//                               nil]];
//        [gamecenter runAction:[CCSequence actions:
//                                [CCDelayTime actionWithDuration:0.9],[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//                                [CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],nil]];
//        [pairPlay runAction:[CCSequence actions:
//                             [CCDelayTime actionWithDuration:1],[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-size.width/2,0)]  rate:2],
//                             [CCRepeat actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:1 scale:1.3],[CCScaleTo actionWithDuration:1 scale:1],nil] times:9000],nil]];
        
        //播放背景音乐
        NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
        BOOL sound = [usrDef boolForKey:@"music"];
        if (YES == sound) 
        {
            int randomNum = random()%2;
            
            if (0 == randomNum) 
            {
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"destinationshort.mp3" loop:YES];
            }
            else
            {
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"barnbeatshort.mp3" loop:YES];
                
            }
        }
        

        
//        //角色选择：0:总得分 1：小鸟 2：小猪 3：待定 
//        CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"options_check.png"
//                                                       selectedImage:@"options_check_d.png" target:self selector:@selector(button1Tapped:)];
//        CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"options_check.png"
//                                                       selectedImage:@"options_check_d.png" target:self selector:@selector(button2Tapped:)];
////        CCMenuItem *menuItem3 = [CCMenuItemImage itemFromNormalImage:@"options_check.png"
////                                selectedImage:@"options_check_d.png" target:self selector:@selector(button3Tapped:)];
//        CCRadioMenu *radioMenu =
//        [CCRadioMenu menuWithItems:menuItem1, menuItem2, nil];
//        radioMenu.position = ccp(50, 180);
//        //[radioMenu alignItemsHorizontally];
//        [radioMenu alignItemsVerticallyWithPadding:10];
//        
//        //默认要写一次文件，设置为小鸟
//        NSString *strName = [NSString stringWithFormat:@"RoleType"];
//        int roleType = [[NSUserDefaults standardUserDefaults]  integerForKey:strName];
//        if (roleType > 2 || roleType < 1) 
//        {
//            roleType = 1;
//            [[NSUserDefaults standardUserDefaults] setInteger:roleType forKey:strName];
//        }
//        
//        if (1 == roleType) 
//        {
//            [radioMenu setSelectedItem_:menuItem1];
//            [menuItem1 selected];
//        }
//        else if (2 == roleType)
//        {
//            [radioMenu setSelectedItem_:menuItem2];
//            [menuItem2 selected];
//        }
//        
//        [self addChild:radioMenu];
		
    }    
    
    return self;
}

//角色选择回调函数，把角色类型写入文件
//- (void)button1Tapped:(id)sender 
//{
//    NSString *strName = [NSString stringWithFormat:@"RoleType"];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:strName];
//}
//- (void)button2Tapped:(id)sender 
//{
//    NSString *strName = [NSString stringWithFormat:@"RoleType"];
//    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:strName];
//}
//- (void)button3Tapped:(id)sender 
//{
//    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"RoleType"];
//}


-(void)playAudio:(int)audioType
{
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    BOOL sound = [usrDef boolForKey:@"sound"];
    if (NO == sound) 
    {
        return;
    }
    
    switch (audioType) {
        case NeedTouch:
            [[SimpleAudioEngine sharedEngine] playEffect:@"needtouch.caf"];
            break; 
            
        case GetScore:
            [[SimpleAudioEngine sharedEngine] playEffect:@"getscore.caf"];
            break;            
            
        case EatCandy:
            [[SimpleAudioEngine sharedEngine] playEffect:@"der.caf"];
            break;            
            
        case EatGood:
            [[SimpleAudioEngine sharedEngine] playEffect:@"good.caf"];
            break;    
            
        case EatBad:
            [[SimpleAudioEngine sharedEngine] playEffect:@"toll.caf"];
            break;
            
        case Droping:
            [[SimpleAudioEngine sharedEngine] playEffect:@"drop.caf"];
            break;            
            
        case BubbleBreak:
            [[SimpleAudioEngine sharedEngine] playEffect:@"bubblebreak.caf"];
            break;            
            
        case BubbleHit:
            [[SimpleAudioEngine sharedEngine] playEffect:@"bubblehit.caf"];
            break;            
            
        case SelectOK:
            [[SimpleAudioEngine sharedEngine] playEffect:@"select.caf"];
            break;            
            
        case SelectNo:
            [[SimpleAudioEngine sharedEngine] playEffect:@"failwarning.caf"];
            break;            
            
        case Bombing:
            [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.caf"];
            break;   
            
        case NewHighScore:
            [[SimpleAudioEngine sharedEngine] playEffect:@"drum.caf"];
            break;   
            
        default:
            break;
    }
}

-(void)newGame:(id)sender
{
	//start a new game
    //[self showDifficultySelection];
    //数据提交
//    CCLOG(@"role type: %d", [[NSUserDefaults standardUserDefaults]  integerForKey:@"RoleType"]);
//
//    [[NSUserDefaults standardUserDefaults] synchronize];
//	[[CCDirector sharedDirector] replaceScene:[LevelScene scene]];
    [self playAudio:SelectOK];
    [[CCDirector sharedDirector] replaceScene:[RoleScene scene]];
    
}

-(void)options:(id)sender
{
    [self playAudio:SelectOK];
	//show the options of the game
    OptionsScene * gs = [OptionsScene node];
	//[[CCDirector sharedDirector]replaceScene:gs];
    [[CCDirector sharedDirector]pushScene:gs];
}

-(void) updateScoreAndShowLeaderBoard
{
    //更新累计得分,算两个role的总分
    NSString *strTotalScore = [NSString stringWithFormat:@"Totalscore_Bird"];
    int temTotalScore = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    strTotalScore = [NSString stringWithFormat:@"Totalscore_Pig"];
    temTotalScore += [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    //更新累计总时间
    NSString *strTotalTime = [NSString stringWithFormat:@"Playtime"];
    int temTotalTime = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalTime];  
    
    strTotalScore = [NSString stringWithFormat:@"Totalscore"];
    //传入分数和时间累计数
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:temTotalTime category:strTotalTime];
    [gkHelper submitScore:temTotalScore category:strTotalScore];
    
    [gkHelper showLeaderboard];
}

-(void) updateScoreAndShowAchievements
{
    //更新累计得分,算两个role的总分
    NSString *strTotalScore = [NSString stringWithFormat:@"Totalscore_Bird"];
    int temTotalScore = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    strTotalScore = [NSString stringWithFormat:@"Totalscore_Pig"];
    temTotalScore += [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    //更新累计总时间
    NSString *strTotalTime = [NSString stringWithFormat:@"Playtime"];
    int temTotalTime = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalTime]; 
    
    strTotalScore = [NSString stringWithFormat:@"Totalscore"];
    //传入分数和时间累计数
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:temTotalTime category:strTotalTime];
    [gkHelper submitScore:temTotalScore category:strTotalScore];
    
    [gkHelper showAchievements];
}

-(void)showGameLeaderboard:(id)sender
{
    [self playAudio:SelectOK];
	//connect to game center
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = self;
    _viewType = 0;
    [gkHelper authenticateLocalPlayer];

    //第一次调用需要初始化后在里边调用
    if (gkHelper.callCount != 0) 
    {
        [self updateScoreAndShowLeaderBoard];
    }

}


-(void)showGameAchievements:(id)sender
{
    [self playAudio:SelectOK];
	//connect to game center
    //[[CCDirector sharedDirector] replaceScene:[GameCenterScene gamecenterScene]];
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = self;
    _viewType = 1;
    [gkHelper authenticateLocalPlayer];
    
    //第一次调用需要初始化后在里边调用
    if (gkHelper.callCount != 0) 
    {
        [self updateScoreAndShowAchievements];
    }
    
}
                               
-(void)connectGameCenter:(id)sender
{
    [self playAudio:SelectOK];
    //connect to game center
    [[CCDirector sharedDirector] replaceScene:[GameCenterScene gamecenterScene]];
}

-(void)pairGame:(id)sender
{
    [self playAudio:SelectOK];
    //connect to game center
    //[[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:TargetSceneINVALID]];
	[[CCDirector sharedDirector] replaceScene:[LevelScenePair scene]];
}

+(id)scene
{
    //order = order;
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NavigationScene *navigationScene = [NavigationScene sceneWithNavigationScene];
	
	// add layer as a child to scene
	[scene addChild: navigationScene];

	return scene;

}

+(id)sceneWithNavigationScene
{
    return [[[self alloc] initWithNavigationScene] autorelease];
}



#pragma mark GameKitHelper delegate methods
-(int) getViewType
{
    return _viewType;
}

-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper getPlayerInfo:friends];
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	CCLOG(@"onPlayerInfoReceived: %@", [players description]);
    
    for (GKPlayer* gkPlayer in players)
	{
		CCLOG(@"PlayerID: %@, Alias: %@, isFriend: %i", gkPlayer.playerID, gkPlayer.alias, gkPlayer.isFriend);
	}
    
    //更新累计得分,算两个role的总分
    NSString *strTotalScore = [NSString stringWithFormat:@"Totalscore_Bird"];
    int temTotalScore = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    strTotalScore = [NSString stringWithFormat:@"Totalscore_Pig"];
    temTotalScore += [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalScore];
    //更新累计总时间
    NSString *strTotalTime = [NSString stringWithFormat:@"Playtime"];
    int temTotalTime = [[[MyGameScore sharedScore] standardUserDefaults] integerForKey:strTotalTime]; 
    
    strTotalScore = [NSString stringWithFormat:@"Totalscore"];
    //传入分数和时间累计数
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:temTotalTime category:strTotalTime];
    [gkHelper submitScore:temTotalScore category:strTotalScore];
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
	
	if (success)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper retrieveTopTenAllTimeGlobalScores];
	}
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	
    if (0 != gkHelper.callCount) 
    {
        return;
    }
    
    if (_viewType == 0) 
    {
        [gkHelper showLeaderboard];
    }
    
    else
    {
        [gkHelper showAchievements];
    }
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onAchievementsViewDismissed
{
    
	CCLOG(@"onAchievementsViewDismissed");
}

/*
-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	fingerLocation = [self locationFromTouch:touch];
    isTouch = YES;
	return YES;
    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //isTouch = NO;
}

-(void)update:(ccTime)delta
{
    if (isTouch)
    {
        //CGSize size = [[CCDirector sharedDirector] winSize]; 
    
        //CGRect rect1 =  CGRectMake(size.width / 2, size.height - 30.0f, 100.0f, 100.0f);
        //CGRect rect2 =  CGRectMake(size.width / 2, size.height / 2, 100.0f, 100.0f); 
        //CGRect rect3 =  CGRectMake(size.width / 2, 30.0f, 100.0f, 100.0f); 
        if (CGRectContainsPoint([label1 boundingBox], fingerLocation))
        {
        
            CCLOG(@"11111111%@\n", label1.textureRect);
            label1.color = ccWHITE;
            //CCTransitionShrinkGrow* transition = [CCTransitionShrinkGrow transitionWithDuration:3 scene:[MainScene scene:1]];
        
            //[[CCDirector sharedDirector] replaceScene:transition];
        
            [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:TargetSceneFstScene]];

            //[[CCDirector sharedDirector] replaceScene:[MainScene scene:1]];
        }
        else if (CGRectContainsPoint([label2 boundingBox], fingerLocation))
        {
            CCLOG(@"22222222\n");
            label2.color = ccWHITE;
            [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:TargetSceneScdScene]];
        }
        else if (CGRectContainsPoint([label3 boundingBox], fingerLocation))
        {
            CCLOG(@"333333\n");
            label3.color = ccWHITE;
        
            //[[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:TargetSceneThrdScene]];
                
            //CCTransitionSlideInB* transition = [CCTransitionSlideInB transitionWithDuration:3 
                                            //scene:[LoadingScene sceneWithTargetScene://TargetSceneThrdScene]];
            //[[CCDirector sharedDirector] replaceScene:transition];
            
            [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:TargetSceneThrdScene]];            
            
        }
        isTouch = NO;
        self.isTouchEnabled = NO;
    }
    
}
*/
@end
