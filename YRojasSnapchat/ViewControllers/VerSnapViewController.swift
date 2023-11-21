//
//  VerSnapViewController.swift
//  YRojasSnapchat
//
//  Created by yrojas on 21/11/23.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseStorage

class VerSnapViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblMensaje: UILabel!
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMensaje.text = "Mensaje: " + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("\(snap.imagenID).jpg").delete { (error) in
            print("Se eliminio la imagen correctamente")
        }
    }

    
    
    

}
