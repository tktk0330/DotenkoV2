import SwiftUI

struct AccordionView<Content: View>: View {
    let title: String
    let content: Content
    @State private var isExpanded: Bool = false
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? Appearance.Icon.chevronUp : Appearance.Icon.chevronDown)
                        .foregroundColor(Appearance.Color.commonWhite)
                        .font(.system(size: 14))
                }
            }
            
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
        .background(Color.gray.opacity(1.0))
        .cornerRadius(10)
    }
} 
