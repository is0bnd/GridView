//
//  ViewController.swift
//  GridviewDemo
//
//  Created by shuai on 2018/10/17.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    lazy var imageSources: [[String]] = {
        var imageSources = [[String]]()
        for i in 0..<100 {
            let count = arc4random_uniform(9) + 1
            let urlStr = "http://img1.imgtn.bdimg.com/it/u=1377601590,3543048053&fm=200&gp=0.jpg"
            let images = Array(repeating: urlStr, count: Int(count))
            imageSources.append(images)
        }
        return imageSources
    }()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let num = NSDecimalNumber(floatLiteral: 8.800000000001)
        let formatter : NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.floor
        let str = formatter.string(from: num)!
        print(str)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }
    
   
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewControllerCell") as! ViewControllerCell
        let imageSource = imageSources[indexPath.section]
        cell.gridView.imageSource = imageSource
        cell.titleLabel.text = "第\(indexPath.section)组"
        cell.countLabel.text = "共\(imageSource.count)张照片"
        return cell
    }
}

class ViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        gridView.delegate = self
    }
    
}

extension ViewControllerCell: GridViewDelegate {
    func gridView(_ gridView: GridView, didSelectImageAt Index: Int) {
        print(Index)
    }
}
