//
//  CipherLayer.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 2/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherLayer.h"


// ===============================================================================================================
@implementation CipherLayer
// ===============================================================================================================

NSString *const kMorphAnimationKey      = @"kMorphAnimationKey";

- (id) init
{
    self = [super init];
    if (self)
	{
        _degreeOfCipher = 0;
    }
    return self;
}


- (void) setDegreeOfCipher:(CGFloat)degreeOfCipher
{
	_degreeOfCipher = degreeOfCipher;

	[self setUpAnimation];
}


- (void) setUpAnimation
{
	[self removeAnimationForKey:kMorphAnimationKey];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
	animation.duration = 1.01;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.speed = 0;
	animation.timeOffset = _degreeOfCipher;
	animation.fromValue = (id)self.clearTextPath.CGPath;
	animation.toValue = (id)self.cipherTextPath.CGPath;
	[self addAnimation:animation forKey:kMorphAnimationKey];
}


@end
