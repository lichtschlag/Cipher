//
//  CipherFirstViewController.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherFirstViewController.h"
#import <QuartzCore/QuartzCore.h>


// ===============================================================================================================
@interface CipherFirstViewController ()
// ===============================================================================================================

@property (strong) NSMutableArray* touchlayers;

@end


// ===============================================================================================================
@implementation CipherFirstViewController
// ===============================================================================================================

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Class Life Cycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.touchlayers = [NSMutableArray new];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark User Interaction
// ---------------------------------------------------------------------------------------------------------------

- (IBAction) userDidLongPress:(UIGestureRecognizer *)sender
{
	// remove all old layers
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
}


@end

