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
                    
                    let title = "\(channel.name)"
                    let body = "What about you?"
                    UILocalNotification.notify(title, body:body, channelId:cid)
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("democracy", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            if let dict = notification.userInfo as? [String:Int],
                let cid = dict["channel"],
                let democracy = dict["democracy"],
                let channels = self.channels?.filter({ $0.id! == cid }){
                    
                    let channel = channels[0]
                    let title = "\(channel.name)"
                    
                    let body: String
                    switch democracy {
                    case 0:
                        body = "Has Lost"
                    case 1:
                        body = "Has Won"
                    default:
                        body = ""
                    }
                    UILocalNotification.notify(title, body:body, channelId:cid)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Cells.channelCell, forIndexPath: indexPath) as! UITableViewCell
        
        
        let channel = channels?[indexPath.row]
        if let name = channel?.name,
            let yes = channel?.yes,
            let no = channel?.no {
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = "\(yes):\(no)"
        }
        
        switch channel?.democracy {
        case .Some(1):
            cell.backgroundColor = UIColor.greenColor()
        case .Some(0):
            cell.backgroundColor = UIColor.redColor()
        default:
            cell.backgroundColor = UIColor.whiteColor()
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
