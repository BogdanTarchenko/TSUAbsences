import Foundation
import SwiftUI

final class EditProfileViewModel: ObservableObject {
    @Published var fullName: String
    @Published var email: String
    @Published var groupNumberText: String
    @Published var isLoading = false
    @Published var errorMessage: String?
    let role: UserRole
    
    private var originalProfile: UserProfile
    
    init(profile: UserProfile) {
        self.originalProfile = profile
        self.fullName = profile.fullName
        self.email = profile.email
        self.groupNumberText = profile.group.map { String($0.groupNumber) } ?? ""
        self.role = profile.role
    }
    
    @MainActor
    func saveProfile() async -> Bool {
        do {
            try Validation.validateNonEmpty(fullName, fieldName: "ФИО")
            try Validation.validateNonEmpty(email, fieldName: "Email")
            
            if !Validation.validateEmail(email) {
                errorMessage = ValidationError.invalidEmail.message
                return false
            }
            
            if !Validation.validateGroupNumber(groupNumberText) {
                errorMessage = ValidationError.invalidGroupNumber.message
                return false
            }
            
            let groupNumber = groupNumberText.isEmpty ? nil : Int(groupNumberText)
            
            isLoading = true
            
            let groupNumberForRequest: Int? = {
                guard let number = groupNumber else { return nil }
                return number != originalProfile.group?.groupNumber ? number : nil
            }()
            
            let request = EditProfileRequest(
                fullName: fullName != originalProfile.fullName ? fullName : nil,
                group: groupNumberForRequest,
                email: email != originalProfile.email ? email : nil
            )
            
            let updatedProfile: UserProfile = try await NetworkManager.shared.request(
                endpoint: "/user/profile",
                method: "PATCH",
                body: request
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name("ProfileUpdated"),
                object: nil,
                userInfo: ["profile": updatedProfile]
            )
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
} 
