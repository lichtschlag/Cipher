//
//  CipherLayer.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 2/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherLayer.h"

#define USE_OUR_OWN_MORPHING

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
        self.degreeOfCipher = 1;
		
#ifdef USE_OUR_OWN_MORPHING
		//
#else
		self.prototypeAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
		self.prototypeAnimation.duration = 1.01;
		self.prototypeAnimation.speed = 0;
		self.prototypeAnimation.timeOffset = _degreeOfCipher;
#endif
		
    }
    return self;
}


- (void) prep;
{
	self.prototypeAnimation.fromValue = (id)(self.clearTextPath.CGPath);
	self.prototypeAnimation.toValue = (id)(self.cipherTextPath.CGPath);

	self.backgroundColor = [UIColor whiteColor].CGColor;
	self.strokeColor = [self.clearColor colorWithSaturationMultiplier:0.5].CGColor;
	self.fillColor = [self.clearColor colorWithSaturationMultiplier:0.5].CGColor;
	self.opaque = YES;
	
	self.path = self.cipherTextPath.CGPath;
	
#ifdef USE_OUR_OWN_MORPHING
	self.drawsAsynchronously = YES;
	self.cipherTextPath = [UIBezierPath bezierPathByConvertingPathToCurves:self.cipherTextPath];
	self.clearTextPath = [UIBezierPath bezierPathByConvertingPathToCurves:self.clearTextPath];
#else
	self.drawsAsynchronously = NO;
#endif
}


- (void) setDegreeOfCipher:(CGFloat)degreeOfCipher
{
	if (_degreeOfCipher == degreeOfCipher)
		return;
	
	_degreeOfCipher = degreeOfCipher;
	
#ifdef USE_OUR_OWN_MORPHING
	if (degreeOfCipher == 1.0)
	{
		self.path = self.cipherTextPath.CGPath;
	}
	else if (degreeOfCipher == 0.0)
	{
		self.path = self.clearTextPath.CGPath;
	}
	else
	{
		self.path = [UIBezierPath bezierPathByMorphingFromPath:self.clearTextPath toPath:self.cipherTextPath progress:_degreeOfCipher].CGPath;
	}
	
	UIColor *dimmedColor = [self.clearColor colorWithSaturationMultiplier:(1.0 - degreeOfCipher *0.5)];
	
	self.strokeColor = dimmedColor.CGColor;
	self.fillColor = dimmedColor.CGColor;
#else
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

#endif


}



@end
