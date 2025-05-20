import Foundation

struct OdysseyPlan: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var yearlyPlans: [YearlyPlan]
    var scores: PlanScores
    var questions: [String]
    var challenges: [String]
    var resources: [String]
    var risks: [String]
    var history: [PlanHistory]
    var currentNotes: String
    
    var progressPercentage: Double {
        let totalWeeks = 5 * 52 // 5年
        return Double(livedWeeks) / Double(totalWeeks) * 100
    }
    
    var livedWeeks: Int {
        // 這裡可以根據實際需求計算已過週數
        return 0
    }
    
    var totalWeeks: Int {
        return 5 * 52 // 5年
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        yearlyPlans: [YearlyPlan] = Array(repeating: YearlyPlan(), count: 5),
        scores: PlanScores = PlanScores(),
        questions: [String] = [],
        challenges: [String] = [],
        resources: [String] = [],
        risks: [String] = [],
        history: [PlanHistory] = [],
        currentNotes: String = ""
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.yearlyPlans = yearlyPlans
        self.scores = scores
        self.questions = questions
        self.challenges = challenges
        self.resources = resources
        self.risks = risks
        self.history = history
        self.currentNotes = currentNotes
    }
}

struct YearlyPlan: Codable {
    var goals: [PlanItem]
    var milestones: [PlanItem]
    var actions: [PlanItem]
    
    init(goals: [PlanItem] = [], milestones: [PlanItem] = [], actions: [PlanItem] = []) {
        self.goals = goals
        self.milestones = milestones
        self.actions = actions
    }
}

struct PlanItem: Identifiable, Codable {
    let id: UUID
    var content: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), content: String, isCompleted: Bool = false) {
        self.id = id
        self.content = content
        self.isCompleted = isCompleted
    }
}

struct PlanScores: Codable {
    var resources: Double
    var interest: Double
    var confidence: Double
    var consistency: Double
    var questions: Double
    
    init(
        resources: Double = 0,
        interest: Double = 0,
        confidence: Double = 0,
        consistency: Double = 0,
        questions: Double = 0
    ) {
        self.resources = resources
        self.interest = interest
        self.confidence = confidence
        self.consistency = consistency
        self.questions = questions
    }
}

struct PlanHistory: Identifiable, Codable {
    let id: UUID
    let date: Date
    let scores: PlanScores
    let notes: String
    
    init(id: UUID = UUID(), date: Date = Date(), scores: PlanScores, notes: String = "") {
        self.id = id
        self.date = date
        self.scores = scores
        self.notes = notes
    }
}

// 計畫類型枚舉
enum PlanType: String, Codable, CaseIterable {
    case dream = "夢想版"
    case reality = "現實版"
    case adventure = "冒險版"
    
    var description: String {
        switch self {
        case .dream:
            return "最理想的人生藍圖"
        case .reality:
            return "最務實的人生藍圖"
        case .adventure:
            return "最具挑戰的人生藍圖"
        }
    }
    
    var icon: String {
        switch self {
        case .dream:
            return "sparkles"
        case .reality:
            return "checkmark.circle"
        case .adventure:
            return "map"
        }
    }
} 