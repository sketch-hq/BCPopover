//  Created by Pieter Omvlee on 08-09-09.
//  Copyright 2009 Bohemian Coding. All rights reserved.

#import <Cocoa/Cocoa.h>

#define kArrowSize 10
#define kCornerRadius 5

@interface BCPopoverContentView : NSView

@property (nonatomic) NSRectEdge arrowEdge;
@property (nonatomic) CGFloat arrowPosition;

- (NSRect)availableContentRect;
@end
