// Created by Pieter Omvlee on 06/11/2013.

#import "BCPopover.h"
#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"
#import "BCPopoverContentController.h"

@interface BCPopover ()
@property(nonatomic, strong) NSView *attachedToView;
@property(nonatomic) NSRectEdge preferredEdge;
@end

@implementation BCPopover

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge {
  [self configureNotifications:view];

  self.attachedToView = view;
  self.preferredEdge = edge;

  self.window = [BCPopoverWindow attachedWindowWithView:self.contentViewController.view];

  if ([self.contentViewController respondsToSelector:@selector(setMaximumAvailableHeight:forPopover:)]) {

    NSRect rect = [self screenAnchorRect];
    NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
    NSInteger maxAvailableHeight = 0;
    if (self.preferredEdge == NSMinYEdge)
      maxAvailableHeight = (NSInteger) NSMinY(rect);
    else
      maxAvailableHeight = (NSInteger) (NSMaxY(screenRect) - NSMaxY(rect));

    [self.contentViewController setMaximumAvailableHeight:maxAvailableHeight forPopover:self];
  }

  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setReleasedWhenClosed:NO];
  
  self.window.arrowPosition = [self popoverArrowPosition];
  self.window.arrowEdge = edge;
  self.window.delegate = self;

  [view.window addChildWindow:self.window ordered:NSWindowAbove];
  [self.window makeKeyAndOrderFront:nil];

  if ([self.contentViewController respondsToSelector:@selector(popoverWindowDidShow:)])
    [self.contentViewController popoverWindowDidShow:self];
}

- (void)configureNotifications:(NSView *)view {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName:BCPopoverWillShowNotification object:self];

  [center addObserver:self selector:@selector(otherPopoverDidShow:) name:BCPopoverWillShowNotification object:nil];
  [center addObserver:self selector:@selector(contentViewDidResizeNotification:) name:NSViewFrameDidChangeNotification object:self.contentViewController.view];

  NSView *aView = view;
  while (aView != nil) {
    [center addObserver:self selector:@selector(attachedViewDidMove:) name:NSViewFrameDidChangeNotification object:aView];
    aView = [aView superview];
  }
}

- (void)contentViewDidResizeNotification:(NSNotification *)note {
  if (self.window.parentWindow) {
    [self.window setFrame:[self popoverWindowFrame] display:YES];

    BCPopoverContentView *arrowView = self.window.contentView;
    NSView *contentView = [[arrowView subviews] firstObject];
    [contentView setFrame:[arrowView availableContentRect]];
  }
}

- (void)otherPopoverDidShow:(NSNotification *)note {
  id delegate = self.delegate;
  BOOL delegateImplemented = [delegate respondsToSelector:@selector(popoverShouldCloseWhenOtherPopoverOpens:otherPopover:)];
  BOOL delegateReturnedYes = [delegate popoverShouldCloseWhenOtherPopoverOpens:self otherPopover:[note object]];
  if (!delegateImplemented || delegateReturnedYes)
    [self close];
}

- (CGFloat)popoverArrowPosition {
  NSRect windowRect = [self popoverWindowFrame];
  NSPoint point = [self attachToPointInScreenCoordinates];
  if (self.preferredEdge == NSMinYEdge || self.preferredEdge == NSMaxYEdge)
    return (point.x - NSMinX(windowRect)) / NSWidth(windowRect);
  else
    return (point.y - NSMinY(windowRect)) / NSHeight(windowRect);
}

- (NSRect)popoverWindowFrame {
  NSPoint point = [self attachToPointInScreenCoordinates];
  if (!NSEqualPoints(point, NSZeroPoint)) {
    NSRect windowRect = [self windowRectForViewSize:[self.contentViewController.view frame].size above:[self screenAnchorRect] pointingTo:point edge:self.preferredEdge];
    if (NSContainsRect([[NSScreen mainScreen] visibleFrame], windowRect))
      return windowRect;
    else
      return NSIntersectionRect(windowRect, [[NSScreen mainScreen] visibleFrame]);
  } else
    return NSZeroRect;
}

- (NSRect)screenAnchorRect {
  if (self.attachedToView) {
    NSView *anchoredView = self.attachedToView.superview;
    return [self.attachedToView.window convertRectToScreen:[anchoredView convertRect:anchoredView.bounds toView:nil]];
  } else
    return [self.window frame];
}

- (NSPoint)attachToPointInScreenCoordinates {
  if (self.attachedToView) {
    NSRect screenRect = [self.attachedToView convertRect:[self.attachedToView bounds] toView:nil];
    NSPoint pointAtEdge = [self pointAtEdge:self.preferredEdge ofRect:screenRect];
    return [self.attachedToView.window convertBaseToScreen:pointAtEdge];
  } else {
    NSRect windowFrame = self.window.frame;
    return NSMakePoint(NSMinX(windowFrame), NSMaxY(windowFrame));
  }
}

- (void)attachedViewDidMove:(NSNotification *)notification {
  NSRect popoverRect = [self popoverWindowFrame];
  if (!NSEqualRects(popoverRect, NSZeroRect))
    [self.window setFrame:popoverRect display:YES];
}

- (NSPoint)pointAtEdge:(NSRectEdge)edge ofRect:(NSRect)rect {
  NSPoint point = NSMakePoint(NSMidX(rect), NSMidY(rect));
  if (edge == NSMinYEdge)
    point.y = NSMinY(rect);
  else if (edge == NSMaxYEdge)
    point.y = NSMaxY(rect);
  else if (edge == NSMinXEdge)
    point.x = NSMinX(rect);
  else if (edge == NSMaxXEdge)
    point.x = NSMaxX(rect);
  return point;
}

- (NSRect)windowRectForViewSize:(NSSize)viewSize above:(NSRect)aboveRect pointingTo:(NSPoint)point edge:(NSRectEdge)edge {
  NSRect windowRect;
  windowRect.size = viewSize;
  if (edge == NSMinXEdge) {
    windowRect.size.width  += kArrowSize;
    windowRect.origin.x     = point.x - kArrowSize - viewSize.width;
    windowRect.origin.y     = point.y - viewSize.height/2;
  } else if (edge == NSMaxXEdge) {
    windowRect.origin.x     = point.x;
    windowRect.origin.y     = point.y - viewSize.height/2;
    windowRect.size.width  += kArrowSize;
  } else if (edge == NSMinYEdge) {
    windowRect.size.height += kArrowSize;
    windowRect.origin.x     = NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = point.y - kArrowSize - viewSize.height;
  } else if (edge == NSMaxYEdge) {
    windowRect.origin.x     = NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = point.y;
    windowRect.size.height += kArrowSize;;
  }
  return windowRect;
}

- (void)windowWillClose:(NSNotification *)notification {
  [self.delegate popoverWillClose:self];
}

- (void)close {
  [[self.window parentWindow] removeChildWindow:self.window];
  [self.window close];
  self.window.delegate = nil;
  self.window = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
