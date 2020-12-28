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
    @IBOutlet weak var rightBarView: UIView!
    @IBOutlet weak var leftBarView: UIView!
    @IBOutlet weak var barWidth: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var gameModeImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var subrankLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var killLabel: UILabel!
    @IBOutlet weak var killImageView: UIImageView!
    @IBOutlet weak var assistLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    @IBOutlet weak var deathImageView: UIImageView!
    @IBOutlet weak var kdLabel: UILabel!
    @IBOutlet weak var kdImageView: UIImageView!
    
    var record: DBRecord? {
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
        
        rightBarView.backgroundColor = UIColor.systemGray3
        rightBarView.layer.cornerRadius = 2.5
        rightBarView.clipsToBounds = true
        
        resultLabel.font = AppTheme.spFont?.withSize(14)
        ruleNameLabel.font = AppTheme.spFont?.withSize(12)
        rankLabel.font = AppTheme.spFont?.withSize(12)
        subrankLabel.font = AppTheme.spFont?.withSize(8)
        
        killLabel.font = AppTheme.sp2Font?.withSize(10)
        assistLabel.font = AppTheme.sp2Font?.withSize(7)
        deathLabel.font = AppTheme.sp2Font?.withSize(10)
        kdLabel.font = AppTheme.sp2Font?.withSize(10)
    }
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ?
                UIColor.systemGray5 :
                AppUIColor.listItemBackgroundColor
        }
    }
    
    private func configure(with record: DBRecord) {
        battleNumberLabel.text = "#\(record.battleNumber) · \(record.stageName.localized)"
        resultLabel.text = "\(record.victory ? NSLocalizedString("VICTORY", comment: "") : NSLocalizedString("DEFEAT", comment: ""))"
        resultLabel.textColor = record.victory ?
            AppUIColor.spPink :
            AppUIColor.spLightGreen
        ruleNameLabel.text = record.rule.localized
        ruleNameLabel.textColor = record.gameModeColor
        gameModeImageView.image = UIImage(named: record.gameModeImageName)
        leftBarView.backgroundColor = record.victory ?
            AppUIColor.spPink :
            AppUIColor.spLightGreen
        barWidth.constant = self.rightBarView.frame.width * CGFloat(record.myPoint &/ (record.myPoint + record.otherPoint))
        
        weaponImageView.image = nil
        weaponImageView.sd_setImage(with: record.weaponImageURL)
        
        if record.gameMode == "gachi" ||
            record.gameMode == "league_pair" ||
            record.gameMode == "league_team" {
            rankLabel.text = record.udemaeName ?? "C-"
            subrankLabel.isHidden = record.udemaeSPlusNumber == nil
            if let sPlusNumber = record.udemaeSPlusNumber {
                subrankLabel.text = "\(sPlusNumber)"
            } else {
                subrankLabel.text = ""
            }
        } else {
            rankLabel.text = ""
            subrankLabel.isHidden = true;
        }
        
        if record.gameMode == "league_pair" ||
            record.gameMode == "league_team" {
            if let power = record.leaguePoint, power > 0 {
                powerLabel.text = String(format: "%@ power".localized, "\(power, places: 0)")
            } else {
                powerLabel.text = String(format: "%@ power".localized, "---")
            }
        } else if record.gameMode == "gachi", let power = record.estimateGachiPower {
            powerLabel.text = String(format: "%@ power".localized, "\(power)")
        } else {
            powerLabel.text = ""
        }
        
        killLabel.text = "\(record.killCount + record.assistCount)"
        assistLabel.text = " (\(record.assistCount))"
        assistLabel.isHidden = record.assistCount == 0
        deathLabel.text = "\(record.deathCount)"
        kdLabel.text = "\(Double(record.killCount) -/ Double(record.deathCount), places: 1)"
        
        let species = record.playerTypeSpecies
        self.killImageView.image = UIImage(named: species == .octolings ? "Tako_k" : "Ika_k")
        self.deathImageView.image = UIImage(named: species == .octolings ? "Tako_d" : "Ika_d")
        self.kdImageView.image = UIImage(named: species == .octolings ? "Tako_kd" : "Ika_kd")
        
        activityIndicatorView.isHidden = record.isDetail
        if !record.isDetail {
            activityIndicatorView.startAnimating()
        }
        containerView.alpha = record.isDetail ? 1 : 0.5
    }
    
}

extension DBRecord {
    
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
