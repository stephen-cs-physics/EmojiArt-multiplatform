//
//  iOS.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/14.
//

import SwiftUI

// MARK: - Abstraction

extension UIImage {
    var imageData: Data? { jpegData(compressionQuality: 1.0) }
}

struct Pasteboard {
    static var imageData: Data? {
        UIPasteboard.general.image?.imageData
    }
    static var imageURL: URL? {
        UIPasteboard.general.url?.imageURL
    }
}


// MARK: - extension

extension View {
    func paletteControlButtonStyle() -> some View {
        self
    }
    func popoverPadding() -> some View {
        self
    }
    @ViewBuilder    //only in pad -> return Navi View or self
    func wrappedInNavigationViewToMakeDismissable(_ dismiss: (() -> Void)?) -> some View {   // not a view modifier for simple
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationView {
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(dismiss)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            self
        }
    }
    
    @ViewBuilder
    func dismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        } else {
            self
        }
    }
}
