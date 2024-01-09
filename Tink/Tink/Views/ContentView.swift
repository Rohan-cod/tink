//
//  ContentView.swift
//  Tink
//
//  Created by Rohan  Gupta on 09/01/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var tabBarViewModel = TabBarViewModel()
    
    var body: some View {
        TabView(selection: $tabBarViewModel.selectedTab,
                content:  {
            ForEach(Tabs.tabs, id: \.index) { tab in
                AnyView(tab.view)
                    .tabItem {
                        Image(systemName: tab.tabImageUnSelected)
                        Text(tab.title)
                    }
                    .toolbar(.visible, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.green, for: .tabBar)
                    .tag(tab.index)
            }
        })
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
