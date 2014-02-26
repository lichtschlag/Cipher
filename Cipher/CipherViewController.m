//
//  CipherFirstViewController.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "CipherViewController.h"
//#import "CipherLayer.h"
#import "CipherLayerQuartz.h"


// ===============================================================================================================
@interface CipherViewController ()
// ===============================================================================================================

@property (strong) NSMutableArray	*touchlayers;
@property (strong) CALayer			*textContainer;

@end


// ===============================================================================================================
@implementation CipherViewController
// ===============================================================================================================

static NSUInteger currentNumberOfElements	= 0;
static NSUInteger currentElementIndex		= 0;
static CGRect     currentGlyphBox;
static BOOL		  isFirstPoint = YES;
static CGFloat    startingAngle = 0;

static const CGFloat kMarginWidth		=	80;
static const CGFloat kMarginHeight		=	40;
static const CGFloat kMinRevealDistance	=  200;
static const CGFloat kMaxRevealDistance	=  100;


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Class Life Cycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.touchlayers = [NSMutableArray new];
//	self.fontName = @"Helvetica-Bold";
//	self.fontSize = 50.0f;
	
	// a page has a white background
	self.view.backgroundColor = [UIColor whiteColor];
	
	// setup the text as layers
	[self setupTextContainer];
}


- (void) setupTextContainer
{
	// create a nice text container with a wide side margin
	self.textContainer = [CALayer layer];
	CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.textContainer.frame = CGRectMake(kMarginWidth, kMarginHeight,
										  CGRectGetWidth(self.view.layer.bounds) - 2*kMarginWidth,
										  CGRectGetHeight(self.view.layer.bounds) - 2*kMarginHeight - tabBarHeight);
	self.textContainer.backgroundColor = [UIColor whiteColor].CGColor;

    [self.view.layer addSublayer:self.textContainer];
	
	
	self.textContainer.geometryFlipped = YES;
	self.textContainer.opaque = YES;
	
	// "Chalkduster"
	// "Copperplate"
	// "Helvetica Bold"
	// "Helvetica Neue UltraLight"
	
	// create a text string
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.fontSize, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)CFBridgingRelease(font), kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                                                     attributes:attrs];

    // layout text in the frame of our text container
	
	// Create a typesetter using the attributed string.
	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrString));

	// Find a break for line from the beginning of the string to the given width.
	CFIndex start = 0;
	
	// Use the returned character count (to the break) to create the line.
	CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, self.textContainer.bounds.size.width);
	CTLineRef aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
	start += count;

	UIGraphicsBeginImageContextWithOptions(self.textContainer.bounds.size, YES, 0);
	
	CGFloat descent;
	CTLineGetTypographicBounds(aLine, NULL, &descent, NULL);
	CGFloat lineY = self.textContainer.bounds.size.height - self.fontSize + descent;
	
	while (CTLineGetStringRange(aLine).length != 0)
	{
		//					DO SOMETHING WITH THE LINE
		// ------------------------------------------------------------------------------------------------------------
		
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
				CGMutablePathRef straightLettersPath = CGPathCreateMutable();
				
				
				// get Glyph & Glyph-data
				CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
				CGGlyph glyph;
				CGPoint glyphPosition;
				CTRunGetGlyphs(aRun, thisGlyphRange, &glyph);
				CTRunGetPositions(aRun, thisGlyphRange, &glyphPosition);
				
				// Get normal PATH of the letters
				CGPathRef letterOutlinePath = CTFontCreatePathForGlyph(runFont, glyph, NULL);
//				CGAffineTransform letterTranslation = CGAffineTransformMakeTranslation(position.x, position.y);
				CGPathAddPath(lettersOutlinePath, NULL, letterOutlinePath);
				
				// Get PATH of mophed letters
				CGPathRef straightLetter = CGPathCreateMutable();
				NSUInteger numberOfElementsInPath = 0;
				CGPathApply(letterOutlinePath, (void *)&numberOfElementsInPath, CGPathElementsCount);
				currentNumberOfElements = numberOfElementsInPath;
				currentElementIndex = 0;
				currentGlyphBox = CGPathGetBoundingBox(letterOutlinePath);
				isFirstPoint = YES;
				startingAngle = 0;
				CGPathApply(letterOutlinePath, (void *)straightLetter, CGPathMorphToCircles);
				numberOfElementsInPath = 0;
				CGPathApply(straightLetter, (void *)&numberOfElementsInPath, CGPathElementsCount);
				
//				NSLog(@"%s %@", __PRETTY_FUNCTION__,(NSString *) NSStringFromCGRect(currentGlyphBox));

				CGPathAddPath(straightLettersPath, NULL, straightLetter);
				
				// cleanup
				CGPathRelease(letterOutlinePath);
				CGPathRelease(straightLetter);
				
				
				
				UIBezierPath *clearTextPath = [UIBezierPath bezierPath];
				[clearTextPath moveToPoint:CGPointZero];
				[clearTextPath appendPath:[UIBezierPath bezierPathWithCGPath:lettersOutlinePath]];
				
				UIBezierPath *cipherTextPath = [UIBezierPath bezierPath];
				[cipherTextPath moveToPoint:CGPointZero];
				[cipherTextPath appendPath:[UIBezierPath bezierPathWithCGPath:straightLettersPath]];
				
				CGPathRelease(lettersOutlinePath);
				CGPathRelease(straightLettersPath);

				
				// create visuals for this glyph
				
//				CipherLayer *glyphLayer = [CipherLayer layer];
				CipherLayerQuartz *glyphLayer = [CipherLayerQuartz layer];
				glyphLayer.clearTextPath = clearTextPath;
				glyphLayer.cipherTextPath = cipherTextPath;
				[glyphLayer prep];
				 
				glyphLayer.anchorPoint = CGPointMake(0,0);
				
				glyphLayer.frame = currentGlyphBox;
				glyphLayer.bounds = currentGlyphBox;
				glyphLayer.position = CGPointMake(glyphLayer.position.x +glyphPosition.x, glyphLayer.position.y + glyphPosition.y +lineY);
//				glyphLayer.backgroundColor = [[UIColor colorWithRed:1.000 green:1.000 blue:0.000 alpha:1.00] CGColor];
				
//				glyphLayer.fillColor = [[UIColor colorWithRed:0.854 green:0.272 blue:0.071 alpha:1.000] CGColor];
				glyphLayer.fillColor = nil;
				
				glyphLayer.strokeColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
				glyphLayer.lineWidth = 1.0f;
//				glyphLayer.lineJoin = kCALineJoinBevel;
				
				[self.textContainer addSublayer:glyphLayer];
			}
		}
		
		// -----------------------------------------------------------------------------------------------------------------
		
		// get metrics for the next line
		count = CTTypesetterSuggestLineBreak(typesetter, start, self.textContainer.bounds.size.width);
		CFRelease(aLine);
		aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
		start += count;

		lineY = lineY - self.fontSize - 2;
		
