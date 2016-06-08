//
//  ViewController.swift
//  Filter
//
//  Created by tse on 16/6/4.
//  Copyright © 2016年 tse. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var oriImage:UIImage?
    var filteredImage:UIImage?
    var avrRed = 0
    var avrBlue = 0
    var avrGreen = 0
    var totalRed = 0
    var totalBlue = 0
    var totalGreen = 0
    var firstLoad = true
    enum filterType{
        case red, green, blue
    }
    var currentFilterType: filterType? = nil
    var minZoom: CGFloat = 0

    @IBOutlet weak var showLabel: UILabel!
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
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet weak var Editor: UIButton!
    @IBOutlet var zoomTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    
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
            //var width = myRGBA.width
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
        slider.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        slider.translatesAutoresizingMaskIntoConstraints = false
        Editor.enabled = false
        
        zoomTapGestureRecognizer.numberOfTapsRequired = 2
        
        updateZoom()
        updateConstraints()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willAnimateRotationToInterfaceOrientation(
        toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        updateZoom()
    }
    
    func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = view.bounds.size.width
            let viewHeight = view.bounds.size.height
            
            // center image if it is smaller than screen
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            // Makes zoom out animation smooth and starting from the right point not from (0, 0)
            view.layoutIfNeeded()
        }
    }
    
    private func updateZoom() {
        if let image = imageView.image {
            minZoom = min(view.bounds.size.width / image.size.width,
                              view.bounds.size.height / image.size.height)
            
            if minZoom > 1 { minZoom = 1 }
            
            scrollView.minimumZoomScale = minZoom
            scrollView.zoomScale = minZoom
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
            showLabel.hidden = false
            Editor.selected = false
            Editor.enabled = false
            updateZoom()
            updateConstraints()
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
        self.slider.alpha = 0
        self.Editor.selected = false
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
    
    @IBAction func onEditor(sender: UIButton) {
        if(sender.selected) {
            hideSlider()
            sender.selected = false
        } else {
            showSlider()
            sender.selected = true
        }
    }
    
    func showSlider() {
        self.secondaryMenu.alpha = 0
        self.filter.selected = false
        view.addSubview(slider)
        
        let bottomConstraint = slider.bottomAnchor.constraintEqualToAnchor(buttomMenu.topAnchor)
        let leftConstraint = slider.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = slider.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = slider.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint,leftConstraint,rightConstraint,heightConstraint])
        
        view.layoutIfNeeded()
        
        self.slider.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.slider.alpha = 1.0
        }
        
    }
    
    func hideSlider() {
        UIView.animateWithDuration(0.4, animations: {
            self.slider.alpha = 0
        }) { completed in
            if completed == true {
                self.slider.removeFromSuperview()
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
        showLabel.hidden = true
        Editor.enabled = false
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
                    let updateVal = avrRed + Int(Float(redDiff) * slider.value)
                    pixel.red = UInt8(max(0, min(255, updateVal)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
        showLabel.hidden = true
        currentFilterType = filterType.red
        Editor.enabled = true
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
                    let updateVal = avrBlue + Int(Float(blueDiff) * slider.value)
                    pixel.blue = UInt8(max(0, min(255, updateVal)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
        showLabel.hidden = true
        currentFilterType = filterType.blue
        Editor.enabled = true
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
                    let updateVal = avrGreen + Int(Float(greenDiff) * slider.value)
                    pixel.green = UInt8(max(0, min(255, updateVal)))
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
        showLabel.hidden = true
        currentFilterType = filterType.green
        Editor.enabled = true
    }
    @IBAction func onCompared(sender: AnyObject) {
        if compare.selected {
            imageView.image = filteredImage
            compare.selected = false
            showLabel.hidden = true
        } else {
            imageView.image = oriImage
            compare.selected = true
            showLabel.hidden = false
        }
        
    }
    @IBAction func onShowOrigin(sender: AnyObject) {
        filteredImage = oriImage
        imageView.image = filteredImage
        compare.selected = false
        compare.enabled = false
        showLabel.hidden = false
        Editor.enabled = false
    }
    @IBAction func tapIn(sender: AnyObject) {
        if imageView.image == filteredImage {
            imageView.image = oriImage
            showLabel.hidden = false
            compare.enabled = false
        } else {
            imageView.image = filteredImage
            showLabel.hidden = true
            compare.enabled = true
        }
    }
    @IBAction func tapOut(sender: AnyObject) {
        if imageView.image == filteredImage {
            imageView.image = oriImage
            showLabel.hidden = false
            compare.enabled = false
        } else {
            imageView.image = filteredImage
            showLabel.hidden = true
            compare.enabled = true
        }
    }
    @IBAction func tapDown(sender: AnyObject) {
        if imageView.image == filteredImage {
            imageView.image = oriImage
            showLabel.hidden = false
            compare.enabled = false
        } else {
            imageView.image = filteredImage
            showLabel.hidden = true
            compare.enabled = true
        }
        
    }
    @IBAction func onSlider(sender: AnyObject) {
        var myRGBA = RGBAImage(image: oriImage!)!
        if currentFilterType == .red {
            for y in 0..<myRGBA.height {
                for x in 0..<myRGBA.width {
                    let index = y * myRGBA.width + x
                    var pixel = myRGBA.pixels[index]
                    let redDiff = Int(pixel.red) - avrRed
                    if redDiff > 0 {
                        let updateVal = avrRed + Int(Float(redDiff) * slider.value)
                        pixel.red = UInt8(max(0, min(255, updateVal)))
                        myRGBA.pixels[index] = pixel
                    }
                }
            }
        } else if currentFilterType == .green {
            for y in 0..<myRGBA.height {
                for x in 0..<myRGBA.width {
                    let index = y * myRGBA.width + x
                    var pixel = myRGBA.pixels[index]
                    let greenDiff = Int(pixel.green) - avrGreen
                    if greenDiff > 0 {
                        let updateVal = avrGreen + Int(Float(greenDiff) * slider.value)
                        pixel.green = UInt8(max(0, min(255, updateVal)))
                        myRGBA.pixels[index] = pixel
                    }
                }
            }
        } else if currentFilterType == .blue {
            for y in 0..<myRGBA.height {
                for x in 0..<myRGBA.width {
                    let index = y * myRGBA.width + x
                    var pixel = myRGBA.pixels[index]
                    let blueDiff = Int(pixel.blue) - avrBlue
                    if blueDiff > 0 {
                        let updateVal = avrBlue + Int(Float(blueDiff) * slider.value)
                        pixel.blue = UInt8(max(0, min(255, updateVal)))
                        myRGBA.pixels[index] = pixel
                    }
                }
            }
        }
        filteredImage = myRGBA.toUIImage()
        imageView.image = filteredImage
        compare.enabled = true
        showLabel.hidden = true
    }
    
   
    
    @IBAction func onTapGesture(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.4) { () -> Void in
            if self.minZoom == self.scrollView.zoomScale {
            self.scrollView.zoomScale = 2 * self.scrollView.zoomScale
            } else {
                self.scrollView.zoomScale = self.minZoom
            }
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "PresentSocial" {
//            let destination = segue.destinationViewController
//            destination.per
//        }
//    }
}

