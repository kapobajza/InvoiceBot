import AppKit
import Combine
import Foundation

class InvoicePdfViewModel: CancellableViewModel {
    @Published var alertMessage: String? = nil
    @Published var showAlert: Bool = false

    @Published var sendEmailFetchable = Fetchable<AnyDecodable?>(
        key: FetchableCacheKey("send-email"),
        options: FetchableOptions(cacheTime: 0.0)
    )

    private let msGraphHttpClient: HttpClientProtocol
    private let config: ConfigProtocol

    init(
        msGraphHttpClient: HttpClientProtocol,
        config: ConfigProtocol
    ) {
        self.msGraphHttpClient = msGraphHttpClient
        self.config = config
        super.init()
        setupObservation(for: sendEmailFetchable)
        sendEmailFetchable.$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state.status {
                case .loading:
                    self.showAlert = false
                case .error:
                    self.showAlert = true
                    self.alertMessage = state.error?.localizedDescription
                case .success:
                    self.showAlert = true
                    self.alertMessage = "Invoice sent successfully"
                default:
                    break
                }
            }.store(in: &cancellables)
    }

    func sendPdfAsMail(_ data: Data, invoiceFormData: InvoiceFormViewDTO) {
        let month = String(format: "%02d", Calendar.current.component(.month, from: Date()))
        let year = Calendar.current.component(.year, from: Date())

        sendEmailFetchable.fetchData {
            let emailRecipients = extractEmailRecipients(self.config.emailRecipients)
            let sendMailPublishers = emailRecipients
                .map { emailRecipient in
                    let publisher: AnyPublisher<AnyDecodable?, Error> = self.msGraphHttpClient
                        .post(
                            route: "/me/sendMail",
                            body: HttpRequestBody(
                                encodable: MSEmail(
                                    message: MSEmailMessage(
                                        subject: "Invoice \(month)/\(year)",
                                        body: MSEmailBody(
                                            contentType: "Text",
                                            content: "This message is auto-generated.\n\nBest regards, Faruk"
                                        ),
                                        toRecipients: emailRecipient.to,
                                        ccRecipients: emailRecipient.cc,
                                        attachments: [
                                            MSAttachment(
                                                odataType: "#microsoft.graph.fileAttachment",
                                                name: "\(self.config.companyName)-invoice-\(month)-\(year).pdf",
                                                contentType: "application/pdf",
                                                contentBytes: data.base64EncodedString()
                                            )
                                        ]
                                    )
                                )
                            )
                        )

                    return publisher
                }

            let invoice = Invoice(invoiceFormData)
            let jsonRepresentation = invoice.incrementValues().jsonRepresentation()!

            let updateInvoiceDataPublisher: AnyPublisher<AnyDecodable?, Error> = self
                .msGraphHttpClient
                .put(
                    route: "/me/drive/items/\(self.config.oneDriveItemId)/content",
                    body: HttpRequestBody(data: jsonRepresentation)
                )

            return Publishers.MergeMany(sendMailPublishers)
                .flatMap { _ in
                    updateInvoiceDataPublisher
                }
                .handleEvents(receiveCompletion: { completion in
                    if case .finished = completion {
                        FetchableCache.shared.clearByKey(FetchableCacheKey("invoice-form-data"))
                    }
                }).eraseToAnyPublisher()
        }.store(in: &cancellables)
    }

    func onOkPress() {
        DispatchQueue.main.async {
            self.showAlert = false
        }
    }
}
