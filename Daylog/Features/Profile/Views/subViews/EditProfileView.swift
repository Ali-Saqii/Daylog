//
//  EditProfileView.swift
//  Daylog
//
//  Created by Mac mini on 29/08/2026.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var profileVm : ProfileViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileViewModel())
}
