//
//  ViewController.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/19.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController {

    let url = "https://httpbin.org/get"
    let postUrl = "https://httpbin.org/post"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        test()
        //        testResponseValidation()
        //        testURLEncoding()
        //        testURLEncoding2()
        //        testJSONEncoding()
//        testHttpHeaders()
//        testDownload()
        testCustomConfiguation()
    }
    
    
    func test() -> Void {
        Alamofire.request("https://httpbin.org/get").responseJSON {response in
            print("Timeline: \(response.timeline)")
            
            if #available(iOS 10.0, *) {
                print("Task Metrics: \(String(describing: response.metrics))")
            }
            
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Result: \(response.result)")
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
            
        }
    }
    
    func testResponseValidation() -> Void {
        
        /*
         status code 200..<300 请求成功
         300..<600 请求错误
         */
        
        // 手动验证
        Alamofire.request(url)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
        }
        
        // 自动验证  直接使用validate()
    }
    
    func testURLEncoding() -> Void {
        let parameters: Parameters = ["foo": "bar"]
        
        Alamofire.request(url, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            print("Response: \(String(describing: response.request))")
            
            if let body = response.request?.httpBody {
                print("Body: \(String(data: body, encoding: .utf8) ?? "failuer")")
            }
        }
    }
    
    func testURLEncoding2() -> Void {
        let parameters: Parameters = [
            "foo": "bar",
            "baz": ["a", "1"],
            "qux": [
                "x": 1,
                "y": 2,
                "z": 3
            ],
            "isPure": true,
            "isRed": false
        ]
        
        Alamofire.request(postUrl, method: .post, parameters: parameters, encoding: URLEncoding(destination: .httpBody, boolEncoding: .literal)).responseJSON { (response) in
            if let body = response.request?.httpBody {
                print("Body: \(String(data: body, encoding: .utf8) ?? "failuer")")
            }
        }
        
        // 设置arrayEncoding "baz": ["a", "1"] .brackets为baz[0]=a&baz[1]=1 .noBrackets为baz=a&baz=1
        
    }
    
    func testJSONEncoding() -> Void {
        let parameters: Parameters = [
            "foo": [1,2,3],
            "bar": [
                "baz": "qux"
            ]
        ]
        
        Alamofire.request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { (response) in
            if let body = response.request?.httpBody {
                print("Body: \(String(data: body, encoding: .utf8) ?? "failuer")")
            }
        }
    }
    
    func testPropertyListEncoding() -> Void {
        
    }
    
    func testHttpHeaders() -> Void {
        let header: HTTPHeaders = [
            "Authorization": "Basic  QWxhZGRpbjpvcGVuIHN1c2FtZQ==",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://httpbin.org/headers", headers: header).responseJSON { (response) in
            debugPrint(response)
        }
    }
    

    func testDownload() -> Void {
        let pngUrl = "https://httpbin.org/image/png"
        
//        Alamofire.download(pngUrl).responseData { (response) in
//            print("---- download image -- success")
//            if let data = response.result.value {
//                print("---- download image -- set imageView")
//
//            }
//        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("pig.png")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(pngUrl, to: destination)
            .downloadProgress(closure: { (progress) in
            print("Download Progress: \(progress.fractionCompleted)")
        })
            .response { (response) in
//            print(response)
            
            if response.error == nil, let imagePath = response.destinationURL?.path {
                let image = UIImage(contentsOfFile: imagePath)
                let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 60, height: 60))
                imageView.image = image
                self.view.addSubview(imageView)
            }
        }
    }
    
    func testCustomConfiguation() -> Void {
        
        /**
         https://api.baishop.com/api/Home/GetNewHomePage?type=1&versionNo=2.0.1
         
         (lldb) po task.currentRequest.allHTTPHeaderFields
         {
        deviceNo = B8B4BFD5-96B6-4CBF-A118-63A5501906F7;
        DevicePlatform = iOS;
        AppVersion = 2.0.1;
        salePlatformId = 60CBE5FE-71A7-4660-9BEC-1422227D6ADB;
        User-Agent = BaiShop/2.0.1 (iPhone; iOS 12.0; Scale/3.00);
        Accept-Language = en;q=1;
        Accept-Encoding = br, gzip, deflate;
        Token = dce16d2d0e374585982abfd3038c65e7;
    }

         */
        
//        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//        defaultHeaders["token"] = "dce16d2d0e374585982abfd3038c65e7"
//        defaultHeaders["devicePlatform"] = "iOS"
//        defaultHeaders["salePlatformId"] = "60CBE5FE-71A7-4660-9BEC-1422227D6ADB"
//
//
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = defaultHeaders
//
//        let sessionManager = Alamofire.SessionManager(configuration: configuration)
//
//        let parameters = [
//            "type": "1",
//            "versionNo": "2.0.1"
//        ]

        // ?type=1&versionNo=2.0.1
        
        let url = "https://api.baishop.com/api/Home/GetNewHomePage?type=1&versionNo=2.0.1"
        
        //  parameters: parameters, encoding: URLEncoding(destination: .queryString)
        
//        sessionManager.request(url, method: .post).responseJSON { (response) in
//            print(response)
//        }
        
        let header: HTTPHeaders = [
            "salePlatformId": "60CBE5FE-71A7-4660-9BEC-1422227D6ADB"
        ]
        
        Alamofire.SessionManager.default.request(url, method: .post, headers:header).responseJSON { (response) in
            print(response)
        }
        
    }
    
}

