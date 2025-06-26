import SwiftUI

struct NavigationBannerView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let gradient: LinearGradient
    let style: BannerStyle
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        gradient: LinearGradient? = nil,
        style: BannerStyle = .primary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradient = gradient ?? style.defaultGradient
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Banner background
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    if let icon = icon {
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
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(title)
                            .font(.custom("Bradley Hand", size: 36, relativeTo: .title2))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.custom("Bradley Hand", size: 18, relativeTo: .caption))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
                .padding(.bottom, subtitle != nil ? DesignSystem.Spacing.sm : DesignSystem.Spacing.lg)
            }
            .background(gradient)
            .overlay(
                // Subtle pattern overlay for texture
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.1),
                                .clear,
                                .white.opacity(0.05)
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
                            .black.opacity(0.1),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 4)
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
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Bradley Hand", size: 26, relativeTo: .title3))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.custom("Bradley Hand", size: 16, relativeTo: .caption))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(style.defaultGradient)
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
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
                icon: "list.bullet",
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