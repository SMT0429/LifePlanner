import SwiftUI
import Charts

// MARK: - Guide Row
struct GuideRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Score Row
struct ScoreRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Main View
struct OdysseyPlanView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var editingPlanIndex: IntIdentifiable? = nil
    @State private var isPresentingNewPlan = false
    @State private var tempNewPlan = OdysseyPlan(title: "", description: "")
    @State private var isShowingIntro = true
    
    var body: some View {
        NavigationView {
            List {
                // 介紹區塊
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // 標題
                        HStack {
                            Text("奧德賽介紹")
                                .font(.title2)
                                .bold()
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isShowingIntro.toggle()
                                }
                            }) {
                                Image(systemName: isShowingIntro ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if isShowingIntro {
                            // 核心概念
                            VStack(alignment: .leading, spacing: 12) {
                                Text("核心概念")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Text("奧德賽計劃是一個長期規劃工具，幫助你設計並探索不同的人生藍圖。透過設定目標、里程碑和具體行動，讓你的夢想逐步實現。")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // 使用指南
                            VStack(alignment: .leading, spacing: 12) {
                                Text("使用指南")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    GuideRow(number: "1", text: "點擊右上角「+」新增計劃")
                                    GuideRow(number: "2", text: "設定不同生命藍圖的內容")
                                    GuideRow(number: "3", text: "定期評分並追蹤進度")
                                    GuideRow(number: "4", text: "查看歷史記錄，了解成長軌跡")
                                }
                            }
                            
                            // 五大指標說明
                            VStack(alignment: .leading, spacing: 12) {
                                Text("五大評分指標")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ScoreRow(title: "資源", description: "所需資源的充足程度")
                                    ScoreRow(title: "喜歡", description: "對計劃的熱情程度")
                                    ScoreRow(title: "自信", description: "實現計劃的信心程度")
                                    ScoreRow(title: "一致", description: "與價值觀的契合程度")
                                    ScoreRow(title: "疑問", description: "需要解決的問題數量")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 原有的計劃列表
                ForEach(dataManager.odysseyPlans.indices, id: \.self) { idx in
                    PlanRow(plan: dataManager.odysseyPlans[idx])
                        .onTapGesture {
                            editingPlanIndex = IntIdentifiable(value: idx)
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        dataManager.deleteOdysseyPlan(dataManager.odysseyPlans[index].id)
                    }
                }
            }
            .navigationTitle("奧德賽計畫")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        tempNewPlan = OdysseyPlan(title: "", description: "")
                        isPresentingNewPlan = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewPlan) {
                NavigationView {
                    PlanDetailView(
                        plan: $tempNewPlan,
                        isNew: true
                    ) { plan in
                        if isPresentingNewPlan {
                            dataManager.addOdysseyPlan(plan)
                            isPresentingNewPlan = false
                        }
                    }
                }
            }
            .sheet(item: $editingPlanIndex) { idxIdentifiable in
                let idx = idxIdentifiable.value
                NavigationView {
                    PlanDetailView(
                        plan: $dataManager.odysseyPlans[idx],
                        isNew: false
                    ) { plan in
                        dataManager.updateOdysseyPlan(
                            plan,
                            title: plan.title,
                            description: plan.description,
                            yearlyPlans: plan.yearlyPlans
                        )
                        editingPlanIndex = nil
                    }
                }
            }
            .onAppear {
                dataManager.loadOdysseyPlans()
            }
        }
    }
}

struct PlanRow: View {
    let plan: OdysseyPlan
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.title)
                        .font(.headline)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("進度：\(Int(plan.progressPercentage))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("\(plan.livedWeeks)/\(plan.totalWeeks)週")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .alert("確定要刪除這個計劃嗎？", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("刪除", role: .destructive) {
                dataManager.deleteOdysseyPlan(plan.id)
            }
        } message: {
            Text("刪除後將無法恢復")
        }
    }
}

