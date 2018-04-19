//
//  ViewController.swift
//  ESCHints
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var hints = [String]()

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var hintTableView: UITableView!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let questionString = questionTextView.textStorage.string
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

