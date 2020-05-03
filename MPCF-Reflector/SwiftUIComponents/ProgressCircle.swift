//
//  ProgressCircle.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//  code from https://programmingwithswift.com/swiftui-progress-bar-indicator/
//

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

    private let value: Double
    private let maxValue: Double
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineWidth: CGFloat

    init(
        value: Double,
        maxValue: Double,
        style: Stroke = .line,
        backgroundEnabled: Bool = true,
        backgroundColor: Color = Color(
            UIColor(
                red: 245 / 255,
                green: 245 / 255,
                blue: 245 / 255,
                alpha: 1.0
            )
        ),
        foregroundColor: Color = Color.black,
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
                Circle()
                    .stroke(lineWidth: self.lineWidth)
                    .foregroundColor(self.backgroundColor)
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
struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(value: 69, maxValue: 100)
            .frame(width: 50, height: 50, alignment: .center)
    }
}
