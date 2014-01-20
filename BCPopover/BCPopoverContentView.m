//  Created by Pieter Omvlee on 08-09-09.
//  Copyright 2009 Bohemian Coding. All rights reserved.

#import "BCPopoverContentView.h"

@implementation BCPopoverContentView

- (void)drawRect:(NSRect)rect {
  [[NSColor clearColor] set];
  NSRectFill([self bounds]);
  
  [[NSColor whiteColor] set];
  [[self backgroundPath] fill];
}

- (NSRect)availableContentRect {
  NSRect contentRect = [self bounds];

  if (!self.shouldShowArrow)
    return NSInsetRect(contentRect, 0, 3);
  
  if (self.arrowEdge == NSMaxXEdge) {
    contentRect.origin.x    += kArrowSize;
    contentRect.size.width  -= kArrowSize;
  } else if (self.arrowEdge == NSMinYEdge) {
    contentRect.size.height -= kArrowSize;
  } else if (self.arrowEdge == NSMinXEdge) {
    contentRect.size.width  -= kArrowSize;
  } else if (self.arrowEdge == NSMaxYEdge) {
    contentRect.origin.y    += kArrowSize;
    contentRect.size.height -= kArrowSize;
  }
  return contentRect;
}

- (NSBezierPath *)backgroundPath {
  CGFloat radius = kCornerRadius;
  NSRect rect = [self availableContentRect];

  if (NSEqualRects(NSZeroRect, rect))
    return nil;

  if (!self.shouldShowArrow)
    return [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:radius yRadius:radius];

  CGFloat minX = NSMinX(rect);
  CGFloat maxX = NSMaxX(rect);
  CGFloat minY = NSMinY(rect);
  CGFloat maxY = NSMaxY(rect);
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(minX, minY+radius)];
  
  if (self.arrowEdge == NSMaxXEdge) {
    [path lineToPoint:NSMakePoint(minX, NSMinY(rect)+ NSHeight(rect)*self.arrowPosition-kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(-kArrowSize, kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(kArrowSize,  kArrowSize)];
  }
  
  [path lineToPoint:NSMakePoint(minX, maxY-radius)];
  [path curveToPoint:NSMakePoint(minX+radius, maxY)
       controlPoint1:NSMakePoint(minX, maxY-radius/2)
       controlPoint2:NSMakePoint(minX+radius/2, maxY)];
  
  if (self.arrowEdge == NSMinYEdge) {
    [path lineToPoint:NSMakePoint(NSMinX(rect)+ NSWidth(rect)*self.arrowPosition-kArrowSize, NSMaxY(rect))];
    [path relativeLineToPoint:NSMakePoint(kArrowSize, kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(kArrowSize, -kArrowSize)];
  }
  
  [path lineToPoint:NSMakePoint(maxX-radius, maxY)];
  [path curveToPoint:NSMakePoint(maxX, maxY-radius)
       controlPoint1:NSMakePoint(maxX-radius/2,maxY)
       controlPoint2:NSMakePoint(maxX, maxY-radius/2)];
  
  if (self.arrowEdge == NSMinXEdge) {
    [path lineToPoint:NSMakePoint(maxX, NSMinY(rect)+ NSHeight(rect)*self.arrowPosition+kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(kArrowSize, -kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(-kArrowSize, -kArrowSize)];
  }
  
  [path lineToPoint:NSMakePoint(maxX, minY+radius)];
  [path curveToPoint:NSMakePoint(maxX-radius, minY)
       controlPoint1:NSMakePoint(maxX, minY+radius/2)
       controlPoint2:NSMakePoint(maxX-radius/2, minY)];
  
  if (self.arrowEdge == NSMaxYEdge) {
    [path lineToPoint:NSMakePoint(NSMinX(rect)+NSWidth(rect)*self.arrowPosition+kArrowSize, NSMinY(rect))];
    [path relativeLineToPoint:NSMakePoint(-kArrowSize, -kArrowSize)];
    [path relativeLineToPoint:NSMakePoint(-kArrowSize, kArrowSize)];
  }
  
  [path lineToPoint:NSMakePoint(minX+radius, minY)];
  [path lineToPoint:NSMakePoint(minX+radius, minY)];
  [path curveToPoint:NSMakePoint(minX, minY+radius)
       controlPoint1:NSMakePoint(minX+radius/2, minY)
       controlPoint2:NSMakePoint(minX,minY+radius/2)];
  [path closePath];
  
  return path;
}

@end
