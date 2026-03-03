import SwiftUI

enum Route: Hashable {
    case home
    case timer(totalSession: Int, focusMinutes: Int, breakMinutes: Int)
//    case recap
}
