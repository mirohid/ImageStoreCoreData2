//
//  DetailsViewController.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit
import CoreData
import AVFoundation
import AVKit
class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DetailsTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var users: [UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Users"

        // Register XIB for custom cell
        let nib = UINib(nibName: "DetailsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")

        tableView.delegate = self
        tableView.dataSource = self

        fetchUsers()

    }
    
    
    func fetchUsers() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()

        do {
            users = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch users:", error.localizedDescription)
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DetailsTableViewCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.nameLabel.text = "Name: \(user.name ?? "")"
        cell.emailLabel.text = "Email: \(user.email ?? "")"

        // Set image1 or video1 thumbnail
        if let videoData1 = user.video1, let thumbnail1 = generateThumbnail(from: videoData1) {
            cell.imageView1.image = thumbnail1
            cell.showPlayIconOnImageView1(true)  // method to show play icon overlay
        } else if let img1 = user.image1 {
            cell.imageView1.image = UIImage(data: img1)
            cell.showPlayIconOnImageView1(false)
        } else {
            cell.imageView1.image = UIImage(named: "uploadImgBack")
            cell.showPlayIconOnImageView1(false)
        }

        // Set image2 or video2 thumbnail
        if let videoData2 = user.video2, let thumbnail2 = generateThumbnail(from: videoData2) {
            cell.imageView2.image = thumbnail2
            cell.showPlayIconOnImageView2(true)
        } else if let img2 = user.image2 {
            cell.imageView2.image = UIImage(data: img2)
            cell.showPlayIconOnImageView2(false)
        } else {
            cell.imageView2.image = UIImage(named: "uploadImgBack")
            cell.showPlayIconOnImageView2(false)
        }

        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }

    // Generate thumbnail from video data
   
    func generateThumbnail(from videoData: Data) -> UIImage? {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        do {
            try videoData.write(to: tempURL)
            let asset = AVAsset(url: tempURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let cgImage = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 2), actualTime: nil)
            try? FileManager.default.removeItem(at: tempURL)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail generation failed: \(error)")
            return nil
        }
    }

    // MARK: - Delete Delegate Method
    func deleteButtonTapped(cell: DetailsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let userToDelete = self.users[indexPath.row]
            context.delete(userToDelete)

            do {
                try context.save()
                self.users.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete user: \(error)")
            }
        }))

        present(alert, animated: true)
    }
    
    
    func imageView1Tapped(cell: DetailsTableViewCell) {
            guard let indexPath = tableView.indexPath(for: cell),
                  let videoData = users[indexPath.row].video1 else { return }
            playVideo(from: videoData)
        }

        func imageView2Tapped(cell: DetailsTableViewCell) {
            guard let indexPath = tableView.indexPath(for: cell),
                  let videoData = users[indexPath.row].video2 else { return }
            playVideo(from: videoData)
        }

        // MARK: - Play Video
        func playVideo(from videoData: Data) {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            do {
                try videoData.write(to: tempURL)
                let player = AVPlayer(url: tempURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                present(playerVC, animated: true) {
                    player.play()
                }
            } catch {
                print("Video playback failed: \(error)")
            }
        }

}
