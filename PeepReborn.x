#import "PeepReborn.h"

NSUserDefaults *defaults;
_UIStatusBar *statusBar;
BOOL didLayoutSubviews = 0;

%hook _UIStatusBar
- (id) initWithStyle: (long long) arg1 {
 	self = %orig;
  	if (self) {
		statusBar = self;
 		[self addTapGesture]; // add gesture on init
 	}
  	return self;
}

- (void) layoutSubviews {
	%orig;
	if (self.foregroundView && !didLayoutSubviews) {
		self.foregroundView.hidden = [defaults boolForKey:[NSString @"isStatusBarHidden"]]; // check if supposed to be hidden
		didLayoutSubviews = 1; // minimises layoutSubviews use for efficiency
	}
}

%new 
- (void) handleTapGesture: (id) sender { // when the status bar is tapped
	[UIView transitionWithView:self duration: 0 options: UIViewAnimationOptionTransitionNone animations: ^{self.foregroundView.hidden = !self.foregroundView.hidden;} completion:^(BOOL finished){ [self addTapGesture]; }]; [defaults setBool:self.foregroundView.hidden forKey:[NSString @"isStatusBarHidden"]]; [defaults synchronize]; // idk what half of this does, just used what the original does ahaha
}

%new
- (void) addTapGesture {
	self.userInteractionEnabled = YES; // basically lets the status bar be tapped
	if (self.tapGesture) [self removeGestureRecognizer:self.tapGesture]; // removes the current gesture if it exists
	self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]; // if the status bar is tapped, use the actions defined in handleTapGesture
	self.tapGesture.numberOfTapsRequired = 1; // only requires a single tap, peep 2.0+ did something with preferences but im too lazy
	[self addGestureRecognizer:self.tapGesture]; // add the gesture
	self.fakeStatusBar = [[UIView alloc] initWithFrame:self.bounds]; // make a subview of status bar so it can be tapped whilst hidden
	[self addSubview:self.fakeStatusBar]; // adds the subview to status bar view
}
%end

%ctor {
	defaults = [[NSUserDefaults alloc] _initWithSuiteName:@"ai.paisseon.peepreborn" container:[NSURL URLWithString:@"/var/mobile"]]; // necessary for caching
}