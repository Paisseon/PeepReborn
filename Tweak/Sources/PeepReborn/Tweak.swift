import Jinx

struct Tweak {
    static func ctor() {
        guard Preferences.isEnabled else {
            return
        }
        
        StatusBarHook().hook()
    }
}

@_cdecl("jinx_entry")
func jinxEntry() {
    Tweak.ctor()
}
