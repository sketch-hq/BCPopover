// Created by Pieter Omvlee on 07/02/2014.

#import <Foundation/Foundation.h>

@class BCPopover;

@protocol BCPopoverContentController <NSObject>

@optional;
- (void)popoverWindowDidShow:(BCPopover *)popover;
@end