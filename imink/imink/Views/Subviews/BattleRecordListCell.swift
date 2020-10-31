//
//  BattleRecordListCell.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import SwiftUI
import SnapKit
import SDWebImage

class BattleRecordListCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "BattleRecordListCell", bundle: .main)
    
    @IBOutlet weak var weaponImageView: UIImageView!
    @IBOutlet weak var battleNumberLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var ruleNameLabel: UILabel!
    @IBOutlet weak var gameModeNameLabel: UILabel!
    @IBOutlet weak var killInfoLabel: UILabel!
    @IBOutlet weak var stageNameLabel: UILabel!
    @IBOutlet weak var rightBarView: UIView!
    @IBOutlet weak var leftBarView: UIView!
    @IBOutlet weak var barWidth: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var gameModeImageView: UIImageView!
    
    var record: Record? {
        didSet {
            guard let record = record else { return }
            if record == oldValue { return }
            
            configure(with: record)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        rightBarView.backgroundColor = UIColor.gray
        rightBarView.layer.cornerRadius = 4
        rightBarView.clipsToBounds = true
        
        battleNumberLabel.font = AppTheme.sp2Font?.withSize(10)
        resultLabel.font = AppTheme.spFont?.withSize(17)
        stageNameLabel.font = AppTheme.spFont?.withSize(14)
        gameModeNameLabel.font = AppTheme.spFont?.withSize(10)
        killInfoLabel.font = AppTheme.sp2Font?.withSize(14)
        ruleNameLabel.font = AppTheme.sp2Font?.withSize(10)
        
    }
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ?
                UIColor.systemBlue :
                AppUIColor.listItemBackgroundColor
            killInfoLabel.textColor = isSelected ?
                AppUIColor.recordRowTitleSelectedColor :
                AppUIColor.recordRowTitleNormalColor
            stageNameLabel.textColor = isSelected ?
                AppUIColor.recordRowTitleSelectedColor :
                AppUIColor.recordRowTitleNormalColor
        }
    }
    
    private func configure(with record: Record) {
        battleNumberLabel.text = record.battleNumber
        resultLabel.text = "\(record.victory ? NSLocalizedString("VICTORY", comment: "") : NSLocalizedString("DEFEAT", comment: ""))"
        resultLabel.textColor = record.victory ?
            AppUIColor.spPink :
            AppUIColor.spLightGreen
        ruleNameLabel.text = record.stageName.localized
        gameModeImageView.image = UIImage(named: record.gameModeImageName)
        gameModeNameLabel.text = record.gameMode.localized
        gameModeNameLabel.textColor = record.gameModeColor
        killInfoLabel.text = "\(record.killTotalCount) k  \(record.deathCount) d"
        stageNameLabel.text = record.rule.localized
        leftBarView.backgroundColor = record.victory ?
            AppUIColor.spPink :
            AppUIColor.spLightGreen
        barWidth.constant = self.rightBarView.frame.width * CGFloat(record.myPoint &/ (record.myPoint + record.otherPoint))
        
        weaponImageView.image = nil
        weaponImageView.sd_setImage(with: record.weaponImageURL)
        
        activityIndicatorView.isHidden = record.isDetail
        if !record.isDetail {
            activityIndicatorView.startAnimating()
        }
        containerView.alpha = record.isDetail ? 1 : 0.5
    }
    
}

extension Record {
    
    var gameModeImageName: String {
        switch gameModeKey {
        case "regular":
            return "RegularBattle"
        case "gachi":
            return "RankedBattle"
        case "league_pair":
            return "LeagueBattle"
        case "league_team":
            return "LeagueBattle"
        case "fes_team":
            return "SplatfestBattle"
        case "fes_solo":
            return "SplatfestBattle"
        case "private":
            return "PrivateBattle"
        default:
            return ""
        }
    }
    
    var gameModeColor: UIColor {
        switch gameModeKey {
        case "regular":
            return AppUIColor.spLightGreen
        case "gachi":
            return AppUIColor.spOrange
        case "league_pair":
            return AppUIColor.spPink
        case "league_team":
            return AppUIColor.spPink
        case "fes_team":
            return AppUIColor.spYellow
        case "fes_solo":
            return AppUIColor.spYellow
        case "private":
            return AppUIColor.spPurple
        default:
            return UIColor.black
        }
    }
    
}
