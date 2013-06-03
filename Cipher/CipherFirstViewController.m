//
//  CipherFirstViewController.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherFirstViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "CipherLayer.h"


// ===============================================================================================================
@interface CipherFirstViewController ()
// ===============================================================================================================

@property (strong) NSMutableArray	*touchlayers;
@property (strong) CALayer			*textContainer;

@end


// ===============================================================================================================
@implementation CipherFirstViewController
// ===============================================================================================================

static NSUInteger currentNumberOfElements	= 0;
static NSUInteger currentElementIndex		= 0;
static CGRect     currentGlyphBox;


static const CGFloat kMarginWidth		=	80;
static const CGFloat kMarginHeight		=	40;
static const CGFloat kMinRevealDistance	=  300;
static const CGFloat kMaxRevealDistance	=	50;


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Class Life Cycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.touchlayers = [NSMutableArray new];
	self.fontName = @"Helvetica-Bold";
	self.fontSize = 62.0f;
	
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
	self.textContainer.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.20].CGColor;
    [self.view.layer addSublayer:self.textContainer];
	
	
	self.textContainer.geometryFlipped = YES;

	
	// "Chalkduster"
	// "Copperplate"
	// "Helvetica Bold"
	// "Helvetica Neue UltraLight"
	
	// create a text string
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.fontSize, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)CFBridgingRelease(font), kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                                                                     attributes:attrs];

    // layout text in the frame of our text container
	
	// Create a typesetter using the attributed string.
	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrString));

	// Find a break for line from the beginning of the string to the given width.
	CFIndex start = 0;
	
	// Use the returned character count (to the break) to create the line.
	CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, self.textContainer.bounds.size.width);
	CTLineRef aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
//	CTLineRef line = aLine;
	start += count;

	UIGraphicsBeginImageContextWithOptions(self.textContainer.bounds.size, YES, 0);
	
	CGRect lineBounds = CTLineGetImageBounds(aLine, UIGraphicsGetCurrentContext());
	CGFloat ascent;
	CGFloat descent;
	CGFloat leading;
	double lineWidth = CTLineGetTypographicBounds(aLine, &ascent, &descent, &leading);

	CGFloat yPos = self.textContainer.bounds.size.height - self.fontSize;
	
	while (CTLineGetStringRange(aLine).length != 0)
	{
		// DO SOMETHING WITH THE LINE
		lineBounds = CTLineGetImageBounds(aLine, UIGraphicsGetCurrentContext());
		NSLog(@"rect = %@", NSStringFromCGRect(lineBounds));
		
		lineWidth = CTLineGetTypographicBounds(aLine, &ascent, &descent, &leading);

		NSLog(@"ascent = %f, descent = %f, leading = %f, width = %f,", ascent, descent, leading, lineWidth);

		
		// -----------------------------------------------------------------------------------------------------------------
		
		CFArrayRef runArray = CTLineGetGlyphRuns(aLine);

		// for each RUN
		for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
		{
			// Get FONT for this run
			CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
			CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
			
			// for each GLYPH in run
			for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
			{
				// DO SOMETHING WITH THE GLYPH
				
				// Create path from text
				CGMutablePathRef lettersOutlinePath = CGPathCreateMutable();
				CGMutablePathRef straightLettersPath = CGPathCreateMutable();
				
				
				// get Glyph & Glyph-data
				CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
				CGGlyph glyph;
				CGPoint position;
				CTRunGetGlyphs(run, thisGlyphRange, &glyph);
				CTRunGetPositions(run, thisGlyphRange, &position);
				
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
				CGPathApply(letterOutlinePath, (void *)straightLetter, CGPathMorphToCircles);
				numberOfElementsInPath = 0;
				CGPathApply(straightLetter, (void *)&numberOfElementsInPath, CGPathElementsCount);
				
				NSLog(@"%s %@", __PRETTY_FUNCTION__,(NSString *) NSStringFromCGRect(currentGlyphBox));

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

				
				// create visuals for this
				
				CipherLayer *lineLayer = [CipherLayer layer];
				lineLayer.clearTextPath = clearTextPath;
				lineLayer.cipherTextPath = cipherTextPath;
				lineLayer.path = clearTextPath.CGPath;
				
				lineLayer.anchorPoint = CGPointMake(0,0);
				
				lineLayer.frame = currentGlyphBox;
				lineLayer.bounds = currentGlyphBox;
				//		lineLayer.bounds = CGRectMake(0, 0, lineBounds.size.width, lineBounds.size.height);
//				lineLayer.position = CGPointMake(position.x, yPos - ascent + position.y);
//				lineLayer.position = CGPointMake(lineLayer.position.x, -lineLayer.position.y);
				lineLayer.position = CGPointMake(lineLayer.position.x +position.x, lineLayer.position.y+yPos+position.y);
				lineLayer.backgroundColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:0.4].CGColor;
				
				
				lineLayer.backgroundColor = [[UIColor colorWithRed:1.000 green:1.000 blue:0.000 alpha:1.00] CGColor];
				
				lineLayer.geometryFlipped = NO;
				lineLayer.fillColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
				
				//		lineLayer.strokeColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
				//		lineLayer.lineWidth = 3.0f;
				//		lineLayer.lineJoin = kCALineJoinBevel;
				
				
				
				
				
				[self.textContainer addSublayer:lineLayer];
			}
		}
		
		

		
		// -----------------------------------------------------------------------------------------------------------------
		
		
		
		
		

		
		// get metrics for the next line
		count = CTTypesetterSuggestLineBreak(typesetter, start, self.textContainer.bounds.size.width);
		aLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
		start += count;
		lineWidth = CTLineGetTypographicBounds(aLine, &ascent, &descent, &leading);

