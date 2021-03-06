//
//  NoBodyObjectsLayer.h
//  GreedFamily
//
//  Created by 赵 苹果 on 12-4-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LandCandyCache.h"
#import "LandAnimal.h"
typedef enum
{   
    LandAnimalTag = 1,
    CompetitorTag,
    LandCandyTag,
    LandAnimalPlay2Tag
    
}NoBodyObjectsLayerTags;

typedef enum
{
	IceType = 50,   
    PepperType,              
	BombType,            
    CrystalType,
    SpeedfastType,
    SmokeType
    
} ParticleType;

@interface NoBodyObjectsLayer : CCLayer {
    
}
+(id)CreateNoBodyObjectsLayer;
+(NoBodyObjectsLayer *)sharedNoBodyObjectsLayer;
-(LandCandyCache*) getLandCandyCache;
-(LandAnimal *) getLandAnimalPlay2;
-(LandAnimal *) getLandAnimal;
@end
