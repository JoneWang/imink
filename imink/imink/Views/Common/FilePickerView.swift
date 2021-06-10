//
//  FilePickerView.swift
//  imink
//
//  Created by Jone Wang on 2021/6/10.
//

import Foundation
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct FilePickerView: View {
    
    let fileType: UTType
    let selected: (URL) -> ()
    
    var body: some View {
        _FilePickerView(fileType: fileType, selected: selected)
            .ignoresSafeArea()
    }
}

private struct _FilePickerView: UIViewControllerRepresentable {
    
    let fileType: UTType
    let selected: (URL) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<_FilePickerView>) {
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.zip], asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: _FilePickerView
        
        init(_ pickerController: _FilePickerView) {
            self.parent = pickerController
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selected(url)
            }
        }
    }
}

struct PickerView_Preview: PreviewProvider {
    
    static var previews: some View {
        FilePickerView(fileType: .zip) { url in
            print(url)
        }
    }
}
