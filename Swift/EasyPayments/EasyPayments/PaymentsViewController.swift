//
//  PaymentsViewController.swift
//  EasyPayments
//
//  Created by Kostyantyn Hushchyn on 27.02.2024.
//

import UIKit
import CoreData

protocol Providable {
    associatedtype ProvidedItem: Hashable
    
    func configure(with item: ProvidedItem)
}

class PaymentCell: UICollectionViewCell, Providable {
    typealias ProvidedItem = Payment
    
    @IBOutlet weak var payType: UIImageView!
    @IBOutlet weak var payDescription: UITextView!
    @IBOutlet weak var payAmount: UILabel!
    @IBOutlet weak var payDate: UILabel!

    public func configure(with item: ProvidedItem) {
        self.payDescription.text = item.info
        self.payAmount.text = "\(item.bill)$"
        self.payDate.text = item.expectedDate?.formatted(date: .numeric, time: .omitted) ?? ""
    }
}

class PaymentsViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var fetchedResultController: NSFetchedResultsController<Payment>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        collectionView.collectionViewLayout = configureLayout()
        initFetchedResultsController()
    }
    
    private func initFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // sort by item text
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Payment.expectedDate), ascending: false)]
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        resultsController.delegate = self;
        fetchedResultController = resultsController
        
        do {
            try fetchedResultController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror)")
        }
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController!.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        let model = fetchedResultController!.object(at: indexPath)
        cell.configure(with: model)
        return cell
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            collectionView.deleteItems(at: [indexPath!])

        case .insert:
            collectionView.insertItems(at: [newIndexPath!])

        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)

        case .update:
            let cell = collectionView.cellForItem(at: indexPath!) as! PaymentCell
            let model = fetchedResultController!.object(at: indexPath!)
            cell.configure(with: model)

        default:
            break
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        let namesArray = ["Electricity", "Water", "Fuel", "TV", "Rent"]

        let date1 = Date.parse("2018-01-01")
        let date2 = Date()
        
        let payment = Payment(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        payment.info = namesArray.randomElement() ?? namesArray[0]
        payment.bill = round(Double.random(in: 1.0 ..< 20.0) * 100) / 100.0
        payment.expectedDate = Date.randomBetween(start: date1, end: date2)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func calcItems(_ sender: Any) {
        let bill = round((fetchedResultController?.fetchedObjects?.reduce(0.0) {
            $0 + $1.bill
        } ?? 0.0) * 100) / 100.0
        let result = "Total: \(bill) $"
        presentAlert(title: "Bill Summary", subTitle: result, primaryAction: UIAlertAction(title: "OK", style: .destructive))
    }
    
    func presentAlert(title: String, subTitle: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
            alertController.addAction(primaryAction)
            if let secondary = secondaryAction {
                alertController.addAction(secondary)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
