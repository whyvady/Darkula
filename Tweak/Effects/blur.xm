#import <UIKit/UIKit.h>
#import "palette.h"
%hook UIBlurEffect
+ (UIBlurEffect *)effectWithStyle:(UIBlurEffectStyle)style {
    switch (style) {
        case UIBlurEffectStyleExtraLight:
        case UIBlurEffectStyleLight:
        case UIBlurEffectStyleRegular:
        case UIBlurEffectStyleProminent:
            return %orig(UIBlurEffectStyleDark);
        default:
            return %orig(style);
    }
}
%end
%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
