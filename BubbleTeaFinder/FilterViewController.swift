/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!

  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!

  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

  // MARK: - Properties
  var coredataStack: CoreDataStack!
  weak var delegate: FilterViewControllerDelegate?
  var selectedPredicate: NSPredicate?
  var selectedSortDescriptor: NSSortDescriptor?

  var filterCells: [UITableViewCell] {
    return [
      cheapVenueCell,
      moderateVenueCell,
      expensiveVenueCell,

      offeringDealCell,
      walkingDistanceCell,
      userTipsCell
    ]
  }

  var sortCells: [UITableViewCell] {
    return [
      nameAZSortCell,
      nameZASortCell,
      distanceSortCell,
      priceSortCell
    ]
  }

  var allCell: [UITableViewCell] {
    return filterCells + sortCells
  }

  lazy var cheapVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
  }()

  lazy var moderateVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
  }()

  lazy var expensiveVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
  }()

  lazy var offeringDealPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
  }()

  lazy var walkingDistancePredicate: NSPredicate = {
    return NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
  }()

  lazy var hasTipsPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
  }()

  lazy var nameSortDescriptor: NSSortDescriptor = {
    let compareSelector = #selector(NSString.localizedStandardCompare(_:))
    return NSSortDescriptor(
      key: #keyPath(Venue.name),
      ascending: true,
      selector: compareSelector
    )
  }()

  lazy var distanceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(
      key: #keyPath(Venue.location.distance),
      ascending: true
    )
  }()

  lazy var priceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(
      key: #keyPath(Venue.priceInfo.priceCategory),
      ascending: true
    )
  }()

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    populateCheapVenueCountLabel()
    populateModerateVenueCountLabel()
    populateExpensiveVenueCountLabel()
    populateDealsCountLabel()
  }
}

// MARK: - Helper Methods
extension FilterViewController {
  func populateCheapVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = cheapVenuePredicate

    do {
      let countResult = try coredataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first?.intValue ?? 0
      let pluralized = count == 1 ? "place" : "places"
      firstPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Fetch error: \(error), userInfo: \(error.userInfo)")
    }
  }

  func populateModerateVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = moderateVenuePredicate

    do {
      let countResult = try coredataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first?.intValue ?? 0
      let pluralized = count == 1 ? "place" : "places"
      secondPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Fetch error: \(error), userInfo: \(error.userInfo)")
    }
  }

  func populateExpensiveVenueCountLabel() {
    let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
    fetchRequest.predicate = expensiveVenuePredicate

    do {
      let count = try coredataStack.managedContext.count(for: fetchRequest)
      let pluralized = count == 1 ? "place" : "places"
      thirdPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print("Fetch error: \(error), userInfo: \(error.userInfo)")
    }
  }

  func populateDealsCountLabel() {
    let specialCountKeyPathExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
    let sumExpression = NSExpression(forFunction: "sum:", arguments: [specialCountKeyPathExp])

    let sumExpressionDesc = NSExpressionDescription()
    sumExpressionDesc.name = "sumDeals"
    sumExpressionDesc.expression = sumExpression
    sumExpressionDesc.expressionResultType = .integer32AttributeType


    // count does not need any specific colulm but NSExpression(forFunction:arguments:)
    // expects at least one argument in its arguments list
//    let countExpression = NSExpression(forFunction: "count:", arguments: [specialCountKeyPathExp])

//    let countExpressionDesc = NSExpressionDescription()
//    countExpressionDesc.name = "countVenue"
//    countExpressionDesc.expression = countExpression
//    countExpressionDesc.expressionResultType = .integer32AttributeType

    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
    fetchRequest.resultType = .dictionaryResultType
//    fetchRequest.propertiesToFetch = [sumExpressionDesc, countExpressionDesc]
    fetchRequest.propertiesToFetch = [sumExpressionDesc]

    do {
      let results = try coredataStack.managedContext.fetch(fetchRequest)
      let resultDict = results.first!
      let numDeals = resultDict["sumDeals"] as! Int
//      let numVenue = resultDict["countVenue"] as! Int
      let pluralized = numDeals == 1 ? "deal" : "deals"
      numDealsLabel.text = "\(numDeals) \(pluralized)"
    } catch let error as NSError {
      print("Fetch error: \(error), userInfo: \(error.userInfo)")
    }
  }

  func deselectAllFilterCell() {
    for cell in filterCells {
      cell.accessoryType = .none
    }
  }

  func deselectAllSortCells() {
    for cell in sortCells {
      cell.accessoryType = .none
    }
  }
}

// MARK: - IBActions
extension FilterViewController {
  @IBAction func search(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate
extension FilterViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath)
    else {
      return
    }

    switch cell {
    // price section
    case cheapVenueCell:
      selectedPredicate = cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = expensiveVenuePredicate

    // most popular section
    case offeringDealCell:
      selectedPredicate = offeringDealPredicate
    case walkingDistanceCell:
      selectedPredicate = walkingDistancePredicate
    case userTipsCell:
      selectedPredicate = hasTipsPredicate

    // sort by section
    case nameAZSortCell:
      selectedSortDescriptor = nameSortDescriptor
    case nameZASortCell:
      selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
    case distanceSortCell:
      selectedSortDescriptor = distanceSortDescriptor
    case priceSortCell:
      selectedSortDescriptor = priceSortDescriptor
    default:
      break
    }

    if filterCells.contains(cell) {
      deselectAllFilterCell()
    } else if sortCells.contains(cell) {
      deselectAllSortCells()
    }

    cell.accessoryType = .checkmark
  }
}
