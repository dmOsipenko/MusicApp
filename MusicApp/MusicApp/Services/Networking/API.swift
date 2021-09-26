
import Foundation
import Moya

enum MusicApi {
    case getMusic(search: String)
}

extension MusicApi: TargetType {
    var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }
    
    var path: String {
        return "/search"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var parameter:[String: Any]? {
        var params = [String: Any]()
        switch self {
        case .getMusic(let text):
            params["term"] = text
            params["limit"] = 10
            params["media"] = "music"
        }
        return params
    }
    
    var task: Task {
        guard let params = parameter else {
            return .requestPlain
        }
        return .requestParameters(parameters: params, encoding: parameterEncoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
}

