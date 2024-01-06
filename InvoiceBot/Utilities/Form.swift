import Foundation

struct FormUtilities {
    static func isValid(_ form: FormStateMap) -> Bool {
        form.values.allSatisfy { formValidatorState in
            formValidatorState.errorMessage == nil
        }
    }
}
