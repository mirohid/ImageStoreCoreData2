//
//  DetailsViewController.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit
import CoreData

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
                print(" Failed to fetch users:", error.localizedDescription)
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

            if let img1 = user.image1 {
                cell.imageView1.image = UIImage(data: img1)
            } else {
                cell.imageView1.image = UIImage(named: "uploadImgBack")
            }

            if let img2 = user.image2 {
                cell.imageView2.image = UIImage(data: img2)
            } else {
                cell.imageView2.image = UIImage(named: "uploadImgBack")
            }
            
            cell.delegate = self

            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 290
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
