import SwiftUI

struct ValidatingTextField: View {
    @Binding var text: String
    @EnvironmentObject var formValidator: FormValidator

    private var field: String
    private var disabled: Bool
    var onChange: (String) -> Void = { _ in } // Default is a no-op

    init(
        field: String,
        text: Binding<String>,
        disabled: Bool = false
    ) {
        self.field = field
        self.disabled = disabled
        _text = text
    }

    var body: some View {
        Section {
            TextField(formValidator.titles[field]!, text: $text)
                .onChange(of: text) { value in
                    formValidator.setError(field: self.field, message: value)
                    self.onChange(value)
                }
                .disabled(disabled)
            if let error = formValidator.errors[field], let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    func onChange(_ perform: @escaping (String) -> Void) -> some View {
        var copy = self
        copy.onChange = perform
        return copy
    }
}

#Preview {
    ValidatingTextField(field: "my_field", text: .constant(""))
}
