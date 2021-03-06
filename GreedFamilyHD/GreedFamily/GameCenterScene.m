//
//  GameCenterScene.m
//  GreedFamily
//
//  Created by 赵 苹果 on 12-7-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameCenterScene.h"
#import "NavigationScene.h"
#import "GCHelper.h"
#import "AppDelegate.h"

@implementation GameCenterScene

+(CCScene *) gamecenterScene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameCenterScene *layer = [GameCenterScene createGameCenterScene];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
	return scene;
}

+(id)createGameCenterScene
{
    return [[[GameCenterScene alloc] init] autorelease];
}

- (id) init {
    if ((self = [super init])) 
    {
		self.isTouchEnabled = YES;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *returnLabel=[CCLabelTTF labelWithString:@"GO Back" fontName:@"Marker Felt" fontSize:25];
        [returnLabel setColor:ccRED];
        CCMenuItemLabel * returnBtn = [CCMenuItemLabel itemWithLabel:returnLabel target:self selector:@selector(goBack:)];
        [returnBtn setPosition:ccp((screenSize.width)/2,(screenSize.height)/4)];
        CCMenu * menu = [CCMenu menuWithItems:returnBtn,nil];
		[self addChild:menu];
		[menu setPosition:ccp(0,0)];
        
        [[GCHelper sharedInstance] authenticateLocalUser];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;  
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 
                                                maxPlayers:2 
                                            viewController:delegate.viewController
                                                  delegate:self];
    }   
    
    return self;
}

-(void)goBack:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[NavigationScene scene]];
}
@end
