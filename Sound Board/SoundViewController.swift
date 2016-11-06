//
//  SoundViewController.swift
//  Sound Board
//
//  Created by Andrei Palonski on 06.11.16.
//  Copyright © 2016 Andrei Palonski. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  
  var audioRecoder : AVAudioRecorder?
  var audioPlayer : AVAudioPlayer?
  var audioURL : URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameTextField.delegate = self
    setupRecoder()
    playButton.isEnabled = false
    addButton.isEnabled = false
  }
  
  func setupRecoder() {
    
    // создание аудио сессии
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
      try audioSession.overrideOutputAudioPort(.speaker)
      try audioSession.setActive(true)
      
      // создание URL для аудио файла
      
      let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! // возвращает 1ый элемент массива
      let pathComponents = [basePath, "audio.m4a"] // можно попробовать и с mp3
      audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
      
      // создание настроек для audio recoder
      
      var audioSettings : [String:Any] = [:]
      audioSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
      audioSettings[AVSampleRateKey] = 44100.0
      audioSettings[AVNumberOfChannelsKey] = 2
      
      
      // создание объекта AudioRecoder
      audioRecoder = try AVAudioRecorder(url: audioURL!, settings: audioSettings)
      audioRecoder!.prepareToRecord()
      
    } catch let error as NSError{
      print(error.localizedDescription)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder() // кнопкой return  клавиатуры можно ее отпустить
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)  // отпускаем клавиатуру тапом в любое мето
  }
  
  @IBAction func recordButtonTapped(_ sender: Any) {
    
    if audioRecoder!.isRecording {
      
      // Остановить запись
      audioRecoder?.stop()
      
      // Поменять тайтл кнопки на Записать
      recordButton.setTitle("Записать", for: .normal)
      playButton.isEnabled = true
      addButton.isEnabled = true
      
    } else {
      
      // Начать запись
      audioRecoder?.record()
      
      // Поменять тайтл кнопки на Остановить
      recordButton.setTitle("Остановить", for: .normal)
      
    }
  }
  
  @IBAction func playButtonTapped(_ sender: Any) {
    
    do {
   try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
      audioPlayer!.play()
    } catch let error as NSError {
    print(error.localizedDescription)
    }
  }
  
  @IBAction func addButtonTapped(_ sender: Any) {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let sound = Sound(context: context)
    sound.name = nameTextField.text
    sound.audio = NSData(contentsOf: audioURL!)
    (UIApplication.shared.delegate as! AppDelegate).saveContext()
    
    navigationController!.popViewController(animated: true)
  }
  
  
}
