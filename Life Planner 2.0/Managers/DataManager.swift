import Foundation

// MARK: - Core Value
struct CoreValue: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var priority: Int
    var reflection: String
    
    init(id: UUID = UUID(), name: String, description: String, priority: Int, reflection: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.priority = priority
        self.reflection = reflection
    }
}

// MARK: - Goal
struct Goal: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var targetDate: Date
    var category: Category
    var progress: Double
    var weeklyActions: [WeeklyAction]
    
    init(id: UUID = UUID(), title: String, description: String, targetDate: Date, category: Category, progress: Double = 0.0, weeklyActions: [WeeklyAction] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.category = category
        self.progress = progress
        self.weeklyActions = weeklyActions
    }
    
    enum Category: String, Codable, CaseIterable {
        case health = "健康"
        case career = "事業"
        case family = "家庭"
        case finance = "財務"
        case learning = "學習"
        case social = "社交"
        case leisure = "休閒"
        case spiritual = "心靈"
    }
    
    struct WeeklyAction: Codable, Identifiable {
        let id: UUID
        var weekNumber: Int
        var action: String
        var isCompleted: Bool
        var reflection: String
        
        init(id: UUID = UUID(), weekNumber: Int, action: String, isCompleted: Bool = false, reflection: String = "") {
            self.id = id
            self.weekNumber = weekNumber
            self.action = action
            self.isCompleted = isCompleted
            self.reflection = reflection
        }
    }
}

// MARK: - Life Wheel Assessment
struct LifeWheelAssessment: Codable {
    var health: Double
    var career: Double
    var family: Double
    var finance: Double
    var learning: Double
    var social: Double
    var leisure: Double
    var spiritual: Double
    var goals: [String: [LifeWheelGoal]] // 每個領域的目標列表
    
    var scores: [String: Double] {
        get {
            [
                "健康": health,
                "事業": career,
                "家庭": family,
                "財務": finance,
                "學習": learning,
                "社交": social,
                "休閒": leisure,
                "心靈": spiritual
            ]
        }
        set {
            health = newValue["健康"] ?? 0
            career = newValue["事業"] ?? 0
            family = newValue["家庭"] ?? 0
            finance = newValue["財務"] ?? 0
            learning = newValue["學習"] ?? 0
            social = newValue["社交"] ?? 0
            leisure = newValue["休閒"] ?? 0
            spiritual = newValue["心靈"] ?? 0
        }
    }
    
    var average: Double {
        let sum = health + career + family + finance + learning + social + leisure + spiritual
        return sum / 8.0
    }
    
    init(health: Double = 0.0, career: Double = 0.0, family: Double = 0.0, finance: Double = 0.0, learning: Double = 0.0, social: Double = 0.0, leisure: Double = 0.0, spiritual: Double = 0.0) {
        self.health = health
        self.career = career
        self.family = family
        self.finance = finance
        self.learning = learning
        self.social = social
        self.leisure = leisure
        self.spiritual = spiritual
        self.goals = [:]
    }
    
    init(scores: [String: Double]) {
        self.health = scores["健康"] ?? 0
        self.career = scores["事業"] ?? 0
        self.family = scores["家庭"] ?? 0
        self.finance = scores["財務"] ?? 0
        self.learning = scores["學習"] ?? 0
        self.social = scores["社交"] ?? 0
        self.leisure = scores["休閒"] ?? 0
        self.spiritual = scores["心靈"] ?? 0
        self.goals = [:]
    }
    
    mutating func addGoal(_ goal: LifeWheelGoal, for area: String) {
        if goals[area] == nil {
            goals[area] = []
        }
        goals[area]?.append(goal)
    }
    
    mutating func updateGoal(_ goal: LifeWheelGoal, for area: String) {
        if let index = goals[area]?.firstIndex(where: { $0.id == goal.id }) {
            goals[area]?[index] = goal
        }
    }
    
    mutating func deleteGoal(_ goalId: UUID, from area: String) {
        goals[area]?.removeAll { $0.id == goalId }
    }
}

