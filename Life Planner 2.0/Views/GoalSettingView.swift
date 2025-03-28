import SwiftUI
import Foundation

struct GoalSettingView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingNewGoal = false
    
    var body: some View {
        NavigationView {
            List {
                if let profile = dataManager.userProfile {
                    ForEach(profile.goals) { goal in
                        NavigationLink(destination: GoalDetailView(goal: goal)) {
                            GoalRow(goal: goal)
                        }
                    }
                }
            }
            .navigationTitle("目標設定")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewGoal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewGoal) {
                NewGoalView()
            }
        }
    }
}

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(goal.title)
                .font(.headline)
            
            Text(goal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: goal.progress)
                .tint(.blue)
            
            HStack {
                Text(goal.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var title = ""
    @State private var description = ""
    @State private var category: Goal.Category = .career
    @State private var weeklyActions: [Goal.WeeklyAction] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標資訊")) {
                    TextField("標題", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    Picker("類別", selection: $category) {
                        ForEach(Goal.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("每週行動")) {
                    ForEach($weeklyActions) { $action in
                        HStack {
                            Text("第\(action.weekNumber)週")
                            TextField("行動內容", text: $action.action)
                        }
                    }
                    
                    Button(action: {
                        weeklyActions.append(Goal.WeeklyAction(weekNumber: weeklyActions.count + 1, action: ""))
                    }) {
                        Label("新增行動", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("新增目標")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("儲存") {
                    saveGoal()
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description,
            targetDate: Date().addingTimeInterval(12 * 7 * 24 * 60 * 60), // 12週後
            category: category
        )
        var newGoal = goal
        newGoal.weeklyActions = weeklyActions
        dataManager.addGoal(newGoal)
        dismiss()
    }
}

struct GoalDetailView: View {
    let goal: Goal
    @State private var showingEdit = false
    
    var body: some View {
        List {
            Section(header: Text("目標資訊")) {
                Text(goal.title)
                    .font(.headline)
                Text(goal.description)
                    .font(.body)
                Text(goal.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("進度")) {
                ProgressView(value: goal.progress)
                    .tint(.blue)
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("每週行動")) {
                ForEach(goal.weeklyActions) { action in
                    VStack(alignment: .leading) {
                        Text("第\(action.weekNumber)週")
                            .font(.headline)
                        Text(action.action)
                            .font(.body)
                    }
                }
            }
        }
        .navigationTitle("目標詳情")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEdit = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditGoalView(goal: goal)
        }
    }
}

struct EditGoalView: View {
    let goal: Goal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var title: String
    @State private var description: String
    @State private var category: Goal.Category
    @State private var weeklyActions: [Goal.WeeklyAction]
    
    init(goal: Goal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _category = State(initialValue: goal.category)
        _weeklyActions = State(initialValue: goal.weeklyActions)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標資訊")) {
                    TextField("標題", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    Picker("類別", selection: $category) {
                        ForEach(Goal.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("每週行動")) {
                    ForEach($weeklyActions) { $action in
                        HStack {
                            Text("第\(action.weekNumber)週")
                            TextField("行動內容", text: $action.action)
                        }
                    }
                    
                    Button(action: {
                        weeklyActions.append(Goal.WeeklyAction(weekNumber: weeklyActions.count + 1, action: ""))
                    }) {
                        Label("新增行動", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("編輯目標")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("儲存") {
                    saveGoal()
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func saveGoal() {
        var updatedGoal = goal
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.category = category
        updatedGoal.weeklyActions = weeklyActions
        dataManager.updateGoal(updatedGoal)
        dismiss()
    }
} 