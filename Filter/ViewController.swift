//
//  ViewController.swift
//  Filter
//
//  Created by tse on 16/6/4.
//  Copyright © 2016年 tse. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var oriImage:UIImage?
    var filteredImage:UIImage?
    var avrRed = 0
    var avrBlue = 0
    var avrGreen = 0
    var totalRed = 0
    var totalBlue = 0
    var totalGreen = 0
    var firstLoad = true

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttomMenu: UIView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var greyFilter: UIButton!
    @IBOutlet weak var blueFilter: UIButton!
    @IBOutlet weak var greenFilter: UIButton!
    @IBOutlet weak var redFilter: UIButton!
    @IBOutlet weak var compare: UIButton!
    @IBOutlet weak var showOrigin: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if firstLoad {
            oriImage = imageView.image
            filteredImage = oriImage
            totalRed = 0
            totalGreen = 0
            totalBlue = 0
            var myRGBA = RGBAImage(image: oriImage!)!
            for y in 0..<myRGBA.height {
                for x in 0..<myRGBA.width {
                    let index = y * myRGBA.width + x
                    var pixel = myRGBA.pixels[index]
                    totalRed += Int(pixel.red)
                    totalBlue += Int(pixel.blue)
                    totalGreen += Int(pixel.green)
                }
            }
            let pixCount = myRGBA.width * myRGBA.height
            avrRed = totalRed/pixCount
            avrGreen = totalGreen/pixCount
            avrBlue = totalBlue/pixCount
            firstLoad = false
        }
        compare.enabled = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out my really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            oriImage = image
            //calculate the average RGB component
            totalRed = 0
            totalGreen = 0
            totalBlue = 0
            var myRGBA = RGBAImage(image: oriImage!)!
            for y in 0..<myRGBA.height {
                for x in 0..<myRGBA.width {
                    let index = y * myRGBA.width + x
                    var pixel = myRGBA.pixels[index]
                    totalRed += Int(pixel.red)
                    totalBlue += Int(pixel.blue)
                    totalGreen += Int(pixel.green)
                }
            }
            let pixCount = myRGBA.width * myRGBA.height
            avrRed = totalRed/pixCount
            avrGreen = totalGreen/pixCount
            avrBlue = totalBlue/pixCount
            compare.enabled = false
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if(sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(buttomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint,leftConstraint,rightConstraint,heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
        
    }
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
            self.secondaryMenu.removeFromSuperview()
                }
            }
        
    }
    
    @IBAction func onGreyFilter(sender: AnyObject) {

        // Process the image!
        
        var myRGBA = RGBAImage(image: oriImage!)!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let picRed = Double(pixel.red) * 0.2989
                let picGreen = Double(pixel.green) * 0.5870
                let picBlue = Double(pixel.blue) * 0.1140
                let greyPic = UInt8(picRed + picGreen + picBlue)
                pixel.red = greyPic
                pixel.green = greyPic
                pixel.blue = greyPic
                myRGBA.pixels[index] = pixel
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
    }
    @IBAction func onRedFilter(sender: AnyObject) {
        
        // Process the image!
        
        var myRGBA = RGBAImage(image: oriImage!)!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let redDiff = Int(pixel.red) - avrRed
                if redDiff > 0 {
                    pixel.red = UInt8(max(0, min(255, avrRed + redDiff * 3)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
    }
    @IBAction func onBlueFilter(sender: AnyObject) {
        // Process the image!
        
        var myRGBA = RGBAImage(image: oriImage!)!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let blueDiff = Int(pixel.blue) - avrBlue
                if blueDiff > 0 {
                    pixel.blue = UInt8(max(0, min(255, avrBlue + blueDiff * 3)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
    }
    @IBAction func onGreenFilter(sender: AnyObject) {
        // Process the image!
        
        var myRGBA = RGBAImage(image: oriImage!)!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let greenDiff = Int(pixel.green) - avrGreen
                if greenDiff > 0 {
                    pixel.green = UInt8(max(0, min(255, avrGreen + greenDiff * 3)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
    }
    @IBAction func onCompared(sender: AnyObject) {
        if compare.selected {
            imageView.image = filteredImage
            compare.selected = false
        } else {
            imageView.image = oriImage
            compare.selected = true
        }
        
    }
    @IBAction func onShowOrigin(sender: AnyObject) {
        filteredImage = oriImage
        imageView.image = filteredImage
        compare.selected = false
        compare.enabled = false
    }
}

