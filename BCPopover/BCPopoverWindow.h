//  Created by Pieter Omvlee on 09-09-09.
//  Copyright 2009 Bohemian Coding. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface BCPopoverWindow : NSWindow
+ (id)attachedWindowWithView:(NSView *)aView frame:(NSRect)windowRect;
@property (nonatomic) NSRectEdge arrowEdge;
@property (nonatomic) CGFloat arrowPosition;
@property(nonatomic) BOOL shouldShowArrow;
@end
