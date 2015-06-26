// Created by Pieter Omvlee on 06/11/2013.

#import "BCPopover.h"
#import "BCPopoverWindow.h"
#import "BCPopoverContentView.h"
#import "BCPopoverContentController.h"

@interface BCPopover ()
@property(nonatomic) NSRectEdge preferredEdge;
@end

@implementation BCPopover {
  BOOL dontSendNextPopoverWindowSizeNotification;
}

- (id)init {
  self = [super init];
  if (self) {
    self.constrainToScreenSize = YES;
    self.layerDependency = BCPopoverLayerDependant;
  }
  return self;
}

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge {
  [self configureNotifications:view];

  self.attachedToView = view;
  self.preferredEdge = edge;

  self.window = [BCPopoverWindow attachedWindowWithView:self.contentViewController.view];
  
  [self.window setFrame:[self popoverWindowFrame] display:YES];
  [self.window setReleasedWhenClosed:NO];
  
  self.window.arrowPosition = [self popoverArrowPosition];
  self.window.arrowEdge = edge;
  self.window.delegate = self;

  [view.window addChildWindow:self.window ordered:NSWindowAbove];
  [self.window makeKeyAndOrderFront:nil];
  if (![self.window.firstResponder isKindOfClass:[NSTextView class]])
    [self.window makeFirstResponder:self.window.contentView];

  if ([self.contentViewController respondsToSelector:@selector(popoverWindowDidShow:)])
    [self.contentViewController popoverWindowDidShow:self];
}

- (void)move {
  [self.window setFrame:[self popoverWindowFrame] display:YES];
}

- (void)configureNotifications:(NSView *)view {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName:BCPopoverWillShowNotification object:self];

  [center addObserver:self selector:@selector(otherPopoverDidShow:) name:BCPopoverWillShowNotification object:nil];
  [center addObserver:self selector:@selector(contentViewDidResizeNotification:) name:NSViewFrameDidChangeNotification object:self.contentViewController.view];
  [center addObserver:self selector:@selector(attachedWindowDidMove:) name:NSWindowDidResizeNotification object:view.window];

  NSView *aView = view;
  while (aView != nil) {
    [center addObserver:self selector:@selector(attachedViewDidMove:) name:NSViewFrameDidChangeNotification object:aView];
    aView = [aView superview];
  }
}

- (void)attachedWindowDidMove:(NSNotification *)note {
  BCPopoverWindow *window = (id)self.window;
  CGFloat arrowPosition = window.arrowPosition;
  CGFloat newArrowPosition = [self popoverArrowPosition];
  
  //NSWindow doesn't invalidate its cached shadow, so we have to force it here
  //make sure we only do it when he arrowPosition changes though as its expensive
  //if we invaliate the shadow immediately we get a trailing one when we resize too fast
  //if we invalidate with a delay then slow resize shows artefacts
  //so we do both. I suspect this is because NSEvent tracking interrupts the normal refresh cycle
  if (ABS(arrowPosition - newArrowPosition) > 0.001) {
    window.arrowPosition = newArrowPosition;
    window.hasShadow = NO;
    window.hasShadow = YES;
    BCDispatchMain(^{
      window.hasShadow = NO;
      window.hasShadow = YES;
    });
  }
}

- (void)contentViewDidResizeNotification:(NSNotification *)note {
  if (self.window.parentWindow) {
    dontSendNextPopoverWindowSizeNotification++;
    [self.window setFrame:[self popoverWindowFrame] display:YES];

    BCPopoverContentView *arrowView = self.window.contentView;
    NSView *contentView = [[arrowView subviews] firstObject];
    [contentView setFrame:[arrowView availableContentRect]];
    
    id <BCPopoverDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(popoverWindowSizeDidChange:)]) {
      if (dontSendNextPopoverWindowSizeNotification == 1)
        [delegate popoverWindowSizeDidChange:self];
    }
    dontSendNextPopoverWindowSizeNotification--;
  }
}

