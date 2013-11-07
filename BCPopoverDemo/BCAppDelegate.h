//  Created by Pieter Omvlee on 06/11/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "BCPopoverDelegate.h"

@class BCPopover;

@interface BCAppDelegate : NSObject <NSApplicationDelegate, BCPopoverDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSButton *button;

- (IBAction)attach:(id)sender;
- (IBAction)resize:(id)sender;
@end
