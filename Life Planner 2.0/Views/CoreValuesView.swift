import SwiftUI

struct CoreValuesView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var draggedCard: ValueCard?
    @State private var showingResetAlert = false
    @State private var selectedCategory: ValueCard.Category = .unassigned
    @State private var showingGuide = true
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingGuide {
                    guideView
                }
                
                // 分類選擇器
                Picker("分類", selection: $selectedCategory) {
                    ForEach([ValueCard.Category.unassigned,
                            .important, .neutral,
                            .unimportant, .core], id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 階段提示
                stagePromptView
                    .padding(.horizontal)
                
                // 卡片網格
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dataManager.valueCards.filter { $0.category == selectedCategory }) { card in
                            ValueCardView(card: card)
                                .onDrag {
                                    self.draggedCard = card
                                    return NSItemProvider(object: card.id.uuidString as NSString)
                                }
                        }
                    }
                    .padding()
                }
                
                // 分類區域
                if selectedCategory == .unassigned {
                    HStack(spacing: 0) {
                        CategoryDropZone(category: .important, prompt: "對我來說很重要\n拖放至此")
                        CategoryDropZone(category: .neutral, prompt: "還好，不確定\n拖放至此")
                        CategoryDropZone(category: .unimportant, prompt: "不太重要\n拖放至此")
                    }
                    .frame(height: 120)
                } else if selectedCategory == .important {
                    CategoryDropZone(category: .core, prompt: "這是我的核心價值觀\n拖放至此")
                        .frame(height: 120)
                }
                
                // 進度提示
                progressView
                    .padding()
            }
            .navigationTitle("價值觀篩選")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingGuide.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        
                        Button {
                            showingResetAlert = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
            .alert("重新開始", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("確定", role: .destructive) {
                    dataManager.resetValueCards()
                }
            } message: {
                Text("確定要重新開始篩選嗎？所有已分類的卡片將會重置。")
            }
        }
    }
    
    private var guideView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("價值觀卡片篩選遊戲")
                .font(.headline)
            
            Text("第一階段：將20張卡片分類到「重要」、「普通」、「不重要」三個區域")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            Text("第二階段：從「重要」類別中，選出5-10張最重要的核心價值觀")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            Text("最終階段：檢視你的核心價值觀，作為生活決策的指南")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            Button("開始篩選") {
                showingGuide = false
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding()
    }
    
    private var stagePromptView: some View {
        HStack {
            if selectedCategory == .unassigned {
                Text("第一階段：請將卡片拖放到下方對應的區域")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if selectedCategory == .important {
                Text("第二階段：從重要的卡片中選出5-10張核心價值觀")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if selectedCategory == .core {
                Text("最終階段：這些是你的核心價值觀")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let unassignedCount = dataManager.valueCards.filter { $0.category == .unassigned }.count
            let importantCount = dataManager.valueCards.filter { $0.category == .important }.count
            let coreCount = dataManager.valueCards.filter { $0.category == .core }.count
            
            if selectedCategory == .unassigned {
                Text("還有 \(unassignedCount) 張卡片待分類")
            } else if selectedCategory == .important {
                if coreCount < 5 {
                    Text("請至少選擇 \(5 - coreCount) 張核心價值觀")
                } else if coreCount > 10 {
                    Text("已超出建議數量，請減少 \(coreCount - 10) 張")
                } else {
                    Text("已選擇 \(coreCount) 張核心價值觀")
                }
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}

struct ValueCardView: View {
    let card: ValueCard
    
    var body: some View {
        VStack(spacing: 8) {
            Text(card.name)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(card.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(height: 100)
        .padding()
        .background(Color(card.category.color).opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(card.category.color), lineWidth: 2)
        )
    }
}

struct CategoryDropZone: View {
    @EnvironmentObject private var dataManager: DataManager
    let category: ValueCard.Category
    let prompt: String
    @State private var isDropTarget = false
    
    private var zoneColor: Color {
        switch category {
        case .important:
            return .green
        case .neutral:
            return .yellow
        case .unimportant:
            return .red
        default:
            return Color(category.color)
        }
    }
    
    var body: some View {
        VStack {
            Text(category.rawValue)
                .font(.headline)
                .foregroundColor(zoneColor)
            
            Spacer()
            
            Text(prompt)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            zoneColor.opacity(isDropTarget ? 0.38 : 0.22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(zoneColor, lineWidth: 2)
        )
        .cornerRadius(10)
        .onDrop(of: [.text], delegate: CategoryDropDelegateWithHighlight(category: category, dataManager: dataManager, isDropTarget: $isDropTarget))
    }
}

struct CategoryDropDelegateWithHighlight: DropDelegate {
    let category: ValueCard.Category
    let dataManager: DataManager
    @Binding var isDropTarget: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        isDropTarget = false
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        itemProvider.loadObject(ofClass: NSString.self) { string, error in
            guard let uuidString = string as? String,
                  let uuid = UUID(uuidString: uuidString) else { return }
            DispatchQueue.main.async {
                dataManager.updateCardCategory(uuid, to: category)
            }
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        isDropTarget = true
    }
    
    func dropExited(info: DropInfo) {
        isDropTarget = false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct NewCoreValueView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var name = ""
    @State private var description = ""
    @State private var priority = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("價值觀資訊")) {
                    TextField("名稱", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    Stepper("優先級：\(priority)", value: $priority, in: 1...5)
                }
            }
            .navigationTitle("新增價值觀")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("儲存") {
                    saveValue()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func saveValue() {
        let value = CoreValue(name: name, description: description, priority: priority)
        dataManager.addCoreValue(value)
        dismiss()
    }
} 