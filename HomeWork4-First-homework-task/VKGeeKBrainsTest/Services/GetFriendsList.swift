//
//  GetFriendsList.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import Foundation
import RealmSwift

struct FriendsResponse: Decodable {
    var response: Response
    
    struct Response: Decodable {
        var count: Int
        var items: [Item]
        
        struct Item: Decodable {
            var id: Int
            var firstName: String
            var lastName: String
            var avatar: String
            var deactivated: String?

            private enum CodingKeys: String, CodingKey {
                case id
                case firstName = "first_name"
                case lastName = "last_name"
                case avatar  = "photo_50"
                case deactivated
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                id = try container.decode(Int.self, forKey: .id)
                firstName = try container.decode(String.self, forKey: .firstName)
                lastName = try container.decode(String.self, forKey: .lastName)
                avatar = try container.decode(String.self, forKey: .avatar)

                deactivated = try? container.decodeIfPresent(String.self, forKey: .deactivated)
            }
        }
    }
}

final class GetFriendsList {
    

     func loadData() {
        

        let configuration = URLSessionConfiguration.default

        let session =  URLSession(configuration: configuration)

        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        urlConstructor.path = "/method/friends.get"
        urlConstructor.queryItems = [
            URLQueryItem(name: "user_id", value: String(Session.instance.userId)),
            URLQueryItem(name: "fields", value: "photo_50"),
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "v", value: "5.122")
        ]
        

        let task = session.dataTask(with: urlConstructor.url!) { (data, response, error) in

            guard let data = data else { return }
            
            do {
                let arrayFriends = try JSONDecoder().decode(FriendsResponse.self, from: data)
                var friendList: [Friend] = []
                for i in 0...arrayFriends.response.items.count-1 {

                    if arrayFriends.response.items[i].deactivated == nil {
                        let name = ((arrayFriends.response.items[i].firstName) + " " + (arrayFriends.response.items[i].lastName))
                        let avatar = arrayFriends.response.items[i].avatar
                        let id = String(arrayFriends.response.items[i].id)
                        friendList.append(Friend.init(userName: name, userAvatar: avatar, ownerID: id))
                    }
                }
                
                DispatchQueue.main.async {
                    RealmOperations().saveFriendsToRealm(friendList)
                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}
