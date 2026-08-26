//
//  PrimaryAuthButton.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

struct PrimaryAuthButton: View {
    let action : () -> Void
    let title : String
    let isDiable : Bool
    let height : CGFloat
    let radius : CGFloat
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(.orange)
                .font(.dmSans(30, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }.background(
          RoundedRectangle(cornerRadius: radius)
            .stroke(.orange,lineWidth: 2)
        )

    }
}

#Preview {
    PrimaryAuthButton(action: {}, title: "login",isDiable: false, height: 60, radius: 10)
}
