//
//  HomeView.swift
//  Tink
//
//  Created by Rohan  Gupta on 09/01/24.
//

import SwiftUI

private struct Constants {
    static let topRectangleHeight: CGFloat = UIScreen.main.bounds.height * 0.2
    static let topRectangleCornerRadius: CGFloat = UIScreen.main.bounds.height * 0.15 / 2
    
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    static let roundedRectangleWidth: CGFloat = 140
}

struct HomeView: View {
    @State var showIssuesHover: Bool = false
    @State var selectedIssues: [String] = []
    
    private let tracks: ClosedRange<Int> = 0...10
    private let games: ClosedRange<Int> = 0...7
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(spacing: 20) {
                    headerView()
                        .ignoresSafeArea(.all)
                        .padding(.top, -60)
                    
                    bodyView()
                }
                .opacity(showIssuesHover ? 0.4 : 1)
                
                if showIssuesHover {
                    IssueSelectionView(showIssuesHover: $showIssuesHover, selectedIssues: $selectedIssues)
                }
            }
        }
    }
    
    private func headerView() -> some View {
        Rectangle()
            .fill(.green)
            .frame(height: Constants.topRectangleHeight)
            .cornerRadius(Constants.topRectangleCornerRadius, corners: .bottomLeft)
            .overlay {
                HStack(spacing: 20) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hello !")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        
                        Text("Shreya")
                            .font(.system(size: 34))
                            .fontWeight(.bold)
                    }
                    
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: Constants.topRectangleHeight * 0.5, height: Constants.topRectangleHeight * 0.5)
                }
                .foregroundStyle(.white)
                .padding()
                .padding(.top, 30)
            }
    }
    
    private func bodyView() -> some View {
        VStack {
            tinkView()
                .padding(.bottom)
            
            Rectangle()
                .foregroundStyle(.gray)
                .frame(height: 2)
                .padding(.horizontal)
            
            createAMemeButton()
                .padding(.bottom)
            
            quoteOfTheDayView()
                .padding(.bottom)
            
            tracksView()
                .padding(.bottom)
            
            gamesView()
                .padding(.bottom)
        }
    }
    
    private func tinkView() -> some View {
        HStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: Constants.screenWidth * 0.3,
                       height: Constants.screenWidth * 0.3)
                .foregroundStyle(.cyan)
            
            VStack(spacing: 10) {
                Text("I'M TINK")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                
                Button {
                    withAnimation {
                        showIssuesHover = true
                    }
                } label: {
                    Text("LET'S TALK")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background {
                            Color.black
                                .cornerRadius(8)
                        }
                }
                
                
            }
            
            Spacer()
        }
    }
    
    private func createAMemeButton() -> some View {
        HStack {
            Button {
                print("Create a meme tapped!")
            } label: {
                Text("CREATE A MEME")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background {
                        Color.green
                            .cornerRadius(8)
                    }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func quoteOfTheDayView() -> some View {
        VStack {
            HStack {
                Spacer()
                Text("QUOTE OF THE DAY")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
            
            Rectangle()
                .fill(.yellow)
                .frame(height: 40)
                .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
                .shadow(radius: 4)
                .overlay {
                    Text("Be yourself no matter what they say!")
                }
        }
        .padding(.horizontal)
    }
    
    private func tracksView() -> some View {
        VStack {
            HStack {
                Text("TRACKS TO REFRESH YOUR MOOD!")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(tracks, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: Constants.roundedRectangleWidth,
                                   height: Constants.roundedRectangleWidth)
                    }
                }
            }
            .padding(.leading)
        }
        .padding(.horizontal)
    }
    
    private func gamesView() -> some View {
        VStack {
            HStack {
                Text("GAMES TO RELAX YOUR MIND!")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(games, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: Constants.roundedRectangleWidth,
                                   height: Constants.roundedRectangleWidth)
                    }
                }
            }
            .padding(.leading)
        }
        .padding(.horizontal)
    }
}

struct IssueSelectionView: View {
    @Binding private var showIssuesHover: Bool
    
    var issues: [String] = ["Anger", "Anxiety and Panic Attacks", "Depression", "Eating Disorders", "Self-esteem", "Self-harm", "Stress", "Sleep disorders"]
    
    @Binding var selectedIssues: [String]
    
    init(showIssuesHover: Binding<Bool>, selectedIssues: Binding<[String]>) {
        _showIssuesHover = showIssuesHover
        _selectedIssues = selectedIssues
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .frame(width: Constants.screenWidth * 0.9,
                   height: Constants.screenWidth * 0.9)
            .shadow(radius: 12)
            .overlay {
                VStack {
                    HStack {
                        Text("Select issues you are concerned about")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.leading)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding([.top, .leading], 40)
                        Spacer()
                    }
                    
                    WrappingHStack(issues) { issue in
                        Text(issue)
                            .foregroundStyle(.green)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(issueIsSelected(issue) ? .clear : .gray, lineWidth: 1)
                                    .fill(issueIsSelected(issue) ? .green.opacity(0.2) : .clear)
                            }
                            .onTapGesture {
                                withAnimation {
                                    if issueIsSelected(issue) {
                                        selectedIssues.removeAll { $0 == issue }
                                    } else {
                                        selectedIssues.append(issue)
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 30)
                    
                    
                    Spacer()
                    
                    doneButton()
                        .padding(.bottom, 40)
                    
                }
            }
    }
    
    private func issueIsSelected(_ issue: String) -> Bool {
        selectedIssues.contains(issue)
    }
    
    private func doneButton() -> some View {
        Button {
            withAnimation {
                showIssuesHover = false
            }
        } label: {
            Text("Done")
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 40)
                .background {
                    Color.yellow
                        .cornerRadius(20)
                }
        }
        .shadow(radius: 2)
    }
}

#Preview {
    HomeView()
}
