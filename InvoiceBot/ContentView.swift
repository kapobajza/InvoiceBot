import AppKit
import MSAL
import SwiftUI
import UserNotifications
import WebKit

struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack {
            if loginViewModel.acquireTokenSilentlyFetchable.state.isIdle
                || loginViewModel.acquireTokenSilentlyFetchable.state.isLoading
            {
                ProgressView()
            } else if loginViewModel.isLoggedIn == true {
                NavigationStackRootView(InvoiceFormView())
            } else {
                LoginView()
            }
        }
        .padding()
        .onAppear(perform: {
            loginViewModel.initSession()
        })
        .lifecycle(loginViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(
                LoginViewModel(
                    msGraphHttpClient: HttpClientMock(),
                    msAuth: MSAuthMock(),
                    storage: StorageMock()
                )
            )
    }
}
