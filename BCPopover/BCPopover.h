// Created by Pieter Omvlee on 06/11/2013.

#import <Cocoa/Cocoa.h>
#import "BCPopoverDelegate.h"

@class BCPopoverWindow;
@protocol BCPopoverContentController;

static NSString *const BCPopoverWillShowNotification = @"BCPopoverWillShowNotification";

typedef NS_ENUM(NSUInteger, BCPopOverType) {
  BCPopOverTypePopOver,
  BCPopOverTypeMenu
};

@interface BCPopover : NSObject <NSWindowDelegate>
@property (nonatomic, strong) NSViewController <BCPopoverContentController>*contentViewController;
@property (nonatomic, weak) id<BCPopoverDelegate> delegate;
@property (nonatomic, strong) BCPopoverWindow *window;
@property (nonatomic) BCPopOverType popoverType;

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge;
- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge type:(BCPopOverType)type;
- (void)close;
- (void)detach;

- (NSRect)popoverWindowFrame;

@end
