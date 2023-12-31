//
//  CrearUsuarioViewController.swift
//  YRojasSnapchat
//
//  Created by yrojas on 18/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CrearUsuarioViewController: UIViewController {

    @IBOutlet weak var nuevoEmailTextField: UITextField!
    @IBOutlet weak var nuevaPasswordTextField: UITextField!
    @IBOutlet weak var ConfirmanuevaPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func crearUsuarioTapped(_ sender: Any) {
        guard let email = nuevoEmailTextField.text, !email.isEmpty,
              let password = nuevaPasswordTextField.text, !password.isEmpty,
            let confirmPassword = ConfirmanuevaPasswordTextField.text, !confirmPassword.isEmpty else{
                        // Manejar caso en el que los campos estén vacíos
                        mostrarAlerta(mensaje: "Por favor, completa todos los campos.")
                        return
                    }
                    
                    guard password == confirmPassword else {
                        // Mostrar alerta si las contraseñas no coinciden
                        mostrarAlerta(mensaje: "Las contraseñas no coinciden.")
                        return
                    }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            if let error = error {
                print("Error al crear usuario: \(error.localizedDescription)")
                self?.mostrarAlerta(mensaje: "Se presentó un error al crear el usuario.")
            } else {
                print("Usuario creado exitosamente")
                // Notificar al usuario que se creó exitosamente
                self?.mostrarAlertaExitosa()

                // Guardar el correo electrónico en la base de datos
                if let user = user {
                    let email = user.user.email ?? "" // Obtener el correo electrónico del usuario
                    let userID = user.user.uid // Obtener el UID del usuario
                    
                    let databaseRef = Database.database().reference().child("usuarios").child(userID).child("email")
                    databaseRef.setValue(email) { (error, ref) in
                        if let error = error {
                            print("Error al guardar el correo electrónico: \(error.localizedDescription)")
                            // Manejar el error al guardar en la base de datos si es necesario
                        } else {
                            print("Correo electrónico guardado en la base de datos correctamente")
                            // Puedes realizar acciones adicionales después de guardar en la base de datos si es necesario
                        }
                    }
                }
            }
        }

    }
    
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        let accionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alerta.addAction(accionOK)
        present(alerta, animated: true, completion: nil)
    }
    
    func mostrarAlertaExitosa() {
            let alerta = UIAlertController(title: "Éxito", message: "Usuario creado exitosamente.", preferredStyle: .alert)
            let accionOK = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
                // Activar el segue hacia la pantalla de inicio de sesión
                self?.performSegue(withIdentifier: "mostrarCrearUsuarioSegue", sender: nil)
            }
            alerta.addAction(accionOK)
            present(alerta, animated: true, completion: nil)
        }

}

