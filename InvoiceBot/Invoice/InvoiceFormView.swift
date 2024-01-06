import SwiftUI

enum InvoiceFormField: String {
    case invoiceNumber
    case invoiceFiscalNumber
    case invoiceAmountEuro
    case invoiceAmountKM
}

struct InvoiceFormView: StackNavigationView {
    @State private var invoiceData = InvoiceFormViewDTO()
    @EnvironmentObject var invoiceFormViewModel: InvoiceFormViewModel
    @EnvironmentObject var navigationStack: NavigationStack

    @StateObject private var formValidator = FormValidator(instance: [
        InvoiceFormField.invoiceNumber.rawValue: FormValidationOptions(title: "Invoice number", validator: .number),
        InvoiceFormField.invoiceFiscalNumber.rawValue: FormValidationOptions(title: "Invoice fiscal number", validator: .number),
        InvoiceFormField.invoiceAmountEuro.rawValue: FormValidationOptions(title: "Invoice amount in Euro", validator: .decimal),
        InvoiceFormField.invoiceAmountKM.rawValue: FormValidationOptions(title: "Invoice amount in KM", validator: .decimal),
    ])

    var body: some View {
        VStack {
            Text("Generate invoice PDF")
                .font(.title)
                .padding(
                    EdgeInsets(
                        top: 16,
                        leading: 16,
                        bottom: 32,
                        trailing: 16
                    )
                )

            if invoiceFormViewModel.invoiceDataFetchable.state.isLoading {
                ProgressView()
            } else if let error = invoiceFormViewModel.invoiceDataFetchable.state.error {
                Text(error.localizedDescription)
            } else if invoiceFormViewModel.invoiceDataFetchable.state.result != nil {
                FormValidatorContext(formValidator: formValidator) {
                    ValidatingTextField(
                        field: InvoiceFormField.invoiceNumber.rawValue,
                        text: $invoiceData.invoiceNumber
                    )
                    ValidatingTextField(
                        field: InvoiceFormField.invoiceFiscalNumber.rawValue,
                        text: $invoiceData.fiscalNumber
                    )
                    ValidatingTextField(
                        field: InvoiceFormField.invoiceAmountEuro.rawValue,
                        text: $invoiceData.amountEuro
                    )
                    ValidatingTextField(
                        field: InvoiceFormField.invoiceAmountKM.rawValue,
                        text: $invoiceData.amountKM
                    )
                    DatePicker("Select a Date", selection: Binding(get: {
                        invoiceData.issueDate ?? Date()
                    }, set: {
                        invoiceData.issueDate = $0
                    }), displayedComponents: .date)

                    Button("Generate PDF") {
                        navigationStack.push(InvoicePdfView(), params: invoiceData)
                    }.disabled(!formValidator.isValid)
                }
            }
        }
        .onAppear(perform: {
            invoiceFormViewModel.getInvoiceFormData()
        })
        .onReceive(invoiceFormViewModel.invoiceDataFetchable.$state, perform: { val in
            if let invoiceData = val.result {
                self.invoiceData = invoiceData
            }
        })
        .padding()
    }
}

#Preview {
    InvoiceFormView()
        .environmentObject(
            InvoiceFormViewModel(
                msGraphHttpClient: HttpClientMock(),
                config: ConfigMock()
            )
        )
}
