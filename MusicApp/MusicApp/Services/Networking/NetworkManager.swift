//
//  NetworkManager.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 29.08.21.
//

import Foundation
import Moya
import Moya_ObjectMapper

class NetworkManager {
    private let provider = MoyaProvider<MusicApi>(plugins: [NetworkLoggerPlugin()])
    static var shared = NetworkManager()
    private init() {}
    
    func getMusic(text: String, completion: @escaping (SearchResponse) -> Void, failure: @escaping () -> Void) {
        provider.request(MusicApi.getMusic(search: text)) { result in
            switch result {
            case .success(let response):
                guard let music = try? response.mapObject(SearchResponse.self) else { return }
                completion(music)
            case .failure(let error):
                print(error)
            }
        }
    }
}
