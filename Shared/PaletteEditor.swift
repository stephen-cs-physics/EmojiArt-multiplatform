//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/10.
//

import SwiftUI

struct PaletteEditor: View {
//    @State private var palette: Palette = PaletteStore(named: "Test").palette(at: 2)
    @Binding var palette: Palette   //no =, private for binding
    
    var body: some View {
        Form {
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)  //bind!!
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd) //onCommit: {  }, onEditingChanged: { began in ... }
//                .keyboardType(.webSearch)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter { $0.isEmoji }
                .removingDuplicateCharacters
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.removingDuplicateCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))] ) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 4)))
            .previewLayout(.fixed(width: 300, height: 350))
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 4)))
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
