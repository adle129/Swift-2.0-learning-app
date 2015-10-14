//
//  SearchResultsViewController.swift
//  test
//
//  Created by nluo on 5/14/15.
//  Copyright (c) 2015 nluo. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol, UISearchBarDelegate {
    
    var api : APIController!
    
    @IBOutlet var appsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var interstitial: GADInterstitial?
    
    var albums = [Album]()
    
    let kCellIdentifier: String = "SearchResultCell"
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
                
        interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
        let request = DFPRequest()
        request.testDevices = [ kGADSimulatorID ];
        interstitial!.loadRequest(request)
        
        // Do any additional setup after loading the view, typically from a nib.
        api = APIController(delegate: self)
        searchBar.delegate = self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchItunesFor("Lady Gaga")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return self.albums.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)!
        
        let album: Album = self.albums[indexPath.row]
        
        // Get the formatted price string for display in the subtitle
        cell.detailTextLabel?.text = album.price
        // Update the textLabel text to use the title from the Album model
        cell.textLabel?.text = album.title
        
        // Start by setting the cell's image to a static file
        // Without this, we will end up without an image view!
        cell.imageView?.image = UIImage(named: "Blank52")
        
        let thumbnailURLString = album.thumbnailImageURL
        let thumbnailURL = NSURL(string: thumbnailURLString)!
        
        // If this image is already cached, don't re-download
        if let img = imageCache[thumbnailURLString] {
            cell.imageView?.image = img
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: thumbnailURL)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Store the image in to our cache
                    self.imageCache[thumbnailURLString] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(results)
            self.appsTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (interstitial!.isReady) {
            interstitial!.presentFromRootViewController(self)
        }
        if let detailsViewController: DetailsViewController = segue.destinationViewController as? DetailsViewController {
            let albumIndex = appsTableView!.indexPathForSelectedRow!.row
            let selectedAlbum = self.albums[albumIndex]
            detailsViewController.album = selectedAlbum
        }
    }
    
    //func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.filterContentForSearchText(searchBar.text!)
    }

    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        api.searchItunesFor(searchText)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles as [String]!
        api.searchItunesFor(scope[selectedScope])
    }
}

