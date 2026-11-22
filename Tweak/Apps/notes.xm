#import <UIKit/UIKit.h>
#import "palette.h"

static UIColor *DKNotesPaper(void) {
    return [UIColor colorWithWhite:0.11 alpha:1];
}

static UIColor *DKNotesText(UIColor *color) {
    return DKTextColor(color ?: UIColor.blackColor);
}

%group Notes

%hook NotesTextureView

- (void)setBackgroundColor:(UIColor *)color {
    %orig(DKNotesPaper());
}

- (void)didMoveToWindow {
    %orig;
    [(UIView *)self setBackgroundColor:DKNotesPaper()];
}

%end

%hook ICListTableView

- (void)setBackgroundColor:(UIColor *)color {
    %orig(CGColorGetAlpha(color.CGColor) < 0.05 ? color : DKNotesPaper());
}

%end

%hook _UICompatibilityTextView

- (void)setTextColor:(UIColor *)color {
    %orig(DKNotesText(color));
}

- (void)didMoveToWindow {
    %orig;
    id view = self;
    [view setTextColor:[view textColor]];
}

%end

%end

%ctor {
    if (!DKProcessEnabled()) return;
    if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.mobilenotes"]) return;
    %init(Notes);
}