// MARK: - Plan Detail View
struct PlanDetailView: View {
    @Binding var plan: OdysseyPlan
    var isNew: Bool
    var onSave: (OdysseyPlan) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var title: String
    @State private var description: String
    @State private var yearlyPlans: [YearlyPlan]
    @State private var selectedYearIndex = 0
    @State private var newGoal = ""
    @State private var newMilestone = ""
    @State private var newAction = ""
    @State private var showingScoreSheet = false
    @State private var showingHistorySheet = false

    init(plan: Binding<OdysseyPlan>, isNew: Bool, onSave: @escaping (OdysseyPlan) -> Void) {
        self._plan = plan
        self.isNew = isNew
        self.onSave = onSave
        _title = State(initialValue: plan.wrappedValue.title)
        _description = State(initialValue: plan.wrappedValue.description)
        _yearlyPlans = State(initialValue: plan.wrappedValue.yearlyPlans)
    }

    var body: some View {
        Form {
            Section(header: Text("基本資訊")) {
                TextField("標題", text: $title)
                TextEditor(text: $description)
            }
            yearlyPlanSection
            actionButtons
        }
        .navigationTitle(isNew ? "新建計畫" : "編輯計畫")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    savePlan()
                }
            }
        }
        .sheet(isPresented: $showingScoreSheet) {
            PlanScoreView(plan: plan)
        }
        .sheet(isPresented: $showingHistorySheet) {
            PlanHistoryView(plan: plan)
        }
    }
    
    private func savePlan() {
        var updatedPlan = plan
        updatedPlan.title = title
        updatedPlan.description = description
        updatedPlan.yearlyPlans = yearlyPlans
        
        if isNew {
            // 不再呼叫 dataManager.addOdysseyPlan，交由外部 onSave 處理
        } else {
            dataManager.updateOdysseyPlan(
                updatedPlan,
                title: updatedPlan.title,
                description: updatedPlan.description,
                yearlyPlans: updatedPlan.yearlyPlans
            )
        }
        
        onSave(updatedPlan)
        dismiss()
    }
    
    private var yearlyPlanSection: some View {
        Section(header: Text("年度計畫")) {
            yearPicker
            goalsSection
            milestonesSection
            actionsSection
        }
    }
    
    private var yearPicker: some View {
        Picker("選擇年份", selection: $selectedYearIndex) {
            ForEach(0..<5) { index in
                Text("第\(index + 1)年").tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("目標")
                .font(.headline)
            
            ForEach(yearlyPlans[selectedYearIndex].goals) { goal in
                Text("• \(goal.content)")
                    .font(.subheadline)
            }
            
            HStack {
                TextField("新增目標", text: $newGoal)
                Button(action: {
                    if !newGoal.isEmpty {
                        addGoal()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("里程碑")
                .font(.headline)
            
            ForEach(yearlyPlans[selectedYearIndex].milestones) { milestone in
                Text("• \(milestone.content)")
                    .font(.subheadline)
            }
            
            HStack {
                TextField("新增里程碑", text: $newMilestone)
                Button(action: {
                    if !newMilestone.isEmpty {
                        addMilestone()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("具體行動")
                .font(.headline)
            
            ForEach(yearlyPlans[selectedYearIndex].actions) { action in
                Text("• \(action.content)")
                    .font(.subheadline)
            }
            
            HStack {
                TextField("新增行動", text: $newAction)
                Button(action: {
                    if !newAction.isEmpty {
                        addAction()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        Section {
            if !isNew {
                Button("評分計畫") {
                    showingScoreSheet = true
                }
                
                Button("查看歷史") {
                    showingHistorySheet = true
                }
            }
        }
    }
    
    private func addGoal() {
        let newPlanItem = PlanItem(content: newGoal)
        yearlyPlans[selectedYearIndex].goals.append(newPlanItem)
        newGoal = ""
    }
    
    private func addMilestone() {
        let newPlanItem = PlanItem(content: newMilestone)
        yearlyPlans[selectedYearIndex].milestones.append(newPlanItem)
        newMilestone = ""
    }
    
    private func addAction() {
        let newPlanItem = PlanItem(content: newAction)
        yearlyPlans[selectedYearIndex].actions.append(newPlanItem)
        newAction = ""
    }
}

// MARK: - Plan History View
struct PlanHistoryView: View {
    @Environment(\.dismiss) var dismiss
    let plan: OdysseyPlan
    
    var body: some View {
        NavigationView {
            List {
                ForEach(plan.history) { history in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(history.date.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RadarChart(scores: history.scores)
                            .frame(height: 150)
                        
                        if !history.notes.isEmpty {
                            Text(history.notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("評分歷史")
            .navigationBarItems(trailing: Button("完成") { dismiss() })
        }
    }
}

// MARK: - Radar Chart
struct RadarChart: View {
    let scores: PlanScores
    
    private var chartData: [(String, Double)] {
        [
            ("資源", scores.resources),
            ("喜歡", scores.interest),
            ("自信", scores.confidence),
            ("一致", scores.consistency),
            ("疑問", scores.questions)
        ]
    }
    
    var body: some View {
        Chart {
            ForEach(chartData, id: \.0) { item in
                LineMark(
                    x: .value("指標", item.0),
                    y: .value("分數", item.1)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let strValue = value.as(String.self) {
                        Text(strValue)
                            .font(.caption)
                    }
                }
            }
        }
        .chartYScale(domain: 0...10)
    }
}

// MARK: - Plan Score View
struct PlanScoreView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let plan: OdysseyPlan
    
    @State private var scores: PlanScores
    @State private var questions: [String]
    @State private var notes: String = ""
    
    init(plan: OdysseyPlan) {
        self.plan = plan
        _scores = State(initialValue: plan.scores)
        _questions = State(initialValue: plan.questions)
        _notes = State(initialValue: plan.currentNotes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                scoreSection
                questionsSection
                notesSection
            }
            .navigationTitle("計畫評分")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    dataManager.updateOdysseyPlanScoreAndQuestions(plan.id, scores: scores, notes: notes, questions: questions)
                    dismiss()
                }
            )
        }
    }
    
    private var scoreSection: some View {
        Section(header: Text("五大指標評分")) {
            resourcesScore
            interestScore
            confidenceScore
            consistencyScore
            questionsScore
        }
    }
    
    private var resourcesScore: some View {
        VStack(alignment: .leading) {
            Text("資源")
            Slider(value: $scores.resources, in: 0...10, step: 0.5)
        }
    }
    
    private var interestScore: some View {
        VStack(alignment: .leading) {
            Text("喜歡程度")
            Slider(value: $scores.interest, in: 0...10, step: 0.5)
        }
    }
    
    private var confidenceScore: some View {
        VStack(alignment: .leading) {
            Text("自信程度")
            Slider(value: $scores.confidence, in: 0...10, step: 0.5)
        }
    }
    
    private var consistencyScore: some View {
        VStack(alignment: .leading) {
            Text("一致性")
            Slider(value: $scores.consistency, in: 0...10, step: 0.5)
        }
    }
    
    private var questionsScore: some View {
        VStack(alignment: .leading) {
            Text("疑問")
            Slider(value: $scores.questions, in: 0...10, step: 0.5)
        }
    }
    
    private var questionsSection: some View {
        Section(header: Text("計畫疑問")) {
            ForEach(questions.indices, id: \.self) { index in
                TextField("輸入疑問", text: $questions[index])
            }
            
            Button("添加疑問") {
                questions.append("")
            }
        }
    }
    
    private var notesSection: some View {
        Section(header: Text("評分筆記")) {
            TextEditor(text: $notes)
                .frame(height: 100)
        }
    }
}

struct IntIdentifiable: Identifiable {
    let value: Int
    var id: Int { value }
}

#Preview {
    OdysseyPlanView()
        .environmentObject(DataManager())
} 
