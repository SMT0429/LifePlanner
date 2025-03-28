import SwiftUI
import Charts

// MARK: - Main View
struct OdysseyPlanView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingNewPlanSheet = false
    @State private var selectedPlan: OdysseyPlan?
    @State private var showingScoreSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.odysseyPlans) { plan in
                    PlanRow(plan: plan)
                        .onTapGesture {
                            selectedPlan = plan
                        }
                }
            }
            .navigationTitle("奧德賽計畫")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewPlanSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPlanSheet) {
                NavigationView {
                    PlanDetailView(plan: nil)
                }
            }
            .sheet(item: $selectedPlan) { plan in
                NavigationView {
                    PlanDetailView(plan: plan)
                }
            }
        }
    }
}

struct PlanRow: View {
    let plan: OdysseyPlan
    
    var body: some View {
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
        .padding(.vertical, 4)
    }
}

// MARK: - Plan Detail View
struct PlanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    let plan: OdysseyPlan?
    
    @State private var title: String
    @State private var description: String
    @State private var selectedYearIndex = 0
    @State private var newGoal = ""
    @State private var newMilestone = ""
    @State private var newAction = ""
    @State private var showingScoreSheet = false
    @State private var showingHistorySheet = false
    
    init(plan: OdysseyPlan?) {
        self.plan = plan
        _title = State(initialValue: plan?.title ?? "")
        _description = State(initialValue: plan?.description ?? "")
    }
    
    var body: some View {
        Form {
            basicInfoSection
            yearlyPlanSection
            actionButtons
        }
        .navigationTitle(plan == nil ? "新建計畫" : "編輯計畫")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    savePlan()
                }
            }
        }
        .sheet(isPresented: $showingScoreSheet) {
            if let plan = plan {
                PlanScoreView(plan: plan)
            }
        }
        .sheet(isPresented: $showingHistorySheet) {
            if let plan = plan {
                PlanHistoryView(plan: plan)
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("基本資訊")) {
            TextField("標題", text: $title)
            TextEditor(text: $description)
                .frame(height: 100)
        }
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
            
            ForEach(currentYearlyPlan.goals) { goal in
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
            
            ForEach(currentYearlyPlan.milestones) { milestone in
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
            
            ForEach(currentYearlyPlan.actions) { action in
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
            if let plan = plan {
                Button("評分計畫") {
                    showingScoreSheet = true
                }
                
                Button("查看歷史") {
                    showingHistorySheet = true
                }
            }
        }
    }
    
    private var currentYearlyPlan: YearlyPlan {
        plan?.yearlyPlans[selectedYearIndex] ?? YearlyPlan()
    }
    
    private func addGoal() {
        let newPlanItem = PlanItem(content: newGoal)
        var updatedYearlyPlan = currentYearlyPlan
        updatedYearlyPlan.goals.append(newPlanItem)
        updateYearlyPlan(updatedYearlyPlan)
        newGoal = ""
    }
    
    private func addMilestone() {
        let newPlanItem = PlanItem(content: newMilestone)
        var updatedYearlyPlan = currentYearlyPlan
        updatedYearlyPlan.milestones.append(newPlanItem)
        updateYearlyPlan(updatedYearlyPlan)
        newMilestone = ""
    }
    
    private func addAction() {
        let newPlanItem = PlanItem(content: newAction)
        var updatedYearlyPlan = currentYearlyPlan
        updatedYearlyPlan.actions.append(newPlanItem)
        updateYearlyPlan(updatedYearlyPlan)
        newAction = ""
    }
    
    private func updateYearlyPlan(_ updatedPlan: YearlyPlan) {
        guard let existingPlan = plan else { return }
        var updatedYearlyPlans = existingPlan.yearlyPlans
        updatedYearlyPlans[selectedYearIndex] = updatedPlan
        dataManager.updateOdysseyPlan(
            existingPlan,
            title: title,
            description: description,
            yearlyPlans: updatedYearlyPlans
        )
    }
    
    private func savePlan() {
        if let existingPlan = plan {
            dataManager.updateOdysseyPlan(
                existingPlan,
                title: title,
                description: description,
                yearlyPlans: existingPlan.yearlyPlans
            )
        } else {
            let newPlan = OdysseyPlan(
                title: title,
                description: description
            )
            dataManager.addOdysseyPlan(newPlan)
        }
        dismiss()
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
                    dataManager.updateOdysseyPlanScore(plan.id, scores: scores, notes: notes)
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

#Preview {
    OdysseyPlanView()
        .environmentObject(DataManager())
} 