//
//  ViewController.swift
//  FinanceTrack
//
//  Created by vlad on 8/8/21.
//  Copyright © 2021 Vlad Lazoryk. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<SpendingModel>!

    @IBOutlet weak var allSpending: UILabel!
    @IBOutlet weak var hawManyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var limitLabe: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var numberFromKeyBoard: [UIButton]! {
        didSet {
            for button in numberFromKeyBoard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    var styllTyping = false
    var categoryName = ""
    var displayValue: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftLabels()
        spendingArray = realm.objects(SpendingModel.self)
        allSpendin()
        
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        guard let number = sender.currentTitle else { return }
        
        if number == "0" && displayLabel.text == "0" {
            styllTyping = false
        } else {
            
            if styllTyping {
                if displayLabel.text!.count < 15 {
                    displayLabel.text = displayLabel.text! + number
                }
            } else {
                displayLabel.text = number
                styllTyping = true
            }
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        styllTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        guard let categoryName = sender.currentTitle else { return }
        guard let displayValue = Int(displayLabel.text!) else { return }
        displayLabel.text = "0"
        styllTyping = false
     
        let value = SpendingModel(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
        }
        
        leftLabels()
        allSpendin()
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { (action) in
            let tfsum = ac.textFields?[0].text
            
            let tfday = ac.textFields?[1].text
            
            guard tfday != "" && tfsum != "" else { return }
            
            self.limitLabe.text = tfsum
            
            if let day = tfday {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabe.text, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].limitSum = self.self.limitLabe.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDay = lastDay as NSDate
                    }
                }
                
            }
            
            self.leftLabels()
        }
        
        ac.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        ac.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
            
        }
        
        ac.addAction(alertInstall)
        ac.addAction(alertCancel)
        
        present(ac, animated: true, completion: nil)
    }
    
    func leftLabels() {
       
        let limit = self.realm.objects(Limit.self)
        
        guard limit.isEmpty == false else { return }
        
        limitLabe.text = limit[0].limitSum

        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date

        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)

        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any

        let filtredLimit: Int = realm.objects(SpendingModel.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")

        spendByCheck.text = "\(filtredLimit)"
        
        guard let a = Int(limitLabe.text!) else { return }
        guard let b = Int(spendByCheck.text!) else { return }
        let c = a - b
        
        hawManyCanSpend.text = "\(c)"
        
        
    }
    
    func allSpendin() {
        let allSpend: Int = realm.objects(SpendingModel.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Еда")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Одежда")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "Category_Связь")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "Category_Досуг")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "Category_Красота")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "Category_Авто")
        default: cell.recordImage.image = #imageLiteral(resourceName: "Display")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, _) in
            try! self.realm.write {
                self.realm.delete(editingRow)
                self.leftLabels()
                self.allSpendin()
                tableView.reloadData()
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
