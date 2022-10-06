import Foundation

struct Constants {
    
    struct URL{
        //baseURL
        static let baseURL = "http://3.34.126.253:3000"
        
        //auth관련
        static let registerURL = baseURL + "/auth"
        static let loginURL = baseURL + "/auth/login"
        static let socialLoginURL = baseURL + "/auth/social"
        static let putNameAndIdURL = baseURL + "/auth/"
        static let putWithdrawalURL = baseURL + "/auth/withdrawal"
        static let refreshAccessTokenURL = baseURL + "/auth/refresh"
        
        //home관련
        static let homeURL = { (year: String, month: String) -> String in
            baseURL + "/plan/comeplan/\(year)/\(month)"
        }
        static let lastURL = { (year: String, month: String, day: String) -> String in
            baseURL + "/plan/lastplan/\(year)/\(month)/\(day)"
        }
        
        //Calendar
        static var calendarURL = { (year: String, month: String) -> String in
            baseURL + "/plan/month/\(year)/\(month)"
        }
        
        //친구 관련
        static let friendsListURL = baseURL + "/friend/list"
        static let searchFriendsURL = baseURL + "/friend/search"
        static let addFriendsURL = baseURL + "/friend/addFriend"
        
        //약속 관련
        static let plansListURL = baseURL + "/invitation/list"
        static let plansDetailURL = { (postID: String) in
            baseURL + "/invitation/\(postID)"
        }
        static let plansCanceledDetailURL = { (postID: String) in
            baseURL + "/invitation/canceled/\(postID)"
        }
        static let plansResponseURL = { (date: String) in
            baseURL + "/plan/response/\(date)"
        }
        static let plansRequestURL = { (plansID: String) in
            baseURL + "/invitation-response/\(plansID)"
        }
        static let plansRejectURL = { (plansID: String) in
            baseURL + "/invitation-response/\(plansID)/reject"
        }
        static let plansDeleteURL = { (plansID: String) in
            baseURL + "/plan/delete/\(plansID)"
        }
        
        //약속신청 관련
        static let invitationURL = baseURL + "/invitation"
        static let invitationPlanURL = { (year: String, month: String) in
            baseURL + "/plan/invitationplan/\(year)/\(month)"
        }
        
        //마이페이지 관련
        static let postProfileImageURL = baseURL + "/user/upload"
        static let putPasswordUrl = baseURL + "/user/password"
        static let postNotificationSetURL = baseURL + "/user/push"
    }
}
