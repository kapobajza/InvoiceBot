import SwiftUI

struct BlueButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(Color.white)
      .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
      .cornerRadius(6.0)
      .font(.headline)
  }
}

struct LoginView: View {
  @EnvironmentObject var loginViewModel: LoginViewModel

  var body: some View {
    VStack(
      alignment: .center,
      content: {
        Text("Sign in to Invoice Bot")
          .font(.title)
          .padding(
            EdgeInsets(
              top: 16,
              leading: 16,
              bottom: 32,
              trailing: 16
            ))

        Button(action: loginViewModel.signInWithMicrosoft) {
          HStack {
            if loginViewModel.acquireTokenFetchable.state.isLoading == true {
              ProgressView()
                .scaleEffect(0.5)
                .progressViewStyle(
                  CircularProgressViewStyle(tint: .white)
                )
            }
            Text("Sign in using Microsoft")
              .padding(8)
          }
        }
        .buttonStyle(BlueButtonStyle())
        .disabled(loginViewModel.acquireTokenFetchable.state.isLoading)
      }
    )
    .padding()
    .lifecycle(loginViewModel)
  }
}

#Preview {
  LoginView()
    .environmentObject(
      LoginViewModel(
        msGraphHttpClient: HttpClientMock(),
        msAuth: MSAuthMock(),
        storage: StorageMock()
      )
    )
}
