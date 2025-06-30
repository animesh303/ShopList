import SwiftUI

// MARK: - App Icon View
struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 64) {
        self.size = size
    }
    
    var body: some View {
        if let appIcon = getAppIcon() {
            Image(uiImage: appIcon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        } else {
            // Fallback to a default icon if app icon can't be loaded
            Image(systemName: "app.fill")
                .font(.system(size: size * 0.6))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.2)
                        .fill(.blue)
                )
        }
    }
    
    private func getAppIcon() -> UIImage? {
        guard let iconFiles = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = iconFiles["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFilesArray = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFilesArray.first else {
            return nil
        }
        
        return UIImage(named: iconFileName)
    }
}

// MARK: - Navigation Banner View
struct NavigationBannerView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let style: BannerStyle
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Banner background
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if let icon = icon {
                        if icon == "app_icon" {
                            AppIconView(size: 64)
                        } else {
                            Image(systemName: icon)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.custom("Bradley Hand", size: 38, relativeTo: .title2))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.custom("Bradley Hand", size: 20, relativeTo: .caption))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.95))
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
                .padding(.bottom, subtitle != nil ? DesignSystem.Spacing.xs : DesignSystem.Spacing.sm)
            }
            .background(themeAwareGradient)
            .overlay(
                // Subtle pattern overlay for texture
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.05 : 0.1),
                                .clear,
                                .white.opacity(colorScheme == .dark ? 0.02 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            
            // Bottom shadow for depth
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .black.opacity(colorScheme == .dark ? 0.2 : 0.1),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
        }
    }
    
    // Theme-aware gradient based on user's appearance setting
    private var themeAwareGradient: LinearGradient {
        // For now, use system color scheme to avoid crashes
        // The theme-aware functionality can be added later when UserSettingsManager is properly injected
        let effectiveColorScheme = colorScheme
        
        switch style {
        case .primary:
            return effectiveColorScheme == .dark ? 
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.5),
                        Color(red: 0.0, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                DesignSystem.Colors.primaryButtonGradient
                
        case .secondary:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.1, blue: 0.3),
                        Color(red: 0.3, green: 0.0, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                DesignSystem.Colors.secondaryButtonGradient
                
        case .success:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.4, blue: 0.2),
                        Color(red: 0.0, green: 0.3, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.success,
                        DesignSystem.Colors.success.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .warning:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.4, blue: 0.0),
                        Color(red: 0.4, green: 0.3, blue: 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.warning,
                        DesignSystem.Colors.warning.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .error:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.1, blue: 0.1),
                        Color(red: 0.4, green: 0.0, blue: 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.error,
                        DesignSystem.Colors.error.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .info:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.3, blue: 0.5),
                        Color(red: 0.0, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.info,
                        DesignSystem.Colors.info.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .custom(let gradient):
            return gradient
        }
    }
}

enum BannerStyle {
    case primary
    case secondary
    case success
    case warning
    case error
    case info
    case custom(LinearGradient)
    
    var defaultGradient: LinearGradient {
        switch self {
        case .primary:
            return DesignSystem.Colors.primaryButtonGradient
        case .secondary:
            return DesignSystem.Colors.secondaryButtonGradient
        case .success:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.success,
                    DesignSystem.Colors.success.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warning:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.warning,
                    DesignSystem.Colors.warning.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .error:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.error,
                    DesignSystem.Colors.error.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .info:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.info,
                    DesignSystem.Colors.info.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .custom(let gradient):
            return gradient
        }
    }
}

