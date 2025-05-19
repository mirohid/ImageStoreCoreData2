//
//  DetailsTableViewCell.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit

protocol DetailsTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(cell: DetailsTableViewCell)
}


class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var deleteImageView: UIImageView!
    weak var delegate: DetailsTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView1.contentMode = .scaleAspectFill
        imageView2.contentMode = .scaleAspectFill
        imageView1.clipsToBounds = true
        imageView2.clipsToBounds = true
        
        // Enable tap on delete icon
        deleteImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
        deleteImageView.addGestureRecognizer(tap)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
                                             
    @objc func deleteTapped() {
            delegate?.deleteButtonTapped(cell: self)
        }
    
}
