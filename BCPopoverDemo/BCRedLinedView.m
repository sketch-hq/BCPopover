//  Created by Pieter Omvlee on 06/11/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.

#import "BCRedLinedView.h"

@implementation BCRedLinedView

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor redColor] set];
  NSFrameRect([self bounds]);
}

@end
