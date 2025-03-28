import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "歡迎使用生命規劃師",
            description: "讓我們一起規劃你的人生藍圖",
            imageName: "star.fill"
        ),
        OnboardingPage(
            title: "生命之輪",
            description: "透過生命之輪評估各個面向的滿意度",
            imageName: "circle.grid.cross.fill"
        ),
        OnboardingPage(
            title: "目標設定",
            description: "設定具體可行的目標，並追蹤進度",
            imageName: "target"
        ),
        OnboardingPage(
            title: "每週行動",
            description: "將目標分解為每週可執行的行動",
            imageName: "calendar"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                OnboardingPageView(page: pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Text(currentPage == pages.count - 1 ? "開始使用" : "跳過")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            , alignment: .bottom
        )
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
} 