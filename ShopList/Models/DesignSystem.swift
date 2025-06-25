import SwiftUI

// MARK: - Design System
/// Comprehensive design system following iOS Human Interface Guidelines
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color("AccentColor")
        static let primaryLight = Color(red: 0.0, green: 0.576, blue: 0.941)
        static let primaryDark = Color(red: 0.0, green: 0.678, blue: 1.0)
        
        // Semantic Colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
        static let info = Color(red: 0.0, green: 0.6, blue: 1.0)
        
        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Text Colors
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let quaternaryText = Color(.quaternaryLabel)
        
        // Border Colors
        static let border = Color(.separator)
        static let borderLight = Color(.separator).opacity(0.5)
        
        // Category Colors (Enhanced)
        static let categoryGroceries = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let categoryHousehold = Color(red: 0.0, green: 0.6, blue: 1.0)
        static let categoryPersonalCare = Color(red: 0.9, green: 0.3, blue: 0.7)
        static let categoryHealth = Color(red: 1.0, green: 0.3, blue: 0.3)
        static let categoryElectronics = Color(red: 0.6, green: 0.3, blue: 0.9)
        static let categoryClothing = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let categoryOffice = Color(red: 0.5, green: 0.5, blue: 0.5)
        static let categoryPet = Color(red: 0.8, green: 0.5, blue: 0.2)
        static let categoryBaby = Color(red: 0.3, green: 0.8, blue: 0.8)
        static let categoryAutomotive = Color(red: 0.4, green: 0.3, blue: 0.8)
        static let categoryHomeImprovement = Color(red: 0.0, green: 0.7, blue: 0.7)
        static let categoryGarden = Color(red: 0.2, green: 0.7, blue: 0.3)
        static let categoryGifts = Color(red: 0.9, green: 0.3, blue: 0.5)
        static let categoryParty = Color(red: 0.7, green: 0.3, blue: 0.9)
        static let categoryHoliday = Color(red: 1.0, green: 0.4, blue: 0.4)
        static let categoryTravel = Color(red: 0.0, green: 0.5, blue: 0.8)
        static let categoryVacation = Color(red: 0.0, green: 0.8, blue: 0.8)
        static let categoryWork = Color(red: 0.6, green: 0.6, blue: 0.6)
        static let categoryBusiness = Color(red: 0.4, green: 0.3, blue: 0.7)
        static let categoryPersonal = Color(red: 0.3, green: 0.7, blue: 0.7)
        static let categoryOther = Color(red: 0.5, green: 0.5, blue: 0.5)
    }
    
    // MARK: - Typography
    struct Typography {
        // Font Sizes (following iOS guidelines)
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let bodyBold = Font.body.weight(.semibold)
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let subheadlineBold = Font.subheadline.weight(.semibold)
        static let footnote = Font.footnote
        static let caption1 = Font.caption
        static let caption2 = Font.caption2
        
        // Line Heights
        static let lineHeightTight: CGFloat = 1.2
        static let lineHeightNormal: CGFloat = 1.4
        static let lineHeightRelaxed: CGFloat = 1.6
        
        // Letter Spacing
        static let letterSpacingTight: CGFloat = -0.5
        static let letterSpacingNormal: CGFloat = 0.0
        static let letterSpacingWide: CGFloat = 0.5
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let xxxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let full: CGFloat = 999
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let extraLarge = Shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Animations
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
    
    // MARK: - Layout
    struct Layout {
        // Minimum touch targets (44pt as per iOS guidelines)
        static let minimumTouchTarget: CGFloat = 44
        
        // Standard padding
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat = 12
        static let largePadding: CGFloat = 20
        
        // Card dimensions
        static let cardCornerRadius: CGFloat = 12
        static let cardShadow = Shadows.medium
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extensions
extension Color {
    static let designPrimary = DesignSystem.Colors.primary
    static let designSuccess = DesignSystem.Colors.success
    static let designWarning = DesignSystem.Colors.warning
    static let designError = DesignSystem.Colors.error
    static let designInfo = DesignSystem.Colors.info
}

// MARK: - View Extensions
extension View {
    // Typography modifiers
    func largeTitleStyle() -> some View {
        self.font(DesignSystem.Typography.largeTitle)
    }
    
    func title1Style() -> some View {
        self.font(DesignSystem.Typography.title1)
    }
    
    func title2Style() -> some View {
        self.font(DesignSystem.Typography.title2)
    }
    
    func title3Style() -> some View {
        self.font(DesignSystem.Typography.title3)
    }
    
    func headlineStyle() -> some View {
        self.font(DesignSystem.Typography.headline)
    }
    
    func bodyStyle() -> some View {
        self.font(DesignSystem.Typography.body)
    }
    
    func bodyBoldStyle() -> some View {
        self.font(DesignSystem.Typography.bodyBold)
    }
    
    func subheadlineStyle() -> some View {
        self.font(DesignSystem.Typography.subheadline)
    }
    
    func subheadlineBoldStyle() -> some View {
        self.font(DesignSystem.Typography.subheadlineBold)
    }
    
    func captionStyle() -> some View {
        self.font(DesignSystem.Typography.caption1)
    }
    
    // Spacing modifiers
    func standardPadding() -> some View {
        self.padding(DesignSystem.Layout.standardPadding)
    }
    
    func compactPadding() -> some View {
        self.padding(DesignSystem.Layout.compactPadding)
    }
    
    func largePadding() -> some View {
        self.padding(DesignSystem.Layout.largePadding)
    }
    
    // Card styling
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.background)
            .cornerRadius(DesignSystem.Layout.cardCornerRadius)
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
    
    // Button styling
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
} 