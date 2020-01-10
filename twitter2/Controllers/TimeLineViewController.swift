//
//  TimeLineViewController.swift
//  twitter2
//
//  Created by MacBook Pro  on 31.12.2019.
//  Copyright © 2019 MacBook Pro . All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching{
    
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    var arrayOfTweetIds = [String]()
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "home_timeline"
        view.backgroundColor = .white
        
        do {
            try self.fetchedResultController.performFetch()
            print("fetched from CoreData: \(self.fetchedResultController.sections?[0].numberOfObjects ?? 404)")
        } catch let error  {
            print("ERROR: \(error)")
        }

        //попробовать убрать clearData, в базу помещать твиты только с болеее новой айдишкой
        APIManager.shared.getTimeline{ (response) in
            print(response)
            self.clearData()
            self.saveInCoreDataWith(array: response)
        }
        // timeLineTableView.reloadData()
        
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self
        timeLineTableView.prefetchDataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    private func createTweetEntityFrom(dictionary: TweetStruct) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let tweetEntity = NSEntityDescription.insertNewObject(forEntityName: "Tweet", into: context) as? Tweet {
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
    
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Tweet.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ("id_str"), ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private func clearData() {

        //сделать через forEach()
        
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TwitterTableViewCell
        if let cell_tweet = fetchedResultController.object(at: indexPath) as? Tweet {
            cell.nameLabel.text = cell_tweet.name
            cell.screenNameLabel.text = "@\(cell_tweet.screen_name ?? "error")"
            cell.tweetTextView.text = cell_tweet.text
            cell.dateLabel.text = cell_tweet.created_at?.toShortDateFormat()
            let URL = NSURL(string: cell_tweet.profile_image_url!)!
            cell.avatarImage.af_setImage(withURL: URL as URL, filter: CircleFilter())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("indexpath = \(indexPath.row)")
        let lastItem = timeLineTableView.numberOfRows(inSection: 0) - 1
        print("lastItem= \(lastItem)")
        guard let oldestTweet = arrayOfTweetIds.min() else {return}
        guard let oldestTweetInt = Int(oldestTweet) else {return}
        guard page < 5 else {return}
        if indexPath.row == lastItem {
            APIManager.shared.getTimelineWithId(id:String(oldestTweetInt-1)) { (response) in
                print(response)
                self.saveInCoreDataWith(array: response)
                self.page+=1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        
//        print(indexPaths)
//        print(timeLineTableView.numberOfRows(inSection: 0))
//        print("the oldest tweet id = \(arrayOfTweetIds.min())")
//        if indexPaths.count >= timeLineTableView.numberOfRows(inSection: 0){
//            page+=1
//            APIManager.shared.getTimeline(page: self.page){ (response) in
//                print(response)
//                self.clearData()
//                self.saveInCoreDataWith(array: response)
//            }
//        }
    }
    
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = timeLineTableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}


extension TimeLineViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.timeLineTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.timeLineTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            print("update...")
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.timeLineTableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timeLineTableView.beginUpdates()
    }
}

//E MMM dd HH:mm:ss Z yyyy -> "MMM d, h:mm a"
extension String {
    func toShortDateFormat (format: String = "MMM d, HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        guard let dateObj = formatter.date(from: self) else {return "error"}
        
        // show time interval, if > week: show date
        let secondsAgo = Int(Date().timeIntervalSince(dateObj))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return ("\(secondsAgo) sec.")
        } else if secondsAgo < hour {
            return ("\(secondsAgo / minute) min.")
        } else if secondsAgo < day {
            return ("\(secondsAgo / hour) h.")
        } else if secondsAgo < week {
            return ("\(secondsAgo / day) d. ago")
        } else {
            formatter.dateFormat = format
            return formatter.string(from: dateObj)
        }
    }
}


