//
//  ViewController.swift
//  MemeMe_YongJin
//
//  Created by 한용진 on 2017. 1. 23..
//  Copyright © 2017년 DalnaraCrater. All rights reserved.
//

import UIKit

struct Meme{
    var upText: String!
    var downText: String!
    var selectedImage: UIImage!
    var memedImage: UIImage!
    
    init(topText : String!, bottomText : String!, originalImage: UIImage!, memedImage: UIImage!){
        self.upText = topText
        self.downText = bottomText
        self.selectedImage = originalImage
        self.memedImage = memedImage
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var textType: Int = 0   //indicates a textField which user selects
    var memes: [Meme]!
    
    let memeMeTextAttributes: [String: Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: 0
    ]
    
    //---------------------------------------- Outlets ----------------------------------------
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var upperTextBox: UITextField!
    @IBOutlet weak var bottomTextBox: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var saveButton: UIButton!
    

    @IBOutlet weak var saveImage: UIButton!
    override func viewDidLoad() {
        /*
         Definition     : override func viewDidLoad()
         Description    : A method implemeted before presenting view
         Return         : void
         */
        super.viewDidLoad()
        UIImagePickerController.isSourceTypeAvailable(.camera)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //allow memeMeTextAttributes.
        upperTextBox.defaultTextAttributes = memeMeTextAttributes
        bottomTextBox.defaultTextAttributes = memeMeTextAttributes
        
        //textField be center.
        upperTextBox.textAlignment = .center
        bottomTextBox.textAlignment = .center
        
        //delegate themselves.
        upperTextBox.delegate = self
        bottomTextBox.delegate = self
        
        memes = appDelegate.globalMemes
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.frame.origin.y = 0
        
        if imagePickerView.image != nil{
            saveImage.isEnabled = true
        }
        else{
            saveImage.isEnabled = false
        }
        
        //use Notification to notify textField be selected.
        self.subscribeToKeyboardNotification()
        self.subscribeToHideKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //release Notification.
        self.unsubscribeFromKeyboardNotifications()
        self.unsubscribeToHideKeyboardNotification()
    }

    //---------------------------------------- Actions ----------------------------------------
    @IBAction func pickAnImage(_ sender: Any) {
        //make access an album
        print("앨범 접근")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self                             //delegate itself
        imagePicker.sourceType = .photoLibrary                  //use photoLibrary
        present(imagePicker, animated: true, completion: nil)   //show an image alblum
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        //make use of camera
        print("카메라 사용")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera                        //use camera function.
        present(imagePicker, animated: true, completion: nil)   //run camera
    }
    
    @IBAction func saveMemedImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = { activity, success, items, errors in
            
            if success == true
            {
                //Generate a memed image
                self.save(memedImage: memedImage);
                //Dismiss
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // present the ActivityViewController
        present(activity, animated: true, completion: nil)
    }
    
    //---------------------------------------- functions ----------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //When user selects a image from album, the choosed image be appeared at imagePickerView
        if let imageTemp = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imagePickerView.contentMode = .scaleAspectFit   //A choosen photo must fits in imagePickerView frame.
            imagePickerView.image = imageTemp               //hand imagePickerView a photo choosen by User.
            
        }
        
        dismiss(animated: true, completion: nil)    //dismiss a page
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //In album page, cancel choosing an image.
        
        dismiss(animated: true, completion: nil)    //dismiss a page.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //A function that activates when a textField be choosen
        
        //Initiate values.
        textField.text = ""                 //text be cleared
        textType = textField.tag            //assign tag value to know which textFields be choosen.
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        textField.resignFirstResponder()    //hide keyboard
        textType = 0                        //make textType 0 to reuse.
        return true
    }
    
    func keyboardWillShow(_ notification: Notification){
        if textType == 1{//upper Text Field be selected now
            //do nothing.
        }
        else {//bottom Text Field be selected now
            //ImageViewer must be pushed, the viewer is cut though.
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyBoardWillHide(_ notification: Notification){
        
        if textType == 1{//upper Text Field be selected now
            //do nothing.
        }
        else {//bottom Text Field be selected now
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification)->CGFloat{
        //return a height of keyboard.
        let userInfo = notification.userInfo    //load user Information.
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //extracts value from userInfo dic
        return keyboardSize.cgRectValue.height  //return value.
    }
    
    func subscribeToKeyboardNotification() {
        //post Notification to NoticifationCenter.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToHideKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToHideKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let upperTxt = upperTextBox.text, let bottomTxt = bottomTextBox.text{
            
            let meme = Meme(topText: upperTxt, bottomText: bottomTxt, originalImage: imagePickerView.image!, memedImage: memedImage)
            
            appDelegate.globalMemes.append(meme)
        }
        else {
            
        }
    }
    
    func generateMemedImage() -> UIImage {

        // TODO: Hide toolbar and navbar
        self.saveButton.isHidden = true
        self.bottomToolBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar
        self.saveButton.isHidden = false
        self.bottomToolBar.isHidden = false

        return memedImage
    }
}

