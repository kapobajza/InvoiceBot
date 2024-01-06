import Combine
import SwiftUI

enum FormValidatorEnum {
    case number
    case decimal
}

typealias FormValidatorFn = (String) -> String?

class FormValidationOptions {
    var title: String
    var validator: FormValidatorEnum?
    var validatorFn: FormValidatorFn
    var errorMessage: String?

    init(title: String, validator: @escaping FormValidatorFn) {
        self.title = title
        self.validatorFn = validator
    }

    init(title: String, validator: FormValidatorEnum) {
        self.title = title
        let numberFormatter = NumberFormatter()

        switch validator {
        case .number:
            self.validatorFn = { val in
                if numberFormatter.number(from: val) != nil {
                    return nil
                }

                return "\(title) must be a number"
            }

        case .decimal:
            self.validatorFn = { val in
                if NumberFormatter.amountNumberFormatter.number(from: val) != nil {
                    return nil
                }

                return "\(title) must be a decimal number"
            }
        }
    }
}

typealias FormStateMap = [String: FormValidationOptions]

class FormValidator: ObservableObject {
    @Published var isValid: Bool = false
    @Published var errors: [String: String?] = [:]
    var titles: [String: String] = [:]

    private var instance: FormStateMap
    private var cancellables = Set<AnyCancellable>()

    func setError(field: String, message: String?) {
        guard let formMap = instance[field], let message = message else {
            return
        }

        errors[field] = formMap.validatorFn(message)
    }

    init(instance: FormStateMap) {
        self.instance = instance
        self.errors = instance.mapValues { $0.errorMessage }
        self.titles = instance.mapValues { $0.title }

        $errors.map { errorsMap in
            errorsMap.allSatisfy { _, value in
                value == nil
            }
        }
        .assign(to: \.isValid, on: self)
        .store(in: &cancellables)
    }
}

struct FormValidatorContext<Content: View>: View {
    @StateObject var formValidator: FormValidator
    let content: Content

    init(formValidator: FormValidator, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._formValidator = StateObject(wrappedValue: formValidator)
    }

    var body: some View {
        Form {
            content
        }
        .environmentObject(formValidator)
    }
}
