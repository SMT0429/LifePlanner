import SwiftUI

struct LifeCalculatorView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var birthDate = Date()
    @State private var currentDate = Date()
    @State private var expectedLifespan = 80
    @State private var sleepHours = 8.0
    @State private var commuteHours = 1.0
    @State private var workHours = 8.0
    @State private var selectedTab = 0
    
    private var calculator: LifeCalculator {
        LifeCalculator(
            birthDate: birthDate,
            currentDate: currentDate,
            expectedLifespan: expectedLifespan,
            dailyTime: .init(
                sleep: sleepHours,
                commute: commuteHours,
                work: workHours
            )
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 基本資料輸入
                    inputSection
                    
                    // 時間分配設定
                    timeAllocationSection
                    
                    // 分頁選擇器
                    Picker("顯示方式", selection: $selectedTab) {
                        Text("概覽").tag(0)
                        Text("時間分配").tag(1)
                        Text("生命日曆").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 分頁內容
                    switch selectedTab {
                    case 0:
                        overviewSection
                    case 1:
                        timeDistributionSection
                    case 2:
                        calendarSection
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationTitle("壽命計算")
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            DatePicker("出生日期", selection: $birthDate, displayedComponents: .date)
            
            DatePicker("當前日期", selection: $currentDate, displayedComponents: .date)
            
            Stepper("預計壽命：\(expectedLifespan)歲", value: $expectedLifespan, in: 1...120)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var timeAllocationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("每日時間分配")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("睡眠時間")
                    Slider(
                        value: Binding(
                            get: { sleepHours },
                            set: { newValue in
                                let maxValue = min(12, 24 - commuteHours - workHours)
                                sleepHours = min(newValue, maxValue)
                            }
                        ),
                        in: 4...min(12, 24 - commuteHours - workHours),
                        step: 0.5
                    )
                    Text("\(sleepHours, specifier: "%.1f")小時")
                        .frame(width: 60)
                }
                
                HStack {
                    Text("通勤時間")
                    Slider(
                        value: Binding(
                            get: { commuteHours },
                            set: { newValue in
                                let maxValue = min(6, 24 - sleepHours - workHours)
                                commuteHours = min(newValue, maxValue)
                            }
                        ),
                        in: 0...min(6, 24 - sleepHours - workHours),
                        step: 0.5
                    )
                    Text("\(commuteHours, specifier: "%.1f")小時")
                        .frame(width: 60)
                }
                
                HStack {
                    Text("工作時間")
                    Slider(
                        value: Binding(
                            get: { workHours },
                            set: { newValue in
                                let maxValue = min(16, 24 - sleepHours - commuteHours)
                                workHours = min(newValue, maxValue)
                            }
                        ),
                        in: 0...min(16, 24 - sleepHours - commuteHours),
                        step: 0.5
                    )
                    Text("\(workHours, specifier: "%.1f")小時")
                        .frame(width: 60)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // 生命進度條
            VStack(alignment: .leading, spacing: 8) {
                Text("生命進度")
                    .font(.headline)
                LifeProgressBar(progress: calculator.progressPercentage)
            }
            
            // 每日可支配時間
            VStack(alignment: .leading, spacing: 8) {
                Text("每日時間分配")
                    .font(.headline)
                DisposableTimeChart(
                    totalHours: 24,
                    disposableHours: calculator.dailyTime.disposableTime
                )
            }
            
            // 已活時間
            VStack(alignment: .leading, spacing: 8) {
                Text("已經活了")
                    .font(.headline)
                Text(calculator.livedTime.description)
                    .foregroundColor(.secondary)
            }
            
            // 剩餘時間
            VStack(alignment: .leading, spacing: 8) {
                Text("還可以活")
                    .font(.headline)
                Text(calculator.remainingTime.description)
                    .foregroundColor(.secondary)
                Text("剩餘可支配時間：\(Int(calculator.remainingDisposableTime))小時 ≈ \(Int(calculator.remainingDisposableTime / 24))天")
                    .foregroundColor(.green)
            }
            
            // 時間對比圖
            VStack(alignment: .leading, spacing: 8) {
                Text("時間對比")
                    .font(.headline)
                LifeTimeChart(
                    lived: currentDate.timeIntervalSince(birthDate),
                    remaining: Double(calculator.remainingTime.years) * 365.25 * 24 * 60 * 60
                )
                .frame(height: 100)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var timeDistributionSection: some View {
        VStack(spacing: 16) {
            // 每日時間分配圓餅圖
            VStack(alignment: .leading, spacing: 8) {
                Text("每日時間分配")
                    .font(.headline)
                TimeDistributionChart(distribution: calculator.dailyTimeDistribution)
                    .frame(height: 200)
            }
            
            // 可支配時間統計
            VStack(alignment: .leading, spacing: 8) {
                Text("可支配時間")
                    .font(.headline)
                Text("每天可自由支配：\(calculator.dailyTime.disposableTime, specifier: "%.1f")小時")
                Text("剩餘生命可支配：\(calculator.remainingDisposableTime, specifier: "%.1f")小時")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顯示剩餘可支配時間
            Text("剩餘可支配時間：\(Int(calculator.remainingDisposableTime))小時 ≈ \(Int(calculator.remainingDisposableTime / 24))天")
                .font(.headline)
                .foregroundColor(.green)
            
            // 生命日曆圖
            WeekCalendarWithTime(
                totalWeeks: calculator.totalWeeks,
                livedWeeks: calculator.livedWeeks,
                disposableHoursPerDay: calculator.dailyTime.disposableTime
            )
            
            // 圖例
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                    Text("已經活過的週數")
                        .font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 16, height: 16)
                    Text("剩餘可支配週數")
                        .font(.caption)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct DailyTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var sleepHours: Double = 8
    @State private var workHours: Double = 8
    @State private var commuteHours: Double = 1
    @State private var mealHours: Double = 2
    @State private var hygieneHours: Double = 1
    
    var body: some View {
        Form {
            Section(header: Text("每日必要時間分配")) {
                VStack(alignment: .leading) {
                    Text("睡眠：\(Int(sleepHours))小時")
                    Slider(value: $sleepHours, in: 4...12, step: 0.5)
                }
                
                VStack(alignment: .leading) {
                    Text("工作：\(Int(workHours))小時")
                    Slider(value: $workHours, in: 0...12, step: 0.5)
                }
                
                VStack(alignment: .leading) {
                    Text("通勤：\(Int(commuteHours))小時")
                    Slider(value: $commuteHours, in: 0...4, step: 0.5)
                }
                
                VStack(alignment: .leading) {
                    Text("用餐：\(Int(mealHours))小時")
                    Slider(value: $mealHours, in: 1...4, step: 0.5)
                }
                
                VStack(alignment: .leading) {
                    Text("個人衛生：\(Int(hygieneHours))小時")
                    Slider(value: $hygieneHours, in: 0.5...2, step: 0.5)
                }
            }
            
            Section {
                let totalHours = sleepHours + workHours + commuteHours + mealHours + hygieneHours
                let remainingHours = 24 - totalHours
                
                Text("總必要時間：\(Int(totalHours))小時")
                Text("剩餘時間：\(Int(remainingHours))小時")
                    .foregroundColor(remainingHours >= 0 ? .green : .red)
            }
        }
        .navigationTitle("每日必要時間")
        .navigationBarItems(trailing: Button("完成") {
            saveDailyTime()
            dismiss()
        })
        .onAppear {
            if let profile = dataManager.userProfile {
                sleepHours = profile.dailyNecessaryTime.sleep
                workHours = profile.dailyNecessaryTime.work
                commuteHours = profile.dailyNecessaryTime.commute
                mealHours = profile.dailyNecessaryTime.meals
                hygieneHours = profile.dailyNecessaryTime.other
            }
        }
    }
    
    private func saveDailyTime() {
        let dailyTime = UserProfile.DailyTime(
            sleep: sleepHours,
            work: workHours,
            commute: commuteHours,
            meals: mealHours,
            other: hygieneHours
        )
        dataManager.updateDailyTime(dailyTime)
    }
}

struct LifespanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    @State private var expectedLifespan: Int = 80
    
    var body: some View {
        Form {
            Section(header: Text("預期壽命設定")) {
                Stepper("預期壽命：\(expectedLifespan)歲", value: $expectedLifespan, in: 60...100)
            }
            
            Section {
                if let profile = dataManager.userProfile {
                    let remainingYears = expectedLifespan - profile.age
                    Text("剩餘年數：\(remainingYears)年")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("預期壽命")
        .navigationBarItems(trailing: Button("完成") {
            dataManager.updateLifeExpectancy(expectedLifespan)
            dismiss()
        })
        .onAppear {
            if let profile = dataManager.userProfile {
                expectedLifespan = profile.expectedLifespan
            }
        }
    }
} 