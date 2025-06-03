import SwiftUI

struct WelcomeView: View {
    @State private var showingMainTab = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("生命規劃師")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("讓我們一起規劃你的人生藍圖")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    CommonViews.FeatureRow(
                        icon: "circle.grid.cross.fill",
                        title: "生命之輪",
                        description: "評估你目前的生活平衡"
                    )
                    
                    CommonViews.FeatureRow(
                        icon: "target",
                        title: "目標設定",
                        description: "設定具體可行的目標"
                    )
                    
                    CommonViews.FeatureRow(
                        icon: "calendar",
                        title: "每週行動",
                        description: "將目標分解為可執行的行動"
                    )
                    
                    CommonViews.FeatureRow(
                        icon: "chart.bar.fill",
                        title: "進度追蹤",
                        description: "追蹤目標完成情況"
                    )
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    showingMainTab = true
                }) {
                    Text("開始使用")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding()
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingMainTab) {
                MainTabView()
            }
        }
    }
} 