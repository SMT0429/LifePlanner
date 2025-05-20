import SwiftUI
import Charts

struct LifeProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(max(progress / 100, 0), 1))
                
                Text(String(format: "%.1f%%", progress))
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
        }
        .frame(height: 30)
        .cornerRadius(15)
    }
}

struct TimeDistributionChart: View {
    let distribution: [String: Double]
    
    var data: [(String, Double)] {
        distribution.map { ($0.key, $0.value) }
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                SectorMark(
                    angle: .value("時數", item.1),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.0
                )
                .foregroundStyle(by: .value("類別", item.0))
            }
        }
        .chartLegend(position: .bottom)
    }
}

struct LifeTimeChart: View {
    let lived: TimeInterval
    let remaining: TimeInterval
    
    var data: [(String, TimeInterval)] {
        [
            ("已度過", lived),
            ("剩餘", remaining)
        ]
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                BarMark(
                    x: .value("時間", item.1 / (365.25 * 24 * 60 * 60)),
                    y: .value("類別", item.0)
                )
                .foregroundStyle(by: .value("類別", item.0))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel("年")
            }
        }
    }
}

struct LifeCalendarView: View {
    let totalWeeks: Int
    let livedWeeks: Int
    let weeksPerRow: Int = 52
    
    var body: some View {
        let rows = (totalWeeks + weeksPerRow - 1) / weeksPerRow
        
        VStack(spacing: 2) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<weeksPerRow, id: \.self) { col in
                        let week = row * weeksPerRow + col
                        if week < totalWeeks {
                            Rectangle()
                                .fill(week < livedWeeks ? Color.blue : Color.gray.opacity(0.2))
                                .frame(width: 4, height: 4)
                        }
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

struct DisposableTimeChart: View {
    let totalHours: Double
    let disposableHours: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                // 可支配時間
                Rectangle()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: geometry.size.width * CGFloat(disposableHours / totalHours))
                    .overlay(
                        Text("\(Int(disposableHours))小時")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                    )
                
                // 必要時間
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat((totalHours - disposableHours) / totalHours))
                    .overlay(
                        Text("\(Int(totalHours - disposableHours))小時")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                    )
            }
        }
        .frame(height: 30)
        .cornerRadius(15)
    }
}

struct WeekCalendarWithTime: View {
    let totalWeeks: Int
    let livedWeeks: Int
    let disposableHoursPerDay: Double
    let weeksPerRow: Int = 52
    
    var body: some View {
        VStack(spacing: 16) {
            // 週曆視圖
            VStack(spacing: 2) {
                ForEach(0..<((totalWeeks + weeksPerRow - 1) / weeksPerRow), id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<weeksPerRow, id: \.self) { col in
                            let week = row * weeksPerRow + col
                            if week < totalWeeks {
                                Rectangle()
                                    .fill(week < livedWeeks ? Color.blue : Color.green.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
            }
            
            // 剩餘可支配時間統計
            VStack(alignment: .leading, spacing: 4) {
                let remainingWeeks = totalWeeks - livedWeeks
                let remainingDisposableHours = Double(remainingWeeks) * 7 * disposableHoursPerDay
                

                
                Text("每週可支配：\(Int(disposableHoursPerDay * 7))小時")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
} 