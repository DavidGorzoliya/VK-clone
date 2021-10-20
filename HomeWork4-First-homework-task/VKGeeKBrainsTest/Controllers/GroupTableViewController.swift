//
//  GroupTableViewController.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import Kingfisher
import RealmSwift
import FirebaseDatabase

final class GroupTableViewController: UITableViewController {

    @IBAction func addNewGroup(segue:UIStoryboardSegue) {

        if segue.identifier == "AddGroup"{

            guard let newGroupFromController = segue.source as? NewGroupTableViewController else { return }

            if let indexPath = newGroupFromController.tableView.indexPathForSelectedRow {

                let newGroup = newGroupFromController.GroupsList[indexPath.row]

                guard myGroups.description.contains(newGroup.groupName) == false else { return }

                do {
                    try realm.write{
                        realm.add(newGroup)
                    }
                } catch {
                    print(error)
                }

                writeNewGroupToFirebase(newGroup)

            }
        }
    }

    var realm: Realm = {
        let configrealm = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configrealm)
        return realm
    }()

    lazy var groupsFromRealm: Results<Group> = {
        return realm.objects(Group.self)
    }()

    var notificationToken: NotificationToken?

    var myGroups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeToNotificationRealm()
        GetGroupsList().loadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as! GroupTableViewCell
        
        cell.nameGroupLabel.text = myGroups[indexPath.row].groupName
        
        if let imgUrl = URL(string: myGroups[indexPath.row].groupLogo) {
            let avatar = ImageResource(downloadURL: imgUrl)
            cell.avatarGroupView.avatarImage.kf.indicatorType = .activity
            cell.avatarGroupView.avatarImage.kf.setImage(with: avatar)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            do {
                try realm.write{
                    realm.delete(groupsFromRealm.filter("groupName == %@", myGroups[indexPath.row].groupName))
                }
            } catch {
                print(error)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func subscribeToNotificationRealm() {
        notificationToken = groupsFromRealm.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.loadGroupsFromRealm()

            case .update:
                self?.loadGroupsFromRealm()

            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadGroupsFromRealm() {
        myGroups = Array(groupsFromRealm)
        guard groupsFromRealm.count != 0 else { return } // проверка, что в реалме что-то есть
        tableView.reloadData()
    }

    private func writeNewGroupToFirebase(_ newGroup: Group){
        let database = Database.database()
        let ref: DatabaseReference = database.reference(withPath: "All logged users").child(String(Session.instance.userId))

        ref.observe(.value) { snapshot in
            
            let groupsIDs = snapshot.children.compactMap { $0 as? DataSnapshot }
                .compactMap { $0.key }
            guard groupsIDs.contains(String(newGroup.id)) == false else { return }
            ref.child(String(newGroup.id)).setValue(newGroup.groupName) // записываем новую группу в Firebase
            
            print("Для пользователя с ID: \(String(Session.instance.userId)) в Firebase записана группа:\n\(newGroup.groupName)")
            
            let groups = snapshot.children.compactMap { $0 as? DataSnapshot }
                .compactMap { $0.value }
            
            print("\nРанее добавленные в Firebase группы пользователя с ID \(String(Session.instance.userId)):\n\(groups)")
            ref.removeAllObservers()
        }
    }
}
