//
//  ImagenViewController.swift
//  YRojasSnapchat
//
//  Created by yrojas on 14/11/23.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    var audioRecorder: AVAudioRecorder?
    var audioURL: URL?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        
        setupAudioRecorder()
        // Do any additional setup after loading the view.
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupAudioRecorder() {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("audioRecording.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.delegate = self
                audioURL = audioFilename
                audioRecorder?.prepareToRecord()
            } catch {
                print("Error setting up audio recording: \(error.localizedDescription)")
            }
        }
    
    @IBAction func camaraTapped(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func mediaTapped(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            grabarButton.setTitle("Grabar", for: .normal)
        } else {
            audioRecorder?.record()
            grabarButton.setTitle("Detener", for: .normal)
                }
    }
    
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        
        self.elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        cargarImagen.putData(imagenData!, metadata: nil){(metadata, error) in if error != nil{
            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imgen. vERIFICA SU CONEXION AL INTERNET Y VUELVA A INTENTRLO", accion: "Aceptar")
            self.elegirContactoBoton.isEnabled = true
            print("Ocurrio un error al subir la imagen: \(error) ")
            return
        }else{
            
            cargarImagen.downloadURL(completion: {(url, error) in guard let enlaceURL = url else {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener informacion de imagen", accion: "Cancelar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrio un error al subir la imagen: \(error) ")
                return
            }
            self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
            })
        }
        }
    }
    
    
    /*
        let alertaCarga = UIAlertController(title: "Cargando Imagen ... ", message: "0%", preferredStyle: .alert)
        let progresoCarga : UIProgressView = UIProgressView(progressViewStyle:
        .default)
        cargarImagen.observe(.progress) { (snapshot) in
        let porcentaje = Double(snapshot.progress!.completedUnitCount)
        / Double(snapshot.progress!.totalUnitCount)
        print(porcentaje)
        progresoCarga.setProgress(Float(porcentaje),animated:true)
        progresoCarga.frame = CGRect (x: 10, y: 70, width: 250, height: 0)
        alertaCarga.message=String(round(porcentaje*100.0)) + " %"
        if porcentaje>=1.0 {
            alertaCarga.dismiss(animated:true,completion:nil)
        }
        }
        let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alertaCarga.addAction(btnOK)
        alertaCarga.view.addSubview(progresoCarga)
        present (alertaCarga, animated: true, completion: nil)
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
        
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    let siguienteVC = segue.destination as! ElegirUsuarioViewController
    siguienteVC.imagenURL = sender as! String
    siguienteVC.descrip = descripcionTextField.text!
    siguienteVC.imagenID = imagenID
        
    }
    
    func mostrarAlerta(titulo:String, mensaje:String, accion:String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: titulo, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
    
    // ++++++++++++++++++++++
    
    // Función del AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // Audio grabado exitosamente
            // Aquí puedes proceder a guardar el audio en Firebase Storage y la referencia en la base de datos.
            guard let audioURL = audioURL else { return }
            uploadAudioToStorage(audioURL)
        } else {
            print("Error al grabar el audio")
        }
    }
    
    func uploadAudioToStorage(_ audioURL: URL) {
        let audioStorageRef = Storage.storage().reference().child("audio").child("\(NSUUID().uuidString).m4a")
        audioStorageRef.putFile(from: audioURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error al subir el audio al Storage: \(error.localizedDescription)")
                return
            }
            // El audio se ha subido correctamente, ahora puedes guardar la referencia en la base de datos.
            audioStorageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error al obtener la URL de descarga del audio: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let audioReference = downloadURL.absoluteString
                // Aquí puedes guardar audioReference en la base de datos, junto con otros detalles si es necesario.
                print("URL de descarga del audio: \(audioReference)")
            }
        }
    }

}
