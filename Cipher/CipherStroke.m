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
	
	// ?
	//	UIGraphicsBeginImageContextWithOptions(containerBounds.size, YES, 0);
	
	// this has always been a wonky computation
	CGFloat descent;
	CTLineGetTypographicBounds(aLine, NULL, &descent, NULL);
	//	CGFloat lineY = containerBounds.size.height - self.fontSize + descent;
	
	
	
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
				glyphModel.path = clearTextPath;
				glyphModel.frame = CGPathGetBoundingBox(lettersOutlinePath);
				
				// create model object for this stroke
				//				CipherStroke *glyphModel = [CipherStroke new];
				//				glyphModel.stroke = clearTextPath;
				////				glyphModel.anchorPoint = CGPointMake(0,0);
				//				glyphModel.frame = currentGlyphBox;
				//				glyphModel.bounds = currentGlyphBox;
				//
				//				glyphModel.position = CGPointMake(glyphLayer.position.x +glyphPosition.x,
				//												  glyphLayer.position.y + glyphPosition.y +lineY);
				//				glyphModel.strokeColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
				//				glyphModel.lineWidth = 1.0f;
				//				//				glyphLayer.lineJoin = kCALineJoinBevel;
				
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
		
		//		lineY = lineY - self.fontSize - 2;
	}
	
	
	return [NSArray arrayWithArray:result];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Conversion
// ---------------------------------------------------------------------------------------------------------------

- (CipherStroke *) cicularCipher
{
	UIBezierPath *resultPath = [[UIBezierPath alloc] init];

	// morph into a cricle
	NSInteger currentNumberOfElements = [self.path countOfPathElements];
	__block NSInteger currentElementIndex = 0;
	__block BOOL isFirstPoint = YES;
	__block float startingAngle = 0;
	
	// compute position
	CGPoint origin = self.frame.origin;
	CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) / 2.0;
	CGPoint middlePos;
	middlePos.x = origin.x + (self.frame.size.width / 2.0);
	middlePos.y = origin.y + (self.frame.size.height / 2.0);

	[self.path enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;

		// do nothing on line ends
		if (currentPointType == kCGPathElementCloseSubpath)
			return;

		// on the first point, compute the starting angle
		if (isFirstPoint)
		{
			isFirstPoint = NO;
			CGPoint originalPoint = element->points[0];
			CGPoint delta = CGPointMake(originalPoint.x - middlePos.x,
										originalPoint.y - middlePos.y);
			startingAngle = atan2(delta.x, delta.y);
		}
		
		CGFloat angle = 2*M_PI * ((float)currentElementIndex  /
								  (float)currentNumberOfElements) +startingAngle;
		CGPoint endPos;
		endPos.x = middlePos.x + sin(angle)* radius;
		endPos.y = middlePos.y + cos(angle)* radius;
		
		
		//	CGFloat beginAngle = 2*M_PI * (((float)currentElementIndex-1)  / (float)currentNumberOfElements) +startingAngle;
		CGFloat halfAngle = 2*M_PI * (((float)currentElementIndex-0.5)  / (float)currentNumberOfElements) +startingAngle;
		CGFloat deltaAngle =  2*M_PI * (1.0  / (float)currentNumberOfElements);
		
		//	CGPoint halfPos = CGPointMake(middlePos.x + sin(halfAngle)* radius, middlePos.y + cos(halfAngle)* radius);
		
		CGFloat Cradius = radius * sqrt(1+tan(deltaAngle/2.0)*tan(deltaAngle/2.0));
		
		CGPoint CPos = CGPointMake(middlePos.x + sin(halfAngle)* Cradius, middlePos.y + cos(halfAngle)* Cradius);
		
		//	point.y = point.y + currentGlyphBox.size.height * (1-(float)currentElementIndex  / (float)currentNumberOfElements);
		//	CGPoint point = element->points[0];
		
		if (currentPointType == kCGPathElementMoveToPoint)
		{
			[resultPath moveToPoint:CGPointMake(endPos.x, endPos.y)];
			//CGPathMoveToPoint(lineLetter, NULL, endPos.x, endPos.y);
		}
		else
		{
			//		CGPathAddLineToPoint(lineLetter, NULL, endPos.x, endPos.y);
			
			//		CGPoint beginPos =  CGPathGetCurrentPoint(lineLetter);
			//		//		CGPathAddArc(lineLetter, NULL, middlePos.x, middlePos.y, radius, beginAngle, angle, YES);
			//		//		CGPathAddRelativeArc(lineLetter, NULL, middlePos.x, middlePos.y, radius, angle, 2*M_PI * (1.0  / (float)currentNumberOfElements));
			//		//		CGPoint halfPos = CGPointMake((beginPos.x + endPos.x) /2.0, (beginPos.y + endPos.y) /2.0);
			//
			//
			//		// http://en.wikipedia.org/wiki/B%C3%A9zier_spline#Approximating_circular_arcs
			////		CGFloat deltaAngle =  2*M_PI * (1.0  / (float)currentNumberOfElements);
			//		CGPoint A = CGPointMake(radius * cos(deltaAngle/2.0f), radius * sin(deltaAngle/2.0f));
			//		CGPoint B = CGPointMake(A.x, -A.y);
			//
			//		CGPoint Aprime = CGPointMake( (4.0f-A.x)/3.0f,  (1.0f-A.x)*(3.0f-A.x)/(3.0f*A.y) );
			//		CGPoint Bprime = CGPointMake( Aprime.x, -Aprime.y);
			//
			//		CGAffineTransform rotation = CGAffineTransformMakeRotation(angle - deltaAngle/2.0f);
			//		//		CGPathAddCurveToPoint(lineLetter, &rotation, Aprime.x, Aprime.y, Bprime.x, Bprime.y, B.x, B.y);
			
			
			[resultPath addQuadCurveToPoint:CGPointMake(CPos.x, CPos.y)
							   controlPoint:CGPointMake(endPos.x, endPos.y)];
			// CGPathAddQuadCurveToPoint(lineLetter, NULL, CPos.x, CPos.y, endPos.x, endPos.y);
		}
		currentElementIndex ++;
	}];

	// create model object
	CipherStroke *resultStroke = [CipherStroke new];
	resultStroke.path = resultPath;
	resultStroke.frame = self.frame;
	
	return resultStroke;
}




@end
