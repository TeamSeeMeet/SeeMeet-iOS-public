import Foundation

// MARK: - friendsDataModel
struct FriendsDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String?
    let data: [FriendsData]?
}

// MARK: - Datum
struct FriendsData: Codable {
    let id: Int
    let username: String
    let email: String?

    init(){
        self.id = 0
        self.username = ""
        self.email = ""
    }
    
}

extension FriendsData: Equatable {
    static func == (lhs: FriendsData, rhs: FriendsData) -> Bool {
        return lhs.id == rhs.id
    }
}

extension FriendsData: Comparable {//Comparable 이게 최선은 아닐듯 ..
    static func < (lhs: FriendsData, rhs: FriendsData) -> Bool {
        return lhs.username<lhs.username
    }
    
    static func <= (lhs: FriendsData, rhs: FriendsData) -> Bool {
        return lhs.username<=lhs.username
    }
    
    static func > (lhs: FriendsData, rhs: FriendsData) -> Bool {
        return lhs.username>lhs.username
    }
    
    static func >= (lhs: FriendsData, rhs: FriendsData) -> Bool {
        return lhs.username>=lhs.username
    }
    
    
}

