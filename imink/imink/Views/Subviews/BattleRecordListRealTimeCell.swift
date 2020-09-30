//
//  BattleRecordListRealTimeCell.swift
//  imink
//
//  Created by Jone Wang on 2020/9/25.
//

import UIKit
import Combine

class BattleRecordListRealTimeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "battleRecordListRealTimeCell"
    static let nib = UINib(nibName: "BattleRecordListRealTimeCell", bundle: .main)
    
    @IBOutlet weak var realTimeLabel: UILabel!
    @IBOutlet weak var battleNumberLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicatorView.startAnimating()

        cancelBag = Set<AnyCancellable>()
    }
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ?
                UIColor.systemBlue :
                AppUIColor.battleListRowBackgroundColor
            realTimeLabel.textColor = isSelected ?
                AppUIColor.recordRowTitleSelectedColor :
                AppUIColor.recordRowTitleNormalColor
        }
    }
    
    func configure(with record: Record) {        
        battleNumberLabel.text = "ID: \(record.battleNumber)"
        
        NotificationCenter.default
            .publisher(for: .isLoadingRealTimeBattleResult)
            .map { $0.object as! Bool }
            .sink { [weak self] in
                self?.battleNumberLabel.isHidden = $0
                self?.activityIndicatorView.isHidden = !$0
            }
            .store(in: &cancelBag)
    }
}
