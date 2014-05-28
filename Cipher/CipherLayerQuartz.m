//
//  CipherLayerQuartz.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 26/Feb/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherLayerQuartz.h"


// =================================================================================================================
@interface CipherLayerQuartz()
// =================================================================================================================

@property (strong) UIBezierPath *currentTextPath;

@end



// ===============================================================================================================
@implementation CipherLayerQuartz
// ===============================================================================================================

//+ (id < CAAction >)defaultActionForKey:(NSString *)key
//{
//	return (id < CAAction >)[NSNull null];
//}

- (id) init
{
    self = [super init];
    if (self)
	{
        self.degreeOfCipher = 1;

		self.contentsScale = [UIScreen mainScreen].scale;
		[self setNeedsDisplay];
    }
    return self;
}


- (void) prep;
{
	self.backgroundColor = [UIColor whiteColor].CGColor;
	self.opaque = NO;
	self.cipherTextPath = [UIBezierPath bezierPathByConvertingPathToCurves:self.cipherTextPath];
	self.clearTextPath = [UIBezierPath bezierPathByConvertingPathToCurves:self.clearTextPath];
	self.currentTextPath = self.cipherTextPath;
}


- (void) setDegreeOfCipher:(CGFloat)degreeOfCipher
{
	if (_degreeOfCipher == degreeOfCipher)
		return;
	
	_degreeOfCipher = degreeOfCipher;

	if (degreeOfCipher == 1.0)
	{
		self.currentTextPath = self.cipherTextPath;
	}
	else if (degreeOfCipher == 0.0)
	{
		self.currentTextPath = self.clearTextPath;
	}
	else
	{
		self.currentTextPath = [UIBezierPath bezierPathByMorphingFromPath:self.clearTextPath toPath:self.cipherTextPath progress:_degreeOfCipher];
	}

	[self setNeedsDisplay];
}


- (void) drawInContext:(CGContextRef)ctx
{
	// clear
	CGContextSetFillColorWithColor(ctx, self.backgroundColor);
	CGContextFillRect(ctx, self.bounds);
	
	// draw path
	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor]);
//	CGContextSetFillColorWithColor(ctx, self.fillColor);
	CGContextAddPath(ctx, self.currentTextPath.CGPath);
	CGContextDrawPath(ctx, kCGPathStroke);
}


@end
