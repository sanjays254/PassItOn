//
//  PostPreviewViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2019-03-11.
//  Copyright © 2019 Sanjay Shah. All rights reserved.
//

import UIKit

class PostPreviewViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {


    var scrollView: UIScrollView!
    var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.clipsToBounds = true
        
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = self.view.frame.size

        scrollView.backgroundColor = .blue
        view.addSubview(scrollView)
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        
        let photoCollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        photoCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        photoCollectionViewFlowLayout.minimumInteritemSpacing = 5.0
        
        
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoCollectionViewFlowLayout)
        
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.backgroundColor = .green
        view.addSubview(photoCollectionView)
        
        photoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        photoCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        photoCollectionView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PostPhotoCollectionViewCell
        
            return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
