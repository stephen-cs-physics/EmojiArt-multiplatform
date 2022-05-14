//
//  macOS.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/14.
//

import SwiftUI
//MARK: - iOS -> Mac Way: #if
//#if os(iOS)
//#else
//#endif


//MARK: - iOS -> Mac Way 1: typealias

typealias UIImage = NSImage

typealias PaletteManager = EmptyView

//MARK: - iOS -> Mac Way 2: extension (iOS/Mac diff)

extension Image {
    init(uiImage: UIImage) {
        self.init(nsImage: uiImage)
    }
}


extension View {
    func wrappedInNavigationViewToMakeDismissable(_ dismiss: (() -> Void)?) -> some View {
        self
    }
    func paletteControlButtonStyle() -> some View {
        self.buttonStyle(PlainButtonStyle())
            .foregroundColor(.accentColor)
            .padding(.vertical)
    }
    func popoverPadding() -> some View {
        self.padding(.horizontal)
    }
}

//MARK: - iOS -> Mac Way 3: EmptyView struct + typealias

struct CantDoItPhotoPicker: View {
    var handlePickedImage: (UIImage?) -> Void
    
    static let isAvailable = false
    
    var body: some View {
        EmptyView()
    }
}

typealias Camera = CantDoItPhotoPicker
typealias PhotoLibrary = CantDoItPhotoPicker


//MARK: - iOS -> Mac Way 4: Abstraction

extension UIImage {
    var imageData: Data? { tiffRepresentation }
}

struct Pasteboard {
    static var imageData: Data? {
        NSPasteboard.general.data(forType: .tiff) ?? NSPasteboard.general.data(forType: .png)
    }
    static var imageURL: URL? {
        (NSURL(from: NSPasteboard.general) as URL?)?.imageURL
    }
}
