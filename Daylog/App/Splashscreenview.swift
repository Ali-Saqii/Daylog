//
//  Splashscreenview.swift
//  Daylog
//
//  Created by Mac mini on 02/09/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding  var isActive : Bool
    @State private var iconScale: CGFloat = 0.85
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
            ZStack {
                Color.dlBackground
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ZStack {
                        Image("DaylogAppIcon")
                            .resizable()
                            .frame(width: 96, height: 96)
                            .foregroundStyle(Color.dlAccent)
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                    VStack(spacing: 4) {
                        Text("DayLog")
                            .font(.dmSans(25, weight: .bold))
                            .foregroundStyle(Color.dlInk)

                        Text("Habits & journal, together")
                            .font(.dmSans(15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .opacity(textOpacity)
                }
            }
            .task {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                    iconScale = 1.0
                    iconOpacity = 1
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    textOpacity = 1
                }

                withAnimation(.easeInOut(duration: 0.3)) {
                    isActive = true
                }
            }
        }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}
