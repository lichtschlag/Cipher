//
//  CipherFirstViewController.h
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import <UIKit/UIKit.h>


// ===============================================================================================================
@interface CipherFirstViewController : UIViewController
// ===============================================================================================================

@property (strong) NSString *fontName;
@property NSUInteger fontSize;

- (IBAction) userDidLongPress:(UIGestureRecognizer *)sender;


@end
