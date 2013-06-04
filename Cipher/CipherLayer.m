//
//  CipherLayer.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 2/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherLayer.h"


// =================================================================================================================
@interface CipherLayer()
// =================================================================================================================

@property (strong) CABasicAnimation *prototypeAnimation;

@end



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
		
		self.prototypeAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
		self.prototypeAnimation.duration = 1.01;
		self.prototypeAnimation.speed = 0;
		self.prototypeAnimation.timeOffset = _degreeOfCipher;
    }
    return self;
}

- (void) prep;
{
	self.prototypeAnimation.fromValue = (id)(self.clearTextPath.CGPath);
	self.prototypeAnimation.toValue = (id)(self.cipherTextPath.CGPath);

	self.backgroundColor = [UIColor whiteColor].CGColor;
	self.opaque = YES;
	self.drawsAsynchronously = YES;
}


- (void) setDegreeOfCipher:(CGFloat)degreeOfCipher
{
	if (_degreeOfCipher == degreeOfCipher)
		return;
	
	_degreeOfCipher = degreeOfCipher;
	
	[self removeAnimationForKey:kMorphAnimationKey];

	if (degreeOfCipher == 1.0)
	{
		self.path = self.cipherTextPath.CGPath;
//		[CATransaction begin];
//		[CATransaction setDisableActions: YES];
//		self.hidden = YES;
//		[CATransaction commit];
	}
	else if (degreeOfCipher == 0.0)
	{
		self.path = self.clearTextPath.CGPath;
//		[CATransaction begin];
//		[CATransaction setDisableActions: YES];
//		self.hidden = YES;
//		[CATransaction commit];
	}
	else
	{
//		[CATransaction begin];
//		[CATransaction setDisableActions: YES];
//		self.hidden = NO;
//		[CATransaction commit];
		//	A copy from the prototype speeds up the setup of the animation by -20%
		CABasicAnimation *animation = [self.prototypeAnimation copy];
		animation.timeOffset = _degreeOfCipher;
		[self addAnimation:animation forKey:kMorphAnimationKey];
	}
}



@end
