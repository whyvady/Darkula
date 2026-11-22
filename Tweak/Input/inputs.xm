#import <UIKit/UIKit.h>
#import "palette.h"
static void DKRefreshField(UITextField *field) {
    if (field.keyboardAppearance == UIKeyboardAppearanceDefault) field.keyboardAppearance = UIKeyboardAppearanceDark;
    if (!DKIsUniformText(field.attributedText)) return;
    UIColor *current = field.textColor ?: [UIColor blackColor];
    UIColor *mapped = DKTextColor(current);
    if (mapped != current) field.textColor = mapped;
}
static void DKRefreshTextView(UITextView *view) {
    if (view.keyboardAppearance == UIKeyboardAppearanceDefault) view.keyboardAppearance = UIKeyboardAppearanceDark;
    if (!DKIsUniformText(view.attributedText)) return;
    UIColor *current = view.textColor ?: [UIColor blackColor];
    UIColor *mapped = DKTextColor(current);
    if (mapped != current) view.textColor = mapped;
}
%hook UITextField
- (void)setTextColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKTextColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self)) DKRefreshField(self);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)color {
    %orig(DKIsPrivateObject(self) ? color : DKTextColor(color));
}
- (void)didMoveToWindow {
    %orig;
    if (self.window && !DKIsPrivateObject(self)) DKRefreshTextView(self);
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
