#import <UIKit/UIKit.h>
#import "palette.h"

%hook UITextInputTraits

- (NSInteger)keyboardAppearance {
    return UIKeyboardAppearanceDark;
}

- (void)setKeyboardAppearance:(NSInteger)appearance {
    %orig(UIKeyboardAppearanceDark);
}

%end

%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
