import SwiftUI
import MessageUI

struct FeatureRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var featureTitle = ""
    @State private var featureDescription = ""
    @State private var useCase = ""
    @State private var priority = FeaturePriority.medium
    @State private var category = FeatureCategory.general
    @State private var showingMailComposer = false
    @State private var showingSuccessAlert = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Header
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(DesignSystem.Colors.success)
                            
                            VStack(spacing: DesignSystem.Spacing.xs) {
                                let titleFont = Font.custom("Bradley Hand", size: 28, relativeTo: .title2)
                                Text("Request a Feature")
                                    .font(titleFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Text("Help us improve ShopList by suggesting new features")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.xl)
                        
                        // Feature Request Form
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            // Feature Title
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Feature Title")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                TextField("e.g., Dark mode for widgets", text: $featureTitle)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .font(DesignSystem.Typography.body)
                            }
                            
                            // Feature Category
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Feature Category")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Picker("Category", selection: $category) {
                                    ForEach(FeatureCategory.allCases, id: \.self) { category in
                                        HStack {
                                            Image(systemName: category.icon)
                                                .foregroundColor(category.color)
                                            Text(category.displayName)
                                        }
                                        .tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .fill(DesignSystem.Colors.secondaryBackground)
                                )
                            }
                            
                            // Priority Level
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Priority Level")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    ForEach(FeaturePriority.allCases, id: \.self) { priorityLevel in
                                        PriorityButton(
                                            priority: priorityLevel,
                                            isSelected: priority == priorityLevel
                                        ) {
                                            priority = priorityLevel
                                        }
                                    }
                                }
                            }
                            
                            // Feature Description
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Feature Description")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Text("Describe the feature in detail. What should it do? How should it work?")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                
                                TextEditor(text: $featureDescription)
                                    .frame(minHeight: 120)
                                    .padding(DesignSystem.Spacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                            .fill(DesignSystem.Colors.secondaryBackground)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                            .stroke(DesignSystem.Colors.tertiaryText.opacity(0.3), lineWidth: 1)
                                    )
                                    .font(DesignSystem.Typography.body)
                            }
                            
                            // Use Case
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Use Case")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Text("How would you use this feature? What problem does it solve?")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                
                                TextEditor(text: $useCase)
                                    .frame(minHeight: 100)
                                    .padding(DesignSystem.Spacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                            .fill(DesignSystem.Colors.secondaryBackground)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                            .stroke(DesignSystem.Colors.tertiaryText.opacity(0.3), lineWidth: 1)
                                    )
                                    .font(DesignSystem.Typography.body)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Submit Button
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Button(action: submitFeatureRequest) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Submit Feature Request")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                        .fill(DesignSystem.Colors.success)
                                )
                                .foregroundColor(.white)
                            }
                            .disabled(featureTitle.isEmpty || featureDescription.isEmpty)
                            .opacity(featureTitle.isEmpty || featureDescription.isEmpty ? 0.6 : 1.0)
                            
                            Text("Your feature request will be sent to our development team")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                }
                
                // Back Button FAB at bottom left
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            BackButtonFAB {
                                dismiss()
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                        
                        Spacer()
                    }
                }
            }
            .enhancedNavigation(
                title: "Feature Request",
                subtitle: "Suggest new features",
                icon: "plus.circle",
                style: .success,
                showBanner: true
            )
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    subject: "ShopList Feature Request: \(featureTitle)",
                    body: createFeatureRequestEmail()
                )
            }
            .alert("Feature Request Sent!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feature request. We'll review it and get back to you soon!")
            }
        }
    }
    
    private func submitFeatureRequest() {
        showingMailComposer = true
    }
    
    private func createFeatureRequestEmail() -> String {
        return """
        Hello ShopList Development Team,
        
        I would like to request a new feature for the ShopList app.
        
        Feature Request Details:
        =======================
        
        Title: \(featureTitle)
        Category: \(category.displayName)
        Priority: \(priority.displayName)
        
        Description:
        \(featureDescription)
        
        Use Case:
        \(useCase)
        
        Device Information:
        - iOS Version: \(UIDevice.current.systemVersion)
        - Device Model: \(UIDevice.current.model)
        - App Version: \(appVersion) (\(buildNumber))
        
        Thank you for considering this feature request!
        
        Best regards,
        [Your name]
        """
    }
}

// MARK: - Supporting Types

enum FeatureCategory: String, CaseIterable {
    case general = "general"
    case ui = "ui"
    case functionality = "functionality"
    case integration = "integration"
    case performance = "performance"
    case accessibility = "accessibility"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .ui: return "User Interface"
        case .functionality: return "Functionality"
        case .integration: return "Integration"
        case .performance: return "Performance"
        case .accessibility: return "Accessibility"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "star.fill"
        case .ui: return "paintbrush.fill"
        case .functionality: return "gearshape.fill"
        case .integration: return "link.circle.fill"
        case .performance: return "speedometer"
        case .accessibility: return "accessibility"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return DesignSystem.Colors.primary
        case .ui: return DesignSystem.Colors.accent1
        case .functionality: return DesignSystem.Colors.accent2
        case .integration: return DesignSystem.Colors.accent3
        case .performance: return DesignSystem.Colors.success
        case .accessibility: return DesignSystem.Colors.info
        }
    }
}

enum FeaturePriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return DesignSystem.Colors.success
        case .medium: return DesignSystem.Colors.info
        case .high: return DesignSystem.Colors.warning
        case .critical: return DesignSystem.Colors.error
        }
    }
}

// MARK: - Supporting Views

struct PriorityButton: View {
    let priority: FeaturePriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(priority.color)
                    .font(.title3)
                
                Text(priority.displayName)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isSelected ? priority.color.opacity(0.1) : DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(isSelected ? priority.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.tertiaryText.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    FeatureRequestView()
} 