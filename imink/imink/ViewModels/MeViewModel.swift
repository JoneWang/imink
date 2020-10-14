//
//  MeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation
import Combine

class MeViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var records: SP2Records?
    @Published var nicknameAndIcons: SP2NicknameAndIcon?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        
        isLoading = true
        
        Splatoon2API.records
            .request()
            .receive(on: DispatchQueue.main)
            .compactMap { data -> SP2Records? in
                // Cache
                AppUserDefaults.shared.splatoon2RecordsData = data
                return data.decode(SP2Records.self)
            }
            .flatMap { [weak self] records -> AnyPublisher<Data, APIError> in
                self?.records = records
                return Splatoon2API.nicknameAndIcon(id: records.records.player.principalId)
                    .request()
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .compactMap { data -> SP2NicknameAndIcon? in
                // Cache
                AppUserDefaults.shared.splatoon2NicknameAndIconData = data
                return data.decode(SP2NicknameAndIcon.self)
            }
            .sink { [weak self] error in
                self?.isLoading = false
            } receiveValue: { [weak self] nicknameAndIconData in
                self?.isLoading = false
                self?.nicknameAndIcons = nicknameAndIconData
            }
            .store(in: &cancelBag)
            
        loadCacheData()
    }
    
    func loadCacheData() {
        guard let recordsData = AppUserDefaults.shared.splatoon2RecordsData,
              let nicknameAndIconData = AppUserDefaults.shared.splatoon2NicknameAndIconData else {
            return
        }
        
        records = recordsData.decode(SP2Records.self)
        nicknameAndIcons = nicknameAndIconData.decode(SP2NicknameAndIcon.self)
    }
    
}
