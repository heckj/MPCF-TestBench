//
//  ProgressBar.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//  code from https://programmingwithswift.com/swiftui-progress-bar-indicator/
//

import SwiftUI

struct ProgressConfig {
    static func backgroundColor() -> Color {
        return Color(
            UIColor(
                red: 245 / 255,
                green: 245 / 255,
                blue: 245 / 255,
                alpha: 1.0
            )
        )
    }

    static func foregroundColor() -> Color {
        return Color.primary
    }
}

struct ProgressBar: View {
    private let value: Double
    private let maxValue: Double
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color

    init(
        value: Double,
        maxValue: Double,
        backgroundEnabled: Bool = true,
        backgroundColor: Color = Color(
            UIColor(
                red: 245 / 255,
                green: 245 / 255,
                blue: 245 / 255,
                alpha: 1.0
            )
        ),
        foregroundColor: Color = Color.black
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
                    Capsule()
                        .foregroundColor(self.backgroundColor)
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

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(value: 69, maxValue: 100)
            .frame(height: 10, alignment: .leading)
    }
}
