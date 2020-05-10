//
//  ProgressBar.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//  code from https://programmingwithswift.com/swiftui-progress-bar-indicator/
//

import PreviewBackground
import SwiftUI

struct ProgressBar: View {
    private let value: Double
    private let maxValue: Double
    private let backgroundEnabled: Bool
    private let backgroundColor: Color?
    private let foregroundColor: Color

    /// Exposes the colorscheme in this view so we can make
    /// choices based on it.
    @Environment(\.colorScheme) public var colorSchemeMode

    private func defaultBackgroundColor() -> Color {
        switch colorSchemeMode {
        case .dark:
            return Color(
                Color.RGBColorSpace.sRGB,
                red: 50 / 255,
                green: 50 / 255,
                blue: 50 / 255,
                opacity: 1
            )

        case .light:
            return Color(
                Color.RGBColorSpace.sRGB,
                red: 235 / 255,
                green: 235 / 255,
                blue: 235 / 255,
                opacity: 1
            )
        @unknown default:
            return Color.yellow
        }
    }

    init(
        value: Double,
        maxValue: Double,
        backgroundEnabled: Bool = true,
        backgroundColor: Color? = nil,
        foregroundColor: Color = .primary
    ) {
        self.value = value
        self.maxValue = maxValue
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    private func progress(
        value: Double,
        maxValue: Double,
        width: CGFloat
    ) -> CGFloat {
        let percentage = value / maxValue
        return width * CGFloat(percentage)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometryReader in
                if self.backgroundEnabled {
                    if self.backgroundColor != nil {
                        Capsule()
                            .foregroundColor(self.backgroundColor)
                    } else {
                        Capsule()
                            .foregroundColor(self.defaultBackgroundColor())
                    }

                }

                Capsule()
                    .frame(
                        width: self.progress(
                            value: self.value,
                            maxValue: self.maxValue,
                            width: geometryReader.size.width
                        )
                    )
                    .foregroundColor(self.foregroundColor)
                    .animation(.easeIn)
            }
        }
        .frame(minHeight: 2, idealHeight: 10, maxHeight: 20, alignment: .center)
    }
}

#if DEBUG
    struct ProgressBar_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            ProgressBar(value: 69, maxValue: 100)
                                .frame(height: 10, alignment: .leading)

                            ProgressBar(value: 69, maxValue: 100, foregroundColor: .blue)
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
