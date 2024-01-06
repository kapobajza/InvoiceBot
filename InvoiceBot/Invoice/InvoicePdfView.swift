import SwiftUI

struct InvoicePdfView: StackNavigationView {
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var invoicePdfViewModel: InvoicePdfViewModel

    var body: some View {
        if let params = navigationStack.getParams() as? InvoiceFormViewDTO {
            let webView = WebView(html: getPdfInvoiceHTML(data: params))
            VStack {
                webView.frame(width: 760, height: 500)
                Button(action: {
                    webView.createPDF { result in
                        switch result {
                        case .success(let data):
                            invoicePdfViewModel.sendPdfAsMail(data, invoiceFormData: params)

                        case .failure(let error):
                            invoicePdfViewModel.alertMessage = error.localizedDescription
                        }
                    }
                }, label: {
                    if invoicePdfViewModel.sendEmailFetchable.state.isLoading {
                        ProgressView()
                            .scaleEffect(0.5, anchor: .center)
                            .fixedSize(horizontal: true, vertical: true)
                    } else {
                        Text("Send PDF as mail")
                    }
                }).alert(
                    invoicePdfViewModel.alertMessage ?? "",
                    isPresented: $invoicePdfViewModel.showAlert
                ) {
                    Button("OK", role: .cancel) {}
                }.onChange(of: invoicePdfViewModel.showAlert) {
                    if $0 == false {
                        invoicePdfViewModel.onOkPress()
                    }
                }.disabled(invoicePdfViewModel.sendEmailFetchable.state.isLoading)
            }
        } else {
            Text("Navigation route params missing or invalid")
        }
    }
}

#Preview {
    InvoicePdfView()
        .environmentObject(
            NavigationStack(
                InvoicePdfView(),
                params: InvoiceFormViewDTO(
                    invoiceNumber: "1",
                    fiscalNumber: "1",
                    amountEuro: "1",
                    amountKM: "1"
                )
            )
        )
        .environmentObject(
            InvoicePdfViewModel(
                msGraphHttpClient: HttpClientMock(),
                config: ConfigMock()
            )
        )
}
