//
//  AvatarViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/4/4.
//

import Foundation
import Combine

class AvatarViewModel: ObservableObject {
   
    @Published var image: URL?
    
    private var cancelBag = Set<AnyCancellable>()
    
    func update(principalId: String) {
        cancelBag = Set<AnyCancellable>()
        
        image = nil
        
        Splatoon2API.nicknameAndIcon(id: principalId)
            .request()
            .decode(type: NicknameAndIcon.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .map { $0.nicknameAndIcons.first?.thumbnailUrl }
            .sink { _ in
            } receiveValue: {
                self.image = $0
            }
            .store(in: &cancelBag)
    }
}
