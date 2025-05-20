//
//  DetailsViewController.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit
import CoreData
import AVFoundation

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
        // Save video data temporarily to file to generate thumbnail
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let tempVideoURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        do {
            try videoData.write(to: tempVideoURL)
            let asset = AVAsset(url: tempVideoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 2)
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            try? FileManager.default.removeItem(at: tempVideoURL) // Clean up
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error)")
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

}
