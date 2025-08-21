
import SwiftUI

@main
final class ChickenIdentifierApp: UIResponder, UIApplicationDelegate {
    static var orientMask: UIInterfaceOrientationMask = .portrait
    @AppStorage("isRate") var isRate = false
    var isRateRequested = false
    var window: UIWindow?
    var homeVM = HomeViewModel()
}
