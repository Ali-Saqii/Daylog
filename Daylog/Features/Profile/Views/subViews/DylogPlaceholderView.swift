//
//  DylogPlaceholderView.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import SwiftUI

struct DylogPlaceholderView: View {
    var body: some View {
        Image("daylogPlaceholderImage")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .clipped()
        
    }
}

#Preview {
    DylogPlaceholderView()
}
