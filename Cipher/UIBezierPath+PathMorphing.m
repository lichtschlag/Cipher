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

+ (UIBezierPath *) bezierPathByConvertingPathToCurves:(UIBezierPath *)basePath;
{
	CGMutablePathRef newPath = CGPathCreateMutable();
	
	// From NSBezierPath documentation:
	// For curve operations, the order of the points is controlPoint1 (points[0]), controlPoint2 (points[1]), endPoint (points[2]).
	
	__block CGPoint firstPointOfSubpath = CGPointZero;

	[basePath enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementMoveToPoint)
		{
			CGPoint endPoint = element->points[0];
			firstPointOfSubpath = endPoint;
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
			CGPoint beginPoint = CGPathGetCurrentPoint(newPath);
			if ( ! CGPointEqualToPoint(firstPointOfSubpath, beginPoint))
			{
				// close subpath would add a visible line, add curve instead:
				CGPoint endPoint   = firstPointOfSubpath;
				CGPoint controlPoint1 = CGPointMake( beginPoint.x + (endPoint.x-beginPoint.x) * 1.0/3.0,
													 beginPoint.y + (endPoint.y-beginPoint.y) * 1.0/3.0);
				CGPoint controlPoint2 = CGPointMake( beginPoint.x + (endPoint.x-beginPoint.x) * 2.0/3.0,
													 beginPoint.y + (endPoint.y-beginPoint.y) * 2.0/3.0);
				
				CGPathAddCurveToPoint(newPath, NULL,
									  controlPoint1.x, controlPoint1.y,
									  controlPoint2.x, controlPoint2.y,
									  endPoint.x, endPoint.y);
			}
			CGPathCloseSubpath(newPath);
		}
		else
		{
			NSAssert(NO, @"Unexpected Path Element Type");
		}
	}];
	
	UIBezierPath *result = [UIBezierPath bezierPathWithCGPath:newPath];
	CGPathRelease(newPath);
	return result;
}


// will crash if paths are not of the same length or not of the same topology?
+ (UIBezierPath *) bezierPathByMorphingFromPath:(UIBezierPath *)fromPath toPath:(UIBezierPath *)toPath progress:(float)p;
{
	CGMutablePathRef newPath = CGPathCreateMutable();
	NSUInteger count = MAX([fromPath countOfPathElements], [toPath countOfPathElements]);
	NSUInteger maxOffset = count * 3;
	
	// copy path points from first cgpath into a buffer array
	CGPoint *points = calloc(count * 3, sizeof(CGPoint));  // already zeroed
	__block NSUInteger offset = 0;
	
	// iterate over second cgpath to get the other half of the points
	[fromPath enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		NSAssert(offset < maxOffset, @"Buffer overflow while morphing paths");
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementAddCurveToPoint)
		{
			points[offset]   = element->points[0];
			points[offset+1] = element->points[1];
			points[offset+2] = element->points[2];
		}
		else if (currentPointType == kCGPathElementMoveToPoint)
		{
			points[offset]   = element->points[0];
		}

		offset += 3;
	}];
	
	offset = 0;
	// iterate over second cgpath to get the other half of the points
	[toPath enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	{
		NSAssert(offset < maxOffset, @"Buffer overflow while morphing paths");
		CGPathElementType currentPointType = element->type;
		if (currentPointType == kCGPathElementAddCurveToPoint)
		{
			CGPoint controlPoint1 = CGPointMake(element->points[0].x *p	+ points[offset+0].x *(1-p),
												element->points[0].y *p	+ points[offset+0].y *(1-p));
			CGPoint controlPoint2 = CGPointMake(element->points[1].x *p	+ points[offset+1].x *(1-p),
												element->points[1].y *p	+ points[offset+1].y *(1-p));
			CGPoint endPoint	   = CGPointMake(element->points[2].x *p	+ points[offset+2].x *(1-p),
												 element->points[2].y *p	+ points[offset+2].y *(1-p));
			CGPathAddCurveToPoint(newPath, NULL,
								  controlPoint1.x, controlPoint1.y,
								  controlPoint2.x, controlPoint2.y,
								  endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementMoveToPoint)
		{
			CGPoint endPoint	   = CGPointMake(element->points[0].x *p	+ points[offset+0].x *(1-p),
												 element->points[0].y *p	+ points[offset+0].y *(1-p));
			CGPathMoveToPoint(newPath, NULL, endPoint.x, endPoint.y);
		}
		else if (currentPointType == kCGPathElementCloseSubpath)
		{
			CGPathCloseSubpath(newPath);
		}
		else
		{
			NSAssert(NO, @"Unexpected Path Element Type");
		}

		offset += 3;
	}];
	
	free(points);
	
	UIBezierPath *result = [UIBezierPath bezierPathWithCGPath:newPath];
	CGPathRelease(newPath);
	return result;
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


// TODO: Close might as well be visible
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

- (void) logPathElements
{
	[self enumeratePathElementsUsingBlock:^(const CGPathElement *element)
	 {
		 CGPathElementType currentPointType = element->type;
		 NSString *output =	 (currentPointType == kCGPathElementMoveToPoint)		? @"kCGPathElementMoveToPoint" :
							 (currentPointType == kCGPathElementAddLineToPoint)		? @"kCGPathElementAddLineToPoint" :
							 (currentPointType == kCGPathElementAddQuadCurveToPoint)? @"kCGPathElementAddQuadCurveToPoint" :
							 (currentPointType == kCGPathElementAddCurveToPoint)	? @"kCGPathElementAddCurveToPoint" :
							 (currentPointType == kCGPathElementCloseSubpath)		? @"kCGPathElementCloseSubpath" :
							 @"unknown type";
		 NSLog(@"%@", output);
	 }];
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

