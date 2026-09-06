//
//  overlayCntentView.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import SwiftUI

struct overlayCntentView: View {
    var body: some View {
        Circle()
            .stroke(.orange,lineWidth: 2)
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(.orange)
                    .frame(width: 25, height: 25)
                    .overlay {
                        Text("+")
                            .font(.dmSans(25, weight: .black))
                            .foregroundStyle(.white)
                        
                    }
            }
    }
}

#Preview {
    overlayCntentView()
}
