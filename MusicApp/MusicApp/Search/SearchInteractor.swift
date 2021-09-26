//
//  SearchInteractor.swift
//  IMusic
//
//  Created by Алексей Пархоменко on 12/08/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
  func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {

  var presenter: SearchPresentationLogic?
  var service: SearchService?
  
  func makeRequest(request: Search.Model.Request.RequestType) {
    if service == nil {
      service = SearchService()
    }
    switch request {
    case .getTracks(let searchTerm):
        presenter?.presentData(response: Search.Model.Response.ResponseType.presentFooterView)
        NetworkManager.shared.getMusic(text: searchTerm) { [weak self] searchResponse in
            self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(searchResponse: searchResponse))
        } failure: {
            print("ERROR")
        }

        print("interactor .getTracks")
        
    }
  }
  
}
