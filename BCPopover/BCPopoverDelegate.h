// Created by Pieter Omvlee on 06/11/2013.

#import <Foundation/Foundation.h>

@class BCPopover;

@protocol BCPopoverDelegate <NSObject>
- (void)popoverWillClose:(BCPopover *)popover;
@optional;
- (void)popoverWindowSizeDidChange:(BCPopover *)popover;
- (BOOL)popoverShouldCloseWhenNewPopoverOpens:(BCPopover *)popover newPopover:(BCPopover *)newPopover;
- (BOOL)popoverShouldCauseExistingPopoversToClose:(BCPopover *)popover;
@end