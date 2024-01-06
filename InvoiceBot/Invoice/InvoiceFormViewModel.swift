import Combine
import Foundation

class InvoiceFormViewModel: CancellableViewModel {
    @Published var invoiceDataFetchable = Fetchable<InvoiceFormViewDTO>(
        key: FetchableCacheKey("invoice-form-data")
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

        setupObservation(for: invoiceDataFetchable)
    }

    func getInvoiceFormData() {
        invoiceDataFetchable.fetchData {
            let publisher: AnyPublisher<Invoice?, Error> = self.msGraphHttpClient
                .get(route: "/me/drive/items/\(self.config.oneDriveItemId)/content")

            return
                publisher
                    .map { data in
                        InvoiceFormViewDTO(data!)
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        .store(in: &cancellables)
    }

    func generateInvoicePdfPreview(_ data: InvoiceFormViewDTO) {
        print("data: \(data)")
    }
}
