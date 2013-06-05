//
//  UIBezierPath+PathMorphing.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 4/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "UIBezierPath+PathMorphing.h"

// ===============================================================================================================
@implementation UIBezierPath (PathMorphing)
// ===============================================================================================================

+ (UIBezierPath *) pathByConvertingPathToCurves:(UIBezierPath *)basePath;
{
	CGMutablePathRef newPath = CGPathCreateMutable();
	
	// From NSBezierPath documentation:
	// For curve operations, the order of the points is controlPoint1 (points[0]), controlPoint2 (points[1]), endPoint (points[2]).
	
	[basePath enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementMoveToPoint)
		{
			CGPoint endPoint = element->points[0];
			CGPathMoveToPoint(newPath, NULL, endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementAddLineToPoint)
		{
			CGPoint beginPoint = CGPathGetCurrentPoint(newPath);
			CGPoint endPoint   = element->points[0];
			CGPoint controlPoint1 = CGPointMake( beginPoint.x + (endPoint.x-beginPoint.x) * 1.0/3.0,
												 beginPoint.y + (endPoint.y-beginPoint.y) * 1.0/3.0);
			CGPoint controlPoint2 = CGPointMake( beginPoint.x + (endPoint.x-beginPoint.x) * 2.0/3.0,
												 beginPoint.y + (endPoint.y-beginPoint.y) * 2.0/3.0);
			
			CGPathAddCurveToPoint(newPath, NULL,
								  controlPoint1.x, controlPoint1.y,
								  controlPoint2.x, controlPoint2.y,
								  endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementAddQuadCurveToPoint)
		{
			CGPoint beginPoint = CGPathGetCurrentPoint(newPath);
			CGPoint controlPoint = element->points[0];
			CGPoint endPoint = element->points[1];
			CGPoint controlPoint1 = CGPointMake( beginPoint.x + (controlPoint.x-beginPoint.x) * 2.0/3.0,
												 beginPoint.y + (controlPoint.y-beginPoint.y) * 2.0/3.0);
			CGPoint controlPoint2 = CGPointMake( endPoint.x + (controlPoint.x-endPoint.x) * 2.0/3.0,
												 endPoint.y + (controlPoint.y-endPoint.y) * 2.0/3.0);

			CGPathAddCurveToPoint(newPath, NULL,
								  controlPoint1.x, controlPoint1.y,
								  controlPoint2.x, controlPoint2.y,
								  endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementAddCurveToPoint)
		{
			CGPoint controlPoint1 = element->points[0];
			CGPoint controlPoint2 = element->points[1];
			CGPoint endPoint = element->points[2];
			CGPathAddCurveToPoint(newPath, NULL,
								  controlPoint1.x, controlPoint1.y,
								  controlPoint2.x, controlPoint2.y,
								  endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementCloseSubpath)
		{
			CGPathCloseSubpath(newPath);
		}
		else
		{
			NSAssert(NO, @"Unexpected Path Element Type");
		}
	}];
	
	return [UIBezierPath bezierPathWithCGPath:newPath];
}


// will crash if paths are not of the same length or not of the same topology?
+ (UIBezierPath *) pathByMorphingFromPath:(UIBezierPath *)fromPath toPath:(UIBezierPath *)toPath progress:(float)p;
{
	CGMutablePathRef newPath = CGPathCreateMutable();
	
	// copy path points from first cgpath into a buffer array
	
	// iterate over second cgpath to get the other half of the points
	// interpolate all points in the array by p
	
	// construct a new path from the points
	
	return [UIBezierPath bezierPathWithCGPath:newPath];
}


- (NSUInteger) countOfPathElements;
{
	__block NSUInteger count = 0;
	
	[self enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		count++;
	}];
	return count;
}


- (NSUInteger) countOfVisiblePathElements;
{
	__block NSUInteger count = 0;
	
	[self enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		 CGPathElementType currentPointType = element->type;
		 if (currentPointType != kCGPathElementCloseSubpath)
			 count++;
	}];
	return count;
}


- (NSUInteger) countOfSubPaths;
{
	__block NSUInteger count = 0;
	
	[self enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementCloseSubpath)
			count++;
	}];
	return count;
}


- (void) enumeratePathElementsUsingBlock:(void (^)(const CGPathElement *element))enumerateBlock;
{
	CGPathRef internalPath = self.CGPath;
	CGPathApply(internalPath, (__bridge void *)(enumerateBlock), CGPathApplyBlock);
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark C Path Applier Functions
// ---------------------------------------------------------------------------------------------------------------

//void CGPathElementsCount(void *info, const CGPathElement *element)
//{
//	NSUInteger *numberOfElementsSoFar = (NSUInteger *)info;
//	CGPathElementType currentPointType = element->type;
//	
//	if (currentPointType != kCGPathElementCloseSubpath)
//		(*numberOfElementsSoFar)++;
//}


void CGPathApplyBlock(void *blockPointer, const CGPathElement *element)
{
	void(^enumerateBlock)(const CGPathElement *element) = (__bridge void (^)(const CGPathElement *))(blockPointer);
	enumerateBlock(element);
}



@end

