//
//  SinglePostViewController.swift
//  Keinex
//
//  Created by Андрей on 9/16/15.
//  Copyright (c) 2016Keinex. All rights reserved.
//

import UIKit
import SafariServices

class SinglePostViewController: UIViewController, UIWebViewDelegate {

    lazy var json : JSON = JSON.null
    lazy var scrollView : UIScrollView = UIScrollView()
    lazy var postTitle : UILabel = UILabel()
    lazy var featuredImage : UIImageView = UIImageView()
    lazy var postTime : UILabel = UILabel()
    lazy var postContent : UILabel = UILabel()
    lazy var postContentWeb : UIWebView = UIWebView()
    lazy var generalPadding : CGFloat = 10
    
    let isiPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        if let featured = json["better_featured_image"]["source_url"].string{
            
            featuredImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
            featuredImage.contentMode = .ScaleAspectFill
            featuredImage.clipsToBounds = true
            ImageLoader.sharedLoader.imageForUrl(featured, completionHandler:{(image: UIImage?, url: String) in
                self.featuredImage.image = image!
            })
            
            self.scrollView.addSubview(featuredImage)
        }
        
        if let title = json["title"]["rendered"].string {
            
            postTitle.frame = CGRect(x: 10, y: (generalPadding * 2 + featuredImage.frame.height), width:self.view.frame.size.width - 20, height: 50)
            postTitle.textColor = UIColor.blackColor()
            postTitle.textAlignment = NSTextAlignment.Center
            postTitle.font = UIFont.systemFontOfSize(24.0)
            postTitle.numberOfLines = 2
            postTitle.adjustsFontSizeToFitWidth = true
            postTitle.baselineAdjustment = .AlignCenters
            postTitle.minimumScaleFactor = 0.5
            postTitle.text = String(htmlEncodedString:  title)
            self.scrollView.addSubview(postTitle)
            
        }
        
        if let date = json["date"].string{
            
            postTime.frame = CGRect(x: 0, y: (generalPadding * 3 + postTitle.frame.height + featuredImage.frame.height), width: self.view.frame.size.width, height: 20)
            postTime.textColor = UIColor.grayColor()
            postTime.font = UIFont(name: postTime.font.fontName, size: 12)
            postTime.textAlignment = NSTextAlignment.Center
            postTime.text = date
            
            self.scrollView.addSubview(postTime)
        }
        
        if let content = json["content"]["rendered"].string{
            
            let webContent : String = "<!DOCTYPE HTML><html><head><title></title><link rel='stylesheet' href='appStyles.css'></head><body>" + content + "</body></html>"
            let mainbundle = NSBundle.mainBundle().bundlePath
            let bundleURL = NSURL(fileURLWithPath: mainbundle)
            
            postContentWeb.loadHTMLString(webContent, baseURL: bundleURL)
            postContentWeb.frame = CGRectMake(10, (generalPadding * 3 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), self.view.frame.size.width - 20, 10)
            postContentWeb.delegate = self
            self.scrollView.addSubview(postContentWeb)
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(SinglePostViewController.ShareLink))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func wightValue() -> CGFloat {
        var wightValue = 0.0
        if isiPad {
            wightValue = 1.15
        } else {
            wightValue = 1.3
        }
        return CGFloat(wightValue)
    }

    
    func webViewDidFinishLoad(webView: UIWebView) {
    
        postContentWeb.frame = CGRectMake(10, (generalPadding * 4 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), self.view.frame.size.width - 20, postContentWeb.scrollView.contentSize.height + 150)
        
        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        
        self.scrollView.contentSize.height = finalHeight
        
        showCommentsButton()
    }
    
    func showCommentsButton() {
        let commentsButton = UIButton(frame: CGRect(x: self.view.frame.size.width / wightValue(), y: self.view.frame.size.height / 3.15, width: 50, height: 50))
        let image = UIImage(named: "Message.png")
        commentsButton.backgroundColor = .whiteColor()
        commentsButton.setImage(image, forState: .Normal)
        commentsButton.layer.cornerRadius = 25
        commentsButton.layer.shadowOffset = CGSizeMake(1, 0)
        commentsButton.layer.shadowOpacity = 1.0
        commentsButton.layer.shadowColor = UIColor.blackColor().CGColor
        commentsButton.layer.shadowRadius = 1
        commentsButton.addTarget(self, action: #selector(commentsButtonAction), forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(commentsButton)
        
        commentsButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            commentsButton.transform = CGAffineTransformMakeScale(1,1)
        })
    }
    
    func commentsButtonAction(sender: UIButton!) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: json["link"].string! + "#respond")!, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.blackColor()
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            let openLink = NSURL(string : json["link"].string! + "#respond")
            UIApplication.sharedApplication().openURL(openLink!)
        }
    }
    
    func ShareLink() {
        let textToShare = json["title"]["rendered"].string! + " "
        
        if let myWebsite = NSURL(string: json["link"].string!) {
            let objectsToShare = [String(htmlEncodedString:  textToShare), myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    /*
    // MARK: This method fires after all subviews have loaded
    override func viewDidLayoutSubviews() {
        
        //Set variable for final height. Cast it as CGFloat
        var finalHeight : CGFloat = 0
        
        //Loop through all subviews
        self.scrollView.subviews.forEach { (subview) -> () in
            
            //Add each subview height to finalHeight
            finalHeight += subview.frame.height
        }
        
        //Apply final height to scrollview
        self.scrollView.contentSize.height = finalHeight
        
        //NOTE: you maye need to add some padding

    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
