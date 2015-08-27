// Created by Pieter Omvlee on 06/11/2013.

#import <Cocoa/Cocoa.h>
#import "BCPopoverDelegate.h"

@class BCPopoverWindow;
@protocol BCPopoverContentController;

typedef NS_ENUM(NSInteger, BCPopupLayerDependency) {
  BCPopoverLayerDependant,
  BCPopoverLayerIndependent
};

/** Specifies the behaviour the popover should have when it gets outside the edges of the screen. Should it do nothing, should it resize, or should it move itself? */
typedef NS_ENUM(NSInteger, BCPopoverScreenEdgeBehaviour) {
  BCPopoverScreenEdgeBehaviourNone,
  BCPopoverScreenEdgeBehaviourResize,
  BCPopoverScreenEdgeBehaviourMove
};

static NSString *const BCPopoverWillShowNotification = @"BCPopoverWillShowNotification";

@interface BCPopover : NSObject <NSWindowDelegate>
@property (nonatomic, strong) NSViewController <BCPopoverContentController>*contentViewController;
@property (nonatomic, weak) id<BCPopoverDelegate> delegate;
@property (nonatomic, strong) BCPopoverWindow *window;
@property (nonatomic, strong) NSView *attachedToView;
@property (nonatomic) BCPopoverScreenEdgeBehaviour screenEdgeBehaviour;
@property (nonatomic) BCPopupLayerDependency layerDependency;

- (void)showRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)edge;
- (void)close;
- (void)move;

- (NSRect)popoverWindowFrame;

@end
