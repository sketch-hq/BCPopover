// Created by Pieter Omvlee on 06/11/2013.

#import "BCPopover.h"
#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"

@interface BCPopover ()
@property(nonatomic, strong) NSView *attachedToView;
@property(nonatomic) NSRectEdge preferredEdge;
@property(nonatomic, strong) BCPopoverWindow *window;
@end

@implementation BCPopover

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName:BCPopoverWillShowNotification object:self];
  [center addObserver:self selector:@selector(otherPopoverDidShow:) name:BCPopoverWillShowNotification object:nil];

  self.attachedToView = view;
  self.preferredEdge = edge;
  
  NSView *contentView = self.contentViewController.view;
  self.window = [BCPopoverWindow attachedWindowWithView:contentView frame:[contentView frame]];

  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setReleasedWhenClosed:NO];

  self.window.arrowPosition = [self popoverArrowPosition];
  self.window.arrowEdge = edge;
  self.window.delegate = self;

  [view.window addChildWindow:self.window ordered:NSWindowAbove];
}

- (void)otherPopoverDidShow:(NSNotification *)note {
  id delegate = self.delegate;
  if (![delegate respondsToSelector:@selector(popoverShouldCloseWhenOtherPopoverOpens:)] || [delegate popoverShouldCloseWhenOtherPopoverOpens:self])
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
  NSView *anchoredView = self.attachedToView.superview;
  NSRect screenAnchorRect = [self.attachedToView.window convertRectToScreen:[anchoredView convertRect:anchoredView.bounds toView:nil]];

  NSPoint point = [self attachToPointInScreenCoordinates];
  return [self windowRectForViewSize:[self.contentViewController.view frame].size above:screenAnchorRect pointingTo:point edge:self.preferredEdge];
}

- (NSPoint)attachToPointInScreenCoordinates {
  NSRect screenRect = [self.attachedToView convertRect:[self.attachedToView bounds] toView:nil];
  NSPoint point = [self.attachedToView.window convertBaseToScreen:[self pointAtEdge:self.preferredEdge ofRect:screenRect]];
  return point;
}

- (void)windowDidResize:(NSNotification *)notification {
  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setArrowPosition:[self popoverArrowPosition]];
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
    windowRect.size.height += kArrowSize;
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
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self];
}

@end
