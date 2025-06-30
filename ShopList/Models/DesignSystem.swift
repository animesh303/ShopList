import SwiftUI

// MARK: - Design System
/// Comprehensive design system following iOS Human Interface Guidelines
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors - Enhanced with vibrant gradients
        static let primary = Color("AccentColor")
        static let primaryLight = Color(red: 0.2, green: 0.8, blue: 1.0) // Bright cyan
        static let primaryDark = Color(red: 0.0, green: 0.6, blue: 0.9) // Deep blue
        
        // Secondary Colors - Vibrant palette
        static let secondary = Color(red: 0.9, green: 0.3, blue: 0.7) // Bright magenta
        static let secondaryLight = Color(red: 1.0, green: 0.4, blue: 0.8) // Light magenta
        static let secondaryDark = Color(red: 0.7, green: 0.2, blue: 0.6) // Dark magenta
        
        // Accent Colors - Bright and cheerful
        static let accent1 = Color(red: 1.0, green: 0.6, blue: 0.0) // Bright orange
        static let accent2 = Color(red: 0.3, green: 0.9, blue: 0.5) // Bright green
        static let accent3 = Color(red: 0.8, green: 0.2, blue: 0.9) // Bright purple
        static let accent4 = Color(red: 0.0, green: 0.8, blue: 0.8) // Bright teal
        
        // Semantic Colors - Enhanced vibrancy
        static let success = Color(red: 0.2, green: 0.9, blue: 0.4) // Bright green
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0) // Bright yellow
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3) // Bright red
        static let info = Color(red: 0.0, green: 0.7, blue: 1.0) // Bright blue
        
        // Background Colors - Enhanced with gradients
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Enhanced Background Gradients with dark mode support
        static let backgroundGradient = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground).opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardBackgroundGradient = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground).opacity(0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Text Colors - Enhanced for better contrast
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let quaternaryText = Color(.quaternaryLabel)
        
        // Enhanced text colors for better dark mode contrast
        static let textOnLight = Color(.label)
        static let textOnDark = Color.white
        
        // Border Colors - Enhanced
        static let border = Color(.separator)
        static let borderLight = Color(.separator).opacity(0.5)
        static let borderColorful = Color(red: 0.9, green: 0.9, blue: 0.95)
        
        // Category Colors - Completely enhanced with vibrant colors
        static let categoryGroceries = Color(red: 0.2, green: 0.9, blue: 0.4) // Bright green
        static let categoryHousehold = Color(red: 0.0, green: 0.7, blue: 1.0) // Bright blue
        static let categoryPersonalCare = Color(red: 0.9, green: 0.3, blue: 0.7) // Bright magenta
        static let categoryHealth = Color(red: 1.0, green: 0.3, blue: 0.3) // Bright red
        static let categoryElectronics = Color(red: 0.6, green: 0.3, blue: 0.9) // Bright purple
        static let categoryClothing = Color(red: 1.0, green: 0.6, blue: 0.0) // Bright orange
        static let categoryOffice = Color(red: 0.5, green: 0.5, blue: 0.8) // Soft blue-gray
        static let categoryPet = Color(red: 0.8, green: 0.5, blue: 0.2) // Warm brown
        static let categoryBaby = Color(red: 0.3, green: 0.8, blue: 0.8) // Bright teal
        static let categoryAutomotive = Color(red: 0.4, green: 0.3, blue: 0.8) // Deep purple
        static let categoryHomeImprovement = Color(red: 0.0, green: 0.7, blue: 0.7) // Teal
        static let categoryGarden = Color(red: 0.2, green: 0.7, blue: 0.3) // Forest green
        static let categoryGifts = Color(red: 0.9, green: 0.3, blue: 0.5) // Pink
        static let categoryParty = Color(red: 0.7, green: 0.3, blue: 0.9) // Purple
        static let categoryHoliday = Color(red: 1.0, green: 0.4, blue: 0.4) // Coral
        static let categoryTravel = Color(red: 0.0, green: 0.5, blue: 0.8) // Ocean blue
        static let categoryVacation = Color(red: 0.0, green: 0.8, blue: 0.8) // Cyan
        static let categoryWork = Color(red: 0.6, green: 0.6, blue: 0.6) // Gray
        static let categoryBusiness = Color(red: 0.4, green: 0.3, blue: 0.7) // Indigo
        static let categoryPersonal = Color(red: 0.3, green: 0.7, blue: 0.7) // Teal
        static let categoryOther = Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        
        // Enhanced Category Gradients
        static func categoryGradient(for category: ItemCategory) -> LinearGradient {
            let baseColor = category.color
            return LinearGradient(
                colors: [
                    baseColor,
                    baseColor.opacity(0.8),
                    baseColor.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func categoryGradient(for category: ListCategory) -> LinearGradient {
            let baseColor = category.color
            return LinearGradient(
                colors: [
                    baseColor,
                    baseColor.opacity(0.8),
                    baseColor.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Theme-aware category gradient for navigation banners
        static func themeAwareCategoryGradient(for category: ListCategory, colorScheme: ColorScheme) -> LinearGradient {
            let baseColor = category.color
            
            if colorScheme == .dark {
                // For dark theme, use darker, more muted versions of the category colors
                return LinearGradient(
                    colors: [
                        baseColor.opacity(0.7),
                        baseColor.opacity(0.5),
                        baseColor.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // For light theme, create a more pronounced gradient with darker color variations
                return LinearGradient(
                    colors: [
                        baseColor, // 100% opacity at top
                        baseColor.opacity(0.8), // 80% opacity at upper middle
                        baseColor.opacity(0.6), // 60% opacity at lower middle
                        baseColor.opacity(0.1)  // 10% opacity at bottom
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        static func themeAwareCategoryGradient(for category: ItemCategory, colorScheme: ColorScheme) -> LinearGradient {
            let baseColor = category.color
            
            if colorScheme == .dark {
                // For dark theme, use darker, more muted versions of the category colors
                return LinearGradient(
                    colors: [
                        baseColor.opacity(0.7),
                        baseColor.opacity(0.5),
                        baseColor.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // For light theme, create a more pronounced gradient with darker color variations
                return LinearGradient(
                    colors: [
                        baseColor, // 100% opacity at top
                        baseColor.opacity(0.8), // 80% opacity at upper middle
                        baseColor.opacity(0.6), // 60% opacity at lower middle
                        baseColor.opacity(0.1)  // 10% opacity at bottom
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        // Button Gradients
        static let primaryButtonGradient = LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.7, blue: 0.9),
                Color(red: 0.0, green: 0.5, blue: 0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let secondaryButtonGradient = LinearGradient(
            colors: [
                Color(red: 0.9, green: 0.3, blue: 0.7),
                Color(red: 0.7, green: 0.2, blue: 0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accentButtonGradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.0),
                Color(red: 0.8, green: 0.4, blue: 0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Premium Colors and Gradients
        static let premium = Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
        static let premiumLight = Color(red: 1.0, green: 0.7, blue: 0.2) // Light orange
        static let premiumDark = Color(red: 0.8, green: 0.4, blue: 0.0) // Dark orange
        
        static let premiumGradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.0), // Orange
                Color(red: 0.9, green: 0.3, blue: 0.1)  // Red-orange
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Card Gradients with dark mode support
        static let cardGradient = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground).opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardGradientColored = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground).opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Helper function to get appropriate text color for any background
        static func textColor(for backgroundColor: Color) -> Color {
            // For now, we'll use the system label color which adapts to light/dark mode
            return Color(.label)
        }
        
        // Helper function to get card background with proper contrast
        static func cardBackground(for category: ItemCategory) -> LinearGradient {
            return LinearGradient(
                colors: [
                    Color(.systemBackground),
                    category.color.opacity(0.15),  // Increased from 0.05 for more distinct colors
                    category.color.opacity(0.08),  // Added middle layer for depth
                    Color(.secondarySystemBackground).opacity(0.3)  // Increased for better contrast
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func cardBackground(for category: ListCategory) -> LinearGradient {
            return LinearGradient(
                colors: [
                    Color(.systemBackground),
                    category.color.opacity(0.15),  // Increased from 0.05 for more distinct colors
                    category.color.opacity(0.08),  // Added middle layer for depth
                    Color(.secondarySystemBackground).opacity(0.3)  // Increased for better contrast
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Helper function to ensure text has proper contrast
        static func adaptiveTextColor() -> Color {
            return Color(.label)
        }
        
        // Helper function to get secondary text with proper contrast
        static func adaptiveSecondaryTextColor() -> Color {
            return Color(.secondaryLabel)
        }
        
        // Helper function to get tertiary text with proper contrast
        static func adaptiveTertiaryTextColor() -> Color {
            return Color(.tertiaryLabel)
        }
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
    
    // MARK: - Shadows - Enhanced with colorful shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let extraLarge = Shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
        
        // Colorful shadows for enhanced visual appeal
        static let colorfulSmall = Shadow(color: Colors.primary.opacity(0.2), radius: 3, x: 0, y: 2)
        static let colorfulMedium = Shadow(color: Colors.secondary.opacity(0.15), radius: 6, x: 0, y: 3)
        static let colorfulLarge = Shadow(color: Colors.accent1.opacity(0.1), radius: 12, x: 0, y: 6)
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
    static let designSecondary = DesignSystem.Colors.secondary
    static let designAccent1 = DesignSystem.Colors.accent1
    static let designAccent2 = DesignSystem.Colors.accent2
    static let designAccent3 = DesignSystem.Colors.accent3
    static let designAccent4 = DesignSystem.Colors.accent4
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
    
    // Enhanced Card styling with gradients
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardGradient)
            .cornerRadius(DesignSystem.Layout.cardCornerRadius)
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
    
    // Enhanced Card styling with colorful shadows
    func colorfulCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardGradientColored)
            .cornerRadius(DesignSystem.Layout.cardCornerRadius)
            .shadow(
                color: DesignSystem.Shadows.colorfulMedium.color,
                radius: DesignSystem.Shadows.colorfulMedium.radius,
                x: DesignSystem.Shadows.colorfulMedium.x,
                y: DesignSystem.Shadows.colorfulMedium.y
            )
    }
    
    // Enhanced Button styling with gradients
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primaryButtonGradient)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: DesignSystem.Colors.primary.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.secondaryButtonGradient)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: DesignSystem.Colors.secondary.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    func accentButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.accentButtonGradient)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: DesignSystem.Colors.accent1.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    // Background gradient modifier
    func colorfulBackground() -> some View {
        self.background(DesignSystem.Colors.backgroundGradient)
    }
    
    // Adaptive text color modifiers
    func adaptiveTextColor() -> some View {
        self.foregroundColor(DesignSystem.Colors.adaptiveTextColor())
    }
    
    func adaptiveSecondaryTextColor() -> some View {
        self.foregroundColor(DesignSystem.Colors.adaptiveSecondaryTextColor())
    }
    
    func adaptiveTertiaryTextColor() -> some View {
        self.foregroundColor(DesignSystem.Colors.adaptiveTertiaryTextColor())
    }
} 