import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with vibrant gradient
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                        // Header
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Privacy Policy")
                                .font(.custom("Bradley Hand", size: 32, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            Text("Last updated: January 2025")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .padding(.top, DesignSystem.Spacing.xl)
                        
                        // Content
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                            // Introduction
                            PolicySection(
                                title: "Introduction",
                                content: "ShopList is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application."
                            )
                            
                            // Information We Collect
                            PolicySection(
                                title: "Information We Collect",
                                content: """
                                We collect the following types of information:
                                
                                • **Shopping Lists and Items**: Your shopping lists, items, quantities, categories, and notes
                                • **User Preferences**: App settings, appearance preferences, and notification settings
                                • **Location Data**: Only when you enable location-based reminders (stored locally)
                                • **Device Information**: iOS version, device model, and app version for support purposes
                                • **Usage Analytics**: Anonymous usage statistics to improve the app
                                """
                            )
                            
                            // How We Use Your Information
                            PolicySection(
                                title: "How We Use Your Information",
                                content: """
                                We use your information to:
                                
                                • Provide and maintain the ShopList service
                                • Send you notifications and reminders
                                • Improve app functionality and user experience
                                • Provide customer support
                                • Analyze app usage patterns (anonymously)
                                • Ensure app security and prevent fraud
                                """
                            )
                            
                            // Data Storage and Security
                            PolicySection(
                                title: "Data Storage and Security",
                                content: """
                                • **Local Storage**: All your shopping data is stored locally on your device using iOS Core Data
                                • **No Cloud Storage**: We do not upload your shopping lists to external servers
                                • **Encryption**: Data is encrypted using iOS built-in security features
                                • **Access Control**: Only you have access to your data through the app
                                • **Backup**: Your data may be included in your iCloud backup if enabled
                                """
                            )
                            
                            // Location Services
                            PolicySection(
                                title: "Location Services",
                                content: """
                                • **Optional Feature**: Location-based reminders are completely optional
                                • **Local Processing**: Location data is processed locally on your device
                                • **No Tracking**: We do not track your location or movement patterns
                                • **Store Locations**: Only store locations you manually add for reminders
                                • **Permission Control**: You can disable location access at any time in Settings
                                """
                            )
                            
                            // Third-Party Services
                            PolicySection(
                                title: "Third-Party Services",
                                content: """
                                • **Apple Services**: We use Apple's in-app purchase system for premium features
                                • **Analytics**: Anonymous usage analytics through Apple's App Analytics
                                • **No Advertising**: We do not use third-party advertising services
                                • **No Social Media**: We do not integrate with social media platforms
                                """
                            )
                            
                            // Data Sharing
                            PolicySection(
                                title: "Data Sharing",
                                content: """
                                • **No Selling**: We never sell, rent, or trade your personal information
                                • **No Third Parties**: We do not share your data with third parties
                                • **Legal Requirements**: We may disclose information if required by law
                                • **App Sharing**: You can share lists via iOS sharing features (your choice)
                                """
                            )
                            
                            // Your Rights
                            PolicySection(
                                title: "Your Rights",
                                content: """
                                You have the right to:
                                
                                • **Access**: View all your data within the app
                                • **Delete**: Remove individual items, lists, or all data
                                • **Export**: Share your data via text or CSV format
                                • **Control**: Manage permissions and settings
                                • **Contact**: Reach out to us with privacy concerns
                                """
                            )
                            
                            // Children's Privacy
                            PolicySection(
                                title: "Children's Privacy",
                                content: "ShopList is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us."
                            )
                            
                            // Changes to Privacy Policy
                            PolicySection(
                                title: "Changes to This Privacy Policy",
                                content: "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app and updating the 'Last updated' date."
                            )
                            
                            // Contact Information
                            PolicySection(
                                title: "Contact Us",
                                content: """
                                If you have any questions about this Privacy Policy, please contact us:
                                
                                Email: privacy@shoplist.app
                                Developer: Animesh Naskar
                                
                                We're committed to protecting your privacy and will respond to your inquiries promptly.
                                """
                            )
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
                title: "Privacy Policy",
                subtitle: "How we protect your data",
                icon: "hand.raised.fill",
                style: .info,
                showBanner: true
            )
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .lineSpacing(4)
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 