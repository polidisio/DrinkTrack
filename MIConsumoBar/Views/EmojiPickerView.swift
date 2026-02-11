import SwiftUI

struct EmojiCategory: Identifiable {
    let id = UUID()
    let name: String
    let emojis: [String]
}

struct EmojiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedEmoji: String
    @State private var searchText = ""
    @State private var expandedCategories: Set<String> = []
    
    private let categories: [EmojiCategory] = [
        EmojiCategory(name: "Sonrisas y Personas", emojis: [
            "😊", "😃", "😄", "😁", "😅", "😂", "🤣", "🙂", "😉", "😊",
            "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜",
            "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐",
            "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪",
            "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶",
            "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐", "😕", "😟",
            "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨",
            "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩",
            "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️",
            "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖", "👶", "👧",
            "🧒", "👦", "👩", "🧑", "👨", "👵", "👴", "👲", "👳", "🧕"
        ]),
        EmojiCategory(name: "Gestos de Manos", emojis: [
            "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤏", "✌️", "🤞", "🤟",
            "🤘", "🤙", "👈", "👉", "👆", "👇", "☝️", "👍", "👎", "✊",
            "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️",
            "💅", "🤳", "💪", "🖕", "🧠", "🦴", "👀", "👁️", "👅", "👄",
            "🦷", "👣", "💋", "💌", "💘", "💝", "💖", "💗", "💓", "💕",
            "💞", "💟", "❣️", "💔", "❤️", "🧡", "💛", "💚", "💙", "💜",
            "🖤", "🤍", "🤎", "💬", "🗯️", "💭", "💤", "💢", "💥", "💣"
        ]),
        EmojiCategory(name: "Comida y Bebidas", emojis: [
            "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍈", "🍒",
            "🍓", "🥝", "🍅", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️",
            "🥒", "🥬", "🥦", "🍄", "🥜", "🍞", "🥐", "🥖", "🥨", "🥯",
            "🥞", "🧇", "🍳", "🥘", "🍲", "🥣", "🥗", "🍿", "🥫", "🍱",
            "🍙", "🍚", "🍛", "🍜", "🍝", "🍠", "🥟", "🥡", "🥢", "🍽️",
            "🍴", "🍵", "☕", "🧃", "🥤", "🧋", "🍶", "🍺", "🍻", "🥂",
            "🍷", "🥃", "🍸", "🍹", "🧉", "🥛", "🍼", "🥫", "🍴", "🍔"
        ]),
        EmojiCategory(name: "Animales", emojis: [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
            "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒",
            "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇",
            "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜",
            "🕷️", "🕸️", "🦠", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑",
            "🦐", "🦞", "🦀", "🦆", "🦢", "🦩", "🦚", "🦜", "🐕", "🦮"
        ]),
        EmojiCategory(name: "Naturaleza", emojis: [
            "🌸", "🌺", "🌻", "🌹", "🌼", "🌷", "🌱", "🌿", "☘️", "🍀",
            "🍁", "🍂", "🍃", "🌾", "🌵", "🌴", "🌲", "🌳", "🌰", "🌼",
            "🌸", "🌺", "🌻", "🌹", "🌷", "💐", "🥀", "🍁", "🍂", "🍃",
            "🌩️", "⛈️", "🌤️", "⛅", "🌥️", "☁️", "🌦️", "🌧️", "🌨️", "🌪️",
            "🌫️", "🌬️", "🌀", "🌈", "💧", "💦", "☔", "⚡", "🔥", "💥",
            "❄️", "☃️", "⛄", "☃️", "🎄", "🎋", "🎍", "🌸", "🌺", "🌻"
        ]),
        EmojiCategory(name: "Objetos", emojis: [
            "💍", "💎", "🎁", "🎈", "🎉", "🎊", "🎋", "🎌", "🎍", "🎎",
            "🎏", "🎐", "🎑", "🧧", "🎀", "🎗", "🎟", "🎫", "🎖️", "🏅",
            "🥇", "🥈", "🥉", "⚽", "⚾", "🥏", "🥊", "🥋", "🎾", "🏐",
            "🏉", "🎱", "🏓", "🏸", "🥅", "🥙", "🥚", "🍳", "🥘", "🍽️",
            "🍴", "🥄", "🔪", "🏺", "🎃", "🎄", "🎆", "🎇", "🧨", "🎈",
            "🎉", "🎊", "🎋", "🎌", "🎍", "🎎", "🎏", "🎐", "🎑", "🧧"
        ]),
        EmojiCategory(name: "Actividades", emojis: [
            "⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🎱", "🏓",
            "🏸", "🥅", "🥊", "🥋", "🎣", "🤿", "🎽", "🎿", "⛳", "⛸️",
            "🥌", "🎷", "🎸", "🎹", "🎺", "🎻", "🥁", "🎼", "🎧", "🎤",
            "🎧", "🔊", "🔔", "🔕", "📣", "📢", "💬", "💭", "🗯️", "♠️",
            "♣️", "♥️", "♦️", "🃏", "🎴", "🀄", "🕹️", "🎰", "🎱", "🪀",
            "🪁", "🎮", "🎲", "🧩", "🎯", "🎳", "🎨", "🎭", "🎪", "🎬"
        ]),
        EmojiCategory(name: "Símbolos", emojis: [
            "⭐", "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚫", "⚪", "🟤",
            "🔘", "⭕", "❌", "❎", "✅", "✖️", "➕", "➖", "➗", "➰",
            "➿", "🔚", "🔛", "🔝", "🔜", "✔️", "☑️", "🔠", "🔡", "🔢",
            "🔣", "🔤", "©️", "®️", "™️", "🔀", "🔁", "🔂", "🔄", "🔃",
            "🎵", "🎶", "💡", "🔦", "🏮", "🪔", "📱", "📲", "💻", "⌨️",
            "🖥️", "🖨️", "🖱️", "🖲️", "💽", "💾", "💿", "📀", "📼", "📷"
        ])
    ]
    
    private var allEmojis: [String] {
        categories.flatMap { $0.emojis }
    }
    
    private var filteredEmojis: [String] {
        if searchText.isEmpty {
            return allEmojis
        }
        return allEmojis.filter { _ in
            true
        }
    }
    
    private var filteredCategories: [EmojiCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.map { category in
            EmojiCategory(name: category.name, emojis: category.emojis)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Buscar emoji...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                ForEach(filteredCategories) { category in
                    Section(header: Button(action: {
                        if expandedCategories.contains(category.name) {
                            expandedCategories.remove(category.name)
                        } else {
                            expandedCategories.insert(category.name)
                        }
                    }) {
                        HStack {
                            Text(category.name)
                                .font(.headline)
                            Spacer()
                            Image(systemName: expandedCategories.contains(category.name) ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                        }
                    }) {
                        if expandedCategories.contains(category.name) || !searchText.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                                ForEach(searchText.isEmpty ? category.emojis : category.emojis.filter { _ in true }, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 44, height: 44)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedEmoji = emoji
                                            dismiss()
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Emoji")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                for category in categories {
                    expandedCategories.insert(category.name)
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("🍺"))
}
