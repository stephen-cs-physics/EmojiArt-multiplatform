//
//  ContentView.swift
//  Shared
//
//  Created by stephen on 2022/05/14.
//


import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.stephen.ios.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument
{
    static var readableContentTypes = [UTType.emojiart]
    static var writeableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {    //When model is change
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Background
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            //MARK: - [Way 2] Publisher: fetch background image
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlResponse) in UIImage(data: data) }
                .replaceError(with: nil)    //error -> nil. <1> if not exist
                .receive(on: DispatchQueue.main)    //fix below purple error
            
            backgroundImageFetchCancellable = publisher
//                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
//                .sink(  //                                    <1> replaceError is not exist
//                    receiveCompletion: { result in
//                    switch result {
//                    case .finished:
//                        print("sucess!")
//                    case .failure(let error):
//                        print("failed: error = \(error)")
//                    }
//                },
//                      receiveValue: { [weak self] image in
//                          self?.backgroundImage = image
//                          self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)}
//                )
            
                .sink { [weak self] image in
                    self?.backgroundImage = image       //purple ERROR: doing things off the main queue
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
            
            
            //MARK: - [Way 1] GCD Multi thread: fetch background image
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)   //ignore error: try? Data(~)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) { // check user's not drag other images while fetching
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)    //purple ERROR: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
//                            //self.backgroundImage : cause it's in Closure. -> held in the heap! <NOOO!
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add\(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Move", with: undoManager) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Scale", with: undoManager) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    // MARK: - Undo  (undoManager is in the VIEW)
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {   //redo
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
