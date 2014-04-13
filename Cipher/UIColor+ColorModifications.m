//
//  UIColor+ColorModifications.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 13/Apr/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import "UIColor+ColorModifications.h"

// ===============================================================================================================
@implementation UIColor (ColorModifications)
// ===============================================================================================================

- (UIColor *) colorWithSaturationMultiplier:(CGFloat)multiplier
{
	CGFloat hue;
	CGFloat saturation;
	CGFloat brightness;
	CGFloat alpha;
	[self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	saturation = saturation * multiplier;
	UIColor *newColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
	return newColor;
}


@end
