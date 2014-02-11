//  Created by Pieter Omvlee on 09-09-09.
//  Copyright 2009 Bohemian Coding. All rights reserved.

#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"
#import "BCPopover.h"

@implementation BCPopoverWindow

+ (id)attachedWindowWithView:(NSView *)aView {
  BCPopoverWindow *window = [[self alloc] initWithContentRect:[aView frame]];

  BCPopoverContentView *arrowView = [[BCPopoverContentView alloc] initWithFrame:[(NSView *)[window contentView] frame]];
  [window setContentView:arrowView];
  [aView setFrameOrigin:NSZeroPoint];
  [window setAcceptsMouseMovedEvents:YES];
  [arrowView addSubview:aView];

  return window;
}

- (id)initWithContentRect:(NSRect)contentRect {
  self = [super initWithContentRect:contentRect styleMask:0 backing:NSBackingStoreBuffered defer:NO];
  if (self) {
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow:YES];
  }
  return self;
}

- (void)resignMainWindow {
  [super resignMainWindow];
  [self close];
}

- (BOOL)canBecomeKeyWindow {
  return YES;
}

- (NSWindowCollectionBehavior)collectionBehavior {
  return [super collectionBehavior] | NSWindowCollectionBehaviorFullScreenAuxiliary;
}

@dynamic arrowEdge;

- (NSRectEdge)arrowEdge {
  return self.arrowView.arrowEdge;
}

- (void)setArrowEdge:(NSRectEdge)arrowEdge {
  if (self.arrowEdge != arrowEdge) {
    self.arrowView.arrowEdge = arrowEdge;
    NSView *contentView = [[self.arrowView subviews] firstObject];
    [contentView setFrame:[self.arrowView availableContentRect]];
    [self.arrowView setNeedsDisplay:YES];
  }
}

@dynamic arrowPosition;

- (CGFloat)arrowPosition {
  return self.arrowView.arrowPosition;
}

- (void)setArrowPosition:(CGFloat)position {
  if (self.arrowPosition != position) {
    self.arrowView.arrowPosition = position;
    [self.arrowView setNeedsDisplay:YES];
  }
}

- (BCPopoverContentView *)arrowView {
  return self.contentView;
}

@end
