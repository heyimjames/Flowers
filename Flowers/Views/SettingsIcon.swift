import SwiftUI

struct SettingsIcon: View {
    var size: CGFloat = 24
    var color: Color = .flowerTextPrimary
    
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 272
            
            Path { path in
                // Full SVG path from the provided icon
                path.move(to: CGPoint(x: 223.498 * scale, y: 137.445 * scale))
                path.addCurve(to: CGPoint(x: 220.714 * scale, y: 136 * scale), 
                             control1: CGPoint(x: 222.637 * scale, y: 136.945 * scale), 
                             control2: CGPoint(x: 221.691 * scale, y: 136.467 * scale))
                path.addCurve(to: CGPoint(x: 223.498 * scale, y: 134.555 * scale), 
                             control1: CGPoint(x: 221.691 * scale, y: 135.532 * scale), 
                             control2: CGPoint(x: 222.637 * scale, y: 135.054 * scale))
                path.addCurve(to: CGPoint(x: 236.081 * scale, y: 123.648 * scale), 
                             control1: CGPoint(x: 228.37 * scale, y: 131.785 * scale), 
                             control2: CGPoint(x: 232.646 * scale, y: 128.078 * scale))
                path.addCurve(to: CGPoint(x: 243.507 * scale, y: 108.744 * scale), 
                             control1: CGPoint(x: 239.515 * scale, y: 119.219 * scale), 
                             control2: CGPoint(x: 242.039 * scale, y: 114.153 * scale))
                path.addCurve(to: CGPoint(x: 244.637 * scale, y: 92.1309 * scale), 
                             control1: CGPoint(x: 244.976 * scale, y: 103.335 * scale), 
                             control2: CGPoint(x: 245.36 * scale, y: 97.6891 * scale))
                path.addCurve(to: CGPoint(x: 239.298 * scale, y: 76.3585 * scale), 
                             control1: CGPoint(x: 243.915 * scale, y: 86.5728 * scale), 
                             control2: CGPoint(x: 242.1 * scale, y: 81.2124 * scale))
                path.addCurve(to: CGPoint(x: 228.308 * scale, y: 63.8482 * scale), 
                             control1: CGPoint(x: 236.495 * scale, y: 71.5045 * scale), 
                             control2: CGPoint(x: 232.76 * scale, y: 67.2528 * scale))
                path.addCurve(to: CGPoint(x: 213.355 * scale, y: 56.5207 * scale), 
                             control1: CGPoint(x: 223.855 * scale, y: 60.4436 * scale), 
                             control2: CGPoint(x: 218.774 * scale, y: 57.9533 * scale))
                path.addCurve(to: CGPoint(x: 196.734 * scale, y: 55.5007 * scale), 
                             control1: CGPoint(x: 207.936 * scale, y: 55.0881 * scale), 
                             control2: CGPoint(x: 202.288 * scale, y: 54.7414 * scale))
                path.addCurve(to: CGPoint(x: 180.998 * scale, y: 60.9449 * scale), 
                             control1: CGPoint(x: 191.181 * scale, y: 56.26 * scale), 
                             control2: CGPoint(x: 185.833 * scale, y: 58.1102 * scale))
                path.addCurve(to: CGPoint(x: 178.363 * scale, y: 62.6343 * scale), 
                             control1: CGPoint(x: 180.137 * scale, y: 61.4443 * scale), 
                             control2: CGPoint(x: 179.245 * scale, y: 62.0074 * scale))
                path.addCurve(to: CGPoint(x: 178.501 * scale, y: 59.4468 * scale), 
                             control1: CGPoint(x: 178.448 * scale, y: 61.5718 * scale), 
                             control2: CGPoint(x: 178.501 * scale, y: 60.5093 * scale))
                path.addCurve(to: CGPoint(x: 166.053 * scale, y: 29.3947 * scale), 
                             control1: CGPoint(x: 178.501 * scale, y: 48.1751 * scale), 
                             control2: CGPoint(x: 174.023 * scale, y: 37.365 * scale))
                path.addCurve(to: CGPoint(x: 136.001 * scale, y: 16.9468 * scale), 
                             control1: CGPoint(x: 158.083 * scale, y: 21.4244 * scale), 
                             control2: CGPoint(x: 147.273 * scale, y: 16.9468 * scale))
                path.addCurve(to: CGPoint(x: 105.949 * scale, y: 29.3947 * scale), 
                             control1: CGPoint(x: 124.729 * scale, y: 16.9468 * scale), 
                             control2: CGPoint(x: 113.919 * scale, y: 21.4244 * scale))
                path.addCurve(to: CGPoint(x: 93.5008 * scale, y: 59.4468 * scale), 
                             control1: CGPoint(x: 97.9785 * scale, y: 37.365 * scale), 
                             control2: CGPoint(x: 93.5008 * scale, y: 48.1751 * scale))
                path.addCurve(to: CGPoint(x: 93.6389 * scale, y: 62.6343 * scale), 
                             control1: CGPoint(x: 93.5008 * scale, y: 60.4455 * scale), 
                             control2: CGPoint(x: 93.5008 * scale, y: 61.508 * scale))
                path.addCurve(to: CGPoint(x: 91.0039 * scale, y: 60.9449 * scale), 
                             control1: CGPoint(x: 92.757 * scale, y: 62.0286 * scale), 
                             control2: CGPoint(x: 91.8645 * scale, y: 61.4443 * scale))
                path.addCurve(to: CGPoint(x: 75.2672 * scale, y: 55.5007 * scale), 
                             control1: CGPoint(x: 86.1687 * scale, y: 58.1102 * scale), 
                             control2: CGPoint(x: 80.8205 * scale, y: 56.26 * scale))
                path.addCurve(to: CGPoint(x: 58.6467 * scale, y: 56.5207 * scale), 
                             control1: CGPoint(x: 69.714 * scale, y: 54.7414 * scale), 
                             control2: CGPoint(x: 64.0654 * scale, y: 55.0881 * scale))
                path.addCurve(to: CGPoint(x: 43.6938 * scale, y: 63.8482 * scale), 
                             control1: CGPoint(x: 53.228 * scale, y: 57.9533 * scale), 
                             control2: CGPoint(x: 48.1462 * scale, y: 60.4436 * scale))
                path.addCurve(to: CGPoint(x: 32.704 * scale, y: 76.3585 * scale), 
                             control1: CGPoint(x: 39.2414 * scale, y: 67.2528 * scale), 
                             control2: CGPoint(x: 35.5065 * scale, y: 71.5045 * scale))
                path.addCurve(to: CGPoint(x: 27.3643 * scale, y: 92.1309 * scale), 
                             control1: CGPoint(x: 29.9014 * scale, y: 81.2124 * scale), 
                             control2: CGPoint(x: 28.0867 * scale, y: 86.5728 * scale))
                path.addCurve(to: CGPoint(x: 28.4945 * scale, y: 108.744 * scale), 
                             control1: CGPoint(x: 26.6418 * scale, y: 97.6891 * scale), 
                             control2: CGPoint(x: 27.026 * scale, y: 103.335 * scale))
                path.addCurve(to: CGPoint(x: 35.9211 * scale, y: 123.648 * scale), 
                             control1: CGPoint(x: 29.963 * scale, y: 114.153 * scale), 
                             control2: CGPoint(x: 32.487 * scale, y: 119.219 * scale))
                path.addCurve(to: CGPoint(x: 48.5039 * scale, y: 134.555 * scale), 
                             control1: CGPoint(x: 39.3551 * scale, y: 128.078 * scale), 
                             control2: CGPoint(x: 43.6315 * scale, y: 131.785 * scale))
                path.addCurve(to: CGPoint(x: 51.2877 * scale, y: 136 * scale), 
                             control1: CGPoint(x: 49.3645 * scale, y: 135.054 * scale), 
                             control2: CGPoint(x: 50.3102 * scale, y: 135.532 * scale))
                path.addCurve(to: CGPoint(x: 48.5039 * scale, y: 137.445 * scale), 
                             control1: CGPoint(x: 50.3102 * scale, y: 136.467 * scale), 
                             control2: CGPoint(x: 49.3645 * scale, y: 136.945 * scale))
                path.addCurve(to: CGPoint(x: 35.9211 * scale, y: 148.351 * scale), 
                             control1: CGPoint(x: 43.6315 * scale, y: 140.215 * scale), 
                             control2: CGPoint(x: 39.3551 * scale, y: 143.922 * scale))
                path.addCurve(to: CGPoint(x: 28.4945 * scale, y: 163.255 * scale), 
                             control1: CGPoint(x: 32.487 * scale, y: 152.781 * scale), 
                             control2: CGPoint(x: 29.963 * scale, y: 157.846 * scale))
                path.addCurve(to: CGPoint(x: 27.3643 * scale, y: 179.869 * scale), 
                             control1: CGPoint(x: 27.026 * scale, y: 168.665 * scale), 
                             control2: CGPoint(x: 26.6418 * scale, y: 174.311 * scale))
                path.addCurve(to: CGPoint(x: 32.704 * scale, y: 195.641 * scale), 
                             control1: CGPoint(x: 28.0867 * scale, y: 185.427 * scale), 
                             control2: CGPoint(x: 29.9014 * scale, y: 190.787 * scale))
                path.addCurve(to: CGPoint(x: 43.6938 * scale, y: 208.151 * scale), 
                             control1: CGPoint(x: 35.5065 * scale, y: 200.495 * scale), 
                             control2: CGPoint(x: 39.2414 * scale, y: 204.747 * scale))
                path.addCurve(to: CGPoint(x: 58.6467 * scale, y: 215.479 * scale), 
                             control1: CGPoint(x: 48.1462 * scale, y: 211.556 * scale), 
                             control2: CGPoint(x: 53.228 * scale, y: 214.046 * scale))
                path.addCurve(to: CGPoint(x: 75.2672 * scale, y: 216.499 * scale), 
                             control1: CGPoint(x: 64.0654 * scale, y: 216.912 * scale), 
                             control2: CGPoint(x: 69.714 * scale, y: 217.258 * scale))
                path.addCurve(to: CGPoint(x: 91.0039 * scale, y: 211.055 * scale), 
                             control1: CGPoint(x: 80.8205 * scale, y: 215.74 * scale), 
                             control2: CGPoint(x: 86.1687 * scale, y: 213.889 * scale))
                path.addCurve(to: CGPoint(x: 93.6389 * scale, y: 209.365 * scale), 
                             control1: CGPoint(x: 91.8645 * scale, y: 210.555 * scale), 
                             control2: CGPoint(x: 92.757 * scale, y: 209.971 * scale))
                path.addCurve(to: CGPoint(x: 93.5008 * scale, y: 212.5 * scale), 
                             control1: CGPoint(x: 93.5539 * scale, y: 210.428 * scale), 
                             control2: CGPoint(x: 93.5008 * scale, y: 211.49 * scale))
                path.addCurve(to: CGPoint(x: 105.949 * scale, y: 242.552 * scale), 
                             control1: CGPoint(x: 93.5008 * scale, y: 223.772 * scale), 
                             control2: CGPoint(x: 97.9785 * scale, y: 234.582 * scale))
                path.addCurve(to: CGPoint(x: 136.001 * scale, y: 255 * scale), 
                             control1: CGPoint(x: 113.919 * scale, y: 250.522 * scale), 
                             control2: CGPoint(x: 124.729 * scale, y: 255 * scale))
                path.addCurve(to: CGPoint(x: 166.053 * scale, y: 242.552 * scale), 
                             control1: CGPoint(x: 147.273 * scale, y: 255 * scale), 
                             control2: CGPoint(x: 158.083 * scale, y: 250.522 * scale))
                path.addCurve(to: CGPoint(x: 178.501 * scale, y: 212.5 * scale), 
                             control1: CGPoint(x: 174.023 * scale, y: 234.582 * scale), 
                             control2: CGPoint(x: 178.501 * scale, y: 223.772 * scale))
                path.addCurve(to: CGPoint(x: 178.363 * scale, y: 209.365 * scale), 
                             control1: CGPoint(x: 178.501 * scale, y: 211.501 * scale), 
                             control2: CGPoint(x: 178.448 * scale, y: 210.439 * scale))
                path.addCurve(to: CGPoint(x: 180.998 * scale, y: 211.055 * scale), 
                             control1: CGPoint(x: 179.245 * scale, y: 209.971 * scale), 
                             control2: CGPoint(x: 180.137 * scale, y: 210.555 * scale))
                path.addCurve(to: CGPoint(x: 202.184 * scale, y: 216.75 * scale), 
                             control1: CGPoint(x: 187.436 * scale, y: 214.784 * scale), 
                             control2: CGPoint(x: 194.744 * scale, y: 216.749 * scale))
                path.addCurve(to: CGPoint(x: 213.255 * scale, y: 215.284 * scale), 
                             control1: CGPoint(x: 205.922 * scale, y: 216.745 * scale), 
                             control2: CGPoint(x: 209.644 * scale, y: 216.252 * scale))
                path.addCurve(to: CGPoint(x: 234.208 * scale, y: 202.252 * scale), 
                             control1: CGPoint(x: 221.375 * scale, y: 213.107 * scale), 
                             control2: CGPoint(x: 228.666 * scale, y: 208.572 * scale))
                path.addCurve(to: CGPoint(x: 244.39 * scale, y: 179.776 * scale), 
                             control1: CGPoint(x: 239.75 * scale, y: 195.932 * scale), 
                             control2: CGPoint(x: 243.293 * scale, y: 188.11 * scale))
                path.addCurve(to: CGPoint(x: 240.368 * scale, y: 155.431 * scale), 
                             control1: CGPoint(x: 245.486 * scale, y: 171.441 * scale), 
                             control2: CGPoint(x: 244.086 * scale, y: 162.969 * scale))
                path.addCurve(to: CGPoint(x: 223.498 * scale, y: 137.424 * scale), 
                             control1: CGPoint(x: 236.649 * scale, y: 147.892 * scale), 
                             control2: CGPoint(x: 230.778 * scale, y: 141.626 * scale))
                path.closeSubpath()
                
                // Inner circle
                path.move(to: CGPoint(x: 136.001 * scale, y: 165.75 * scale))
                path.addCurve(to: CGPoint(x: 119.473 * scale, y: 160.736 * scale), 
                             control1: CGPoint(x: 130.117 * scale, y: 165.75 * scale), 
                             control2: CGPoint(x: 124.365 * scale, y: 164.005 * scale))
                path.addCurve(to: CGPoint(x: 108.515 * scale, y: 147.385 * scale), 
                             control1: CGPoint(x: 114.58 * scale, y: 157.467 * scale), 
                             control2: CGPoint(x: 110.767 * scale, y: 152.821 * scale))
                path.addCurve(to: CGPoint(x: 106.822 * scale, y: 130.196 * scale), 
                             control1: CGPoint(x: 106.264 * scale, y: 141.949 * scale), 
                             control2: CGPoint(x: 105.675 * scale, y: 135.967 * scale))
                path.addCurve(to: CGPoint(x: 114.964 * scale, y: 114.963 * scale), 
                             control1: CGPoint(x: 107.97 * scale, y: 124.425 * scale), 
                             control2: CGPoint(x: 110.804 * scale, y: 119.124 * scale))
                path.addCurve(to: CGPoint(x: 130.197 * scale, y: 106.822 * scale), 
                             control1: CGPoint(x: 119.125 * scale, y: 110.803 * scale), 
                             control2: CGPoint(x: 124.426 * scale, y: 107.969 * scale))
                path.addCurve(to: CGPoint(x: 147.386 * scale, y: 108.514 * scale), 
                             control1: CGPoint(x: 135.968 * scale, y: 105.674 * scale), 
                             control2: CGPoint(x: 141.95 * scale, y: 106.263 * scale))
                path.addCurve(to: CGPoint(x: 160.737 * scale, y: 119.472 * scale), 
                             control1: CGPoint(x: 152.822 * scale, y: 110.766 * scale), 
                             control2: CGPoint(x: 157.468 * scale, y: 114.579 * scale))
                path.addCurve(to: CGPoint(x: 165.751 * scale, y: 136 * scale), 
                             control1: CGPoint(x: 164.006 * scale, y: 124.364 * scale), 
                             control2: CGPoint(x: 165.751 * scale, y: 130.116 * scale))
                path.addCurve(to: CGPoint(x: 157.037 * scale, y: 157.036 * scale), 
                             control1: CGPoint(x: 165.751 * scale, y: 143.89 * scale), 
                             control2: CGPoint(x: 162.616 * scale, y: 151.457 * scale))
                path.addCurve(to: CGPoint(x: 136.001 * scale, y: 165.75 * scale), 
                             control1: CGPoint(x: 151.458 * scale, y: 162.615 * scale), 
                             control2: CGPoint(x: 143.891 * scale, y: 165.75 * scale))
                path.closeSubpath()
            }
            .fill(color)
        }
        .frame(width: size, height: size)
    }
}

struct SettingsIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SettingsIcon(size: 48, color: .flowerPrimary)
            SettingsIcon(size: 32, color: .black)
            SettingsIcon(size: 24, color: .gray)
        }
        .padding()
    }
} 