struct LifeWheelGoal: Codable, Identifiable, Equatable {
    let id: UUID
    var content: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), content: String, isCompleted: Bool = false) {
        self.id = id
        self.content = content
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    let id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var expectedLifespan: Int
    var dailyNecessaryTime: DailyTime
    var coreValues: [CoreValue]
    var lifeWheelAssessment: LifeWheelAssessment
    var goals: [Goal]
    
    enum Gender: String, Codable {
        case male = "男"
        case female = "女"
        case other = "其他"
    }
    
    struct DailyTime: Codable {
        var sleep: Double // 小時
        var work: Double
        var commute: Double
        var meals: Double
        var other: Double
        
        var total: Double {
            sleep + work + commute + meals + other
        }
        
        init() {
            self.sleep = 8
            self.work = 8
            self.commute = 1
            self.meals = 2
            self.other = 1
        }
        
        init(sleep: Double, work: Double, commute: Double, meals: Double, other: Double) {
            self.sleep = sleep
            self.work = work
            self.commute = commute
            self.meals = meals
            self.other = other
        }
    }
    
    init(id: UUID = UUID(), name: String, age: Int, gender: Gender, expectedLifespan: Int = 80, dailyNecessaryTime: DailyTime = DailyTime(), coreValues: [CoreValue] = [], lifeWheelAssessment: LifeWheelAssessment = LifeWheelAssessment(), goals: [Goal] = []) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.expectedLifespan = expectedLifespan
        self.dailyNecessaryTime = dailyNecessaryTime
        self.coreValues = coreValues
        self.lifeWheelAssessment = lifeWheelAssessment
        self.goals = goals
    }
}

