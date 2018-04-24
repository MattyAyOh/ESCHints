//
//  ViewController.swift
//  ESCHints
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase
    
    var hints = [Hint]()

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var hintTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let questionString = questionTextView.textStorage.string
        if questionString.contains("SETROOM:") {
            UserDefaults().set(questionString.replacingOccurrences(of: "SETROOM:", with: "").trimmingCharacters(in: .whitespacesAndNewlines), forKey: "room")
            return
        }
        
        let newQuestion:Question = Question()
        newQuestion.questionString = "Programmatic Question"
        guard let record = newQuestion.record() else {
            return
        }
        publicDB.save(record) { (savedRecord, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Save Question: \(error)")
                }
                return
            }
            print("Saved Successfully")
        }
        
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        fetchAllHints()
    }
    
    @IBAction func clearHistoryPressed(_ sender: Any) {
        for hint in hints {
            if let record = hint.record() {
                publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Delete Hint: \(error)")
                        }
                    }
                }
            }
        }
        hints.removeAll()
        hintTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAllHints()
        hintTableView.tableFooterView = UIView()
        hintTableView.layer.cornerRadius = 10
        hintTableView.layer.masksToBounds = true
        
        questionTextView.layer.cornerRadius = 10
        questionTextView.layer.masksToBounds = true
        questionTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func saveHint() {
        let newHint:Hint = Hint()
        newHint.hintString = "Programmatic Hint"
        guard let record = newHint.record() else {
            return
        }
        publicDB.save(record) { (savedRecord, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Save Hint: \(error)")
                }
                return
            }
            print("Saved Successfully")
        }
    }
    
    func fetchAllHints() {
        hintTableView.isHidden = true
        activityIndicator.isHidden = false
        
        var currentRoom = "sepia"
        if let defaultsRoom = UserDefaults().value(forKey: "room") as? String {
            currentRoom = defaultsRoom
        }
        let predicate = NSPredicate(format: "room = %@", currentRoom)
        let query = CKQuery(recordType: HintType, predicate: predicate)

        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Hints: \(error)")
                }
                return
            }
            
            if let allHints = records?.map(Hint.init) {
                self.hints = allHints
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.hintTableView.isHidden = false
                    self.hintTableView.reloadData()
                }
            }
        }
    }

    // MARK: TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Ask Away...")
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Ask Away..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hintTableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
        if let hintCell = cell as? HintTableViewCell {
            hintCell.hintTextView.text = hints[indexPath.row].hintString
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let record = hints[indexPath.row].record() {
                publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Cloud Query Error - Delete Hint: \(error)")
                        }
                        self.hints.remove(at: indexPath.row)
                        self.hintTableView.deleteRows(at: [indexPath], with: .fade)
                        self.hintTableView.reloadData()
                    }
                }
            }
        }
    }
}

