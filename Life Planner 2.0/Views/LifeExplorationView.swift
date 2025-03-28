import SwiftUI

struct LifeExplorationView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("探索方式", selection: $selectedTab) {
                Text("生命之輪").tag(0)
                Text("奧德賽計畫").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                LifeWheelView()
            } else {
                OdysseyPlanView()
            }
        }
        .navigationTitle("生命探索")
    }
}

#Preview {
    NavigationStack {
        LifeExplorationView()
            .environmentObject(DataManager())
    }
} 