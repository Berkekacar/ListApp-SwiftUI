//
//  ViewController.swift
//  ListApp
//
//  Created by Berke Kaçar on 17.09.2023.
//

import UIKit
import CoreData
class ViewController: UIViewController{
 
    @IBOutlet weak var tableView:UITableView!
    
     var data = [NSManagedObject]()
    var alertController=UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate=self
        tableView.dataSource=self
        
        //uygulama açılınca veri çekilsin
        self.fetch()
        
        
        
    }
    @IBAction func didDeleteButtonTapped(_ sender: UIBarButtonItem){
        self.presentAlert(title: "Uyarı",
                          message: "Listedeki Tüm Elemanları silmek Istediğinize Emin misiniz?",
                          defaultButtontitle: "Evet",
                          cancelButtontitle: "Vazgeç",
                          isTextFieldButtonTitle:false ,
                          defaultButtonHandler: {_ in
            
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let menagedObjectContect = appDelegate?.persistentContainer.viewContext
            
            for object in self.data {
                menagedObjectContect?.delete(object)
            }
            try! menagedObjectContect?.save()
            self.fetch()
        })
        
        
    }
    
    @IBAction func didAddBarButton(_ sender:UIBarButtonItem){
        
        presentAddAlert()
    }
   
    
    
    
    func presentAddAlert(){
        
        presentAlert(title:"Yeni Eleman Ekle",
                     message: nil,
                     defaultButtontitle: "Ekle",
                     cancelButtontitle: "Vazgeç",
                    isTextFieldButtonTitle: true,
                     defaultButtonHandler: {  _ in
            if self.alertController.textFields?.first?.text != "" {
                //self.data.append((self.alertController.textFields?.first?.text)!)
                
                //Veri tabanına eriş
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                // veri tabanı
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                //entity oluştur
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(self.alertController.textFields?.first?.text, forKey: "title")
                
                
               try?  managedObjectContext?.save()
                self.fetch()
            }else{
                self.presentWarningAlert()
            }
        })
        
}
    
    func presentWarningAlert(){
       
        presentAlert(title: "Uyarı", message: "Liste Elemanı Boş olamaz", cancelButtontitle: "Tamam")
    }
    
    func presentAlert(title:String?,message:String?,
                      preferredStyle:UIAlertController.Style = .alert,
                      defaultButtontitle:String? = nil,
                      cancelButtontitle:String?,
                      isTextFieldButtonTitle:Bool = false,
                      defaultButtonHandler:((UIAlertAction)-> Void)? = nil
                      
    ){
         alertController=UIAlertController(title: title, message: message,
                                               preferredStyle: preferredStyle)
        if defaultButtontitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtontitle
                                              , style: .default,
                                                handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title:cancelButtontitle, style: UIAlertAction.Style.cancel)
        if isTextFieldButtonTitle{
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }

    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let menagedObjectContect = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data=try! menagedObjectContect!.fetch(fetchRequest)
        tableView.reloadData()
    }
}


//var olan klası onu yeniden ütermeden ona yeni özellikler yüklemek.
extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for:indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text =  listItem.value(forKey: "title") as? String
        return cell;
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil!") { _, _, _ in
            
            //self.data.remove(at: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let menagedObjectContect = appDelegate?.persistentContainer.viewContext
            
            menagedObjectContect?.delete(self.data[indexPath.row])
            
            try! menagedObjectContect?.save()
            self.fetch()
            self.tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            self.presentAlert(title: "Elamanı Düzenle",
                              message: nil,
                              defaultButtontitle: "Düzenle" ,
                              cancelButtontitle: "Vazgeç",
                              isTextFieldButtonTitle: true) { _ in
                if self.alertController.textFields?.first?.text != "" {
                    
                    //self.data[indexPath.row]=(self.alertController.textFields?.first?.text)!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let menagedObjectContect = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(self.alertController.textFields?.first?.text, forKey: "title")
                    
                    if menagedObjectContect!.hasChanges{
                        try! menagedObjectContect?.save()
                    }
                    
                    try! menagedObjectContect?.save()
                    self.fetch()
                    
                    
                }else{
                    self.presentWarningAlert()
                }
            }
            
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return config
    }
}
