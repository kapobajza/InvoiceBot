import Foundation
import SwiftUI

protocol StackNavigationView: View {}

extension StackNavigationView {
    var eraseToAnyView: AnyView { AnyView(self) }
}

protocol RouteParams {}

struct ViewParam: Identifiable {
    let id = UUID()
    let view: AnyView
    let params: RouteParams?
}

class NavigationStack: ObservableObject {
    @Published var viewStack: [ViewParam] = []
    @Published var currentView: ViewParam

    init<V: StackNavigationView>(_ initialView: V, params: RouteParams? = nil) {
        self.currentView = ViewParam(view: initialView.eraseToAnyView, params: params)
    }

    func back() {
        if viewStack.count == 0 {
            return
        }
        let last = viewStack.count - 1

        withAnimation(.easeOut(duration: 0.3)) {
            currentView = viewStack[last]
            viewStack.remove(at: last)
        }
    }

    func push<V: StackNavigationView>(_ nextView: V, params: RouteParams? = nil) {
        withAnimation(.easeOut(duration: 0.3)) {
            viewStack.append(currentView)
            currentView = ViewParam(view: nextView.eraseToAnyView, params: params)
        }
    }

    func getParams(for viewId: UUID? = nil) -> RouteParams? {
        if let viewId = viewId {
            return viewStack.first(where: { $0.id == viewId })?.params
        } else {
            return currentView.params
        }
    }
}

struct NavigationStackRootView: View {
    @StateObject var navigationStack: NavigationStack

    init(_ initialView: any StackNavigationView) {
        _navigationStack = StateObject(wrappedValue: NavigationStack(initialView))
    }

    var body: some View {
        navigationStack
            .currentView
            .view
            .transition(.move(edge: .trailing))
            .environmentObject(navigationStack)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if !navigationStack.viewStack.isEmpty {
                        Button(action: {
                            navigationStack.back()
                        }, label: {
                            Label("back", systemImage: "chevron.left")
                        })
                    }
                }
            }
    }
}
