import Foundation

struct LifeCalculator {
    let birthDate: Date
    let currentDate: Date
    let expectedLifespan: Int
    let dailyTime: DailyTimeAllocation
    
    struct DailyTimeAllocation {
        var sleep: Double // 小時
        var commute: Double
        var work: Double
        
        var disposableTime: Double {
            24 - (sleep + commute + work)
        }
        
        static let `default` = DailyTimeAllocation(
            sleep: 8,
            commute: 1,
            work: 8
        )
    }
    
    struct TimeBreakdown {
        let years: Int
        let months: Int
        let days: Int
        let hours: Int
        let minutes: Int
        
        init(timeInterval: TimeInterval) {
            let totalMinutes = Int(timeInterval / 60)
            let totalHours = totalMinutes / 60
            let totalDays = totalHours / 24
            
            self.minutes = totalMinutes % 60
            self.hours = totalHours % 24
            self.days = totalDays % 30
            self.months = (totalDays / 30) % 12
            self.years = totalDays / 365
        }
        
        var description: String {
            return "\(years)年 \(months)個月 \(days)天 \(hours)小時 \(minutes)分鐘"
        }
    }
    
    // 已經活了多久
    var livedTime: TimeBreakdown {
        let interval = currentDate.timeIntervalSince(birthDate)
        return TimeBreakdown(timeInterval: interval)
    }
    
    // 剩餘壽命
    var remainingTime: TimeBreakdown {
        let birthYear = Calendar.current.component(.year, from: birthDate)
        let deathYear = birthYear + expectedLifespan
        guard let deathDate = Calendar.current.date(from: DateComponents(year: deathYear)) else {
            return TimeBreakdown(timeInterval: 0)
        }
        
        let interval = deathDate.timeIntervalSince(currentDate)
        return TimeBreakdown(timeInterval: max(0, interval))
    }
    
    // 生命進度百分比
    var progressPercentage: Double {
        let lived = currentDate.timeIntervalSince(birthDate)
        let total = Double(expectedLifespan) * 365.25 * 24 * 60 * 60
        return (lived / total) * 100
    }
    
    // 每日時間分配
    var dailyTimeDistribution: [String: Double] {
        [
            "睡眠": dailyTime.sleep,
            "通勤": dailyTime.commute,
            "工作": dailyTime.work,
            "自由時間": dailyTime.disposableTime
        ]
    }
    
    // 剩餘生命的可支配時間（小時）
    var remainingDisposableTime: Double {
        let remainingDays = Double(expectedLifespan * 365) - 
            currentDate.timeIntervalSince(birthDate) / (24 * 60 * 60)
        return remainingDays * dailyTime.disposableTime
    }
    
    // 計算週數（用於生命日曆）
    var totalWeeks: Int {
        let totalDays = Double(expectedLifespan * 365)
        return Int(totalDays / 7)
    }
    
    var livedWeeks: Int {
        let lived = currentDate.timeIntervalSince(birthDate)
        return Int(lived / (7 * 24 * 60 * 60))
    }
    
    init(birthDate: Date, currentDate: Date = Date(), expectedLifespan: Int = 80, dailyTime: DailyTimeAllocation = .default) {
        self.birthDate = birthDate
        self.currentDate = currentDate
        self.expectedLifespan = expectedLifespan
        self.dailyTime = dailyTime
    }
} 