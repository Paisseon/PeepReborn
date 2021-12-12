#import <UIKit/UIKit.h>

static NSString* bundleIdentifier = @"ai.paisseon.peepreborn";
static NSMutableDictionary* settings;
static bool enabled;
static bool permaHide;
static int numTaps;

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar : UIView
@property (nonatomic, strong) UIStatusBarForegroundView* foregroundView;
- (void) handleTapGesture: (id) sender;
@end

static bool isHidden;
static UIView* ghostBar;
static UITapGestureRecognizer* tapGesture;