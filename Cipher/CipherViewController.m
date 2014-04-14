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
#import "CipherStroke.h"
#import "CipherLayerQuartz.h"
#import "CipherLayer.h"


// ===============================================================================================================
@interface CipherViewController ()
// ===============================================================================================================

@property (strong) NSMutableArray	*touchlayers;
@property (strong) CALayer			*textContainer;

@end


// ===============================================================================================================
@implementation CipherViewController
// ===============================================================================================================

//static NSUInteger currentNumberOfElements	= 0;
//static NSUInteger currentElementIndex		= 0;
//static CGRect     currentGlyphBox;
//static BOOL		  isFirstPoint = YES;
//static CGFloat    startingAngle = 0;

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
	
	NSArray *glyphStrokes = [CipherStroke strokesForString:attrString
												  inBounds:self.textContainer.bounds
												   options:0];

	CipherStroke *loadingTest  = [CipherStroke strokeForSVGFileNamed:@"portrait"];
	UIBezierPath *loadingPath = loadingTest.path;
	[loadingTest flipGeometry];
	loadingPath = loadingTest.path;
	
	CipherStroke *cipher = [loadingTest circularCipher];
	UIBezierPath *cipherPath = [cipher path];
	
	glyphStrokes = [glyphStrokes arrayByAddingObject:loadingTest];
	
	for (CipherStroke *aStroke in glyphStrokes)
	{
		// create layer from our model
		// cipher strokes are always canonical
//		CipherLayerQuartz *aLayer = [[CipherLayerQuartz alloc] init];
		CipherLayer *aLayer = [[CipherLayer alloc] init];
		aLayer.clearTextPath = aStroke.path;
		aLayer.cipherTextPath = [aStroke circularCipher].path;
		aLayer.anchorPoint = CGPointMake(0,0);
		aLayer.frame = aStroke.frame;
		aLayer.bounds = aStroke.frame;
		aLayer.position = aStroke.position;

		aLayer.clearColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000];
//		aLayer.clearColor = nil;
//		aLayer.fillColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//		aLayer.fillColor = nil;
		aLayer.lineWidth = 0.0f;
		
		// line cap square would be preferable, but invisible line fragments can produce noise
		aLayer.lineCap = kCALineCapButt;
		
		// a lower value redices artifacts during morphs, e.g. Helvetica 'a'
		aLayer.miterLimit = 5.0f;
//		aLayer.lineJoin  = kCALineJoinBevel;
		
		[aLayer prep];
				
		[self.textContainer addSublayer:aLayer];
	}
	
	
//	
//	
//	
//	CipherLayer *aLayer = [[CipherLayer alloc] init];
//	aLayer.clearTextPath = loadingTest.path;
//	aLayer.cipherTextPath = [loadingTest circularCipher].path;
//	aLayer.anchorPoint = CGPointMake(0,0);
//	aLayer.frame = loadingTest.frame;
//	aLayer.bounds = loadingTest.frame;
//	aLayer.position = loadingTest.position;
//	
//	aLayer.clearColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000];
//	//		aLayer.clearColor = nil;
//	//		aLayer.fillColor = [[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000] CGColor];
//	//		aLayer.fillColor = nil;
//	aLayer.lineWidth = 2.0f;
//	
//	// line cap square would be preferable, but invisible line fragments can produce noise
//	aLayer.lineCap = kCALineCapButt;
//	
//	// a lower value redices artifacts during morphs, e.g. Helvetica 'a'
//	aLayer.miterLimit = 5.0f;
//	//		aLayer.lineJoin  = kCALineJoinBevel;
//	
//	[aLayer prep];
//	
//	[self.view.layer addSublayer:aLayer];
//

	
	
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
		
//		for (CipherLayerQuartz *aGlyphLayer in self.textContainer.sublayers)
		for (CipherLayer *aGlyphLayer in self.textContainer.sublayers)
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

