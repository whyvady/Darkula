#import <UIKit/UIKit.h>
#import "palette.h"
static UIStatusBarStyle DKLightStyle(UIStatusBarStyle style) {
    return style == UIStatusBarStyleDefault ? UIStatusBarStyleLightContent : style;
}
%hook UIViewController
- (UIStatusBarStyle)preferredStatusBarStyle {
    return DKLightStyle(%orig);
}
%end
%hook UIApplication
- (void)setStatusBarStyle:(UIStatusBarStyle)style {
    %orig(DKLightStyle(style));
}
- (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated {
    %orig(DKLightStyle(style), animated);
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
