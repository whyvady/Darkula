#import <UIKit/UIKit.h>
#import "palette.h"
#import "attributed.h"

%hook UILabel

- (void)setAttributedText:(NSAttributedString *)text {
    %orig(DKIsPrivateObject(self) ? text : DKAttributedText(text));
}

%end

%hook UIButton

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state {
    %orig(DKIsPrivateObject(self) ? title : DKAttributedText(title), state);
}

%end

%ctor {
    if (!DKProcessEnabled()) return;
    %init;
}
