//
//  ViewController.swift
//  YRojasSnapchat
//
//  Created by yrojas on 11/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class IniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func IniciarSesionGoogle(_ sender: GIDSignInButton) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
              print("Se presento el siguiente error: \(error)")
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              print("El usuario se ha autenticado con exito con google")
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
        }
    }
 
    

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in print("Intentar iniciar sesion")
            if error != nil{
                print("Se presento el siguiente error: \(error)")
            }else{
                print("Inicio de sesion de sesion exitoso")
            }
        }
    }
    
    

}

