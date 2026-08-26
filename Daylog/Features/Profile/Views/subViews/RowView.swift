//
//  RowView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

struct RowView: View {
    let image: String
    let title: String
    let text : String
    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.title3)
            Text (title)
                .font(.dmSans(20, weight: .medium))
                .padding(.leading,10)
                Spacer()
            Text (text)
                .font(.title3)
        }.padding(.horizontal)
    }
}

