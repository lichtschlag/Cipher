//
//  CipherDebugViewController.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherDebugViewController.h"
#import "CipherDebugLayer.h"


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
	// TODO: ask why rotations by 90 degress do nothing
	[circlePath applyTransform:CGAffineTransformMakeRotation(-1.999*M_PI_4)];
//	[circlePath logPathElements];
	
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
}


//- (UIBezierPath *) boxGraphWithSize:(CGSize)boundingBox
//{
//	UIBezierPath *boxGraph = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, boundingBox.width, boundingBox.height)];
//	return boxGraph;
//}


@end
