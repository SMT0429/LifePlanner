import SwiftUI

struct LifeProgressOverview: View {
    let profile: UserProfile

    var body: some View {
        let calculator = LifeCalculator(
            birthDate: profile.birthDate,
            currentDate: Date(),
            expectedLifespan: profile.expectedLifespan
        )
        VStack(alignment: .leading, spacing: 12) {
            Text("生命進度")
                .font(.headline)
            LifeProgressBar(progress: calculator.progressPercentage)
            HStack {
                Text("0歲")
                Spacer()
                Text("\(profile.expectedLifespan)歲")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
} 