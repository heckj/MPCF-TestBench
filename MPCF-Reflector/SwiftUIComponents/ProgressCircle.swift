//
//  ProgressCircle.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//  code from https://programmingwithswift.com/swiftui-progress-bar-indicator/
// updated to be respectful of background mode and cross
// platform (iOS and macOS)
//

import PreviewBackground
import SwiftUI

struct ProgressCircle: View {
    enum Stroke {
        case line
        case dotted

        func strokeStyle(lineWidth: CGFloat) -> StrokeStyle {
            switch self {
            case .line:
                return StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            case .dotted:
                return StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    dash: [12]
                )
            }
        }
    }

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

    private let value: Double
    private let maxValue: Double
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color?
    private let foregroundColor: Color
    private let lineWidth: CGFloat

    init(
        value: Double,
        maxValue: Double,
        style: Stroke = .line,
        backgroundEnabled: Bool = true,
        backgroundColor: Color? = nil,
        foregroundColor: Color = .primary,
        lineWidth: CGFloat = 10
    ) {
        self.value = value
        self.maxValue = maxValue
        self.style = style
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            if self.backgroundEnabled {
                if backgroundColor != nil {
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .foregroundColor(self.backgroundColor)
                } else {
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .foregroundColor(self.defaultBackgroundColor())
                }
            }

            Circle()
                .trim(from: 0, to: CGFloat(self.value / self.maxValue))
                .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                .foregroundColor(self.foregroundColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeIn)
        }
    }
}

#if DEBUG
    struct ProgressCircle_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            ProgressCircle(value: 69, maxValue: 100)
                                .frame(width: 150, height: 150, alignment: .center)
                                .padding()

                            ProgressCircle(
                                value: 69,
                                maxValue: 100,
                                style: ProgressCircle.Stroke.dotted,
                                foregroundColor: .blue
                            )
                            .frame(width: 150, height: 150, alignment: .center)
                            .padding()
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
