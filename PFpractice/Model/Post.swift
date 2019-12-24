//
//  Post.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift

class Post: Object {
    
    static let realm = try! Realm()
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var theme: String = ""
    @objc dynamic var present: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var budget: Int = 0
    @objc dynamic var finished: Bool = false
    @objc dynamic var deposit: Int = 0
    
    @objc dynamic var info: Info?
    
    @objc dynamic private var _photo: UIImage? = nil
    @objc dynamic var photo: UIImage? {
        set{
            self._photo = newValue
            if let value = newValue {
                self.imageData = value.pngData() as NSData?
            }
        }
        get{
            if let image = self._photo {
                return image
            }
            if let data = self.imageData {
                self._photo = UIImage(data: data as Data)
                return self._photo
            }
            return nil
        }
    }
    
    @objc dynamic private var imageData: NSData? = nil
    
    @objc dynamic private var _backImage: UIImage? = nil
    @objc dynamic var backImage: UIImage? {
        set{
            self._backImage = newValue
            if let value = newValue {
                self.backImageData = value.pngData() as NSData?
            }
        }
        get{
            if let backImage = self._backImage {
                return backImage
            }
            if let data = self.backImageData {
                self._backImage = UIImage(data: data as Data)
                return self._backImage
            }
            return nil
        }
    }
    
    @objc dynamic private var backImageData: NSData? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["photo", "_photo", "backImage", "_backImage"]
    }
    
    static func create() -> Post {
        let post = Post()
        post.id = lastId()
        return post
    }
    
    static func lastId() -> Int {
        if let post = realm.objects(Post.self).last {
            return post.id + 1
        } else {
            return 1
        }
    }
    
}
