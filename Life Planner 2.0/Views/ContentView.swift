import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    @State private var isShowingIntro = true
    
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
    @State private var isShowingIntro = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 歡迎區域
                    welcomeSection
                    
                    // 今日時間分配
                    // dailyTimeSection
                    
                    // 應用介紹區
                    appIntroSection
                    
                    // 快速操作區
                    quickActionsSection
                    

                }
                .padding()
            }
            .navigationTitle("LifePlanner")
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
                Text("歡迎來到首頁\(profile.name)")
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
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速操作")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                NavigationLink(destination: LifeWheelView()) {
                    QuickActionButton(
                        title: "生命之輪",
                        icon: "circle.grid.cross.fill",
                        color: .blue,
                        action: {}
                    )
                }
                
                NavigationLink(destination: CoreValuesView()) {
                    QuickActionButton(
                        title: "價值觀",
                        icon: "heart.fill",
                        color: .red,
                        action: {}
                    )
                }
                
                NavigationLink(destination: LifeCalculatorView()) {
                    QuickActionButton(
                        title: "壽命計算",
                        icon: "clock.fill",
                        color: .green,
                        action: {}
                    )
                }
                
                NavigationLink(destination: OdysseyPlanView()) {
                    QuickActionButton(
                        title: "奧德賽計劃",
                        icon: "map.fill",
                        color: .purple,
                        action: {}
                    )
                }
                
                Button {
                    showingLifespanSheet = true
                } label: {
                    QuickActionButton(
                        title: "設定",
                        icon: "gear",
                        color: .gray,
                        action: {}
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private var appIntroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題
            HStack {
                Text("生命規劃師")
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
                // 核心功能介紹
                VStack(alignment: .leading, spacing: 12) {
                    Text("核心功能")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CommonViews.FeatureRow(
                            icon: "circle.grid.cross.fill",
                            title: "生命之輪",
                            description: "評估生活各面向的滿意度，找出需要改善的領域"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "heart.fill",
                            title: "價值觀",
                            description: "探索並確立個人核心價值觀，指引人生方向"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "map.fill",
                            title: "奧德賽計劃",
                            description: "規劃5年人生藍圖，設定目標、里程碑和具體行動"
                        )
                        
                        CommonViews.FeatureRow(
                            icon: "clock.fill",
                            title: "壽命計算",
                            description: "計算生命時間，了解可支配時間，善用每分每秒"
                        )
                    }
                }
                
                // 使用建議
                VStack(alignment: .leading, spacing: 12) {
                    Text("使用建議")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CommonViews.TipRow(number: "1", text: "先完成生命之輪評估，了解現況")
                        CommonViews.TipRow(number: "2", text: "確立核心價值觀，作為決策依據")
                        CommonViews.TipRow(number: "3", text: "制定奧德賽計劃，規劃未來藍圖")
                        CommonViews.TipRow(number: "4", text: "定期檢視進度，適時調整方向")
                    }
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
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
}

struct TipRow: View {
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
