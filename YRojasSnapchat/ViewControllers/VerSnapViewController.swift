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
import AVFoundation

class VerSnapViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var reproducirButton: UIButton!
    
    var snap = Snap()
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMensaje.text = "Mensaje: " + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
        // Do any additional setup after loading the view.
        
        // Recuperar y cargar el audio desde Firebase Storage
        let audioStorageRef = Storage.storage().reference().child("audio").child("\(snap.imagenID).m4a")
        audioStorageRef.downloadURL { url, error in
            guard let audioURL = url else {
                print("Error al obtener la URL del audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // Ahora tenemos la URL del audio, puedes cargarlo y preparar para reproducirlo
            self.prepareAudioPlayer(with: audioURL)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("\(snap.imagenID).jpg").delete { (error) in
            print("Se eliminio la imagen correctamente")
        }
    }
    
    func prepareAudioPlayer(with audioURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error al cargar el audio para reproducir: \(error.localizedDescription)")
        }
    }

    @IBAction func reproducirTapped(_ sender: Any) {
        audioPlayer?.play()
    }
    
    
    

}
