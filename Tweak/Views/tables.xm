#import <UIKit/UIKit.h>
#import "palette.h"
static const CGFloat DKGroupedWhite = 0.95;
%hook UITableView
- (void)didMoveToWindow {
    %orig;
    if (!self.window || DKIsPrivateObject(self)) return;
    UIColor *current = self.backgroundColor;
    CGFloat white = self.style == UITableViewStyleGrouped ? DKGroupedWhite : 1;
    UIColor *base = DKIsSolidColor(current) ? current : [UIColor colorWithWhite:white alpha:1];
    UIColor *mapped = DKBackgroundColor(base);
    if (![mapped isEqual:current]) self.backgroundColor = mapped;
    UIColor *separator = self.separatorColor;
    if (!separator || DKIsLightGray(separator)) self.separatorColor = DKSeparatorColor();
}
%end
%hook UITableViewCell
- (void)didMoveToWindow {
    %orig;
    if (!self.window || DKIsPrivateObject(self)) return;
    UIColor *current = self.backgroundColor;
    UIColor *base = DKIsSolidColor(current) ? current : [UIColor whiteColor];
    UIColor *mapped = DKBackgroundColor(base);
    if (![mapped isEqual:current]) self.backgroundColor = mapped;
    if (self.selectedBackgroundView) return;
    UIView *selected = [UIView new];
    selected.backgroundColor = DKSelectionColor();
    self.selectedBackgroundView = selected;
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