- (void)otherPopoverDidShow:(NSNotification *)note {
  id<BCPopoverDelegate> delegate = self.delegate;
  BCPopover* otherPopover = [note object];
  
  // the default behaviour is for the new popover to cause an existing one to hide
  BOOL shouldClose = YES;

  // the delegate of the new popover can implement popoverShouldCauseExistingPopoversToClose: to change this behaviour
  id<BCPopoverDelegate> otherDelegate = otherPopover.delegate;
  if ([otherDelegate respondsToSelector:@selector(popoverShouldCauseExistingPopoversToClose:)]) {
    shouldClose = [otherDelegate popoverShouldCauseExistingPopoversToClose:otherPopover];
  }

  // delegates of the other popovers can also implement popoverShouldCloseWhenNewPopoverOpens: to prevent this in certain situations
  if (shouldClose) {
    if ([delegate respondsToSelector:@selector(popoverShouldCloseWhenNewPopoverOpens:newPopover:)]) {
      shouldClose = [delegate popoverShouldCloseWhenNewPopoverOpens:self newPopover:otherPopover];
    }
  }

  if (shouldClose)
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

- (NSRect)screenFrame {
  NSRect rect = [[NSScreen mainScreen] frame];
  rect.size.height -= 22; //subtract the menu, but not the dock!
  return rect;
}

- (NSRect)popoverWindowFrame {
  NSPoint point = [self attachToPointInScreenCoordinates];
  
  if (!NSEqualPoints(point, NSZeroPoint)) {
    NSRect screenFrame = [self screenFrame];
    NSRect windowRect = [self windowRectForViewSize:[self.contentViewController.view frame].size above:[self screenAnchorRect] pointingTo:point edge:self.preferredEdge];
    if (NSContainsRect(screenFrame, windowRect))
      return windowRect;
    if (!self.constrainToScreenSize)
      return BCRectWithMaxForAxis(windowRect, NSMaxX(screenFrame), BCAxisHorizontal);
    else
      return NSIntersectionRect(windowRect, screenFrame);
  } else
    return NSZeroRect;
}

- (NSRect)screenAnchorRect {
  if (self.attachedToView) {
    NSView *anchoredView = self.attachedToView.superview;
    NSRect rect = [anchoredView.window convertRectToScreen:[anchoredView convertRect:anchoredView.bounds toView:nil]];
    return [self ensureRectFitsInParentWindow:rect];
  } else
    return [self.window frame];
}

- (NSPoint)attachToPointInScreenCoordinates {
  if (self.attachedToView) {
    NSRect rectInWindow = NSInsetRect([self.attachedToView convertRect:[self.attachedToView bounds] toView:nil], -6, -6);
    NSPoint pointAtEdge = [self pointAtEdge:self.preferredEdge ofRect:rectInWindow];
    
    NSWindow *window = self.attachedToView.window;
    
    NSRect converted = [window convertRectToScreen:NSMakeRect(pointAtEdge.x, pointAtEdge.y, 0, 0)];
    return [self ensureRectFitsInParentWindow:converted].origin;
  } else {
    NSRect windowFrame = self.window.frame;
    return NSMakePoint(NSMinX(windowFrame), NSMaxY(windowFrame));
  }
}

- (NSRect)ensureRectFitsInParentWindow:(NSRect)rect; {
  NSWindow *window = self.attachedToView.window;

  NSUInteger windowMaxX = NSMaxX(window.frame);
  NSUInteger windowMinX = NSMinX(window.frame);
  
  if (NSMidX(rect) > windowMaxX)
    rect = BCRectWithMidX(rect, windowMaxX);
  if (NSMidX(rect) < windowMinX)
    rect = BCRectWithMidX(rect, windowMinX);
  
  
  return rect;
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
  } else {
    windowRect.origin = NSZeroPoint;
  }
  return windowRect;
}

- (void)windowWillClose:(NSNotification *)notification {
  [self.delegate popoverWillClose:self];
}

- (void)close {
  NSWindow *window = self.window;
  
  // we'll actually close next time round the event queue
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [[window parentWindow] removeChildWindow:window];
    [window close];
  }];

  // tell our delegate that we're going, and ignore any future delegate stuff from the native window
  [self.delegate popoverWillClose:self];
  window.delegate = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
