import Foundation

protocol WSBound {
    func wsValueForKey (key: String) -> WSValue?
}

enum WSValue {
    case Text(String)
    case Number(Int)
    case TrueFalse(Bool)
}