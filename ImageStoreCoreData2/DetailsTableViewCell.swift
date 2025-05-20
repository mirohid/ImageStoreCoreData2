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
    
    // Play icon image views (programmatically added)
       private let playIcon1: UIImageView = {
           let iv = UIImageView()
           iv.image = UIImage(systemName: "play.circle.fill") // Use SF Symbol or custom image
           iv.tintColor = .white
           iv.contentMode = .scaleAspectFit
           iv.translatesAutoresizingMaskIntoConstraints = false
           iv.isHidden = true
           return iv
       }()

       private let playIcon2: UIImageView = {
           let iv = UIImageView()
           iv.image = UIImage(systemName: "play.circle.fill")
           iv.tintColor = .white
           iv.contentMode = .scaleAspectFit
           iv.translatesAutoresizingMaskIntoConstraints = false
           iv.isHidden = true
           return iv
       }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imageView1.contentMode = .scaleAspectFill
        imageView2.contentMode = .scaleAspectFill
        imageView1.clipsToBounds = true
        imageView2.clipsToBounds = true

        // Add play icons programmatically on top of image views
        imageView1.addSubview(playIcon1)
        imageView2.addSubview(playIcon2)

        // Constraints for playIcon1 (centered in imageView1)
        NSLayoutConstraint.activate([
            playIcon1.centerXAnchor.constraint(equalTo: imageView1.centerXAnchor),
            playIcon1.centerYAnchor.constraint(equalTo: imageView1.centerYAnchor),
            playIcon1.widthAnchor.constraint(equalToConstant: 40),
            playIcon1.heightAnchor.constraint(equalToConstant: 40),
        ])

        // Constraints for playIcon2 (centered in imageView2)
        NSLayoutConstraint.activate([
            playIcon2.centerXAnchor.constraint(equalTo: imageView2.centerXAnchor),
            playIcon2.centerYAnchor.constraint(equalTo: imageView2.centerYAnchor),
            playIcon2.widthAnchor.constraint(equalToConstant: 40),
            playIcon2.heightAnchor.constraint(equalToConstant: 40),
        ])

        // Enable tap on delete icon
        deleteImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
        deleteImageView.addGestureRecognizer(tap)
    }

    @objc func deleteTapped() {
        delegate?.deleteButtonTapped(cell: self)
    }

    // MARK: - Public methods to show/hide play icon overlays
    func showPlayIconOnImageView1(_ show: Bool) {
        playIcon1.isHidden = !show
    }

    func showPlayIconOnImageView2(_ show: Bool) {
        playIcon2.isHidden = !show
    }
}

