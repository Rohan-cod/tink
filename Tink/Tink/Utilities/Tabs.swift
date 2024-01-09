//
//  Tabs.swift
//  Tink
//
//  Created by Rohan  Gupta on 09/01/24.
//

import SwiftUI

public enum Tabs {
    case home
    case book
    case profile
    case checkmark
    
    var index: Int {
        switch self {
        case .home:
            return 0
        case .book:
            return 1
        case .profile:
            return 2
        case .checkmark:
            return 3
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .book:
            return "Book"
        case .profile:
            return "Profile"
        case .checkmark:
            return "Checkmark"
        }
    }
    
    var tabImageUnSelected: String {
        switch self {
        case .home:
            return "house"
        case .book:
            return "book"
        case .profile:
            return "person"
        case .checkmark:
            return "checkmark.circle"
        }
    }
    
    static var tabs: [Self] {
        [.home, .book, .profile, .checkmark]
    }
    
    var view: any View {
        switch self {
        case .home:
            return HomeView()
        case .book:
            return BookView()
        case .profile:
            return ProfileView()
        case .checkmark:
            return CheckmarkView()
        }
    }
}
