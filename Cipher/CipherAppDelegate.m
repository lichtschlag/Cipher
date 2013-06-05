//
//  CipherAppDelegate.m
//  Cipher
//
//  Created by Leonhard Lichtschlag on 1/Jun/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "CipherAppDelegate.h"
#import "CipherViewController.h"


// ===============================================================================================================
@implementation CipherAppDelegate
// ===============================================================================================================

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // add a view configurations of our cipher layer that are nice to look at
	
	UITabBarController *tabBar = (UITabBarController *)[self.window rootViewController];
	
	CipherViewController *experiment1 = [CipherViewController new];
	experiment1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Helvetica" image:[UIImage imageNamed:@"first"] tag:21];
	experiment1.fontName	= @"Helvetica-Bold";
	experiment1.fontSize	= 50.0f;
	
	[tabBar addChildViewController:experiment1];

	CipherViewController *experiment2 = [CipherViewController new];
	experiment2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Copperplate" image:[UIImage imageNamed:@"second"] tag:22];
	experiment2.fontName	= @"Copperplate";
	experiment2.fontSize	= 80.0f;
	
	[tabBar addChildViewController:experiment2];
	
	CipherViewController *experiment3 = [CipherViewController new];
	experiment3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Whatever" image:[UIImage imageNamed:@"second"] tag:23];
	experiment3.fontName	= @"Helvetica";
	experiment3.fontSize	= 164.0f;
	
	[tabBar addChildViewController:experiment3];

    return YES;
}



@end

