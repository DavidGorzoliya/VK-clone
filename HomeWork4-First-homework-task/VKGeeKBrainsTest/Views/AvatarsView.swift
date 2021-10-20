//
//  AvatarsView.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit

@IBDesignable class AvatarsView: UIView {

    let avatarImage: UIImageView = UIImageView(image: UIImage(systemName: "person"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        tapOnView()
        setupAvatarView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tapOnView()
        setupAvatarView()
    }

    private func tapOnView() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        recognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(recognizer)
    }

    @objc private func onTap(gestureRecognizer: UITapGestureRecognizer) {
        let original = self.transform
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.1, options: [ .autoreverse], animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // меняем размер вьюхи анимировано
        }, completion: { _ in
            self.transform = original
        })
    }

    func setupAvatarView(){
        frame = CGRect(x: 10, y: frame.midY-25, width: 50, height: 50)
        backgroundColor = UIColor.white
        layer.cornerRadius = CGFloat(self.frame.width / 2)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize.zero

        avatarImage.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.layer.cornerRadius = CGFloat(self.frame.width / 2)
        avatarImage.layer.masksToBounds = true
        
        self.addSubview(avatarImage)
    }
}