//		NSLog(@"%s %f", __PRETTY_FUNCTION__, CTFontGetLeading(font));
	}
//	CFRelease(font);
	CFRelease(typesetter);
	CFRelease(aLine);
}


// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Path Functions
// -----------------------------------------------------------------------------------------------------------------

void CGPathElementsCount(void *info, const CGPathElement *element)
{
	NSUInteger *numberOfElementsSoFar = (NSUInteger *)info;
	CGPathElementType currentPointType = element->type;
	
	if (currentPointType != kCGPathElementCloseSubpath)
		(*numberOfElementsSoFar)++;
}


void CGPathElementsLog(void *info, const CGPathElement *element)
{
	CGPathElementType currentPointType = element->type;
	
	NSString *output =	(currentPointType == kCGPathElementMoveToPoint)			? @"kCGPathElementMoveToPoint" :
						(currentPointType == kCGPathElementAddLineToPoint)		? @"kCGPathElementAddLineToPoint" :
						(currentPointType == kCGPathElementAddQuadCurveToPoint) ? @"kCGPathElementAddQuadCurveToPoint" :
						(currentPointType == kCGPathElementAddCurveToPoint)		? @"kCGPathElementAddCurveToPoint" :
						(currentPointType == kCGPathElementCloseSubpath)		? @"kCGPathElementCloseSubpath" :
						@"unknown type";
	NSLog(@"%@", output);
}


