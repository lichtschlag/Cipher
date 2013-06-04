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

+ (UIBezierPath *) pathByConvertingPathToCurves:(UIBezierPath *)basePath;
+ (UIBezierPath *) pathByMorphingFromPath:(UIBezierPath *)fromPath toPath:(UIBezierPath *)toPath progress:(float)p;

- (NSUInteger) countOfPathElements;
- (NSUInteger) countOfVisiblePathElements;
- (NSUInteger) countOfSubPaths;

@end


