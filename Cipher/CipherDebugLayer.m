//
//  CipherDebugLayer.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 14/Feb/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherDebugLayer.h"


// ===============================================================================================================
@implementation CipherDebugLayer
// ===============================================================================================================

- (instancetype) init
{
    self = [super init];
    if (self)
	{
		self.contentsScale = [UIScreen mainScreen].scale;
		[self setNeedsDisplay];
    }
    return self;
}


- (void) drawInContext:(CGContextRef)ctx
{
	CGFloat inset = 10;
	
	CGContextAddRect(ctx, self.bounds);
	CGContextDrawPath(ctx, kCGPathStroke);
	
	// fit the path in our layer bounds
	CGRect drawableBounds = CGRectInset(self.bounds, inset, inset);
	CGFloat factorX = drawableBounds.size.width / self.bounds.size.width;
	CGFloat factorY = drawableBounds.size.height / self.bounds.size.height;
	CGContextTranslateCTM(ctx, inset, inset);
	CGContextScaleCTM(ctx, factorX, factorY);
	
	// draw the path
	CGPathRef path = self.debugPath.CGPath;
	CGRect sourceBounds = CGPathGetBoundingBox(path);
	CGRect targetBounds = self.bounds;
	CGContextScaleCTM(ctx, targetBounds.size.width / sourceBounds.size.width, targetBounds.size.height / sourceBounds.size.height);
	CGContextTranslateCTM(ctx, targetBounds.origin.x - sourceBounds.origin.x,  targetBounds.origin.y - sourceBounds.origin.y);

	CGContextAddPath(ctx, path);
	CGContextDrawPath(ctx, kCGPathStroke);


	// draw the circles around the points of the path
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-inset/2.0, -inset/2.0, inset, inset)];

	UIColor *lightOrangeColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:0.500];
	UIColor *redColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.500];
	CGContextSetStrokeColorWithColor(ctx, lightOrangeColor.CGColor);
	CGContextSetFillColorWithColor(ctx, redColor.CGColor);
	
	void (^drawPointBlock)(CGPoint, BOOL) = ^void(CGPoint point, BOOL styled)
	{
		CGContextTranslateCTM(ctx, point.x, point.y);
		CGContextAddPath(ctx, circlePath.CGPath);
		
		if (!styled)
			CGContextDrawPath(ctx, kCGPathStroke);
		else
			CGContextDrawPath(ctx, kCGPathFillStroke);
		
		CGContextTranslateCTM(ctx, -point.x, -point.y);
	};

	[self.debugPath enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementMoveToPoint)
		{
			CGPoint endPoint = element->points[0];
			drawPointBlock(endPoint, YES);
		}
		else if (currentPointType == kCGPathElementAddLineToPoint)
		{
			CGPoint endPoint   = element->points[0];
			drawPointBlock(endPoint, NO);
		}
		else if (currentPointType == kCGPathElementAddQuadCurveToPoint)
		{
			CGPoint controlPoint = element->points[0];
			CGPoint endPoint = element->points[1];
			drawPointBlock(controlPoint, NO);
			drawPointBlock(endPoint, NO);
		}
		else if (currentPointType == kCGPathElementAddCurveToPoint)
		{
			CGPoint controlPoint1 = element->points[0];
			CGPoint controlPoint2 = element->points[1];
			CGPoint endPoint = element->points[2];
			drawPointBlock(controlPoint1, NO);
			drawPointBlock(controlPoint2, NO);
			drawPointBlock(endPoint, NO);
		}
		else if (currentPointType == kCGPathElementCloseSubpath)
		{
			
		}
		else
		{
			NSAssert(NO, @"Unexpected Path Element Type");
		}
	}];
}


@end

