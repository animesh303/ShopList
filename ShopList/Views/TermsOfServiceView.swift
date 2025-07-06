import SwiftUI

struct TermsOfServiceView: View {
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
                            Text("Terms of Service")
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
                            // Agreement
                            PolicySection(
                                title: "Agreement to Terms",
                                content: "By downloading, installing, or using the ShopList mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
                            )
                            
                            // Description of Service
                            PolicySection(
                                title: "Description of Service",
                                content: """
                                ShopList is a mobile application that allows users to:
                                
                                • Create and manage shopping lists
                                • Organize items by categories
                                • Set budgets and track spending
                                • Receive notifications and reminders
                                • Use location-based features (optional)
                                • Share lists with others
                                • Customize app appearance and settings
                                """
                            )
                            
                            // User Accounts
                            PolicySection(
                                title: "User Accounts",
                                content: """
                                • **No Registration Required**: ShopList does not require user registration or accounts
                                • **Local Data**: All your data is stored locally on your device
                                • **Data Ownership**: You retain full ownership of your shopping lists and data
                                • **Data Control**: You can export, delete, or modify your data at any time
                                • **No Personal Information**: We do not collect personal identifying information
                                """
                            )
                            
                            // Acceptable Use
                            PolicySection(
                                title: "Acceptable Use",
                                content: """
                                You agree to use ShopList only for lawful purposes and in accordance with these Terms. You agree not to:
                                
                                • Use the app for any illegal or unauthorized purpose
                                • Attempt to gain unauthorized access to the app or its systems
                                • Interfere with or disrupt the app's functionality
                                • Use the app to store or transmit harmful content
                                • Reverse engineer or attempt to extract source code
                                • Use the app to violate any applicable laws or regulations
                                """
                            )
                            
                            // Premium Features
                            PolicySection(
                                title: "Premium Features",
                                content: """
                                • **Subscription**: Premium features are available through in-app purchases
                                • **Apple's Terms**: All purchases are subject to Apple's App Store terms
                                • **Auto-Renewal**: Subscriptions automatically renew unless cancelled
                                • **Cancellation**: You can cancel subscriptions in your Apple ID settings
                                • **Refunds**: Refund requests are handled by Apple according to their policies
                                • **Feature Changes**: Premium features may be modified or discontinued with notice
                                """
                            )
                            
                            // Intellectual Property
                            PolicySection(
                                title: "Intellectual Property",
                                content: """
                                • **App Ownership**: ShopList and its content are owned by Animesh Naskar
                                • **Your Content**: You retain ownership of your shopping lists and data
                                • **License**: We grant you a limited license to use the app for personal purposes
                                • **Restrictions**: You may not copy, modify, or distribute the app
                                • **Trademarks**: ShopList trademarks and logos are our property
                                """
                            )
                            
                            // Privacy
                            PolicySection(
                                title: "Privacy",
                                content: "Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the app and is incorporated into these Terms by reference."
                            )
                            
                            // Disclaimers
                            PolicySection(
                                title: "Disclaimers",
                                content: """
                                • **As-Is Service**: The app is provided "as is" without warranties
                                • **No Guarantees**: We do not guarantee uninterrupted or error-free service
                                • **Data Loss**: We are not responsible for data loss or corruption
                                • **Third-Party Services**: We are not responsible for third-party services
                                • **Location Accuracy**: Location-based features depend on device accuracy
                                • **Notifications**: We cannot guarantee delivery of notifications
                                """
                            )
                            
                            // Limitation of Liability
                            PolicySection(
                                title: "Limitation of Liability",
                                content: """
                                To the maximum extent permitted by law, ShopList and its developer shall not be liable for:
                                
                                • Any indirect, incidental, or consequential damages
                                • Loss of data, profits, or business opportunities
                                • Damages resulting from app use or inability to use
                                • Issues arising from third-party services or integrations
                                • Security breaches or data compromises
                                • Any damages exceeding the amount paid for the app
                                """
                            )
                            
                            // Indemnification
                            PolicySection(
                                title: "Indemnification",
                                content: "You agree to indemnify and hold harmless ShopList and its developer from any claims, damages, or expenses arising from your use of the app or violation of these Terms."
                            )
                            
                            // Termination
                            PolicySection(
                                title: "Termination",
                                content: """
                                • **Your Rights**: You may stop using the app at any time
                                • **Our Rights**: We may terminate or suspend access for Terms violations
                                • **Data Retention**: Your data remains on your device after termination
                                • **Effect**: Termination does not affect accrued rights or obligations
                                """
                            )
                            
                            // Governing Law
                            PolicySection(
                                title: "Governing Law",
                                content: "These Terms are governed by the laws of the jurisdiction where the developer is located. Any disputes shall be resolved in the appropriate courts of that jurisdiction."
                            )
                            
                            // Changes to Terms
                            PolicySection(
                                title: "Changes to Terms",
                                content: "We may update these Terms from time to time. We will notify you of significant changes by posting the new Terms in the app and updating the 'Last updated' date. Continued use of the app constitutes acceptance of the updated Terms."
                            )
                            
                            // Contact Information
                            PolicySection(
                                title: "Contact Information",
                                content: """
                                If you have any questions about these Terms of Service, please contact us:
                                
                                Email: legal@shoplist.app
                                Developer: Animesh Naskar
                                
                                We're committed to providing excellent service and will respond to your inquiries promptly.
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
                title: "Terms of Service",
                subtitle: "App usage terms",
                icon: "doc.text.fill",
                style: .info,
                showBanner: true
            )
        }
    }
}

#Preview {
    TermsOfServiceView()
} 