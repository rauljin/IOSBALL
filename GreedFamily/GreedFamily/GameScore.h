//
//  gameScore.h
//  GreedFamily
//
//  Created by 晋 刘 on 12-6-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MyGameScore.h"

#define  RewardTimeScore 15

/*
 struct  struct_gameScore{
 int level1NowScore;
 int level1HighestScore;
 int level2NowScore;
 int level2HighestScore;
 int level3NowScore;
 int level3HighestScore;
 int level4NowScore;
 int level4HighestScore;    
 int level5NowScore;
 int level5HighestScore;
 } ;
 */

typedef enum
{
	BaseScoreTag = 0,
    AwardScoreTag,
	ContinuousAwardScoreTag,
	ScoreTags_MAX,
} ScoreTags;

struct  struct_gameScore_rules{
    int apple;
    int cheese;
    int candy;
    int chocolate;
    int circle;
    int Once6circle;
    int Once5circle;
    int Once4circle;
};

struct  struct_gameScore{
    int level1NowScore;
    int level1HighestScore;
    int level2NowScore;
    int level2HighestScore;
    int level3NowScore;
    int level3HighestScore;
    int level4NowScore;
    int level4HighestScore;    
    int level5NowScore;
    int level5HighestScore;
    int version;
};





@interface GameScore : CCNode {
    struct struct_gameScore_rules my_struct_gameScore_rules;
    struct struct_gameScore my_struct_gameScore;
    CCLabelBMFont*  totalScoreLabel;
    CCLabelBMFont* hightestTotalScoreLabel;
    int gamelevel;
    //当前关卡游戏得分
    int my_nowlevelscore;
    //当前关卡游戏奖励得分
    int award_nowlevelscore;
    int delayTime;
    CCArray *LevelScore;
}

+(GameScore *)sharedgameScore;
+(id)createGameScore:(int)playID;
//初始化得分规则
-(void)setScoreSetRules;
-(id)initWithPlayID:(int)playID;
//获取当前关卡得分
//-(int)getGameNowScore:(int)level HighestScore:(int)highestscore NowScore:(int)nowScore;
//-(int)getGameNowScore:(int)level;

//获得当前关卡最高得分
-(int)getGameHighestScore:(int)level;
//获取当前关卡的星级评定
-(int)getGameStarNumber:(int)level;



//计算当前得分
//一次消的次数 
//int timesOfOneTouch;
//一次消除的个数（所有类型）
//int numbersOfOneTime;
//一种类型消除个数
//int theSameTypeNumOfOneTime;
/*
-(void)calculateGameScore:(int)level TimesofOneTouch:(int)timesofonetouch 
         NumbersOfOneTime:(int)numbersOfOneTime 
  TheSameTypeNumOfOneTime:(int)theSameTypeNumOfOneTime
                Chocolate:(int)choclolatenum
                     Cake:(int)cakenum
                   Circle:(int)circlenum;
*/
//一次性消球得分
-(void)calculateConsistentCombineScore:(int)mygamelevel
                    oneTimeScoreNumber:(int)oneTimeScoreNum
                              foodType:(int)myfoodType
                                Cheese:(int)cheesenum
                                 Candy:(int)candynum
                                 Apple:(int)applenum
                             DelayTime:(int)delayTime;


//-(CCArray *)calculateScoreWhenGameIsOver:(int)level;
-(CCArray *)calculateScoreWhenGameIsOver:(int)level timestamp:(int)mytimestamp;

-(void)calculateContinuousCombineAward:(int)continuousflag 
                               myLevel:(int)gameLevel;

-(void)calculateTimeAward:(int)gameLevel;
//-(int)getGameStarNumber:(int)level;
@end
