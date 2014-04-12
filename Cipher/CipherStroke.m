//
//  CipherStroke.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 12/Apr/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherStroke.h"
#import <CoreText/CoreText.h>

// ===============================================================================================================
@implementation CipherStroke
// ===============================================================================================================


// build scene from CipherStrokes
// returns an array of CiperStrokes (path + location + drawing attributes)
+ (NSArray *) strokesForString:(NSAttributedString *)inputString
					  inBounds:(CGRect)containerBounds
					   options:(int)perLinePerCharacterOrAsOne
{
	NSMutableArray *result = [NSMutableArray array];
	
	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(inputString));
	
	
	// Find a break for line from the beginning of the string to the given width.
	CFIndex start = 0;
	
	// Use the returned character count (to the break) to create the line.
	CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, containerBounds.size.width);
	CTLineRef aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
	start += count;
		
	// this has always been a wonky computation
	CGFloat descent;
	CTLineGetTypographicBounds(aLine, NULL, &descent, NULL);
	CTFontRef font = (__bridge CTFontRef)([inputString attributesAtIndex:0 effectiveRange:NULL][NSFontAttributeName]);
	NSUInteger textFontSize = CTFontGetSize(font);
	CGFloat lineY = containerBounds.size.height - textFontSize + descent;
	
	
	
	//					DO SOMETHING WITH THE LINE
	// ------------------------------------------------------------------------------------------------------------
	while (CTLineGetStringRange(aLine).length != 0)
	{
		
		CFArrayRef runArray = CTLineGetGlyphRuns(aLine);
		
		// for each RUN
		for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
		{
			// Get FONT for this run
			CTRunRef aRun = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
			CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(aRun), kCTFontAttributeName);
			
			// for each GLYPH in run
			for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(aRun); runGlyphIndex++)
			{
				// DO SOMETHING WITH THE GLYPH
				
				// Create path from text
				CGMutablePathRef lettersOutlinePath = CGPathCreateMutable();
				
				// get GLYPH & Glyph-data
				CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
				CGGlyph glyph;
				CGPoint glyphPosition;
				CTRunGetGlyphs(aRun, thisGlyphRange, &glyph);
				CTRunGetPositions(aRun, thisGlyphRange, &glyphPosition);
				
				// Get normal PATH of the letter
				CGPathRef letterOutlinePath = CTFontCreatePathForGlyph(runFont, glyph, NULL);
				CGPathAddPath(lettersOutlinePath, NULL, letterOutlinePath);
				CGPathRelease(letterOutlinePath);
				
				// convert to BEZIERPATH
				UIBezierPath *clearTextPath = [UIBezierPath bezierPath];
				[clearTextPath moveToPoint:CGPointZero];
				[clearTextPath appendPath:[UIBezierPath bezierPathWithCGPath:lettersOutlinePath]];
				CGPathRelease(lettersOutlinePath);
				
				// create model
				CipherStroke *glyphModel = [[CipherStroke alloc] init];
				glyphModel.path = [clearTextPath bezierPathByConvertingToCurves];
				glyphModel.frame = CGPathGetBoundingBox(lettersOutlinePath);
				
				CGPoint position = glyphModel.frame.origin;
				position.x = position.x + glyphPosition.x;
				position.y = position.y + glyphPosition.y + lineY;
				glyphModel.position = position;
								
				[result addObject:glyphModel];
			}
		}
		
		CFRelease(aLine);
		
		
		// -----------------------------------------------------------------------------------------------------------
		
		// get metrics for the next line
		count = CTTypesetterSuggestLineBreak(typesetter, start, containerBounds.size.width);
		//		CFRelease(aLine);
		aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
		start += count;
		
		lineY = lineY - textFontSize - 2;
	}
	
	
	return [NSArray arrayWithArray:result];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Conversion
// ---------------------------------------------------------------------------------------------------------------

- (CipherStroke *) circularCipher
{
	UIBezierPath *circularPath = [[UIBezierPath alloc] init];

	// morph into a cricle
	NSInteger numberOfElements = [self.path countOfVisiblePathElements];
	__block NSInteger elementIndex = 0;
	__block BOOL isFirstPoint = YES;
	__block float startingAngle = 0.0f;
	
	// compute position
	CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) / 2.0;
	CGPoint middlePos = CGPointMake(CGRectGetMidX(self.frame),
									CGRectGetMidY(self.frame));

	[self.path enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;

		// on the first point, compute the starting angle
		if (isFirstPoint)
		{
			isFirstPoint = NO;
			CGPoint originalPoint = element->points[0];
			CGPoint delta = CGPointMake(originalPoint.x - middlePos.x,
										originalPoint.y - middlePos.y);
			startingAngle = atan2(delta.x, delta.y);
		}
		
		// all other points
		CGFloat angle = 2*M_PI * ((float)elementIndex  /
								  (float)numberOfElements) + startingAngle;
		CGPoint endPos;
		endPos.x = middlePos.x + sin(angle) * radius;
		endPos.y = middlePos.y + cos(angle) * radius;
		

		// do nothing on line ends
		if (currentPointType == kCGPathElementCloseSubpath)
		{
			[circularPath closePath];
		}
		else if (currentPointType == kCGPathElementMoveToPoint)
		{
			[circularPath moveToPoint:CGPointMake(endPos.x, endPos.y)];
		}
		else
		{
			// http://en.wikipedia.org/wiki/B%C3%A9zier_spline#Approximating_circular_arcs
			CGFloat halfAngle = 2*M_PI * (((float)elementIndex - 0.5)  /
										  (float)numberOfElements) + startingAngle;
			CGFloat deltaAngle =  2*M_PI * (1.0  / (float)numberOfElements);
			
			CGFloat Cradius = radius * sqrt(1 + tan(deltaAngle/2.0)*tan(deltaAngle/2.0));
			
			CGPoint CPos = CGPointMake(middlePos.x + sin(halfAngle) * Cradius,
									   middlePos.y + cos(halfAngle) * Cradius);
			
			[circularPath addQuadCurveToPoint:CGPointMake(endPos.x, endPos.y)
							   controlPoint:CGPointMake(CPos.x, CPos.y)];
		}
		elementIndex ++;
	}];

	// create model object
	CipherStroke *resultStroke = [CipherStroke new];
	resultStroke.path = [circularPath bezierPathByConvertingToCurves];
	resultStroke.frame = self.frame;
	
	return resultStroke;
}


@end


