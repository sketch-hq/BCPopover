//  Created by Pieter Omvlee on 09-09-09.
//  Copyright 2009 Bohemian Coding. All rights reserved.

#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"

@implementation BCPopoverWindow

+ (id)attachedWindowWithView:(NSView *)aView frame:(NSRect)windowRect {
  BCPopoverWindow *window = [[self alloc] initWithContentRect:windowRect];

  BCPopoverContentView *arrowView = [[BCPopoverContentView alloc] initWithFrame:[(NSView *)[window contentView] frame]];
  [window setContentView:arrowView];
  [aView setFrameOrigin:NSZeroPoint];
  [arrowView addSubview:aView];

  [[NSNotificationCenter defaultCenter] addObserver:window selector:@selector(contentViewDidResizeNotification:) name:NSViewFrameDidChangeNotification object:aView];

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

- (void)contentViewDidResizeNotification:(NSNotification *)note {
  if (!self.parentWindow)
    return;

  BCPopoverContentView *arrowView = self.contentView;
  NSRect arrowFrame = [arrowView frame];
  NSRect arrowAvailableRect = [arrowView availableContentRect];

  NSView *contentView = [[arrowView subviews] firstObject];
  NSRect contentRect = [contentView frame];
  contentRect.size.width += NSWidth(arrowFrame) - NSWidth(arrowAvailableRect);
  contentRect.size.height += NSHeight(arrowFrame) - NSHeight(arrowAvailableRect);

  NSRect windowRect = [self frame];
  windowRect.size = contentRect.size;
  [self setFrame:windowRect display:YES];
  [contentView setFrame:[arrowView availableContentRect]];
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
