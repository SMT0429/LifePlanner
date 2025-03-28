import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var selectedTab = 0
    @State private var showingOnboarding = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LifeCalculatorView()
                .tabItem {
                    Label("壽命計算", systemImage: "clock.fill")
                }
                .tag(0)
            
            CoreValuesView()
                .tabItem {
                    Label("價值觀", systemImage: "star.fill")
                }
                .tag(1)
            
            LifeExplorationView()
                .tabItem {
                    Label("生命探索", systemImage: "circle.grid.3x3")
                }
                .tag(2)
            
            GoalSettingView()
                .tabItem {
                    Label("目標", systemImage: "target")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("個人", systemImage: "person.fill")
                }
                .tag(4)
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
        }
        .onAppear {
            // 設置 TabView 的外觀
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                if let profile = dataManager.userProfile {
                    Section(header: Text("個人資料")) {
                        HStack {
                            Text("姓名")
                            Spacer()
                            Text(profile.name)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("年齡")
                            Spacer()
                            Text("\(profile.age)歲")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("性別")
                            Spacer()
                            Text(profile.gender.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section(header: Text("核心價值觀")) {
                        ForEach(profile.coreValues) { value in
                            VStack(alignment: .leading) {
                                Text(value.name)
                                    .font(.headline)
                                Text(value.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("目標")) {
                        ForEach(profile.goals) { goal in
                            VStack(alignment: .leading) {
                                Text(goal.title)
                                    .font(.headline)
                                Text("進度：\(Int(goal.progress * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("個人資料")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = dataManager.userProfile {
                    EditProfileView(profile: profile)
                }
            }
        }
    }
} 