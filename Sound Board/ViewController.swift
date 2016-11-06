//
//  ViewController.swift
//  Sound Board
//
//  Created by Andrei Palonski on 06.11.16.
//  Copyright © 2016 Andrei Palonski. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var soundsArray : [Sound] = []
  var audioPlayer: AVAudioPlayer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    do {
      soundsArray = try context.fetch(Sound.fetchRequest())
      tableView.reloadData()
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return soundsArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let sound = soundsArray[indexPath.row]
    cell.textLabel?.text = sound.name
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sound = soundsArray[indexPath.row]
    do {
      audioPlayer = try AVAudioPlayer(data: sound.audio! as Data)
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let sound = soundsArray[indexPath.row]
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      context.delete(sound)
      (UIApplication.shared.delegate as! AppDelegate).saveContext()
      do {
        soundsArray = try context.fetch(Sound.fetchRequest())
        tableView.reloadData()
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
  }
  
}

