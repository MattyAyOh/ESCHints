//
//  ViewController.swift
//  ESCHints
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

public let HintType = "Hint"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase

    var hints = [String]()

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var hintTableView: UITableView!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let questionString = questionTextView.textStorage.string
        if questionString.contains("SETROOM:") {
            UserDefaults().set(questionString.replacingOccurrences(of: "SETROOM:", with: "").trimmingCharacters(in: .whitespacesAndNewlines), forKey: "room")
            return
        }
        
        print(questionString) // Need to send to iCloud
    }
    
    @IBAction func clearHistoryPressed(_ sender: Any) {
        hints.removeAll()
        hintTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hints = ["test","totally", "rad", "receipt"]
        hintTableView.tableFooterView = UIView()
        hintTableView.layer.cornerRadius = 10
        hintTableView.layer.masksToBounds = true
        
        questionTextView.layer.cornerRadius = 10
        questionTextView.layer.masksToBounds = true
        questionTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func fetchAllHints() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HintType, predicate: predicate)

        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error as NSError)
                    print("Cloud Query Error - Fetch Establishments: \(error)")
                }
                return
            }
            
            self.hints = records?.map(Lobby.init)
            
            DispatchQueue.main.async {
                completion(self.cachedLobbies, error)
            }
        }
        
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results, error in

            self.items.removeAll(keepingCapacity: true)
            results?.forEach({ (record: CKRecord) in
                self.items.append(Establishment(record: record,
                                                database: self.publicDB))
            })
            DispatchQueue.main.async {
                self.delegate?.modelUpdated()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hintTableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
        if let hintCell = cell as? HintTableViewCell {
            hintCell.hintTextView.text = hints[indexPath.row]
        }
        return cell
        
    }


}

