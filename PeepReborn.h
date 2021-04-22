#import <UIKit/UIKit.h>

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar : UIView
@property(nonatomic, strong) UIStatusBarForegroundView *foregroundView;
@end

@interface _UIStatusBar (PeepReborn)
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *fakeStatusBar;
-(void)handleTapGesture:(id)sender;
-(void)addTapGesture;
@end

@interface NSUserDefaults (Private)
-(instancetype)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container;
@end