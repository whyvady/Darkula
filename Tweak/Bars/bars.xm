#import <UIKit/UIKit.h>
#import "palette.h"
%hook UINavigationBar
- (void)setBarStyle:(UIBarStyle)style {
    %orig(style == UIBarStyleDefault && !DKIsPrivateObject(self) ? UIBarStyleBlack : style);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKBackgroundColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self) && self.barStyle == UIBarStyleDefault) self.barStyle = UIBarStyleBlack;
}
%end
%hook UIToolbar
- (void)setBarStyle:(UIBarStyle)style {
    %orig(style == UIBarStyleDefault && !DKIsPrivateObject(self) ? UIBarStyleBlack : style);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKBackgroundColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self) && self.barStyle == UIBarStyleDefault) self.barStyle = UIBarStyleBlack;
}
%end
%hook UITabBar
- (void)setBarStyle:(UIBarStyle)style {
    %orig(style == UIBarStyleDefault && !DKIsPrivateObject(self) ? UIBarStyleBlack : style);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKBackgroundColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self) && self.barStyle == UIBarStyleDefault) self.barStyle = UIBarStyleBlack;
}
%end
%hook UISearchBar
- (void)setBarStyle:(UIBarStyle)style {
    %orig(style == UIBarStyleDefault && !DKIsPrivateObject(self) ? UIBarStyleBlack : style);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKBackgroundColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (!self.window || DKIsPrivateObject(self)) return;
    if (self.barStyle == UIBarStyleDefault) self.barStyle = UIBarStyleBlack;
    if (self.keyboardAppearance == UIKeyboardAppearanceDefault) self.keyboardAppearance = UIKeyboardAppearanceDark;
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
