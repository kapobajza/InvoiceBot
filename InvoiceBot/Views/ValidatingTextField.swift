import SwiftUI

struct ValidatingTextField: View {
    @Binding var text: String
    @EnvironmentObject var formValidator: FormValidator

    private var field: String

    init(field: String, text: Binding<String>) {
        self.field = field
        _text = text
    }

    var body: some View {
        Section {
            TextField(formValidator.titles[field]!, text: $text)
                .onChange(of: text) { value in
                    formValidator.setError(field: self.field, message: value)
                }
            if let error = formValidator.errors[field], let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ValidatingTextField(field: "my_field", text: .constant(""))
}