//		yPos = yPos + lineBounds.size.height + lineBounds.origin.y;
		yPos = yPos - self.fontSize - 12;
		
//		NSLog(@"%s %f", __PRETTY_FUNCTION__, CTFontGetLeading(font));
//		CFRelease(font);

	
	
//		textPosition.y -= ceilf(descent + leading + 1)
	}

	
	
	
	
//	CFRelease(line);
    
//    UIBezierPath *clearTextPath = [UIBezierPath bezierPath];
//    [clearTextPath moveToPoint:CGPointZero];
//    [clearTextPath appendPath:[UIBezierPath bezierPathWithCGPath:lettersOutlinePath]];
//	
//	UIBezierPath *cipherTextPath = [UIBezierPath bezierPath];
//    [cipherTextPath moveToPoint:CGPointZero];
//    [cipherTextPath appendPath:[UIBezierPath bezierPathWithCGPath:straightLettersPath]];
//	
//    CGPathRelease(lettersOutlinePath);
//    CFRelease(font);
//    
//	
//	// for now just setup one layer
//    CipherLayer *lineLayer = [CipherLayer layer];
//    lineLayer.frame = self.textContainer.bounds;
//	lineLayer.bounds = CGPathGetBoundingBox(clearTextPath.CGPath);
//	lineLayer.backgroundColor = [[UIColor yellowColor] CGColor];
//    lineLayer.geometryFlipped = YES;
//    lineLayer.path = cipherTextPath.CGPath;
//	lineLayer.clearTextPath = clearTextPath;
//	lineLayer.cipherTextPath = cipherTextPath;
////    lineLayer.strokeColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//	lineLayer.fillColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//    lineLayer.lineWidth = 3.0f;
//    lineLayer.lineJoin = kCALineJoinBevel;
//    
//    [self.textContainer addSublayer:lineLayer];
	
	UIGraphicsEndImageContext();
}


