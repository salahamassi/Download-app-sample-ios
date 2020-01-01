//
//  ViewController.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    private var downloads = [Download]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddBarButtonItem))
        return barButtonItem
    }()
    
    private var hasNextPage = false
    private var fetchOffset = 0
    private let fetchLimit = 8
    
    private var contentType: String?
    private var lastURLPath: String?
    private let tableView = UITableView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        fetchDownloads()
        startObservingDownloads()
    }
    
    
    fileprivate func setupViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.frame
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.register(DownloadItemCell.self, forCellReuseIdentifier: Constants.ReuseIdentifier.download)
        tableView.contentInset = .init(top: 0, left: 0, bottom: 64, right: 0)
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTableView)))
    }
    
    // MARK: - Core data functions
    private func fetchDownloads(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Download>(entityName: Constants.CoreData.downloadEntityName)
        let count = try? context.count(for: fetchRequest)
        let sort = NSSortDescriptor(key: #keyPath(Download.createdAt), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        
        fetchOffset = fetchOffset + fetchLimit
        
        hasNextPage = fetchOffset <= (count ?? 0)
        do{
            let downloads = try context.fetch(fetchRequest)
            for download in downloads{
                if download.localFile == nil{
                    deleteDownload(download: download)
                }else{
                    let size = (download.localFile!.localURL?.sizeForLocalFilePath() ?? 0)
                    if size <= 10{
                        deleteDownload(download: download)
                    }else{
                        self.downloads.append(download)
                    }
                }
            }
            tableView.reloadData()
        }catch{
            print("could get downloads with error  \(error)")
        }
    }
    
    private func search(query: String){
        downloads.removeAll()
        NotificationCenter.default.removeObserver(self)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Download>(entityName: Constants.CoreData.downloadEntityName)
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        do{
            let downloads = try context.fetch(fetchRequest)
            self.downloads.append(contentsOf: downloads)
            tableView.reloadData()
        }catch{
            print("could get downloads with error  \(error)")
        }
    }
    
    private func startObservingDownloads(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
    }
    
    @objc
    private func managedObjectContextObjectsDidChange(notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<Download>  {
            //            var startIndex = downloads.count
            downloads.insert(contentsOf: inserts, at: 0)
            //            var indexPathArray = [IndexPath]()
            //
            //            for _ in inserts{
            //                indexPathArray.append(IndexPath(row: startIndex, section: ))
            //                startIndex = startIndex + 1
            //            }
            DispatchQueue.main.async {
                //                self.tableView.insertRows(at: indexPathArray, with: .left)
                self.tableView.reloadData()
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<Download>  {
            for updateDownload in updates{
                searchDownloadAndUpdate(updateDownload: updateDownload)
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<Download>  {
            for deleteDownload in deletes{
                searchDownloadAndDelete(deleteDownload: deleteDownload)
            }
        }
    }
    
    private func searchDownloadAndDelete(deleteDownload: Download){
        var indexToDelete: Int?
        for (index, download) in downloads.enumerated(){
            if deleteDownload.objectID == download.objectID{
                indexToDelete = index
                break
            }
        }
        guard let index = indexToDelete else { return }
        downloads.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            self.tableView.reloadData()
        }
    }
    
    private func searchDownloadAndUpdate(updateDownload: Download){
        var indexToUpdate: Int?
        for (index, download) in downloads.enumerated(){
            if updateDownload.objectID == download.objectID{
                indexToUpdate = index
                break
            }
        }
        guard let index = indexToUpdate else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexPath) as? DownloadItemCell else { return }
        if updateDownload.progress < 1.0 && updateDownload.progress > 0.0 && updateDownload.localFile == nil{
            cell.sizeLabel.text = "\(round(updateDownload.progress * 100.0))%"
            cell.progressView.setProgress(Float(updateDownload.progress), animated: true)
        }else{
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        //        pendingRequestWorkItem?.cancel()
        //
        //        let requestWorkItem = DispatchWorkItem { [weak self] in
        //            guard let weakSelf = self else { return }
        //
        //        }
        //        pendingRequestWorkItem = requestWorkItem
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50),
        //                                      execute: requestWorkItem)
    }
    
    private func deleteDownload(indexPath: IndexPath){
        let download = downloads[indexPath.row]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(download)
        appDelegate.saveContext()
    }
    
    private func deleteDownload(download: Download){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(download)
        appDelegate.saveContext()
    }
    //Mark:- selectors functions
    @objc
    fileprivate func didPressAddBarButtonItem(){
        showDownloadDialog()
    }
    
    @objc
    fileprivate func handleLongPressTableView(_ gesture: UILongPressGestureRecognizer){
        let location = gesture.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return }
        showOtherOptionsAlertSheet(indexPath)
    }
    
    
    // MARK: - Helpers Functions
    fileprivate func showOtherOptionsAlertSheet(_ indexPath: IndexPath){
        
        
        let alert = UIAlertController(title: nil , message: "Please Select an Option", preferredStyle: .actionSheet)
        
        
        
        alert.addAction(UIAlertAction(title: "Share", style: .default , handler:{ (UIAlertAction)in
            guard let url = self.downloads[indexPath.row].localFile?.localURL else { return }
            let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            controller.popoverPresentationController?.sourceView = cell
            self.present(controller, animated: true, completion: nil)
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            self.deleteDownload(indexPath: indexPath)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        alert.popoverPresentationController?.sourceView = cell
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showDownloadDialog() {
        let alertController = UIAlertController(title: "Enter URL", message: "", preferredStyle: UIAlertController.Style.alert)
        let tryAction = UIAlertAction(title: "Try to Download", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.tryDownload(url: firstTextField.text ?? "")
        })
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "URL"
        }
        
        alertController.addAction(tryAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    fileprivate func tryDownload(url: String){
        if url.isEmpty { return }
        if let downloadURL = url.url {
            if downloadURL.absoluteString.contains("jpg"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "jpg")
            }else if downloadURL.absoluteString.contains("png"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "png")
            } else if downloadURL.absoluteString.contains("jpeg"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "jpeg")
            }else if downloadURL.absoluteString.contains("mp4"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "mp4")
            }else if downloadURL.absoluteString.contains("m4a"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "m4a")
            }else if downloadURL.absoluteString.contains("mp3"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "mp3")
            }else if downloadURL.absoluteString.contains("pdf"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "pdf")
            }else if downloadURL.absoluteString.contains("doc"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "doc")
            }else if downloadURL.absoluteString.contains("docx"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "docx")
            }else if downloadURL.absoluteString.contains("ppt"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "ppt")
            }else if downloadURL.absoluteString.contains("pages"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "pages")
            }else if downloadURL.absoluteString.contains("xls"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "xls")
            }else if downloadURL.absoluteString.contains("rtf"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "rtf")
            }else if downloadURL.absoluteString.contains("csv"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "csv")
            }else if downloadURL.absoluteString.contains("zip"){
                DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: "zip")
            }else{
                if let contentType = contentType{
                    if contentType.contains("/") && !contentType.contains("text/html"){
                        DownloadManger.shared.download(file: downloadURL.absoluteString, pathExtension: String(contentType.split(separator: "/")[1]))
                    }
                }else{
                    if url != lastURLPath{
                        getContentType(urlPath: url)
                    }
                }
            }
        }
    }
    
    fileprivate func getContentType(urlPath: String){
        lastURLPath = nil
        if let url = URL(string: urlPath) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let httpResponse = response as? HTTPURLResponse, error == nil {
                    if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                        self.lastURLPath = urlPath
                        self.contentType = contentType
                        DispatchQueue.main.async {
                            self.tryDownload(url: urlPath)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
// MARK: - Table view data source & delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifier.download, for: indexPath) as! DownloadItemCell
        cell.download = downloads[indexPath.row]
        
        if self.hasNextPage && indexPath.row == self.downloads.count - 1 {
            fetchDownloads()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDownload(indexPath: indexPath)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {return}
        if text.isEmpty{
            endSearch()
            return
        }
        search(query: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        if text.isEmpty{
            endSearch()
            return
        }
        search(query: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
    
    fileprivate func endSearch(){
        fetchOffset = 0
        downloads.removeAll()
        fetchDownloads()
        startObservingDownloads()
    }
}

