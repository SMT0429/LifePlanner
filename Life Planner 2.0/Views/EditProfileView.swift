import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    let profile: UserProfile
    
    @State private var name: String
    @State private var age: Int
    @State private var gender: UserProfile.Gender
    
    init(profile: UserProfile) {
        self.profile = profile
        _name = State(initialValue: profile.name)
        _age = State(initialValue: profile.age)
        _gender = State(initialValue: profile.gender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本資料")) {
                    TextField("姓名", text: $name)
                    
                    Stepper("年齡：\(age)歲", value: $age, in: 0...120)
                    
                    Picker("性別", selection: $gender) {
                        ForEach([UserProfile.Gender.male, .female, .other], id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
            }
            .navigationTitle("編輯資料")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("儲存") {
                    saveProfile()
                    dismiss()
                }
            )
        }
    }
    
    private func saveProfile() {
        var updatedProfile = profile
        updatedProfile.name = name
        updatedProfile.age = age
        updatedProfile.gender = gender
        dataManager.updateProfile(updatedProfile)
    }
} 