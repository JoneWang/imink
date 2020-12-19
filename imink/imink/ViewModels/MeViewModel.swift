//
//  MeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation
import Combine
import Moya
import CXMoya

class MeViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var records: Records?
    @Published var nicknameAndIcons: NicknameAndIcon?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        
        isLoading = true
        
        sn2Provider.requestPublisher(.records)
            .receive(on: DispatchQueue.main)
            .map(\.data)
            .compactMap { data -> Records? in
                // Cache
                AppUserDefaults.shared.splatoon2RecordsData = data
                return data.decode(Records.self)
            }
            .flatMap { [weak self] records -> AnyPublisher<Response, MoyaError> in
                self?.records = records
                return sn2Provider.requestPublisher(.nicknameAndIcon(id: records.records.player.principalId))
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .map(\.data)
            .compactMap { data -> NicknameAndIcon? in
                // Cache
                AppUserDefaults.shared.splatoon2NicknameAndIconData = data
                return data.decode(NicknameAndIcon.self)
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
        
        records = recordsData.decode(Records.self)
        nicknameAndIcons = nicknameAndIconData.decode(NicknameAndIcon.self)
    }
    
}
