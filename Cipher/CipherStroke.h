//
//  CipherStroke.h
//  Cipher
//
//  Created by Leonhard Lichtschlag on 12/Apr/14.
//  Copyright (c) 2014 Leonhard Lichtschlag. All rights reserved.
//

#import <Foundation/Foundation.h>


// ===============================================================================================================
@interface CipherStroke : NSObject
// ===============================================================================================================

@property (strong) UIBezierPath *path;
@property (assign) CGRect frame;
@property (assign) CGPoint position;

// loaders
+ (NSArray *) strokesForString:(NSAttributedString *)inputString
					  inBounds:(CGRect)containerBounds
					   options:(int)perLinePerCharacterOrAsOne;

+ (CipherStroke *) strokeForSVGFileNamed:(NSString *)fileName;


// transformations
- (CipherStroke *) circularCipher;
- (void) flipGeometry;


@end
