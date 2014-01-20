// Created by Pieter Omvlee on 06/11/2013.

#import "BCPopover.h"
#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"

@interface BCPopover ()
@property(nonatomic, strong) NSView *attachedToView;
@property(nonatomic) NSRectEdge preferredEdge;
@property(nonatomic, strong) BCPopoverWindow *window;
@property(nonatomic) BCPopOverType popoverType;
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
  self.window = [BCPopoverWindow attachedWindowWithView:contentView frame:[contentView frame]];

  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setReleasedWhenClosed:NO];
  
  self.window.shouldShowArrow = type == BCPopOverTypePopOver;
  self.window.arrowPosition = [self popoverArrowPosition];
  self.window.arrowEdge = edge;
  self.window.delegate = self;

  [view.window addChildWindow:self.window ordered:NSWindowAbove];
  [self.window makeKeyAndOrderFront:nil];
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

- (void)attachedViewDidMove:(NSNotification *)notification {
  [self.window setFrame:[self popoverWindowFrame] display:YES];
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
    windowRect.size.height += arrowSize;
    windowRect.origin.x     = isMenu ? NSMinX(aboveRect) : NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = isMenu ? point.y - arrowSize - viewSize.height - 2 : point.y - arrowSize - viewSize.height;
  } else if (edge == NSMaxYEdge) {
    windowRect.origin.x     = isMenu ? NSMinX(aboveRect) : NSMidX(aboveRect) - viewSize.width/2;
    windowRect.origin.y     = point.y;
    windowRect.size.height += arrowSize;
  }
  return windowRect;
}

- (void)setContentSize:(NSSize)size {
  //unnecessary but it keeps compatibility with NSPopOver
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
