//
//  VKService.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import Foundation

final class VKService {
    
    enum Method {
        case friends
        case photos (ownerID: String)
        case groups
        case searchGroup (searchText: String)
        
        var path: String {
            switch self {
            case .friends:
                return "/method/friends.get"
            case .groups:
                return "/method/photos.getAll"
            case .photos:
                return "/method/groups.get"
            case .searchGroup:
                return "/method/groups.search"
            }
        }
        
        var parameters: [String: String] {
            switch self {
            case .friends:
                return [
                    "fields": "photo_50",
                ]
            case .groups:
                return [
                    "extended": "1",
                ]
            case let .photos(ownerID):
                return [
                    "owner_id": ownerID,
                ]
            case let .searchGroup(searchText):
                return [
                    "q": searchText,
                    "type": "group",
                ]
            }
        }
    }
    
    
    func loadData(_ method: Method, complition: @escaping () -> Void ) {
        
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        urlConstructor.path = method.path
        
        let basicQueryItems = [
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "v", value: "5.122")
        ]
        let additionalQueryItems = method.parameters.map{ URLQueryItem(name: $0, value: $1) }
        urlConstructor.queryItems = basicQueryItems + additionalQueryItems
        
        guard let url = urlConstructor.url else {
            complition()
            return
        }
        
        let configuration = URLSessionConfiguration.default
        let session =  URLSession(configuration: configuration)
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print(data ?? "пусто")
            complition()
        }
        task.resume()
    }    
}