//
//- (void) setupTextContainer2
//{
//	// create a nice text container with a wide side margin
//	self.textContainer = [CALayer layer];
//	CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
//    self.textContainer.frame = CGRectMake(kMarginWidth, kMarginHeight,
//										  CGRectGetWidth(self.view.layer.bounds) - 2*kMarginWidth,
//										  CGRectGetHeight(self.view.layer.bounds) - 2*kMarginHeight - tabBarHeight);
//	self.textContainer.backgroundColor = [UIColor lightGrayColor].CGColor;
//    [self.view.layer addSublayer:self.textContainer];
//
//	
//    // Create path from text
//    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
//    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
//    CGMutablePathRef lettersOutlinePath = CGPathCreateMutable();
//    CGMutablePathRef straightLettersPath = CGPathCreateMutable();
//    
//	// "Chalkduster"
//	// "Copperplate"
//	// "Helvetica Bold"
//	// "Helvetica Neue UltraLight"
//	
//    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.fontSize, NULL);
//    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//                           (id)CFBridgingRelease(font), kCTFontAttributeName,
//                           nil];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Hello i10!"
//                                                                     attributes:attrs];
//    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
//	CFArrayRef runArray = CTLineGetGlyphRuns(line);
//    
//    // for each RUN
//    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
//    {
//        // Get FONT for this run
//        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
//        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
//        
//        // for each GLYPH in run
//        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
//        {
//            // get Glyph & Glyph-data
//            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
//            CGGlyph glyph;
//            CGPoint position;
//            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
//            CTRunGetPositions(run, thisGlyphRange, &position);
//            
//            // Get PATH of outline
//			CGPathRef letterOutlinePath = CTFontCreatePathForGlyph(runFont, glyph, NULL);
//			CGAffineTransform letterTranslation = CGAffineTransformMakeTranslation(position.x, position.y);
//			CGPathAddPath(lettersOutlinePath, &letterTranslation, letterOutlinePath);
//			
//			// Get PATH of vertical line
//			CGPathRef straightLetter = CGPathCreateMutable();
//			NSUInteger numberOfElementsInPath = 0;
//			CGPathApply(letterOutlinePath, (void *)&numberOfElementsInPath, CGPathElementsCount);
////			NSLog(@"%s 1 Count of glyph %3d is %2d", __PRETTY_FUNCTION__, (int)runGlyphIndex, numberOfElementsInPath);
//			currentNumberOfElements = numberOfElementsInPath;
//			currentElementIndex = 0;
//			currentGlyphBox = CGPathGetBoundingBox(letterOutlinePath);
//			CGPathApply(letterOutlinePath, (void *)straightLetter, CGPathMorphToCircles);
//			numberOfElementsInPath = 0;
//			CGPathApply(straightLetter, (void *)&numberOfElementsInPath, CGPathElementsCount);
////			NSLog(@"%s 2 Count of glyph %3d is %2d \n\n\n", __PRETTY_FUNCTION__, (int)runGlyphIndex, numberOfElementsInPath);
//			
//			
//			CGPathAddPath(straightLettersPath, &letterTranslation, straightLetter);
//			
//			// cleanup
//			CGPathRelease(letterOutlinePath);
//			CGPathRelease(straightLetter);
//		}
//    }
//    CFRelease(line);
//    
//    UIBezierPath *clearTextPath = [UIBezierPath bezierPath];
//    [clearTextPath moveToPoint:CGPointZero];
//    [clearTextPath appendPath:[UIBezierPath bezierPathWithCGPath:lettersOutlinePath]];
//	
//	UIBezierPath *cipherTextPath = [UIBezierPath bezierPath];
//    [cipherTextPath moveToPoint:CGPointZero];
//    [cipherTextPath appendPath:[UIBezierPath bezierPathWithCGPath:straightLettersPath]];
//	
//    CGPathRelease(lettersOutlinePath);
//    CFRelease(font);
//    
//	
//	// for now just setup one layer
//    CipherLayer *lineLayer = [CipherLayer layer];
//    lineLayer.frame = self.textContainer.bounds;
//	lineLayer.bounds = CGPathGetBoundingBox(clearTextPath.CGPath);
//	lineLayer.backgroundColor = [[UIColor yellowColor] CGColor];
//    lineLayer.geometryFlipped = YES;
//    lineLayer.path = cipherTextPath.CGPath;
//	lineLayer.clearTextPath = clearTextPath;
//	lineLayer.cipherTextPath = cipherTextPath;
//    lineLayer.strokeColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//	lineLayer.fillColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//    lineLayer.lineWidth = 3.0f;
//    lineLayer.lineJoin = kCALineJoinBevel;
//    
//    [self.textContainer addSublayer:lineLayer];
//}


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
		//		CGPathCloseSubpath(lineLetter);
		return;
	}
	
	// compute position
	CGPoint point = currentGlyphBox.origin;
	CGFloat radius = MIN(currentGlyphBox.size.width, currentGlyphBox.size.height) / 2.0;
	CGFloat angle = 2*M_PI * ((float)currentElementIndex  / (float)currentNumberOfElements);
	point.x = point.x + (currentGlyphBox.size.width / 2.0);
	point.y = point.y + (currentGlyphBox.size.height / 2.0);
	
	CGPoint middlePos =  point;
	
	point.x = middlePos.x + sin(angle)* radius;
	point.y = middlePos.y + cos(angle)* radius;
	
	CGPoint endPos = point;
	
	CGFloat beginAngle = 2*M_PI * (((float)currentElementIndex-1)  / (float)currentNumberOfElements);
	CGFloat halfAngle = 2*M_PI * (((float)currentElementIndex-0.5)  / (float)currentNumberOfElements);
	CGFloat deltaAngle =  2*M_PI * (1.0  / (float)currentNumberOfElements);
	
	CGPoint halfPos = CGPointMake(middlePos.x + sin(halfAngle)* radius, middlePos.y + cos(halfAngle)* radius);
	
	CGFloat Cradius = radius * sqrt(1+tan(deltaAngle/2.0)*tan(deltaAngle/2.0));
	
	CGPoint CPos = CGPointMake(middlePos.x + sin(halfAngle)* Cradius, middlePos.y + cos(halfAngle)* Cradius);
	
	//	point.y = point.y + currentGlyphBox.size.height * (1-(float)currentElementIndex  / (float)currentNumberOfElements);
	//	CGPoint point = element->points[0];
	
	if (currentPointType == kCGPathElementMoveToPoint)
	{
		CGPathMoveToPoint(lineLetter, NULL, point.x, point.y);
	}
	else
	{
		CGPoint beginPos =  CGPathGetCurrentPoint(lineLetter);
		//		CGPathAddLineToPoint(lineLetter, NULL, point.x, point.y);
		//		CGPathAddArc(lineLetter, NULL, middlePos.x, middlePos.y, radius, beginAngle, angle, YES);
		//		CGPathAddRelativeArc(lineLetter, NULL, middlePos.x, middlePos.y, radius, angle, 2*M_PI * (1.0  / (float)currentNumberOfElements));
		//		CGPoint halfPos = CGPointMake((beginPos.x + endPos.x) /2.0, (beginPos.y + endPos.y) /2.0);
		
		
		// http://en.wikipedia.org/wiki/B%C3%A9zier_spline#Approximating_circular_arcs
		CGFloat deltaAngle =  2*M_PI * (1.0  / (float)currentNumberOfElements);
		CGPoint A = CGPointMake(radius * cos(deltaAngle/2.0f), radius * sin(deltaAngle/2.0f));
		CGPoint B = CGPointMake(A.x, -A.y);
		
		CGPoint Aprime = CGPointMake( (4.0f-A.x)/3.0f,  (1.0f-A.x)*(3.0f-A.x)/(3.0f*A.y) );
		CGPoint Bprime = CGPointMake( Aprime.x, -Aprime.y);
		
		CGAffineTransform rotation = CGAffineTransformMakeRotation(angle - deltaAngle/2.0f);
		//		CGPathAddCurveToPoint(lineLetter, &rotation, Aprime.x, Aprime.y, Bprime.x, Bprime.y, B.x, B.y);
		
		
		CGPathAddQuadCurveToPoint(lineLetter, NULL, CPos.x, CPos.y, endPos.x, endPos.y);
	}
	currentElementIndex ++;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark User Interaction
