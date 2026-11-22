#import <UIKit/UIKit.h>
#import "palette.h"
static void DKRefreshLabel(UILabel *label) {
    if (!DKIsUniformText(label.attributedText)) return;
    UIColor *current = label.textColor;
    UIColor *mapped = DKTextColor(current);
    if (mapped != current) label.textColor = mapped;
}
%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKBackgroundColor(color));
}
%end
%hook UILabel
- (void)setTextColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKTextColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self)) DKRefreshLabel(self);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %orig(DKIsPrivateObject(self) ? color : DKTextColor(color), state);
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
