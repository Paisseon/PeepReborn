#import "PeepReborn.h"

static void refreshPrefs() { // prefs by skittyblock
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else settings = nil;
	if (!settings) settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];
	
	enabled   = [([settings objectForKey:@"enabled"] ?: @(true)) boolValue];
	permaHide = [([settings objectForKey:@"permaHide"] ?: @(false)) boolValue];
	numTaps   = [([settings objectForKey:@"numTaps"] ?: @(1)) intValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
	refreshPrefs();
}

static void initGhostBar(_UIStatusBar* arg0) {
	ghostBar = [[UIView alloc] initWithFrame:arg0.bounds]; // frame of the status bar
	[arg0 addSubview:ghostBar]; // this subview prevents the status bar from disappearing when the foreground view is hidden
}

%hook _UIStatusBar
- (void) layoutSubviews {
	%orig;
	if (permaHide) {
		self.foregroundView.hidden = true;
		return;
	}
	if (!tapGesture) { // if this gesture doesn't exist already and we don't have a permanent hide
		self.userInteractionEnabled = true; // let users actually touch the status bar
		UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)]; // set up a gesture recogniser
		tapGesture.numberOfTapsRequired = numTaps; // require the number of taps specified in prefs
		[self addGestureRecognizer:tapGesture]; // add the gesture recogniser
		initGhostBar(self); // send this instance of status bar to the ghost bar function
		self.foregroundView.hidden = isHidden; // determine whether to hide by current hidden value
	}
}

%new 
- (void) handleTapGesture: (id) sender { // when the status bar is tapped
	self.foregroundView.hidden = !self.foregroundView.hidden; // toggle if hidden
	isHidden = self.foregroundView.hidden; // set the global variable to match current state
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
	if (enabled) %init;
}