// ---------------------------------------------------------------------------------------------------------------

- (IBAction) userDidLongPress:(UIGestureRecognizer *)sender
{
	// remove all old touch layers
	for (CALayer *aLayer in self.touchlayers)
	{
		[aLayer removeFromSuperlayer];
	}
	[self.touchlayers removeAllObjects];
	
	if (sender.state == UIGestureRecognizerStateEnded ||
		sender.state == UIGestureRecognizerStateCancelled ||
		sender.state == UIGestureRecognizerStateFailed )
		return;
	
	// create new layers for the touches
	NSUInteger numberOfTouches = [sender numberOfTouches];
	for (int i = 0 ; i < numberOfTouches; i++)
	{
		CGPoint aTouchLocation = [sender locationOfTouch:i inView:self.view];
		
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
	
	
	// get the nearest touch
	CipherLayer *ourOnlyLayer = [self.textContainer.sublayers lastObject];
	CGPoint layerLocation = [self.view.layer convertPoint:[ourOnlyLayer position] fromLayer:self.textContainer];
	CGFloat smallestDistance = MAXFLOAT;
	for (int i = 0 ; i < numberOfTouches; i++)
	{
		CGPoint aTouchLocation = [sender locationOfTouch:i inView:self.view];
		CGFloat distance = sqrt( pow(layerLocation.x - aTouchLocation.x, 2.0) + pow(layerLocation.y - aTouchLocation.y, 2.0));
		smallestDistance = MIN(distance,smallestDistance);
	}
	CGFloat morphProgression = (smallestDistance - kMinRevealDistance) / (kMaxRevealDistance - kMinRevealDistance);
	morphProgression = MAX( MIN(morphProgression, 1.0), 0.0);

	ourOnlyLayer.degreeOfCipher = 1 - morphProgression; // 0 means full reveal, 1 full hide
}


@end

