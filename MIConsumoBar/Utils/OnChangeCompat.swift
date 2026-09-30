import SwiftUI

extension View {
    /// `onChange` sin aviso de deprecación en iOS 17+, manteniendo iOS 16.
    /// ponytail: quitar cuando el mínimo sea iOS 17 y usar `onChange(of:) { _, new in }`.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, _ action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17, *) {
            onChange(of: value) { _, new in action(new) }
        } else {
            onChange(of: value, perform: action)
        }
    }
}
