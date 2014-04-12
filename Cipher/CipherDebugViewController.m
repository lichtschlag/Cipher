//
//  CipherDebugViewController.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherDebugViewController.h"
#import "CipherDebugLayer.h"
#import <CoreText/CoreText.h>
#import "CipherStroke.h"


// ===============================================================================================================
@interface CipherDebugViewController ()
// ===============================================================================================================

@property (strong) CALayer			*textContainer;

@end

static const CGFloat kMarginWidth		=	80;
static const CGFloat kMarginHeight		=	40;


// ===============================================================================================================
@implementation CipherDebugViewController
// ===============================================================================================================

- (void) viewDidLoad
{
    [super viewDidLoad];

	// a page has a white background
	self.view.backgroundColor = [UIColor whiteColor];
	
	// setup the text as layers
	[self setupDebugLayers];
}


- (void) setupDebugLayers
{
	// create a container with a wide side margin
	self.textContainer = [CALayer layer];
	CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.textContainer.frame = CGRectMake(kMarginWidth, kMarginHeight,
										  CGRectGetWidth(self.view.layer.bounds) - 2*kMarginWidth,
										  CGRectGetHeight(self.view.layer.bounds) - 2*kMarginHeight - tabBarHeight);
	UIColor *lightOrangeColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:0.500];
	self.textContainer.borderColor = lightOrangeColor.CGColor;
	self.textContainer.borderWidth = 1.0;
	
    [self.view.layer addSublayer:self.textContainer];


	// debug row 1
	UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
	UIBezierPath *endPath = [startPath copy];
	[endPath applyTransform:CGAffineTransformMakeRotation(M_PI_4)];
	
	CipherDebugLayer *boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = startPath;
	boxLayer.frame = CGRectMake( 0, 0, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [UIBezierPath bezierPathByConvertingPathToCurves:startPath];
	boxLayer.frame = CGRectMake( 100, 0, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [UIBezierPath bezierPathByConvertingPathToCurves:endPath];
	boxLayer.frame = CGRectMake( 200, 0, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	// debug row 2
	int count = 6;
	for (int i = 0; i < count; i++)
	{
		boxLayer = [CipherDebugLayer new];
		boxLayer.debugPath = [UIBezierPath bezierPathByMorphingFromPath:[UIBezierPath bezierPathByConvertingPathToCurves:startPath]
																 toPath:[UIBezierPath bezierPathByConvertingPathToCurves:endPath]
															   progress:(i+1) / (float)(count +1)];
		boxLayer.frame = CGRectMake(i*100, 100, 100, 100);
		[self.textContainer addSublayer:boxLayer];
	}

	// debug row 3
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];

	// On device---but not simulator---90 deg rotations will often default to no-op.
	[circlePath applyTransform:CGAffineTransformMakeRotation(-1.999*M_PI_4)];
	
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [UIBezierPath bezierPathByConvertingPathToCurves:startPath];
	boxLayer.frame = CGRectMake( 0, 200, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [UIBezierPath bezierPathByConvertingPathToCurves:endPath];
	boxLayer.frame = CGRectMake( 100, 200, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [UIBezierPath bezierPathByConvertingPathToCurves:circlePath];
	boxLayer.frame = CGRectMake( 200, 200, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	CipherStroke *aStroke = [[CipherStroke alloc] init];
	aStroke.path = [UIBezierPath bezierPathByConvertingPathToCurves:circlePath];
	aStroke.frame = aStroke.path.bounds;
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [[aStroke circularCipher] path];
	boxLayer.frame = CGRectMake( 300, 200, 100, 100);
	[self.textContainer addSublayer:boxLayer];

	// debug row 4
	count = 6;
	for (int i = 0; i < count; i++)
	{
		boxLayer = [CipherDebugLayer new];
		boxLayer.debugPath = [UIBezierPath bezierPathByMorphingFromPath:[UIBezierPath bezierPathByConvertingPathToCurves:startPath]
																 toPath:[UIBezierPath bezierPathByConvertingPathToCurves:circlePath]
															   progress:(i+1) / (float)(count +1)];
		boxLayer.frame = CGRectMake(i*100, 300, 100, 100);
		[self.textContainer addSublayer:boxLayer];
	}

	// debug row 5
	count = 6;
	for (int i = 0; i < count; i++)
	{
		boxLayer = [CipherDebugLayer new];
		boxLayer.debugPath = [UIBezierPath bezierPathByMorphingFromPath:[UIBezierPath bezierPathByConvertingPathToCurves:endPath]
																 toPath:[UIBezierPath bezierPathByConvertingPathToCurves:circlePath]
															   progress:(i+1) / (float)(count +1)];
		boxLayer.frame = CGRectMake(i*100, 400, 100, 100);
		[self.textContainer addSublayer:boxLayer];
	}
	
	
	// debug row 6 --- o character
	CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)@"Helvetica", 300, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)CFBridgingRelease(font), kCTFontAttributeName,
                           nil];

	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"oe"
																			   attributes:attrs];
	CipherStroke *oStroke = [[CipherStroke strokesForString:string
												   inBounds:CGRectMake(0, 0, 100, 100)
													options:0] firstObject];
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = oStroke.path;
	boxLayer.frame = CGRectMake(0, 500, 100, 100);
	[self.textContainer addSublayer:boxLayer];
	
	oStroke.path = [UIBezierPath bezierPathByConvertingPathToCurves:oStroke.path];

	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = oStroke.path;
	boxLayer.frame = CGRectMake(100, 500, 100, 100);
	[self.textContainer addSublayer:boxLayer];
	
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [[oStroke circularCipher] path];
	boxLayer.frame = CGRectMake(200, 500, 100, 100);
	[self.textContainer addSublayer:boxLayer];
	
	
	// debug row 7 --- e character
	CipherStroke *eStroke = [[CipherStroke strokesForString:string
										inBounds:CGRectMake(0, 0, 100, 100)
										 options:0] lastObject];
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = eStroke.path;
	boxLayer.frame = CGRectMake(0, 600, 100, 100);
	[self.textContainer addSublayer:boxLayer];
	
	eStroke.path = [UIBezierPath bezierPathByConvertingPathToCurves:eStroke.path];
	
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = eStroke.path;
	boxLayer.frame = CGRectMake(100, 600, 100, 100);
	[self.textContainer addSublayer:boxLayer];
		
	boxLayer = [CipherDebugLayer new];
	boxLayer.debugPath = [[eStroke circularCipher] path];
	boxLayer.frame = CGRectMake(200, 600, 100, 100);
	[self.textContainer addSublayer:boxLayer];
	
	// debug row 8 - o morph
	for (int i = 0; i < count; i++)
	{
		boxLayer = [CipherDebugLayer new];
		boxLayer.debugPath = [UIBezierPath bezierPathByMorphingFromPath:oStroke.path
																 toPath:[oStroke circularCipher].path
															   progress:(i+1) / (float)(count +1)];
		boxLayer.frame = CGRectMake(i*100, 700, 100, 100);
		[self.textContainer addSublayer:boxLayer];
	}

	
	// debug row 9 - e morph
	for (int i = 0; i < count; i++)
	{
		boxLayer = [CipherDebugLayer new];
		boxLayer.debugPath = [UIBezierPath bezierPathByMorphingFromPath:eStroke.path
																 toPath:[eStroke circularCipher].path
															   progress:(i+1) / (float)(count +1)];
		boxLayer.frame = CGRectMake(i*100, 800, 100, 100);
		[self.textContainer addSublayer:boxLayer];
	}
}


- (UIBezierPath *) boxGraphWithSize:(CGSize)boundingBox
{
	UIBezierPath *boxGraph = [UIBezierPath bezierPath];
	[boxGraph moveToPoint:CGPointMake(0, 0)];
	[boxGraph addLineToPoint:CGPointMake(boundingBox.width, 0)];
	[boxGraph addLineToPoint:CGPointMake(boundingBox.width, boundingBox.height)];
	[boxGraph addLineToPoint:CGPointMake(0, boundingBox.height)];
	[boxGraph closePath];
	return boxGraph;
}


@end


