// Source: https://gist.github.com/shaps80/8ee53f7e3f07e3cf44f2331775edff98

import SwiftUI
import LinkPresentation
import CoreServices

struct ActivityView: UIViewControllerRepresentable {

    private let applicationActivities: [UIActivity]?
    private let completion: UIActivityViewController.CompletionWithItemsHandler?
    
    @Binding var activityItem: Any
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, item: Binding<Any>, activities: [UIActivity]? = nil, onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        _isPresented = isPresented
        _activityItem = item
        applicationActivities = activities
        completion = onComplete
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        ActivityViewControllerWrapper(isPresented: $isPresented, activityItem: $activityItem, applicationActivities: applicationActivities, onComplete: completion)
    }

    func updateUIViewController(_ uiViewController: ActivityViewControllerWrapper, context: Context) {
        uiViewController.activityItem = $activityItem
        uiViewController.isPresented = $isPresented
        uiViewController.completion = completion
        uiViewController.updateState()
    }

}

final class ActivityViewControllerWrapper: UIViewController {

    var activityItem: Binding<Any>
    var applicationActivities: [UIActivity]?
    var isPresented: Binding<Bool>
    var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(isPresented: Binding<Bool>, activityItem: Binding<Any>, applicationActivities: [UIActivity]? = nil, onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        self.activityItem = activityItem
        self.applicationActivities = applicationActivities
        self.isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        let isActivityPresented = (UIViewController.topmostController is UIActivityViewController) ||
            UIViewController.topmostController?.presentedViewController != nil

        if isActivityPresented != isPresented.wrappedValue {
            if !isActivityPresented {
                let controller = UIActivityViewController(activityItems: [activityItem.wrappedValue], applicationActivities: applicationActivities)
                controller.popoverPresentationController?.sourceView = view
                controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
                    self?.isPresented.wrappedValue = false
                    self?.completion?(activityType, success, items, error)
                }
                UIViewController.topmostController?.present(controller, animated: true, completion: nil)
            }
        }
    }
}

struct ActivityViewTest: View {
    @State private var isActivityPresented = false
    @State private var item: Any = "Mock text"
    
    var body: some View {
        return Button("Share") {
            self.isActivityPresented = true
        }.background(ActivityView(isPresented: $isActivityPresented, item: $item))
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityViewTest()
            .previewDevice("iPhone 8 Plus")
    }
}
