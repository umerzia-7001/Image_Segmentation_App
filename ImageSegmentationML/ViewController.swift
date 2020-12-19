//
//  ViewController.swift
//  imageSegmentationML
//

//  Copyright © 2020 Muhammad umer Zia. All rights reserved.
//

import UIKit
import Vision

@available(iOS 14.0, *)
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   

    let imageView: UIImageView = {
       let img = UIImageView()
        img.image = UIImage(systemName: "hare.fill")
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .black
        img.sizeToFit()
        return img
    }()
    
    let imageView1: UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .black
        img.sizeToFit()
        return img
    }()
    
    let segmentedDrawingView: DrawingSegmentationView = {
       let img = DrawingSegmentationView()
        img.backgroundColor = .clear
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.sizeToFit()
       return img
    }()
    let segmentedDrawingView1: DrawingSegmentationView = {
       let img = DrawingSegmentationView()
        img.backgroundColor = .clear
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.sizeToFit()
       return img
    }()
    
    let startSegmentationButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(handleStartSegmentationButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 5
        btn.tintColor = .white
        btn.layer.masksToBounds  = true
        btn.setTitle("Begin", for: .normal)
        btn.isHidden = true
        return btn
    }()
    let startSegmentationButton1 : UIButton = {
        // button 2
        let btn1 = UIButton(type: .system)
        btn1.addTarget(self, action: #selector(handleStartSegmentationButton1), for: .touchUpInside)
        btn1.translatesAutoresizingMaskIntoConstraints = false
        btn1.backgroundColor = .gray
        btn1.layer.cornerRadius = 5
        btn1.tintColor = .white
        btn1.layer.masksToBounds  = true
        btn1.setTitle("Begin1", for: .normal)
        btn1.isHidden = true
        return btn1
        
    }()
    
    let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .white
    
            return v
        }()
    let imagePickerController = UIImagePickerController()
    
    // first model
    var imageSegmentationModel =  try! DeepLabV3()
    // second model
    var imageSegmentationModel_1 = try! U_Net_model()
    
    var request :  VNCoreMLRequest?
    
    // reuqest for UNet
     var request1 :  VNCoreMLRequest?
    
    var imageURL : URL?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.circle.fill"), style: .done, target: self, action: #selector(handleCameraButtonTapped))
        self.title = "Image Segmentation"
        imagePickerController.delegate = self
        scrollView.isUserInteractionEnabled = true
  
        setupScrollView()
        setUpModel()
        loadUI()
        
    }
    // MARK: - interface

    func loadUI(){
        // for interface
        //adding to scrollview
        scrollView.addSubview(imageView)
        NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 1).isActive = true
        
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20, constant: 320).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 3, constant: 100).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 10, constant: 200).isActive = true
        
        scrollView.addSubview(segmentedDrawingView)
        NSLayoutConstraint(item: segmentedDrawingView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
       
        NSLayoutConstraint(item: segmentedDrawingView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20, constant: 320).isActive = true
        NSLayoutConstraint(item: segmentedDrawingView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 3, constant: 100).isActive = true
        NSLayoutConstraint(item: segmentedDrawingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 10, constant: 200).isActive = true
        
        scrollView.addSubview(startSegmentationButton)
        NSLayoutConstraint(item: startSegmentationButton, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
      
        NSLayoutConstraint(item: startSegmentationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20 ,constant: 320).isActive = true
        NSLayoutConstraint(item: startSegmentationButton, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .topMargin, multiplier: 5, constant: 180).isActive = true
        NSLayoutConstraint(item: startSegmentationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 10, constant: 50).isActive = true
        // second model views
        scrollView.addSubview(imageView1)
        NSLayoutConstraint(item: imageView1, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: imageView1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20, constant: 320).isActive = true
        NSLayoutConstraint(item: imageView1, attribute: .top, relatedBy: .equal, toItem: startSegmentationButton, attribute: .topMargin, multiplier: 10, constant: 30).isActive = true
        NSLayoutConstraint(item: imageView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 10, constant: 200).isActive = true
        
        scrollView.addSubview(segmentedDrawingView1)
        NSLayoutConstraint(item: segmentedDrawingView1, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: segmentedDrawingView1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20, constant: 320).isActive = true
        NSLayoutConstraint(item: segmentedDrawingView1, attribute: .top, relatedBy: .equal, toItem: startSegmentationButton, attribute: .topMargin, multiplier: 10, constant:30).isActive = true
        NSLayoutConstraint(item: segmentedDrawingView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 10, constant: 200).isActive = true
        
        scrollView.addSubview(startSegmentationButton1)
        NSLayoutConstraint(item: startSegmentationButton1, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: startSegmentationButton1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 20 ,constant:320).isActive = true
        NSLayoutConstraint(item: startSegmentationButton1, attribute: .top, relatedBy: .equal, toItem: imageView1, attribute: .topMargin, multiplier: 5, constant: 190).isActive = true
        NSLayoutConstraint(item: startSegmentationButton1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 30, constant: 50).isActive = true
    }
    // for scrolView
    func setupScrollView(){
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 800)
        self.view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    // MARK: - setups
    
    func setUpModel() {
        // setting up model
        if let visionModel1 = try? VNCoreMLModel(for: imageSegmentationModel.model) {// DeepLab model
            request = VNCoreMLRequest(model: visionModel1, completionHandler: visionRequestDidComplete)
            
            request?.imageCropAndScaleOption = .scaleFill
        
        if let visionModel2 = try? VNCoreMLModel(for: imageSegmentationModel_1.model) {// UNet model
            request1 = VNCoreMLRequest(model: visionModel2, completionHandler: visionRequestDidComplete1)
            
            request1?.imageCropAndScaleOption = .scaleFill
        
        }else {
            fatalError()
        }
    }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let image = info[.originalImage] as? UIImage,
           let url = info[.imageURL] as? URL {
            imageView.image = image
            imageView1.image = image
            self.imageURL = url
            self.startSegmentationButton.isHidden = false
            self.startSegmentationButton1.isHidden = false
       }
        if let image = info[.originalImage] as? UIImage,
            let url1 = info[.imageURL] as? URL {
            imageView1.image = image
            self.imageURL = url1
            self.startSegmentationButton.isHidden = false
            self.startSegmentationButton1.isHidden = false
       }
           dismiss(animated: true, completion: nil)
   }
    
    
    func predict(with url: URL) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let request = self.request else { fatalError() }
        let handler = VNImageRequestHandler(url: url, options: [:])
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        }
   }
    // prediction for UNet model
    func predict1(with url1: URL) {
       DispatchQueue.global(qos: .userInitiated).async {
           guard let request = self.request1 else { fatalError() }
           let handler = VNImageRequestHandler(url: url1, options: [:])
           do {
               try handler.perform([request])
           }catch {
               print(error)
           }
           
           }
      }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationmap = observations.first?.featureValue.multiArrayValue {
                self.segmentedDrawingView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
                self.startSegmentationButton.setTitle("Done", for: .normal)
               
            }
        }
            
    }
    // request for UNet model
    func visionRequestDidComplete1(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationmap = observations.first?.featureValue.multiArrayValue {
                self.segmentedDrawingView1.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
               
                self.startSegmentationButton1.setTitle("Done", for: .normal)
            }
        }
            
    }
    
    
    
    // MARK: - Handlers
    
    @objc func handleCameraButtonTapped() {
        self.present(imagePickerController, animated: true, completion: nil)
        self.segmentedDrawingView.segmentationmap = nil
        self.segmentedDrawingView1.segmentationmap = nil
        //self.imageView.image = UIImage(systemName: "hare.fill")
        self.startSegmentationButton.isHidden = true
        self.startSegmentationButton1.isHidden = true
        self.startSegmentationButton.setTitle("Begin", for: .normal)
        self.startSegmentationButton1.setTitle("Begin", for: .normal)
      
    }
    
    @objc func handleStartSegmentationButton() {
        self.startSegmentationButton.setTitle("In Progress...", for: .normal)
        guard let url = self.imageURL else { return }
        self.predict(with: url)
      
        
    }
    @objc func handleStartSegmentationButton1() {
        self.startSegmentationButton1.setTitle("In Progress...", for: .normal)
        guard let url1 = self.imageURL else { return }
        self.predict1(with: url1)
        
    }
    
}
    
    
