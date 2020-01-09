//
//  ProfileViewController.swift
//  twitter2
//
//  Created by MacBook Pro  on 24.12.2019.
//  Copyright © 2019 MacBook Pro . All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageSuperView: UIView!
    
    @IBOutlet weak var shadowEffectView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var profileDescriptionContainer: UIView!
    
    var arrayOfTweetIds = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "user_timeline"
        profileImageView.backgroundColor = .green
        profileImageSuperView.backgroundColor = .red
        
        backgroundImageView.backgroundColor = .gray
        profileDescriptionContainer.tintColor = .blue
        shadowEffectView.backgroundColor = .red
        
        view.backgroundColor = .white
        do {
            try self.fetchedResultController.performFetch()
            print("fetched from CoreData: \(self.fetchedResultController.sections?[0].numberOfObjects ?? 404)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        APIManager.shared.getUserTimeline { (response) in
            self.clearData()
            self.saveInCoreDataWith(array: response)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createTweetEntityFrom(dictionary: TweetStruct) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let tweetEntity = NSEntityDescription.insertNewObject(forEntityName: "UserTweet", into: context) as? UserTweet {
            tweetEntity.id_str = dictionary.id_str
            arrayOfTweetIds.append(dictionary.id_str)
            tweetEntity.created_at = dictionary.createdAt
            tweetEntity.name = dictionary.name
            tweetEntity.profile_image_url = dictionary.profileImageUrl
            tweetEntity.screen_name = dictionary.screenName
            tweetEntity.text = dictionary.text
            return tweetEntity
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [TweetStruct]) {
        _ = array.map{self.createTweetEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTweet")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserTweet.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ("id_str"), ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TwitterTableViewCell
        if let cell_tweet = fetchedResultController.object(at: indexPath) as? UserTweet {
            cell.nameLabel.text = cell_tweet.name
            cell.screenNameLabel.text = "@\(cell_tweet.screen_name ?? "error")"
            cell.tweetTextView.text = cell_tweet.text
            cell.dateLabel.text = cell_tweet.created_at?.toShortDateFormat()
            let URL = NSURL(string: cell_tweet.profile_image_url!)!
            cell.avatarImage.af_setImage(withURL: URL as URL, filter: CircleFilter())
        }
        return cell
    }
    
    
      func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


}


extension ProfileViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            print("update...")
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
