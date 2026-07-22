//
//  SpectrumView.swift
//  OnlyWidgetExtension
//
//  Created by Jacklandrin on 2024/6/9.
//

import Defines
import SwiftUI

struct SpectrumView: View {
    private let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .red]

    init(unitType _: UnitType) {}

    var body: some View {
        AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center
        )
        .opacity(0.2)
    }
}