// MARK: - Custom Navigation Title View
struct CustomNavigationTitleView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let style: BannerStyle
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let icon = icon {
                if icon == "app_icon" {
                    AppIconView(size: 56)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.custom("Bradley Hand", size: 28, relativeTo: .title3))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.custom("Bradley Hand", size: 18, relativeTo: .caption))
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(themeAwareGradient)
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.3 : 0.2),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
    }
    
    // Theme-aware gradient based on user's appearance setting
    private var themeAwareGradient: LinearGradient {
        // For now, use system color scheme to avoid crashes
        // The theme-aware functionality can be added later when UserSettingsManager is properly injected
        let effectiveColorScheme = colorScheme
        
        switch style {
        case .primary:
            return effectiveColorScheme == .dark ? 
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.5),
                        Color(red: 0.0, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                DesignSystem.Colors.primaryButtonGradient
                
        case .secondary:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.1, blue: 0.3),
                        Color(red: 0.3, green: 0.0, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                DesignSystem.Colors.secondaryButtonGradient
                
        case .success:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.4, blue: 0.2),
                        Color(red: 0.0, green: 0.3, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.success,
                        DesignSystem.Colors.success.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .warning:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.4, blue: 0.0),
                        Color(red: 0.4, green: 0.3, blue: 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.warning,
                        DesignSystem.Colors.warning.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .error:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.1, blue: 0.1),
                        Color(red: 0.4, green: 0.0, blue: 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.error,
                        DesignSystem.Colors.error.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .info:
            return effectiveColorScheme == .dark ?
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.3, blue: 0.5),
                        Color(red: 0.0, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.info,
                        DesignSystem.Colors.info.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
        case .custom(let gradient):
            return gradient
        }
    }
}

// MARK: - View Modifier for Enhanced Navigation
struct EnhancedNavigationModifier: ViewModifier {
    let title: String
    let subtitle: String?
    let icon: String?
    let style: BannerStyle
    let showBanner: Bool
    let searchText: Binding<String>?
    let searchPrompt: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        style: BannerStyle = .primary,
        showBanner: Bool = false,
        searchText: Binding<String>? = nil,
        searchPrompt: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.style = style
        self.showBanner = showBanner
        self.searchText = searchText
        self.searchPrompt = searchPrompt
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if showBanner {
                NavigationBannerView(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    style: style
                )
                
                // Custom search bar below banner
                if let searchText = searchText, let searchPrompt = searchPrompt {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                        
                        TextField(searchPrompt, text: searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 8)
                        
                        if !searchText.wrappedValue.isEmpty {
                            Button(action: {
                                searchText.wrappedValue = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 12)
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if !showBanner {
                    CustomNavigationTitleView(
                        title: title,
                        subtitle: subtitle,
                        icon: icon,
                        style: style
                    )
                }
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func enhancedNavigation(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        style: BannerStyle = .primary,
        showBanner: Bool = false,
        searchText: Binding<String>? = nil,
        searchPrompt: String? = nil
    ) -> some View {
        modifier(EnhancedNavigationModifier(
            title: title,
            subtitle: subtitle,
            icon: icon,
            style: style,
            showBanner: showBanner,
            searchText: searchText,
            searchPrompt: searchPrompt
        ))
    }
}

// MARK: - Preview
struct NavigationBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NavigationBannerView(
                title: "Shopping Lists",
                subtitle: "Manage your shopping lists",
                icon: "app_icon",
                style: .primary
            )
            
            CustomNavigationTitleView(
                title: "Settings",
                subtitle: "Customize your app",
                icon: "gear",
                style: .secondary
            )
            
            NavigationBannerView(
                title: "Success",
                subtitle: "Operation completed",
                icon: "checkmark.circle",
                style: .success
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Reusable Back Button FAB
struct BackButtonFAB: View {
    let action: () -> Void
    let isVisible: Bool
    
    init(isVisible: Bool = true, action: @escaping () -> Void) {
        self.isVisible = isVisible
        self.action = action
    }
    
    var body: some View {
        if isVisible {
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: DesignSystem.Layout.minimumTouchTarget, height: DesignSystem.Layout.minimumTouchTarget)
                    .background(
                        DesignSystem.Colors.secondaryButtonGradient
                    )
                    .clipShape(Circle())
                    .shadow(
                        color: DesignSystem.Colors.secondary.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
            .transition(.scale.combined(with: .opacity))
            .animation(DesignSystem.Animations.spring, value: isVisible)
        }
    }
} 