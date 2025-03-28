import Foundation

// 價值觀卡片
struct ValueCard: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    var category: Category = .unassigned
    
    enum Category: String, Codable {
        case important = "重要"
        case neutral = "普通"
        case unimportant = "不重要"
        case unassigned = "未分類"
        case core = "核心價值觀"
        
        var color: String {
            switch self {
            case .important: return "red"
            case .neutral: return "yellow"
            case .unimportant: return "gray"
            case .unassigned: return "blue"
            case .core: return "green"
            }
        }
    }
    
    init(id: UUID = UUID(), name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

// 預設價值觀卡片數據
struct DefaultValueCards {
    static let cards: [ValueCard] = [
        ValueCard(name: "誠信", description: "做自己說過的事，對他人誠實"),
        ValueCard(name: "責任", description: "願意為自己的行為負責，信守承諾"),
        ValueCard(name: "自由", description: "能夠自主做出選擇，不受他人控制"),
        ValueCard(name: "創新", description: "勇於嘗試新事物，追求創意與改變"),
        ValueCard(name: "正義", description: "追求公平公正，維護他人權益"),
        ValueCard(name: "智慧", description: "追求知識與理解，明智決策"),
        ValueCard(name: "勇氣", description: "面對困難時保持堅強，敢於冒險"),
        ValueCard(name: "同理心", description: "能夠理解並體會他人感受"),
        ValueCard(name: "獨立", description: "能夠獨立思考和行動，不依賴他人"),
        ValueCard(name: "和諧", description: "追求人際關係的和睦與平衡"),
        ValueCard(name: "成長", description: "持續學習與進步，追求自我提升"),
        ValueCard(name: "謙遜", description: "保持謙虛的態度，願意學習"),
        ValueCard(name: "寬容", description: "能夠包容他人的不同與缺點"),
        ValueCard(name: "感恩", description: "懂得感謝他人的幫助與付出"),
        ValueCard(name: "堅持", description: "面對困難時不輕易放棄"),
        ValueCard(name: "樂觀", description: "保持積極正向的生活態度"),
        ValueCard(name: "友善", description: "善待他人，樂於助人"),
        ValueCard(name: "專注", description: "能夠專心致志完成目標"),
        ValueCard(name: "效率", description: "追求高效率的工作方式"),
        ValueCard(name: "平衡", description: "在生活各方面保持平衡"),
        // ... 後續可以繼續添加更多價值觀卡片
    ]
} 