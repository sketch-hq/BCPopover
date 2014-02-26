// Created by Pieter Omvlee on 06/11/2013.

#import <Cocoa/Cocoa.h>
#import "BCPopoverDelegate.h"

@class BCPopoverWindow;
@protocol BCPopoverContentController;

static NSString *const BCPopoverWillShowNotification = @"BCPopoverWillShowNotification";

@interface BCPopover : NSObject <NSWindowDelegate>
@property (nonatomic, strong) NSViewController <BCPopoverContentController>*contentViewController;
@property (nonatomic, weak) id<BCPopoverDelegate> delegate;
@property (nonatomic, strong) BCPopoverWindow *window;
@property(nonatomic, strong) NSView *attachedToView;

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge;
- (void)close;
- (void)move;

- (NSRect)popoverWindowFrame;

@end
