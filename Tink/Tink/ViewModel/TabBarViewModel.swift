//
//  TabBarViewModel.swift
//  Tink
//
//  Created by Rohan  Gupta on 09/01/24.
//

import Foundation

class TabBarViewModel: ObservableObject {
    @Published var selectedTab: Int = Tabs.home.index
}
