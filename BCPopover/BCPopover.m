// Created by Pieter Omvlee on 06/11/2013.

#import "BCPopover.h"
#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"
#import "BCPopoverContentController.h"

@interface BCPopover ()
@property(nonatomic, strong) NSView *attachedToView;
@property(nonatomic) NSRectEdge preferredEdge;
@property(nonatomic) NSSize referenceContentSize;
@end

@implementation BCPopover

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge {
  [self showRelativeToView:view preferredEdge:edge type:BCPopOverTypePopOver];
}

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge type:(BCPopOverType)type {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName:BCPopoverWillShowNotification object:self];
  [center addObserver:self selector:@selector(otherPopoverDidShow:) name:BCPopoverWillShowNotification object:nil];
  
  NSView *aView = view;
  while (aView != nil) {
    [center addObserver:self selector:@selector(attachedViewDidMove:) name:NSViewFrameDidChangeNotification object:aView];
    aView = [aView superview];
  }

  self.attachedToView = view;
  self.preferredEdge = edge;
  self.popoverType = type;
  
  NSView *contentView = self.contentViewController.view;
  NSRect contentRect = [contentView frame];
  if (type == BCPopOverTypeMenu)
    contentRect = NSInsetRect(contentRect, 0, -3);
  
  self.window = [BCPopoverWindow attachedWindowWithView:contentView frame:contentRect];

  NSRect popoverWindowFrame = [self popoverWindowFrame];
  id <BCPopoverDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(popover:adjustInitialWindowFrame:)]) {
    popoverWindowFrame = [delegate popover:self adjustInitialWindowFrame:popoverWindowFrame];
  }
  [self.window setFrame:popoverWindowFrame display:YES];
  [self.window setReleasedWhenClosed:NO];
  
  self.window.shouldShowArrow = type == BCPopOverTypePopOver;
  self.window.arrowPosition = [self popoverArrowPosition];
  self.window.arrowEdge = edge;
  self.window.delegate = self;

  [view.window addChildWindow:self.window ordered:NSWindowAbove];
  [self.window makeKeyAndOrderFront:nil];

  NSViewController <BCPopoverContentController> *controller = self.contentViewController;
  if ([controller respondsToSelector:@selector(popoverWindowDidShow:)])
    [controller popoverWindowDidShow:self];
}

- (void)otherPopoverDidShow:(NSNotification *)note {
  id delegate = self.delegate;
  if (![delegate respondsToSelector:@selector(popoverShouldCloseWhenOtherPopoverOpens:otherPopover:)] || [delegate popoverShouldCloseWhenOtherPopoverOpens:self otherPopover:[note object]])
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
  if (!NSEqualPoints(point, NSZeroPoint))
    return [self windowRectForViewSize:[self.contentViewController.view frame].size above:[self screenAnchorRect] pointingTo:point edge:self.preferredEdge];
  else
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

- (void)detach {
  self.attachedToView = nil;
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
  BOOL isMenu = self.popoverType == BCPopOverTypeMenu;
  NSInteger arrowSize = isMenu ? 3 : kArrowSize;
  if (edge == NSMinXEdge) {
    windowRect.size.width  += arrowSize;
    windowRect.origin.x     = point.x - arrowSize - viewSize.width;
    windowRect.origin.y     = point.y - viewSize.height/2;
  } else if (edge == NSMaxXEdge) {
    windowRect.origin.x     = point.x;
    windowRect.origin.y     = point.y - viewSize.height/2;
    windowRect.size.width  += arrowSize;
  } else if (edge == NSMinYEdge) {
    windowRect.size.height += isMenu ? arrowSize*2 : arrowSize;
    windowRect.origin.x     = isMenu ? NSMinX(aboveRect) : NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = isMenu ? point.y - arrowSize - viewSize.height - 2 : point.y - arrowSize - viewSize.height;
  } else if (edge == NSMaxYEdge) {
    windowRect.origin.x     = isMenu ? NSMinX(aboveRect) : NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = point.y;
    windowRect.size.height += isMenu ? arrowSize*2 : arrowSize;;
  }
  return windowRect;
}

- (void)setContentSize:(NSSize)size {
  if (!NSEqualSizes(size, self.referenceContentSize)) {
    self.referenceContentSize = size;
    [self windowDidResize:nil];
  }
}

- (void)windowDidResize:(NSNotification *)notification {
  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setArrowPosition:[self popoverArrowPosition]];
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
