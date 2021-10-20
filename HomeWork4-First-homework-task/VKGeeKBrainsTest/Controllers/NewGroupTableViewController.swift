//
//  NewGroupTableViewController.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit


final class NewGroupTableViewController: UITableViewController, UISearchResultsUpdating {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }

    var searchController:UISearchController!
    var GroupsList: [Group] = []

    private func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Введите запрос для поиска"
        tableView.tableHeaderView = searchController.searchBar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.isActive = true
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func searchGroupVK(searchText: String) {
        SearchGroup().loadData(searchText: searchText) { [weak self] (complition) in
            DispatchQueue.main.async {
                self?.GroupsList = complition
                self?.tableView.reloadData()
            }
        }
    }

     func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            searchGroupVK(searchText: searchText)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroup", for: indexPath)  as! NewGroupTableViewCell

        cell.nameNewGroupLabel.text = GroupsList[indexPath.row].groupName
        
        if let imgUrl = URL(string: GroupsList[indexPath.row].groupLogo) {
            cell.avatarNewGroupView.avatarImage.load(url: imgUrl) // работает через extension UIImageView
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