void CGPathMorphToCircles(void *info, const CGPathElement *element)
{
	CGMutablePathRef lineLetter = info;
	
	CGPathElementType currentPointType = element->type;
	if (currentPointType == kCGPathElementCloseSubpath)
	{
		//CGPathCloseSubpath(lineLetter);
		return;
	}
	
	// compute position
	CGPoint origin = currentGlyphBox.origin;
	CGFloat radius = MIN(currentGlyphBox.size.width, currentGlyphBox.size.height) / 2.0;
	CGPoint middlePos;
	middlePos.x = origin.x + (currentGlyphBox.size.width / 2.0);
	middlePos.y = origin.y + (currentGlyphBox.size.height / 2.0);
	
	
	if (isFirstPoint)
	{
		isFirstPoint = NO;
		// compute the starting angle
		CGPoint originalPoint = element->points[0];
		CGPoint delta = CGPointMake(originalPoint.x - middlePos.x,
									originalPoint.y - middlePos.y);
		startingAngle = atan2(delta.x, delta.y);
	}
	
	CGFloat angle = 2*M_PI * ((float)currentElementIndex  / (float)currentNumberOfElements) +startingAngle;
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
		CGPathMoveToPoint(lineLetter, NULL, endPos.x, endPos.y);
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
		
		
		CGPathAddQuadCurveToPoint(lineLetter, NULL, CPos.x, CPos.y, endPos.x, endPos.y);
	}
	currentElementIndex ++;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark User Interaction
// ---------------------------------------------------------------------------------------------------------------

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self decipherLayersWithTouches:touches];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self decipherLayersWithTouches:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self decipherLayersWithTouches:nil];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self decipherLayersWithTouches:nil];
}



- (void) decipherLayersWithTouches:(NSSet *)touches
{
	// remove all old touch layers
	for (CALayer *aLayer in self.touchlayers)
	{
		[aLayer removeFromSuperlayer];
	}
	[self.touchlayers removeAllObjects];
	
//	if (sender.state == UIGestureRecognizerStateEnded ||
//		sender.state == UIGestureRecognizerStateCancelled ||
//		sender.state == UIGestureRecognizerStateFailed )
//		return;
	
	// create new layers for the touches
//	NSUInteger numberOfTouches = [touches count];

	for (UITouch *aTouch in touches)
	{
		CGPoint aTouchLocation = [aTouch locationInView:self.view];
		
		CALayer *aLayer = [CALayer new];
		aLayer.position = aTouchLocation;
		aLayer.bounds = CGRectMake(0, 0, 100, 100);
		aLayer.cornerRadius = 50;
		aLayer.borderWidth = 2;
		aLayer.borderColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0].CGColor;
		aLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0].CGColor;
		aLayer.shadowRadius = 1.0;
		aLayer.shadowOpacity = 0.8;
		aLayer.shadowOffset = CGSizeMake(0, 0);
		
		[self.touchlayers addObject:aLayer];
		[self.view.layer addSublayer:aLayer];
	}
	
	
	
	
	// iterate over all touches
	for (UITouch *aTouch in touches)
	{
		CGPoint aTouchLocation = [aTouch locationInView:self.view];
		
		aTouchLocation = [self.view.layer convertPoint:aTouchLocation toLayer:self.textContainer];
		
		for (CipherLayerQuartz *aGlyphLayer in self.textContainer.sublayers)
//		for (CipherLayer *aGlyphLayer in self.textContainer.sublayers)
		{
//			int chance = arc4random() % 100;
//			if (chance < 75)
//				continue;
			
			CGPoint layerLocation = aGlyphLayer.position;
			CGFloat smallestDistance = MAXFLOAT;
			CGFloat distance = sqrt( (layerLocation.x - aTouchLocation.x)*(layerLocation.x - aTouchLocation.x)
									+ (layerLocation.y - aTouchLocation.y)*(layerLocation.y - aTouchLocation.y));
			smallestDistance = MIN(distance,smallestDistance);
			CGFloat morphProgression = (smallestDistance - kMinRevealDistance) / (kMaxRevealDistance - kMinRevealDistance);
			morphProgression = MAX( MIN(morphProgression, 1.0), 0.0);

			aGlyphLayer.degreeOfCipher = 1 - morphProgression; // 0 means full reveal, 1 full hide
		}
	}
}
	
	



@end

