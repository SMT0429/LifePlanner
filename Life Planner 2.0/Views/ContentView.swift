import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首頁", systemImage: "house.fill")
                }
                .tag(0)
            
            OdysseyPlanView()
                .tabItem {
                    Label("奧德賽計畫", systemImage: "map.fill")
                }
                .tag(1)
            
            LifeWheelView()
                .tabItem {
                    Label("生命之輪", systemImage: "circle.grid.cross.fill")
                }
                .tag(2)
            
            CoreValuesView()
                .tabItem {
                    Label("價值觀", systemImage: "heart.fill")
                }
                .tag(3)
            
            LifeCalculatorView()
                .tabItem {
                    Label("壽命計算", systemImage: "clock.fill")
                }
                .tag(4)
        }
        .environmentObject(dataManager)
    }
}

struct HomeView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingDailyTimeSheet = false
    @State private var showingLifespanSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 歡迎區域
                    welcomeSection
                    
                    // 生命進度概覽
                    lifeProgressSection
                    
                    // 今日時間分配
                    dailyTimeSection
                    
                    // 快速操作區
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("生命規劃")
            .sheet(isPresented: $showingDailyTimeSheet) {
                NavigationView {
                    DailyTimeView()
                }
            }
            .sheet(isPresented: $showingLifespanSheet) {
                NavigationView {
                    LifespanView()
                }
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let profile = dataManager.userProfile {
                Text("你好，\(profile.name)")
                    .font(.title)
                    .bold()
                
                Text("今天是 \(Date().formatted(.dateTime.year().month().day().weekday()))")
                    .foregroundColor(.secondary)
            } else {
                Text("歡迎使用生命規劃")
                    .font(.title)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var lifeProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("生命進度")
                .font(.headline)
            
            if let profile = dataManager.userProfile {
                let progress = Double(profile.age) / Double(profile.expectedLifespan)
                LifeProgressBar(progress: progress * 100)
                
                HStack {
                    Text("\(profile.age)歲")
                    Spacer()
                    Text("\(profile.expectedLifespan)歲")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
                Text("請先設定個人資料")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var dailyTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日時間分配")
                .font(.headline)
            
            if let profile = dataManager.userProfile {
                let dailyTime = profile.dailyNecessaryTime
                let totalHours = dailyTime.sleep + dailyTime.work + dailyTime.commute + dailyTime.meals + dailyTime.other
                let remainingHours = 24 - totalHours
                
                DisposableTimeChart(
                    totalHours: 24,
                    disposableHours: remainingHours
                )
                
                HStack {
                    Text("剩餘可支配時間：\(Int(remainingHours))小時")
                        .foregroundColor(.green)
                    Spacer()
                    Button("調整") {
                        showingDailyTimeSheet = true
                    }
                }
            } else {
                Text("請先設定每日時間分配")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速操作")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "生命之輪",
                    icon: "circle.grid.cross.fill",
                    color: .blue
                ) {
                    // 導航到生命之輪
                }
                
                QuickActionButton(
                    title: "價值觀",
                    icon: "heart.fill",
                    color: .red
                ) {
                    // 導航到價值觀
                }
                
                QuickActionButton(
                    title: "壽命計算",
                    icon: "clock.fill",
                    color: .green
                ) {
                    // 導航到壽命計算
                }
                
                QuickActionButton(
                    title: "設定",
                    icon: "gear",
                    color: .gray
                ) {
                    showingLifespanSheet = true
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
        }
    }
} 