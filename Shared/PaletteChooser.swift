//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/10.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    @SceneStorage("PaletteChooser.chosenPaletteIndex")
    private var chosenPaletteIndex = 0
    
    var body: some View {
//        let palette = store.palette(at: chosenPaletteIndex)
        HStack {
            paletteControlButton
            body(for: store.palette(at: chosenPaletteIndex))
        }
        .clipped()  //for not smashing btw paletteConrolBtn & body
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1 ) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .paletteControlButtonStyle()
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
//            editing = true  // Way1: Boolean
            paletteToEdit = store.palette(at: chosenPaletteIndex)   //Way 2
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
//            editing = true
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            chosenPaletteIndex =  store.removePalette(at: chosenPaletteIndex)
        }
        #if os(iOS)
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        #endif
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go to", systemImage: "text.insert")
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)             //add this -> animation working!
        .transition(rollTransition) //not working!
//        .popover(isPresented: $editing) {     //Way 1: Boolean
//            PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
//        }
        .popover(item: $paletteToEdit) { palette in     //Way 2
            PaletteEditor(palette: $store.palettes[palette])
                .popoverPadding()
                .wrappedInNavigationViewToMakeDismissable { paletteToEdit = nil }
        }
        .sheet(isPresented: $managing) {
            PaletteManager()
        }
    }
    
//    @State private var editing = false  //Way 1: Boolean
    @State private var managing = false
    @State private var paletteToEdit: Palette?  //Way 2
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x:0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.removingDuplicateCharacters.map{ String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }    //async
                    
                }
            }
        }
    }
}


struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
