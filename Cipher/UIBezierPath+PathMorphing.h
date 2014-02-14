//
//  UIBezierPath+PathMorphing.h
//  Cipher
//
//  Created by Leonhard Lichtschlag on 4/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import <UIKit/UIKit.h>


// ===============================================================================================================
@interface UIBezierPath (PathMorphing)
// ===============================================================================================================

+ (UIBezierPath *) bezierPathByConvertingPathToCurves:(UIBezierPath *)basePath;
+ (UIBezierPath *) bezierPathByMorphingFromPath:(UIBezierPath *)fromPath toPath:(UIBezierPath *)toPath progress:(float)p;

- (void) logPathElements;

- (NSUInteger) countOfPathElements;
- (NSUInteger) countOfVisiblePathElements;
- (NSUInteger) countOfSubPaths;

- (void) enumeratePathElementsUsingBlock:(void (^)(const CGPathElement *element))enumerateBlock;


@end


