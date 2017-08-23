//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by Rohan Reddy on 1/13/17.
//  Copyright © 2017 Rohan Reddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sharebar: UIToolbar!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    
    var editingBottom: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        prepareTextField(textField: topText, defaultText: "TOP")
        prepareTextField(textField: bottomText, defaultText: "BOTTOM")
        shareButton.isEnabled = false;
    }
    
    
    struct Meme{
        var topCaption = ""
        var bottomCaption = ""
        var image: UIImage!
        var memedImage: UIImage!
    }
    
    func save(){
        let meme = Meme(topCaption: topText.text!, bottomCaption: bottomText.text!, image: imagePickerView.image!, memedImage: generateMemedImage())
        
    }
    
    func prepareTextField(textField: UITextField, defaultText: String){
        textField.defaultTextAttributes = [NSStrokeColorAttributeName: UIColor.black,
                                          NSForegroundColorAttributeName: UIColor.white,
                                          NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size:40)!,
                                          NSStrokeWidthAttributeName: -3.0]
        textField.text = defaultText
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    func setBars(hidden: Bool){
        toolbar.isHidden = hidden
        sharebar.isHidden = hidden
    }
    
    
    @IBAction func resetView(_ sender: Any) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
        
    }
    
    func generateMemedImage() -> UIImage{
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.setBars(hidden: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.setBars(hidden: false)
        
        return memedImage
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.text == "TOP" || textField.text == "BOTTOM"){
            textField.text = ""
        }
        
        if(textField==bottomText){
            editingBottom = true
        }else{
            editingBottom = false
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func pick (sourceType: UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.present(pickerController, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let sourceType:UIImagePickerControllerSourceType = .photoLibrary
        pick(sourceType: sourceType)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any){
        let sourceType:UIImagePickerControllerSourceType = .camera
        pick(sourceType: sourceType)
    }
    
    @IBAction func shareMeme(_ sender: Any){
        let myMeme = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [myMeme], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.dismiss(animated: true, completion: nil)
        
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imagePickerView.image = image
        }
        
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide,
                                               object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification){
        if(editingBottom){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    

}

