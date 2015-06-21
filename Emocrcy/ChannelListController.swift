//
//  ChannelListController.swift
//  Emocrcy
//
//  Created by Symentis GmbH on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import UIKit

class ChannelListController: UITableViewController {
    
    struct Storyboard {
        struct Segues {
            static let login = "login"
            static let vote = "vote"
        }
        struct Cells {
            static let channelCell = "channelCell"
        }
    }
    
    var channels: [Channel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Emocracy"
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "updateData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        NSNotificationCenter.defaultCenter().addObserverForName("channels", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            if let dict = notification.userInfo as? [NSString:[Channel]],
                let channels = dict["channels"] {
                    self.channels =  channels
                    self.tableView.reloadData()
            }
            return
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("alive", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            if let dict = notification.userInfo as? [String:Int],
                let cid = dict["channel"],
                let channels = self.channels?.filter({ $0.id! == cid }){
                    
                    println("channel with id \(cid) is alive")
                    let channel = channels[0]
                    
                    let title = "\(channel.name!)"
                    let body = "What about you?"
                    UILocalNotification.notify(title, body:body, channelId:cid, withAction:true)
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("democracy", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            if let dict = notification.userInfo as? [String:Int],
                let cid = dict["channel"],
                let democracy = dict["democracy"],
                let channels = self.channels?.filter({ $0.id! == cid }){
                    
                    let channel = channels[0]
                    let title = "\(channel.name!)"
                    
                    let body: String
                    switch democracy {
                    case 0:
                        body = "\(title): Has Lost"
                    case 1:
                        body = "\(title): Has Won"
                    default:
                        body = ""
                    }
                    UILocalNotification.notify(title, body:body, channelId:cid, withAction:false)
                    println("channel with id \(cid) has decided \(democracy)")
                    
            }
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.userId == nil {
            self.performSegueWithIdentifier(Storyboard.Segues.login, sender: nil)
            return
        }
        
        initData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.userId != nil {
            initData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        WebService.channels { [weak self] in
            self?.channels = $0
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return channels?.count > 0 ? 1 : 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels?.count ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Cells.channelCell, forIndexPath: indexPath) as! ChannelCell
        
        
        let channel = channels?[indexPath.row]
        if let name = channel?.name,
            let yes = channel?.yes,
            let no = channel?.no {
                cell.channelLabel?.text = name
                cell.channelState?.text = "\(yes):\(no)"
        }
        
        cell.channelImageView.image = UIImage(named: "icon_\(channel!.id!)_white")
        
        
        switch (channel?.democracy, channel?.alive) {
        case (.Some(1), _):
            UIView.animateWithDuration(0.3){
                cell.backgroundColor = UIColor.colorWithHexString("#00df90")!
            }
            
        case (.Some(0), _):
            UIView.animateWithDuration(0.3){
                cell.backgroundColor = UIColor.colorWithHexString("#ff0391")!
            }
            
        case (.None, .Some(1)):
            UIView.animateWithDuration(0.3){
                cell.backgroundColor = UIColor.colorWithHexString("#ffba00")!
            }
            
        default:
            UIView.animateWithDuration(0.3){
                cell.backgroundColor = UIColor.colorWithHexString("#9d9d9d")!
            }
            
        }
        return cell
    }
    
    
    func updateData(sender: AnyObject){
        initData()
        refreshControl!.endRefreshing()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        switch (segue.identifier, segue.destinationViewController, tableView.indexPathForSelectedRow()){
        case let (.Some(Storyboard.Segues.vote), controller as VoteController, .Some(index)):
            controller.channel = channels?[index.row]
        default: break
        }
    }
    
    
}


class ChannelCell: UITableViewCell {
    @IBOutlet weak var channelImageView: UIImageView!
    
    @IBOutlet weak var channelLabel: UILabel!
    
    @IBOutlet weak var channelState: UILabel!
}
