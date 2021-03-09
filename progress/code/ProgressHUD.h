//
//  ProgressHUD.h
//  Version 1.1.0
//  Created by Matej Bukovinski on 2.4.09.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2009-2016 Matej Bukovinski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class MBBackgroundView;

extern CGFloat const MBProgressMaxOffset;

typedef NS_ENUM(NSInteger, ProgressHUDMode) {
    /// UIActivityIndicatorView.
    ProgressHUDModeIndeterminate,
    /// Shows a custom view.
    ProgressHUDModeCustomView
};

NS_ASSUME_NONNULL_BEGIN


/**
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The ProgressHUD window spans over the entire space given to it by the initWithFrame: constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view.
 *
 * @note To still allow touches to pass through the HUD, you can set hud.userInteractionEnabled = NO.
 * @attention ProgressHUD is a UI class and should therefore only be accessed on the main thread.
 */
@interface ProgressHUD : UIView

/**
 * Creates a new HUD, adds it to provided view and shows it. The counterpart to this method is hideHUDForView:animated:.
 *
 * @note This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
 *
 * @param view The view that the HUD will be added to
If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 * @return A reference to the created HUD.
 *
 * @see hideHUDForView:animated:
 * @see animationType
 */
+ (instancetype)showHUDAddedTo:(UIView *)view;

/**
 * A convenience constructor that initializes the HUD with the view's bounds. Calls the designated constructor with
 * view.bounds as the parameter.
 *
 * @param view The view instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the view that the HUD will be added to).
 */
- (instancetype)initWithView:(UIView *)view;

/**
 * Displays the HUD.
 *
 * @note You need to make sure that the main thread completes its run loop soon after this method call so that
 * the user interface can be updated. Call this method when your task is already set up to be executed in a new thread
 * (e.g., when using something like NSOperation or making an asynchronous call like NSURLRequest).

 If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 *
 * @see animationType
 */
- (void)showAnimated;

/**
 * Hides the HUD. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 
 If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * 
 * animations while disappearing.
 *
 * @see animationType
 */
- (void)hideAnimated;

/**
 * Hides the HUD after a delay. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @param delay Delay in seconds until the HUD is hidden.
 *
 * @see animationType
 */
- (void)hideAfterDelay:(NSTimeInterval)delay;

/// @name Appearance

/**
 * ProgressHUD operation mode. The default is ProgressHUDModeIndeterminate.
 */
@property (assign, nonatomic) ProgressHUDMode mode;

/**
 * The bezel offset relative to the center of the view. You can use MBProgressMaxOffset
 * and -MBProgressMaxOffset to move the HUD all the way to the screen edge in each direction.
 * E.g., CGPointMake(0.f, MBProgressMaxOffset) would position the HUD centered on the bottom edge.
 */
@property (assign, nonatomic) CGPoint offsetX UI_APPEARANCE_SELECTOR;



/// @name Views

/**
 * The view containing the labels and indicator (or customView).
 */
@property (strong, nonatomic, readonly) MBBackgroundView *bezelView;

/**
 * View covering the entire HUD area, placed behind bezelView.
 */
@property (strong, nonatomic, readonly) MBBackgroundView *backgroundView;

/**
 * The UIView (e.g., a UIImageView) to be shown when the HUD is in ProgressHUDModeCustomView.
 * The view should implement intrinsicContentSize for proper sizing. For best results use approximately 37 by 37 pixels.
 */
@property (strong, nonatomic, nullable) UIView *customView;

/**
 * A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text.
 */
@property (strong, nonatomic, readonly) UILabel *label;


@end

@interface MBBackgroundView: UIView
@end


NS_ASSUME_NONNULL_END

