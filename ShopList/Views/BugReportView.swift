import SwiftUI
import MessageUI

struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bugTitle = ""
    @State private var bugDescription = ""
    @State private var reproductionSteps = ""
    @State private var expectedBehavior = ""
    @State private var actualBehavior = ""
    @State private var severity = BugSeverity.medium
    @State private var category = BugCategory.general
    @State private var includeSystemInfo = true
    @State private var includeCrashLog = false
    @State private var showingMailComposer = false
    @State private var showingSuccessAlert = false
    @State private var showingCrashLogAlert = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Computed Properties
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.error)
            
            VStack(spacing: DesignSystem.Spacing.xs) {
                let titleFont = Font.custom("Bradley Hand", size: 28, relativeTo: .title2)
                Text("Report a Bug")
                    .font(titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Help us fix issues by providing detailed information")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, DesignSystem.Spacing.xl)
    }
    
    private var bugReportForm: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Bug Title
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Bug Title")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                TextField("e.g., App crashes when adding items", text: $bugTitle)
                    .textFieldStyle(CustomTextFieldStyle())
                    .font(DesignSystem.Typography.body)
            }
            
            // Bug Category
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Bug Category")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Picker("Category", selection: $category) {
                    ForEach(BugCategory.allCases, id: \.self) { category in
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
            
            // Severity Level
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Severity Level")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(BugSeverity.allCases, id: \.self) { severityLevel in
                        SeverityButton(
                            severity: severityLevel,
                            isSelected: severity == severityLevel
                        ) {
                            severity = severityLevel
                        }
                    }
                }
            }
            
            // Bug Description
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Bug Description")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Describe the bug in detail. What happened?")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                TextEditor(text: $bugDescription)
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
            
            // Expected vs Actual Behavior
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Expected vs Actual Behavior")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Expected Behavior")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("What should happen when you perform this action?")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    TextEditor(text: $expectedBehavior)
                        .frame(minHeight: 80)
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
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Actual Behavior")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("What actually happened?")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    TextEditor(text: $actualBehavior)
                        .frame(minHeight: 80)
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
            
            // Reproduction Steps
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Steps to Reproduce")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Provide step-by-step instructions to reproduce the bug")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                TextEditor(text: $reproductionSteps)
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
            
            // Additional Information
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Additional Information")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Toggle("Include System Information", isOn: $includeSystemInfo)
                        .toggleStyle(CustomToggleStyle())
                    
                    Toggle("Include Crash Log (if available)", isOn: $includeCrashLog)
                        .toggleStyle(CustomToggleStyle())
                        .onChange(of: includeCrashLog) { _, newValue in
                            if newValue {
                                showingCrashLogAlert = true
                            }
                        }
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var submitSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: submitBugReport) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Submit Bug Report")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(DesignSystem.Colors.error)
                )
                .foregroundColor(.white)
            }
            .disabled(bugTitle.isEmpty || bugDescription.isEmpty)
            .opacity(bugTitle.isEmpty || bugDescription.isEmpty ? 0.6 : 1.0)
            
            Text("Your bug report will be sent to our development team")
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        headerSection
                        bugReportForm
                        submitSection
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
                title: "Bug Report",
                subtitle: "Report issues",
                icon: "exclamationmark.triangle",
                style: .error,
                showBanner: true
            )
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    subject: "ShopList Bug Report: \(bugTitle)",
                    body: createBugReportEmail()
                )
            }
            .alert("Bug Report Sent!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your bug report. We'll investigate and get back to you soon!")
            }
            .alert("Crash Log Information", isPresented: $showingCrashLogAlert) {
                Button("OK") { }
            } message: {
                Text("If the app crashed, iOS automatically collects crash logs. We'll include any available crash information in your report to help us debug the issue.")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func submitBugReport() {
        showingMailComposer = true
    }
    
    private func createBugReportEmail() -> String {
        var emailBody = """
        Hello ShopList Development Team,
        
        I'm reporting a bug in the ShopList app.
        
        Bug Report Details:
        ===================
        
        Title: \(bugTitle)
        Category: \(category.displayName)
        Severity: \(severity.displayName)
        
        Description:
        \(bugDescription)
        
        Expected Behavior:
        \(expectedBehavior)
        
        Actual Behavior:
        \(actualBehavior)
        
        Steps to Reproduce:
        \(reproductionSteps)
        
        """
        
        if includeSystemInfo {
            emailBody += """
            
            System Information:
            - iOS Version: \(UIDevice.current.systemVersion)
            - Device Model: \(UIDevice.current.model)
            - App Version: \(appVersion) (\(buildNumber))
            - Device Memory: \(getDeviceMemory())
            - Available Storage: \(getAvailableStorage())
            
            """
        }
        
        if includeCrashLog {
            emailBody += """
            
            Crash Information:
            [iOS automatically collects crash logs. If a crash occurred, please check the device's crash logs in Settings > Privacy & Security > Analytics & Improvements > Analytics Data for entries related to ShopList.]
            
            """
        }
        
        emailBody += """
        
        Thank you for your attention to this issue!
        
        Best regards,
        [Your name]
        """
        
        return emailBody
    }
    
    private func getDeviceMemory() -> String {
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = processInfo.physicalMemory
        let memoryInGB = Double(physicalMemory) / (1024 * 1024 * 1024)
        return String(format: "%.1f GB", memoryInGB)
    }
    
    private func getAvailableStorage() -> String {
        // This is a simplified version - in a real app you'd use FileManager
        return "Unknown"
    }
}

// MARK: - Supporting Types

enum BugCategory: String, CaseIterable {
    case general = "general"
    case crash = "crash"
    case ui = "ui"
    case functionality = "functionality"
    case performance = "performance"
    case data = "data"
    case notification = "notification"
    case location = "location"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .crash: return "App Crash"
        case .ui: return "User Interface"
        case .functionality: return "Functionality"
        case .performance: return "Performance"
        case .data: return "Data/Lists"
        case .notification: return "Notifications"
        case .location: return "Location Services"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "exclamationmark.triangle.fill"
        case .crash: return "xmark.octagon.fill"
        case .ui: return "paintbrush.fill"
        case .functionality: return "gearshape.fill"
        case .performance: return "speedometer"
        case .data: return "list.bullet"
        case .notification: return "bell.fill"
        case .location: return "location.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return DesignSystem.Colors.primary
        case .crash: return DesignSystem.Colors.error
        case .ui: return DesignSystem.Colors.accent1
        case .functionality: return DesignSystem.Colors.accent2
        case .performance: return DesignSystem.Colors.accent3
        case .data: return DesignSystem.Colors.success
        case .notification: return DesignSystem.Colors.warning
        case .location: return DesignSystem.Colors.info
        }
    }
}

enum BugSeverity: String, CaseIterable {
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
        case .medium: return DesignSystem.Colors.warning
        case .high: return DesignSystem.Colors.error
        case .critical: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "exclamationmark.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
}

struct SeverityButton: View {
    let severity: BugSeverity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: severity.icon)
                    .font(.system(size: 20))
                Text(severity.displayName)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isSelected ? severity.color.opacity(0.2) : DesignSystem.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(isSelected ? severity.color : DesignSystem.Colors.tertiaryText.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .foregroundColor(isSelected ? severity.color : DesignSystem.Colors.primaryText)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Styles

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText.opacity(0.3))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 26, height: 26)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

#Preview {
    BugReportView()
} 