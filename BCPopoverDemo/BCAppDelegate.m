//  Created by Pieter Omvlee on 06/11/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.

#import "BCAppDelegate.h"
#import "BCDummyViewController.h"
#import "BCPopover.h"

@interface BCAppDelegate ()
@property (nonatomic, strong) NSMutableArray *popovers;
@end

@implementation BCAppDelegate

- (IBAction)attach:(id)sender {
  if ([self.popovers count] > 0) {
    for (BCPopover *popover in self.popovers)
      [popover close];
    
    [self.popovers removeAllObjects];
  } else {
    self.popovers = [NSMutableArray array];
    [self.popovers addObject:[self popoverAtEdge:NSMinYEdge]];
    [self.popovers addObject:[self popoverAtEdge:NSMaxYEdge]];
    [self.popovers addObject:[self popoverAtEdge:NSMinXEdge]];
    [self.popovers addObject:[self popoverAtEdge:NSMaxXEdge]];
  }
}

- (BCPopover *)popoverAtEdge:(NSRectEdge)edge {
  BCPopover *popover = [BCPopover new];
  popover.contentViewController = [BCDummyViewController new];
  popover.delegate = self;
  [popover showRelativeToView:self.button preferredEdge:edge];
  return popover;
}

- (void)popoverWillClose:(BCPopover *)popover {
  [self.popovers removeObject:popover];
}

- (IBAction)resize:(id)sender {
  for (BCPopover *popover in self.popovers)
    [self resizePopover:popover];
}

- (void)resizePopover:(BCPopover *)popover {
  NSView *view = popover.contentViewController.view;
  NSRect frame = view.frame;
  frame = NSInsetRect(frame, -50, -50);
  view.frame = frame;
}

@end