import SwiftUI

struct SizeClassPreferenceKey: PreferenceKey {
    static var defaultValue: UserInterfaceSizeClass? = nil
    
    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        value = nextValue() ?? value
    }
}