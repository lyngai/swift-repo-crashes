import SwiftUI

struct SocialView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var searchText = ""
    @State private var showingAddFriend = false
    
    var body: some View {
        NavigationView {
            List {
                // 搜索栏
                SearchBar(text: $searchText)
                
                // 好友列表
                ForEach(habitViewModel.currentUser?.friends ?? [], id: \.self) { friendId in
                    FriendRow(friendId: friendId)
                }
            }
            .navigationTitle("好友圈")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索好友", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FriendRow: View {
    let friendId: UUID
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading) {
                Text("用户\(friendId.uuidString.prefix(4))")
                    .font(.headline)
                Text("已坚持跑步 30 天")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("点赞")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var searchResults: [UUID] = []
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                List(searchResults, id: \.self) { userId in
                    HStack {
                        Text("用户\(userId.uuidString.prefix(4))")
                        Spacer()
                        Button("添加") {
                            // 添加好友逻辑
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("添加好友")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
} 