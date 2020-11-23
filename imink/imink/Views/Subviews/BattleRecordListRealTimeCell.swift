//
//  BattleRecordListRealTimeCell.swift
//  imink
//
//  Created by Jone Wang on 2020/9/25.
//

import UIKit
import Combine

class BattleRecordListRealTimeCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "BattleRecordListRealTimeCell", bundle: .main)
    
    @IBOutlet weak var realTimeLabel: UILabel!
    @IBOutlet weak var battleNumberLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    var record: DBRecord? {
        didSet {
            guard let record = record else { return }
            if record == oldValue { return }
            
            configure(with: record)
        }
    }
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        realTimeLabel.font = AppTheme.spFont?.withSize(18)
        battleNumberLabel.font = AppTheme.spFont?.withSize(18)
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
                AppUIColor.listItemBackgroundColor
            realTimeLabel.textColor = isSelected ?
                AppUIColor.recordRowTitleSelectedColor :
                AppUIColor.recordRowTitleNormalColor
        }
    }
    
    func configure(with record: DBRecord) {
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
