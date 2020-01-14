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

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageSuperView: UIView!
    
    @IBOutlet weak var shadowEffectView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var profileDescriptionContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var logOutButon: UIButton!
    let newPostButton = NewPostButton()

    
    var arrayOfTweetIds = [String]()
    var currentUser = User(userDict: [:])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "user_timeline"
    
       APIManager.shared.getProfileInfo { (user) in
              self.currentUser = user
            self.configureViewController()
          }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureViewController() {
        
        profileImageView.clipsToBounds = true
        profileImageSuperView.backgroundColor = .white
        profileImageSuperView.layer.cornerRadius = profileImageSuperView.frame.size.width / 2
        
        backgroundImageView.backgroundColor = .gray
        backgroundImageView.contentMode = .scaleAspectFill
        profileDescriptionContainer.tintColor = .blue
        
        shadowEffectView.backgroundColor = .gray
        let gradrientLayer = CAGradientLayer()
        gradrientLayer.frame = shadowEffectView.bounds
        let topColor = UIColor.black
        let bottomColor = UIColor.gray
        gradrientLayer.colors = [topColor, bottomColor]
        //gradrientLayer.locations = [0.0, 1.0]
        //self.shadowEffectView.layer.addSublayer(gradrientLayer)
        
        guard let profileImageUrl = NSURL(string: currentUser.profile_image_url_string!) else {return}
        guard let backgroundImageUrl = NSURL(string: currentUser.profile_banner_url_string!) else {return}
        
        profileImageView.af_setImage(withURL: (profileImageUrl as URL), filter: CircleFilter())
        backgroundImageView.af_setImage(withURL: (backgroundImageUrl as URL))
        
        let name = currentUser.name
        let screenName = currentUser.screen_name
        let location = currentUser.location
        let date = currentUser.created_at
        let followingCount = currentUser.friends_count
        let followersCount = currentUser.followers_count
        
        nameLabel.text = String(name!)
        screenNameLabel.text = "@" + String(screenName!)
        locationLabel.text = "🏠" + String(location!)
        dateLabel.text = "📅Registration date: " + String(date!).toShortDateFormat()
        followersCountLabel.text = String(followersCount!) + " followers"
        followingCountLabel.text = String(followingCount!) + " following"
        
        configurePostButton()
    }
    
    func configurePostButton() {
        self.view.addSubview(newPostButton)
        newPostButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.rightAnchor.constraint(equalTo: newPostButton.rightAnchor, constant: 20),
        newPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        newPostButton.widthAnchor.constraint(equalToConstant: 50),
        newPostButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
    @IBAction func logOut() {
        APIManager.shared.logOut {
            self.dismiss(animated: true, completion: nil)
            self.appDelegate.userLoggedIn = false
        }
        
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
