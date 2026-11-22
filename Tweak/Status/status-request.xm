#import <UIKit/UIKit.h>
#import "palette.h"

%hook UIStatusBarStyleRequest

- (NSInteger)style {
    NSInteger style = %orig;
    return style == UIStatusBarStyleDefault ? UIStatusBarStyleLightContent : style;
}

%end

%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
