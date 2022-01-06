//
//  StrogeManger.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 03/06/1443 AH.
//

import Foundation
import FirebaseStorage

final class StrogeManger {
    
    static let sheard = StrogeManger()
    
    private let stroge = Storage.storage().reference()
    
    public typealias UploadPictrueCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture (with data: Data, fileName: String, completion: @escaping UploadPictrueCompletion) {
        stroge.child("images/\(fileName)").putData(data, metadata: nil, completion: {mtadata, error in
            guard error == nil else{
                print("Faild to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.stroge.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("failed To Get Download Url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url retiren: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downlodURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        print("inside \(path)")
        let refrance = stroge.child(path)
        
        refrance.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("Error \(url)")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            print("True \(url)")
            completion(.success(url))

        })
    }
}
