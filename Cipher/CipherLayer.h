//
//  CipherLayer.h
//  Cipher
//
//  Created by Leonhard Lichtschlag on 2/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


// ===============================================================================================================
@interface CipherLayer : CAShapeLayer
// ===============================================================================================================

@property (strong) UIBezierPath *clearTextPath;
@property (strong) UIBezierPath *cipherTextPath;
@property (nonatomic) CGFloat degreeOfCipher;
@property (strong) UIColor *clearColor;

- (void) prep;


@end
