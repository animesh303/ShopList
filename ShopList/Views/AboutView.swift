import SwiftUI
import MessageUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingMailComposer = false
    @State private var showingFeatureRequest = false
    @State private var showingBugReport = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
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
                        // App Header Section
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            AppIconView(size: 80)
                            
                            VStack(spacing: DesignSystem.Spacing.xs) {
                                Text("ShopList")
                                    .font(.custom("Bradley Hand", size: 32, relativeTo: .title))
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Text("Smart Shopping List Manager")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                
                                Text("Version \(appVersion) (\(buildNumber))")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.xl)
                        
                        // App Description
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("About ShopList")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            Text("ShopList is your intelligent shopping companion that helps you organize, track, and manage your shopping lists with ease. From basic grocery lists to complex shopping trips with budgets and location reminders, ShopList has everything you need to make shopping more efficient and enjoyable.")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Key Features
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Key Features")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                FeatureRow(icon: "list.bullet", title: "Smart List Management", description: "Create and organize multiple shopping lists with categories")
                                FeatureRow(icon: "dollarsign.circle", title: "Budget Tracking", description: "Set budgets and track spending with visual progress indicators")
                                FeatureRow(icon: "location.circle", title: "Location Reminders", description: "Get notified when you're near your favorite stores")
                                FeatureRow(icon: "bell.fill", title: "Smart Notifications", description: "Time-based and recurring reminders for your shopping trips")
                                FeatureRow(icon: "square.and.arrow.up", title: "Easy Sharing", description: "Share lists with family and friends via text or CSV")
                                FeatureRow(icon: "paintbrush", title: "Customizable", description: "Dark/light mode and multiple currency support")
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Developer Information
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Developer")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Animesh Naskar")
                                            .font(DesignSystem.Typography.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DesignSystem.Colors.primaryText)
                                        Text("iOS Developer")
                                            .font(DesignSystem.Typography.caption1)
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                    Spacer()
                                }
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(DesignSystem.Colors.accent1)
                                        .font(.title3)
                                    VStack(alignment: .leading) {
                                        Text("Contact")
                                            .font(DesignSystem.Typography.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DesignSystem.Colors.primaryText)
                                        Text("support@shoplist.app")
                                            .font(DesignSystem.Typography.caption1)
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Support & Feedback Section
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Support & Feedback")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                SupportButton(
                                    icon: "plus.circle.fill",
                                    title: "Request Feature",
                                    subtitle: "Suggest new features or improvements",
                                    color: DesignSystem.Colors.success
                                ) {
                                    showingFeatureRequest = true
                                }
                                
                                SupportButton(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Report Bug",
                                    subtitle: "Help us improve by reporting issues",
                                    color: DesignSystem.Colors.error
                                ) {
                                    showingBugReport = true
                                }
                                
                                SupportButton(
                                    icon: "envelope.fill",
                                    title: "Contact Support",
                                    subtitle: "Get help with app issues",
                                    color: DesignSystem.Colors.primary
                                ) {
                                    showingMailComposer = true
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Legal Section
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Legal")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                LegalButton(
                                    title: "Privacy Policy",
                                    subtitle: "How we handle your data"
                                ) {
                                    showingPrivacyPolicy = true
                                }
                                
                                LegalButton(
                                    title: "Terms of Service",
                                    subtitle: "App usage terms and conditions"
                                ) {
                                    showingTermsOfService = true
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // System Information
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("System Information")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                InfoRow(label: "iOS Version", value: UIDevice.current.systemVersion)
                                InfoRow(label: "Device Model", value: UIDevice.current.model)
                                InfoRow(label: "App Version", value: "\(appVersion) (\(buildNumber))")
                                InfoRow(label: "Build Date", value: getBuildDate())
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Footer
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Made with ❤️ for iOS")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                            
                            Text("© 2025 Animesh Naskar. All rights reserved.")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                        .padding(.top, DesignSystem.Spacing.xl)
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
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    subject: "ShopList Support Request",
                    body: createSupportEmailBody()
                )
            }
            .sheet(isPresented: $showingFeatureRequest) {
                FeatureRequestView()
            }
            .sheet(isPresented: $showingBugReport) {
                BugReportView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
        }
    }
    
    private func getBuildDate() -> String {
        if let buildDate = Bundle.main.infoDictionary?["CFBuildDate"] as? String {
            return buildDate
        }
        
        // Fallback to current date if build date not available
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func createSupportEmailBody() -> String {
        return """
        Hello ShopList Support Team,
        
        I'm writing regarding the ShopList app (Version \(appVersion) (\(buildNumber))).
        
        Device Information:
        - iOS Version: \(UIDevice.current.systemVersion)
        - Device Model: \(UIDevice.current.model)
        - App Version: \(appVersion) (\(buildNumber))
        
        [Please describe your issue or question here]
        
        Thank you for your help!
        
        Best regards,
        [Your name]
        """
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.Colors.primary)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                                                Text(description)
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
        }
    }
}

struct SupportButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .font(.caption)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegalButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .font(.caption)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.secondaryBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
    }
}

#Preview {
    AboutView()
} 