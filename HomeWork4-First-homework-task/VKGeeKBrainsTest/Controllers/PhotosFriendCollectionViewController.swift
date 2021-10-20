//
//  PhotosFriendCollectionViewController.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import Kingfisher
import RealmSwift

final class PhotosFriendCollectionViewController: UICollectionViewController {

    var realm: Realm = {
        let configrealm = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configrealm)
        return realm
    }()

    lazy var photosFromRealm: Results<Photo> = {
        return realm.objects(Photo.self).filter("ownerID == %@", ownerID)
    }()

    var notificationToken: NotificationToken?


    var ownerID = ""
    var collectionPhotos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotificationRealm()
        GetPhotosFriend().loadData(ownerID)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosFriendCell", for: indexPath) as! PhotosFriendCollectionViewCell
        
        if let imgUrl = URL(string: collectionPhotos[indexPath.row].photo) {
            let photo = ImageResource(downloadURL: imgUrl)
            cell.photosFrienndImage.kf.setImage(with: photo)

        }
        
        return cell
    }

    private func subscribeToNotificationRealm() {
        notificationToken = photosFromRealm.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.loadPhotosFromRealm()
            case .update:
                self?.loadPhotosFromRealm()

            case let .error(error):
                print(error)
            }
        }
    }
    
    private func loadPhotosFromRealm() {
        collectionPhotos = Array(photosFromRealm)
        guard collectionPhotos.count != 0 else { return }
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUserPhoto"{
            guard let photosFriend = segue.destination as? FriendsPhotosViewController else { return }

            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                photosFriend.allPhotos = collectionPhotos
                photosFriend.countCurentPhoto = indexPath.row
            }
        }
    }
}
