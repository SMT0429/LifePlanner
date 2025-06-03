import SwiftUI

enum CommonViews {
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
} 