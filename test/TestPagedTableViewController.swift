//
//  TestPagedTableView.swift
//  test
//
//  Created by Wensheng Chen on 7/17/15.
//  Copyright (c) 2015 nluo. All rights reserved.
//
import UIKit
import CoreData

class TestPagedTableViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    var pageLabels: [[String]] = []
    var pageViews: [UITableView?] = []
    var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // 1
        pageLabels = [["row 1", "row 2", "row 3", "row 1", "row 2", "row 3", "row 1", "row 2", "row 3", "row 1", "row 2", "row 3", "row 1", "row 2", "row 3"], ["row a", "row b"], ["WENSHENG", "CHEN"], ["WENSHENG1", "CHEN"], ["WENSHENG2", "CHEN"], ["WENSHENG3", "CHEN"], ["WENSHENG4", "CHEN"]]
        
        let pageCount = pageLabels.count
        
        // 2
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = pageCount
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }

        // 4
        let screenSize = UIScreen.mainScreen().bounds
        scrollView.contentSize = CGSize(width: screenSize.width * CGFloat(pageCount),
            height: scrollView.frame.height)
        // 5
        loadVisiblePages()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let screenSize = UIScreen.mainScreen().bounds
        scrollView.contentOffset.x = CGFloat(currentPage) * screenSize.width
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        println("rotated")
        
        // update content size to current orientation
        let screenSize = UIScreen.mainScreen().bounds
        scrollView.contentSize = CGSize(width: screenSize.width * CGFloat(pageLabels.count),
            height: scrollView.frame.height)
        
        // purge all pages that were created for previous orientation
        for var index = 0; index < pageViews.count; ++index {
            purgePage(index)
        }
        
        loadVisiblePages()
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageLabels.count {
            // If it's outside the range of what you have to display, then do nothing
            println("Skip page \(page)")
            return
        }
        println("Load page \(page)")
        
        // 1
        if let pageView = pageViews[page] {
            println("View is already loaded")
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = UIScreen.mainScreen().bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            println("Adding page \(page) at (\(frame.origin.x), \(frame.origin.y))")
            // 3
            var newPageView = UITableView()
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            newPageView.delegate = self
            newPageView.dataSource = self
            scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageLabels.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            println("Purge page \(page)")
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let screenWidth = UIScreen.mainScreen().bounds.width
        currentPage = Int(floor((scrollView.contentOffset.x * 2.0 + screenWidth) / (screenWidth * 2.0)))
        
        println ("Current page \(currentPage)")
        // Update the page control
        pageControl.currentPage = currentPage
        
        // Work out which pages you want to load
        let firstPage = currentPage - 1
        let lastPage = currentPage + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageLabels.count; ++index {
            purgePage(index)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var data: [String] = []
        for var i = 0; i < pageViews.count; ++i {
            if (tableView == pageViews[i]) {
                data = pageLabels[i]
            }
        }
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("coming here \(indexPath.row)")

        var data: [String] = []
        for var i = 0; i < pageViews.count; ++i {
            if (tableView == pageViews[i]) {
                data = pageLabels[i]
            }
        }

        let cell: UITableViewCell = UITableViewCell()
        cell.detailTextLabel?.text = data[indexPath.row]
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }

}
