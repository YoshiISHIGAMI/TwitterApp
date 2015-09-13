//
//  TimeLineTableViewController.swift
//  Twitter2App
//
//  Created by Yoshi Ishigami on 2015/09/12.
//  Copyright (c) 2015年 Yoshi Ishigami. All rights reserved.
//

import UIKit
import Social
import Accounts
import Alamofire


class TimeLineTableViewController: UITableViewController {
    
    var twitterAccount:ACAccount?
    
    

    var dataArray: [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTwitter();
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TimeLineTableViewCell
        
        //cell.textLabel?.text = dataArray[indexPath.row]["title"]
        if let title = dataArray[indexPath.row]["title"]{
            cell.tweetLabel?.text = title
        }
        
        if let imageURLString = dataArray[indexPath.row]["image"],
            let imageURL = NSURL(string: imageURLString){
                cell.iconImageView?.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "placeholder"))
                cell.iconImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        }
        return cell
    }
    
    
    @IBAction func tapTweetButton(sender: UIBarButtonItem) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //CancelもしくはPostを押した際に呼ばれ、投稿画面を閉じる処理を行っています。
            vc.completionHandler = {(result:SLComposeViewControllerResult) -> () in
                vc.dismissViewControllerAnimated(true, completion:nil)
            }
            
            ////投稿画面の初期値設定
            //vc.setInitialText("初期テキストを設定できます。")
            //vc.addURL(NSURL(string:"シェアURLを設定できます。"))
            self.presentViewController(vc, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "エラー", message: "Twitterアカウントが登録されていません。設定アプリを開きますか？", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                if let URL = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.sharedApplication().openURL(URL)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    /*
    *   Twitterのアクセストークンを取得
    */
    
    private func loginTwitter(){
        
        //Twitterが登録されていないケース
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            return
        }
        
        let store = ACAccountStore();
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if granted == false{
                //アカウントは登録されているが認証が拒否されたケース
                return;
            }
            
            let accounts = store.accountsWithAccountType(type);
            
            if accounts.count == 0{
                return;
            }
            
            if let account = accounts[0] as? ACAccount{
                println("自分のアカウント名：「\(account.username)」\n")
                
                //アカウントをメモリに保持
                self.twitterAccount = account
                //タイムラインを取得する
                self.downloadTwitterTimeLine()
            }
        }
    }
    /*
    Twitterのタイムラインを取得する
    */
    
    private func downloadTwitterTimeLine(){
        
        //自分の投稿一覧は「user_timeline.json」で取得可能
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twitterAccount
        request.performRequestWithHandler { (responseData, responseURL, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if let res = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as? [NSDictionary]{
                
                //データ配列を一度カラにします。
                self.dataArray = []
                
                for entry in res{
                    
                    var dic:[String:String] = [:]
                    
                    if let user = entry["user"] as? NSDictionary, let name = user["name"] as? String{
                        println("ユーザー名：「\(name)」")
                    }
                    
                    if let user = entry["user"] as? NSDictionary, let profile_image_url_https = user["profile_image_url_https"] as? String{
                        dic["image"] = profile_image_url_https
                        println("ユーザー画層URL：「\(profile_image_url_https)」")
                    }
                    
                    if let text = entry["text"] as? String{
                        //dataArray の配列内に連想配列
                        dic["title"] = text
                        println(text)
                    }
                    
                    self.dataArray.append(dic)
                    println("------------------------")
                }
                //追記
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
}


//["title":"タイトル01", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=01"],
//["title":"タイトル02", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=02"],
//["title":"タイトル03", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=03"],
//["title":"タイトル04", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=04"],
//["title":"タイトル05", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=05"],
//["title":"タイトル06", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=06"],
//["title":"タイトル07", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=07"],
//["title":"タイトル09", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=08"],
//["title":"タイトル09", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=09"],
//["title":"タイトル10", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=10"],
//["title":"タイトル11", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=11"],
//["title":"タイトル12", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=12"],
//["title":"タイトル13", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=13"],
//["title":"タイトル14", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=14"],
//["title":"タイトル15", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=15"],
//["title":"タイトル16", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=16"],
//["title":"タイトル17", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=17"],
//["title":"タイトル18", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=18"],
//["title":"タイトル19", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=19"],
//["title":"タイトル20", "image":"http://dummyimage.com/400x400/ccc/fff.png&text=20"],
//["title":"タイトル21", "image":""]
