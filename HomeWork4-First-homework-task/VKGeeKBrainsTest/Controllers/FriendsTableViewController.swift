//
//  FriendsTableViewController.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import Kingfisher
import RealmSwift

class FriendsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeToNotificationRealm()
        GetFriendsList().loadData()
        searchBar.delegate = self
    }

    var realm: Realm = {
        let configrealm = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configrealm)
        return realm
    }()
    
    lazy var friendsFromRealm: Results<Friend> = {
        return realm.objects(Friend.self)
    }()
    
    var notificationToken: NotificationToken?
    
    var friendsList: [Friend] = []
    var namesListFixed: [String] = []
    var namesListModifed: [String] = []
    var letersOfNames: [String] = []

    override func numberOfSections(in tableView: UITableView) -> Int {
        return letersOfNames.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        let leter: UILabel = UILabel(frame: CGRect(x: 30, y: 5, width: 20, height: 20))
        leter.textColor = UIColor.black.withAlphaComponent(0.5)
        leter.text = letersOfNames[section]
        leter.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        header.addSubview(leter)

        return header
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return letersOfNames
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var countOfRows = 0

        for name in namesListModifed {
            if letersOfNames[section].contains(name.first!) {
                countOfRows += 1
            }
        }
        return countOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsTableViewCell

        cell.nameFriendLabel.text = self.getNameFriendForCell(indexPath)

        guard let imgUrl = self.getAvatarFriendForCell(indexPath) else { return cell }
        let avatar = ImageResource(downloadURL: imgUrl) //работает через Kingfisher
        cell.avatarFriendView.avatarImage.kf.indicatorType = .activity
        cell.avatarFriendView.avatarImage.kf.setImage(with: avatar)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func subscribeToNotificationRealm() {
        notificationToken = friendsFromRealm.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.loadFriendsFromRealm()
            case .update:
                self?.loadFriendsFromRealm()
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadFriendsFromRealm() {
        friendsList = Array(friendsFromRealm)
        guard friendsList.count != 0 else { return }
        makeNamesList()
        sortCharacterOfNamesAlphabet()
        tableView.reloadData()
    }
    

    func makeNamesList() {
        namesListFixed.removeAll()
        for item in 0...(friendsList.count - 1){
            namesListFixed.append(friendsList[item].userName)
        }
        namesListModifed = namesListFixed
    }

    func sortCharacterOfNamesAlphabet() {
        var letersSet = Set<Character>()
        letersOfNames = []
        for name in namesListModifed {
            letersSet.insert(name[name.startIndex])
        }
        for leter in letersSet.sorted() {
            letersOfNames.append(String(leter))
        }
    }
    
    func getNameFriendForCell(_ indexPath: IndexPath) -> String {
        var namesRows = [String]()
        for name in namesListModifed.sorted() {
            if letersOfNames[indexPath.section].contains(name.first!) {
                namesRows.append(name)
            }
        }
        return namesRows[indexPath.row]
    }
    
    func getAvatarFriendForCell(_ indexPath: IndexPath) -> URL? {
        for friend in friendsList {
            let namesRows = getNameFriendForCell(indexPath)
            if friend.userName.contains(namesRows) {
                return URL(string: friend.userAvatar)
            }
        }
        return nil
    }
    
    func getIDFriend(_ indexPath: IndexPath) -> String {
        var ownerIDs = ""
        for friend in friendsList {
            let namesRows = getNameFriendForCell(indexPath)
            if friend.userName.contains(namesRows) {
                ownerIDs = friend.ownerID
            }
        }
        return ownerIDs
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        namesListModifed = searchText.isEmpty ? namesListFixed : namesListFixed.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        sortCharacterOfNamesAlphabet()
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        makeNamesList()
        sortCharacterOfNamesAlphabet()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showListUsersPhoto"{
            guard let friend = segue.destination as? PhotosFriendCollectionViewController else { return }

            if let indexPath = tableView.indexPathForSelectedRow {
                friend.title = getNameFriendForCell(indexPath)
                friend.ownerID = getIDFriend(indexPath)
            }
        }
    }
}
