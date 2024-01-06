import Foundation
import SwiftUI

extension View {
  @ViewBuilder
  func lifecycle(_ viewModel: CancellableViewModel) -> some View {
    self.onDisappear {
      viewModel.onDisappear()
    }
  }
}
