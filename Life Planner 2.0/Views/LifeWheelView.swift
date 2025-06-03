import SwiftUI
import Charts

struct LifeWheelView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var selectedArea: String?
    @State private var newGoal = ""
    @State private var isShowingIntro = true
    
    private let areas = [
        "健康", "事業", "家庭", "財務",
        "學習", "社交", "休閒", "心靈"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 介紹區塊
                introSection
                
                if let profile = dataManager.userProfile {
                    radarChart(scores: profile.lifeWheelAssessment.scores)
                        .frame(height: 300)
                        .padding()
                    
                    scoresList(assessment: profile.lifeWheelAssessment)
                    
                    if let selectedArea = selectedArea {
                        goalSection(area: selectedArea, assessment: profile.lifeWheelAssessment)
                    }
                }
            }
            .padding()
        }
    }
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題
            HStack {
                Text("生命之輪")
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
                    
                    Text("生命之輪是一個視覺化工具，幫助你評估生活八大領域的滿意度，找出需要改善的方向。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 使用方式
                VStack(alignment: .leading, spacing: 12) {
                    Text("使用方式")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CommonViews.TipRow(number: "1", text: "拖動雷達圖上的點或使用滑桿來評分（0-10分）")
                        CommonViews.TipRow(number: "2", text: "點擊目標按鈕為低分領域設定改善目標")
                        CommonViews.TipRow(number: "3", text: "定期更新評分，追蹤改善進度")
                        CommonViews.TipRow(number: "4", text: "完成目標後標記，持續優化生活品質")
                    }
                }
                
                // 八大領域說明
                VStack(alignment: .leading, spacing: 12) {
                    Text("八大領域")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CommonViews.FeatureRow(
                            icon: "heart.fill",
                            title: "健康",
                            description: "身體健康、運動習慣、飲食習慣"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "briefcase.fill",
                            title: "事業",
                            description: "工作發展、職業規劃、專業技能"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "house.fill",
                            title: "家庭",
                            description: "家庭關係、親子互動、生活品質"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "dollarsign.circle.fill",
                            title: "財務",
                            description: "收入支出、理財規劃、財務目標"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "book.fill",
                            title: "學習",
                            description: "知識獲取、技能提升、個人成長"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "person.2.fill",
                            title: "社交",
                            description: "人際關係、社交活動、溝通能力"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "gamecontroller.fill",
                            title: "休閒",
                            description: "興趣愛好、娛樂活動、生活樂趣"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "sparkles",
                            title: "心靈",
                            description: "精神層面、價值觀、人生意義"
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private func radarChart(scores: [String: Double]) -> some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
            let radius = min(geometry.size.width, geometry.size.height) / 2.0 * 0.8
            
            ZStack {
                // 背景網格
                ForEach(1...5, id: \.self) { level in
                    createPolygon(center: center, radius: radius * Double(level) / 5.0, sides: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                
                // 分數線
                createPolygon(center: center, radius: radius, scores: scores, maxScore: 10.0)
                    .fill(Color.blue.opacity(0.2))
                
                createPolygon(center: center, radius: radius, scores: scores, maxScore: 10.0)
                    .stroke(Color.blue, lineWidth: 2)
                
                // 區域標籤和分數點
                ForEach(areas.indices, id: \.self) { index in
                    let area = areas[index]
                    let angle = Double(index) * .pi * 2.0 / 8.0 - .pi / 2.0
                    let score = scores[area] ?? 0
                    let point = pointOnCircle(center: center, radius: radius * score / 10.0, angle: angle)
                    
                    // 標籤
                    Text(area)
                        .font(.caption)
                        .position(
                            x: center.x + cos(angle) * (radius + 20.0),
                            y: center.y + sin(angle) * (radius + 20.0)
                        )
                    
                    // 可拖動的評分點
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .position(point)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    updateScore(for: area, at: value.location, in: geometry)
                                }
                        )
                }
            }
        }
    }
    
    private func scoresList(assessment: LifeWheelAssessment) -> some View {
        VStack(spacing: 16) {
            ForEach(areas, id: \.self) { area in
                HStack {
                    Text(area)
                        .frame(width: 60, alignment: .leading)
                    
                    Slider(
                        value: Binding(
                            get: { assessment.scores[area] ?? 0 },
                            set: { updateScore(for: area, to: $0) }
                        ),
                        in: 0...10,
                        step: 0.5
                    )
                    
                    Text(String(format: "%.1f", assessment.scores[area] ?? 0))
                        .frame(width: 40)
                    
                    Button {
                        selectedArea = selectedArea == area ? nil : area
                    } label: {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func goalSection(area: String, assessment: LifeWheelAssessment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(area)領域目標")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                TextField("新增目標（最多50字）", text: $newGoal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(assessment.goals[area]?.count ?? 0 >= 5)
                
                Button("添加") {
                    addGoal(for: area)
                }
                .disabled(newGoal.isEmpty || newGoal.count > 50 || assessment.goals[area]?.count ?? 0 >= 5)
            }
            .padding(.horizontal)
            
            if let goals = assessment.goals[area] {
                ForEach(goals) { goal in
                    HStack {
                        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goal.isCompleted ? .green : .gray)
                            .onTapGesture {
                                toggleGoal(goal, in: area)
                            }
                        
                        Text(goal.content)
                        
                        Spacer()
                        
                        Button {
                            deleteGoal(goal.id, from: area)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private func createPolygon(center: CGPoint, radius: Double, sides: Int) -> Path {
        var path = Path()
        let angle = Double.pi * 2 / Double(sides)
        
        for i in 0..<sides {
            let currentAngle = Double(i) * angle - .pi / 2
            let point = pointOnCircle(center: center, radius: radius, angle: currentAngle)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func createPolygon(center: CGPoint, radius: Double, scores: [String: Double], maxScore: Double) -> Path {
        var path = Path()
        
        for i in 0..<areas.count {
            let area = areas[i]
            let score = scores[area] ?? 0
            let angle = Double(i) * .pi * 2 / Double(areas.count) - .pi / 2
            let point = pointOnCircle(center: center, radius: radius * score / maxScore, angle: angle)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func pointOnCircle(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
    }
    
    private func updateScore(for area: String, at point: CGPoint, in geometry: GeometryProxy) {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let maxRadius = min(geometry.size.width, geometry.size.height) / 2 * 0.8
        let score = min(max(distance / maxRadius * 10, 0), 10)
        
        updateScore(for: area, to: score)
    }
    
    private func updateScore(for area: String, to score: Double) {
        guard var profile = dataManager.userProfile else { return }
        var scores = profile.lifeWheelAssessment.scores
        scores[area] = score
        var newAssessment = LifeWheelAssessment(scores: scores)
        newAssessment.goals = profile.lifeWheelAssessment.goals
        profile.lifeWheelAssessment = newAssessment
        dataManager.updateProfile(profile)
    }
    
    private func addGoal(for area: String) {
        guard var profile = dataManager.userProfile,
              !newGoal.isEmpty,
              newGoal.count <= 50,
              profile.lifeWheelAssessment.goals[area]?.count ?? 0 < 5 else { return }
        
        let goal = LifeWheelGoal(content: newGoal)
        profile.lifeWheelAssessment.addGoal(goal, for: area)
        dataManager.updateProfile(profile)
        newGoal = ""
    }
    
    private func toggleGoal(_ goal: LifeWheelGoal, in area: String) {
        guard var profile = dataManager.userProfile else { return }
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        profile.lifeWheelAssessment.updateGoal(updatedGoal, for: area)
        dataManager.updateProfile(profile)
    }
    
    private func deleteGoal(_ goalId: UUID, from area: String) {
        guard var profile = dataManager.userProfile else { return }
        profile.lifeWheelAssessment.deleteGoal(goalId, from: area)
        dataManager.updateProfile(profile)
    }
}

#Preview {
    LifeWheelView()
        .environmentObject(DataManager())
} 