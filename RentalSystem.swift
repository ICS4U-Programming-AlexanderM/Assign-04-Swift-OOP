import Foundation
//  Created by Alexander Matheson
//  Created on 2023-June-12
//  Version 1.0
//  Copyright (c) 2023 Alexander Matheson. All rights reserved.
//
//  This is a mock-up of a vehicle rental system.

// Customer class
class Customer {
  // Variables for class.
  var _firstName: String
  var _lastName: String
  var _license: Int
  var _phone: Int
  var _email: String
  var _vehicle: String
  var _length: Int

  // Constructor.
  init(firstName: String, lastName: String, license: Int, phone: Int, email: String, vehicle: String, length: Int) {
    self._firstName = firstName
    self._lastName = lastName
    self._license = license
    self._phone = phone
    self._email = email
    self._vehicle = vehicle
    self._length = length
  }
}

// Vehicle class.
class Vehicle {
  // Variables for class.
  let _BASECOST = 100
  var _isAvailable: Bool
  var _multiplier: Int

  // Constructor.
  // This constructor is only ever called if a non-existent vehicle is requested.
  init() {
    self._multiplier = 0
    self._isAvailable = false
  }

  // Drive method.
  // Determines if the rented vehicle was damaged.
  func drive() -> Bool {
    var isDamaged = false

    // Chance of damage has been augmented for testing purposes.
    let chance = Int.random(in: 1...25)

    // Determine if the vehicle is damaged.
    if chance == 1 {
      isDamaged = true
    }
    return isDamaged
  }
}

// Ford subclass.
class Ford: Vehicle {
  // Ford constructor.
  init(stock: Stock) {
    super.init()
    self._multiplier = 25

    // Check if a Ford is available.
    self._isAvailable = stock.decreaseFord()
  }
}

// Honda subclass.
class Honda: Vehicle {
  // Honda constructor.
  init(stock: Stock) {
    super.init()
    self._multiplier = 20

    // Check if a Honda is available.
    self._isAvailable = stock.decreaseHonda()
  }
}

// Rental class.
class Rental {
  // Variables for this class.
  let _DAMAGECHARGE = 2000
  var _vehicle: Vehicle
  var _customer: Customer

  // Rental constructor.
  init(vehicle: Vehicle, customer: Customer) {
    self._vehicle = vehicle
    self._customer = customer
  }

  // Function to calculate the cost of the rental.
  func calculateCost() -> String {
    var cost: Int
    var costString: String

    // Check if the vehicle was damaged.
    if self._vehicle.drive() {
      // Add repair fees.
      cost = self._vehicle._BASECOST + (self._customer._length * self._vehicle._multiplier) + self._DAMAGECHARGE
      costString = "Due to repair fees, $" + "\(cost)"
    } else {
      cost = self._vehicle._BASECOST + (self._customer._length * self._vehicle._multiplier)
      costString = "$" + "\(cost)"
    }
    return costString
  }

  // Print information.
  func print() -> String {
    var info: String

    // Determine the availability of the vehicle.
    if !self._vehicle._isAvailable {
      info = "Unfortunately, the requested vehicle is not available, please contact " + self._customer._firstName + " " + self._customer._lastName + " Once it becomes available."
      info += " You can contact them at: " + self._customer._email + ", or: " + "\(self._customer._phone)"
    } else {
      info = self.calculateCost() + " will be charged to " + self._customer._firstName + " " + self._customer._lastName
      info += " You can contact them at: " + self._customer._email + ", or: " + "\(self._customer._phone)"
    }
    return info
  }
}

// Stock class
class Stock {
  // VAriables for this class.
  var _totalFord: Int
  var _totalHonda: Int

  // Stock constructor.
  init(totalFord: Int, totalHonda: Int) {
    self._totalFord = totalFord
    self._totalHonda = totalHonda
  }

  // Function to check availability of Ford and decrease stock.
  func decreaseFord() -> Bool {
    // Variable for method.
    var isAvailable = true

    // Check availability
    if self._totalFord - 1 < 0 {
      isAvailable = false
    } else {
      self._totalFord -= 1
    }
    return isAvailable
  }

  // Function to check availability of Honda and decrease stock.
  func decreaseHonda() -> Bool {
    // Variable for method.
    var isAvailable = true

    // Check availability
    if self._totalHonda - 1 < 0 {
      isAvailable = false
    } else {
      self._totalHonda -= 1
    }
    return isAvailable
  }
}

// Main body of code.
// Enum for error checking.
enum InputError: Error {
  case InvalidInput
}

// Input in separate function for error checking.
func convert(strUnconverted: String) throws -> Int {
  guard let numConverted = Int(strUnconverted.trimmingCharacters(in: CharacterSet.newlines)) else {
    throw InputError.InvalidInput
  }
  return numConverted
}

// Declare variables, constants and create stock class.
let FORDS = 2
let HONDAS = 3
let totalStock = Stock(totalFord: FORDS, totalHonda: HONDAS)

// User chooses file to get input from.
print("Enter the name of the (csv) file to use: ")
let fileName = readLine()!

let fileManager = FileManager.default

// Check if file exists
if fileManager.fileExists(atPath: fileName) {
  // Read in lines from input file.
  let inputFile = URL(fileURLWithPath: fileName)
  let inputData = try String(contentsOf: inputFile)
  let lineArray = inputData.components(separatedBy: "\r\n")

  // Open the output file for writing.
  let outputFile = URL(fileURLWithPath: "output.txt")

  // Start counter at 1 to skip header line.
  var counter = 1

  // Add greeting message.
  var customerInfo = "Greetings system admin, \(FORDS) Ford vehicles and \(HONDAS) Honda vehicles were available this session. Here are our charges for this session:\n"

  // Loop to read input file.
  while counter < lineArray.count {
    do {
      let customerList = lineArray[counter].components(separatedBy: ",")

      // Convert phone number, license number, and length of rental to int.
      let tempLicense = try convert(strUnconverted: customerList[2])
      let tempPhone = try convert(strUnconverted: customerList[3])
      let tempLength = try convert(strUnconverted: customerList[6])

      // Create customer class.
      let currentCustomer = Customer(firstName: customerList[0], lastName: customerList[1], license: tempLicense, phone: tempPhone, email: customerList[4], vehicle: customerList[5], length: tempLength)

      // Create vehicle class.
      let currentVehicle: Vehicle

      // Determine which vehicle subclass to create.
      if currentCustomer._vehicle.lowercased() == "ford" {
        currentVehicle = Ford(stock: totalStock)
      } else if currentCustomer._vehicle.lowercased() == "honda" {
        currentVehicle = Honda(stock: totalStock)
      } else {
        currentVehicle = Vehicle()
      }

      // Create rental class.
      let currentRental = Rental(vehicle: currentVehicle, customer: currentCustomer)

      // Print cost of the rental.
      customerInfo += currentRental.print() + "\n"
    } catch InputError.InvalidInput {
      customerInfo += "Please ensure all information has been entered correctly.\n"
    }

    // Increment counter
    counter += 1
  }

  // Print to output file.
  try customerInfo.write(to: outputFile, atomically: true, encoding: .utf8)
} else {
  print("Error, the requested file was not found. Please ensure the file name was spelled correctly, and that the file has been placed in the correct folder.")
}
