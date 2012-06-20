//
//  ResultLayer.m
//  GreedFamily
//
//  Created by MagicStudio on 12-6-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResultLayer.h"
#import "LevelScene.h"
#import "LoadingScene.h"

// 该类在GameMainScene中关卡结束时被调用，用于显示分数／关卡等信息
// 使用方法参见 GameMainScene:pauseGame中注释的部分
// 可供测试使用，点击暂停按钮，即可进行测试


@interface ResultLayer (PrivateMethods)
-(id) initWithResult:(ccColor4B)color Level:(int)level Score:(int)score AddScore:(int)addscore;
@end

@implementation ResultLayer

+(id)createResultLayer:(ccColor4B)color Level:(int)level Score:(int)score AddScore:(int)addscore
{
    return [[[ResultLayer alloc] initWithResult:color Level:level Score:score AddScore:addscore] autorelease];
}

-(void)chooseLevel:(CCMenuItemImage *)btn
{
    int level=btn.tag;
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:(TargetScenes)level]];
}

-(void)returnLevel
{
    [[CCDirector sharedDirector] replaceScene:[LevelScene scene]];
}

-(id) initWithResult:(ccColor4B)color Level:(int)level Score:(int)score AddScore:(int)addscore
{
    if ((self = [super initWithColor:color]))
    {
        NSString* temp=[@"level score: " stringByAppendingFormat:@" %d",score];
        CCLabelTTF* labelscore = [CCLabelTTF labelWithString:temp fontName:@"Marker Felt" fontSize:30];
		CGSize size = [[CCDirector sharedDirector] winSize];
		labelscore.position = CGPointMake(size.width / 3, size.height * 4 / 5 );
        [labelscore setColor:ccBLUE];
		[self addChild:labelscore];
        
        temp=[@"added score: " stringByAppendingFormat:@" %d",addscore];
        CCLabelTTF* labeladdscore = [CCLabelTTF labelWithString:temp fontName:@"Marker Felt" fontSize:30];
		labeladdscore.position = CGPointMake(size.width / 3, size.height * 3 / 5 );
        [labeladdscore setColor:ccBLUE];
		[self addChild:labeladdscore];
        
        temp=[@"total score: " stringByAppendingFormat:@" %d",score+addscore];
        CCLabelTTF* labeltotalscore = [CCLabelTTF labelWithString:temp fontName:@"Marker Felt" fontSize:30];
		labeltotalscore.position = CGPointMake(size.width / 3, size.height * 2 / 5 );
        [labeltotalscore setColor:ccBLUE];
		[self addChild:labeltotalscore];
        
        CCLabelTTF *retryLabel=[CCLabelTTF labelWithString:@"Retry" fontName:@"Marker Felt" fontSize:30];
        [retryLabel setColor:ccRED];
        CCMenuItemLabel * retryBtn = [CCMenuItemLabel itemWithLabel:retryLabel target:self selector:@selector(chooseLevel:)];
        
        CCLabelTTF *LevelLabel=[CCLabelTTF labelWithString:@"Level" fontName:@"Marker Felt" fontSize:30];
        [LevelLabel setColor:ccRED];
        CCMenuItemLabel * LevelBtn = [CCMenuItemLabel itemWithLabel:LevelLabel target:self selector:@selector(returnLevel)];
        
        CCLabelTTF *nextLabel=[CCLabelTTF labelWithString:@"Next" fontName:@"Marker Felt" fontSize:30];
        [nextLabel setColor:ccRED];
        CCMenuItemLabel * nextBtn = [CCMenuItemLabel itemWithLabel:nextLabel target:self selector:@selector(chooseLevel:)];
        
        [retryBtn setTag:level];
        [nextBtn setTag:level+1];
        
        CCMenu * dMenu = [CCMenu menuWithItems:retryBtn,LevelBtn,nextBtn,nil];
        [dMenu alignItemsHorizontallyWithPadding:40];
        [dMenu setPosition:ccp((size.width)*0.5f,(size.height)*1/5)];
        [self addChild:dMenu];
        
    }
    return self;
}

@end