// MARK: - Data Manager
class DataManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var valueCards: [ValueCard] = []
    @Published var odysseyPlans: [OdysseyPlan] = []
    
    private let valueCardsKey = "valueCards"
    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    private let plansKey = "odysseyPlans"
    
    init() {
        loadData()
        loadValueCards()
    }
    
    private func loadData() {
        if let profileData = userDefaults.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            userProfile = profile
        }
        
        if let plansData = userDefaults.data(forKey: plansKey),
           let plans = try? JSONDecoder().decode([OdysseyPlan].self, from: plansData) {
            odysseyPlans = plans
        }
    }
    
    private func saveData() {
        if let profile = userProfile,
           let profileData = try? JSONEncoder().encode(profile) {
            userDefaults.set(profileData, forKey: profileKey)
        }
        
        if let plansData = try? JSONEncoder().encode(odysseyPlans) {
            userDefaults.set(plansData, forKey: plansKey)
            userDefaults.synchronize()
            objectWillChange.send()
        }
    }
    
    private func loadValueCards() {
        if let data = UserDefaults.standard.data(forKey: valueCardsKey),
           let cards = try? JSONDecoder().decode([ValueCard].self, from: data) {
            valueCards = cards
        } else {
            // 首次使用時，載入預設卡片
            valueCards = DefaultValueCards.cards
            saveValueCards()
        }
    }
    
    private func saveValueCards() {
        if let encoded = try? JSONEncoder().encode(valueCards) {
            UserDefaults.standard.set(encoded, forKey: valueCardsKey)
            objectWillChange.send()
        }
    }
    
    // MARK: - Core Values Management
    
    func addCoreValue(_ value: CoreValue) {
        userProfile?.coreValues.append(value)
        saveData()
    }
    
    func updateCoreValue(_ value: CoreValue) {
        if let index = userProfile?.coreValues.firstIndex(where: { $0.id == value.id }) {
            userProfile?.coreValues[index] = value
            saveData()
        }
    }
    
    func deleteCoreValue(_ value: CoreValue) {
        userProfile?.coreValues.removeAll { $0.id == value.id }
        saveData()
    }
    
    // MARK: - Goals Management
    
    func addGoal(_ goal: Goal) {
        userProfile?.goals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = userProfile?.goals.firstIndex(where: { $0.id == goal.id }) {
            userProfile?.goals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        userProfile?.goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    // MARK: - Life Wheel Assessment Management
    
    func updateLifeWheelAssessment(_ assessment: LifeWheelAssessment) {
        userProfile?.lifeWheelAssessment = assessment
        saveData()
    }
    
    // MARK: - Daily Time Management
    
    func updateDailyTime(_ dailyTime: UserProfile.DailyTime) {
        userProfile?.dailyNecessaryTime = dailyTime
        saveData()
    }
    
    // MARK: - Life Expectancy Management
    
    func updateLifeExpectancy(_ years: Int) {
        userProfile?.expectedLifespan = years
        saveData()
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
    }
    
    // MARK: - Odyssey Plan Management
    
    func addOdysseyPlan(_ plan: OdysseyPlan) {
        print("新增計畫：", plan.title)
        odysseyPlans.append(plan)
        saveData()
        objectWillChange.send()
    }
    
    func updateOdysseyPlan(_ plan: OdysseyPlan, title: String, description: String, yearlyPlans: [YearlyPlan]) {
        if let index = odysseyPlans.firstIndex(where: { $0.id == plan.id }) {
            var updatedPlan = plan
            updatedPlan.title = title
            updatedPlan.description = description
            updatedPlan.yearlyPlans = yearlyPlans
            odysseyPlans[index] = updatedPlan
            saveData()
            objectWillChange.send()
            
            // 打印调试信息
            print("更新计划：", updatedPlan.title)
            print("年度计划数量：", updatedPlan.yearlyPlans.count)
            for (index, yearlyPlan) in updatedPlan.yearlyPlans.enumerated() {
                print("第\(index + 1)年：")
                print("- 目标数量：", yearlyPlan.goals.count)
                print("- 里程碑数量：", yearlyPlan.milestones.count)
                print("- 行动数量：", yearlyPlan.actions.count)
            }
        }
    }
    
    func updateOdysseyPlanScore(_ planId: UUID, scores: PlanScores, notes: String) {
        if let index = odysseyPlans.firstIndex(where: { $0.id == planId }) {
            var updatedPlan = odysseyPlans[index]
            let history = PlanHistory(
                date: Date(),
                scores: scores,
                notes: notes
            )
            updatedPlan.history.append(history)
            updatedPlan.scores = scores
            odysseyPlans[index] = updatedPlan
            saveData()
            objectWillChange.send()
        }
    }
    
    // 新增：同時更新 scores、notes、questions
    func updateOdysseyPlanScoreAndQuestions(_ planId: UUID, scores: PlanScores, notes: String, questions: [String]) {
        if let index = odysseyPlans.firstIndex(where: { $0.id == planId }) {
            var updatedPlan = odysseyPlans[index]
            let history = PlanHistory(
                date: Date(),
                scores: scores,
                notes: notes
            )
            updatedPlan.history.append(history)
            updatedPlan.scores = scores
            updatedPlan.questions = questions
            updatedPlan.currentNotes = notes
            odysseyPlans[index] = updatedPlan
            saveData()
            objectWillChange.send()
        }
    }
    
    func deleteOdysseyPlan(_ planId: UUID) {
        odysseyPlans.removeAll { $0.id == planId }
        saveData()
        objectWillChange.send()
    }
    
    func loadOdysseyPlans() {
        if let data = UserDefaults.standard.data(forKey: plansKey),
           let decoded = try? JSONDecoder().decode([OdysseyPlan].self, from: data) {
            odysseyPlans = decoded
            objectWillChange.send()
        }
    }
    
    // MARK: - Value Cards Management
    
    func updateCardCategory(_ cardId: UUID, to category: ValueCard.Category) {
        if let index = valueCards.firstIndex(where: { $0.id == cardId }) {
            valueCards[index].category = category
            saveValueCards()
        }
    }
    
    func resetValueCards() {
        valueCards = DefaultValueCards.cards
        saveValueCards()
    }
    
    func getCoreValues() -> [ValueCard] {
        valueCards.filter { $0.category == .core }
    }
} 