// Created by Pieter Omvlee on 06/11/2013.

#import <Foundation/Foundation.h>

@class BCPopover;

@protocol BCPopoverDelegate <NSObject>
- (void)popoverWillClose:(BCPopover *)popover;
@optional;

- (BOOL)popoverShouldCloseWhenOtherPopoverOpens:(BCPopover *)popover otherPopover:(BCPopover *)otherPopover;
@end