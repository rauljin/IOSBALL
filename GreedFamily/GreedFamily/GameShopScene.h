//
//  GameShopScene.h
//  GreedFamily
//
//  Created by 赵 苹果 on 12-7-31.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#define SPEED1 100
#define SPEED2 500
#define SPEED3 1000
#define STORAGE1 200
#define STORAGE2 400
@interface GameShopScene : CCLayer 
{
    CCSpriteBatchNode* batch;    
    CGSize screenSize;
    int roalType;
}
@property (nonatomic) int buyedList;
+(id)createGameShopScene;
+(CCScene *) gameShopScene;
-(void)updateScore;
@end
