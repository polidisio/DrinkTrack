import SwiftUI

let emojiNames: [String: String] = [
    "🍺": "cerveza beer",
    "🍻": "cerveza jarra beer mug",
    "🥂": "copas brindar champagne",
    "🍷": "vino wine",
    "🥃": "whisky bourbon",
    "🍸": "cóctel cocktail",
    "🍹": "cóctel tropical",
    "🧉": "mate",
    "☕": "café coffee",
    "🧃": "zumo juice",
    "🥤": "refresco soda",
    "🧋": "bubble tea",
    "🍶": "sake",
    "🥛": "leche milk",
    "🍼": "biberón",
    "🍔": "hamburguesa burger",
    "🍕": "pizza",
    "🌮": "taco",
    "🍟": "patatas fries",
    "🍿": "palomitas popcorn",
    "🥨": "galleta pretzel",
    "🧀": "queso cheese",
    "🥗": "ensalada salad",
    "🍝": "pasta",
    "🍣": "sushi",
    "🥘": "paella",
    "🍲": "guiso stew",
    "🍏": "manzana green apple",
    "🍎": "manzana red apple",
    "🍐": "pera pear",
    "🍊": "naranja orange",
    "🍋": "limón lemon",
    "🍌": "plátano banana",
    "🍉": "sandía watermelon",
    "🍇": "uvas grapes",
    "🍓": "fresa strawberry",
    "🍒": "cereza cherry",
    "🥝": "kiwi",
    "🍅": "tomato tomato",
    "💶": "euro dinero money cash",
    "💰": "dinero money cash",
    "📊": "gráfico chart",
    "📱": "teléfono phone",
    "👤": "persona user",
    "👥": "grupo people",
    "🍾": "champán champagne cava",
    "🍵": "té verde tea",
    "🌭": "perrito hotdog",
    "🥪": "bocadillo sandwich",
    "🥐": "croissant",
    "🥯": "bagel",
    "🥞": "crepes pancakes",
    "🍰": "tarta pastel cake",
    "🧁": "cupcake",
    "🍩": "dona donut",
    "🍪": "galleta cookie",
    "🍫": "chocolate",
    "🍬": "caramelo candy",
    "🍭": "piruleta lollipop",
]

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
        
        let searchLower = searchText.lowercased()
        
        return categories.compactMap { category in
            let filteredEmojis = category.emojis.filter { emoji in
                guard let name = emojiNames[emoji] else { return false }
                return name.contains(searchLower)
            }
            
            if filteredEmojis.isEmpty {
                return nil
            }
            
            return EmojiCategory(name: category.name, emojis: filteredEmojis)
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
            .navigationTitle("emoji_picker_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("cerrar_button") {
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
