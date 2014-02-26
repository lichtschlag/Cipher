//
//  CipherLayerQuartz.h
//  Cipher
//
//  Created by Leonhard Lichtschlag on 26/Feb/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


// ===============================================================================================================
@interface CipherLayerQuartz : CALayer
// ===============================================================================================================

@property (strong) UIBezierPath *clearTextPath;
@property (strong) UIBezierPath *cipherTextPath;
@property (nonatomic) CGFloat degreeOfCipher;

// shapelayer sim
@property (assign) CGColorRef fillColor;
@property (assign) CGColorRef strokeColor;
@property (assign) CGFloat lineWidth;


- (void) prep;


@end
