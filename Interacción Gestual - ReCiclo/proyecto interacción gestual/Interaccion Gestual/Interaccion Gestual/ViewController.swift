//
//  ViewController.swift
//  Interaccion Gestual
//
//  Created by Alberto Botana on 17/03/2020.
//  Copyright © 2020 Alberto Botana. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    var bottleOrigin: CGPoint!
    var chipOrigin: CGPoint!
    var paperOrigin: CGPoint!
    
    let limitscale: Int = 7
    let limitscale_bot: Int = 6
    
    var running = false
    var ready = false
    
    var seconds = 60
    var timer = Timer()
    
    @IBOutlet weak var bottleView: UIImageView!
    @IBOutlet weak var chipView: UIImageView!
    @IBOutlet weak var paperView: UIImageView!
    @IBOutlet weak var greenTrash: UIImageView!
    @IBOutlet weak var blueTrash: UIImageView!
    @IBOutlet weak var yellowTrash: UIImageView!
    
    var bottle_not_on_origin = false
    var chip_not_on_origin = false
    var paper_not_on_origin = false
    
    var bottleOriH: CGFloat!
    var bottleOriW: CGFloat!
    
    var chipOriH: CGFloat!
    var chipOriW: CGFloat!
    
    var paperOriH: CGFloat!
    var paperOriW: CGFloat!
    
    var score :Float = 0
    
    func callAlert(){
        let alert = UIAlertController(title: "Re:Ciclo", message: "¡Bienvenido a Re:Ciclo! Si ya conoces las reglas, pulsa el botón Listo para empezar. \n De lo contrario, pulsa el botón Reglas para aprender a jugar.", preferredStyle: .actionSheet)
        
        let done = UIAlertAction(title: "Listo", style: .default, handler: { action in
            self.ready = true
            self.runTimer()
            })
        
        let rules = UIAlertAction(title: "Reglas", style: .default, handler:{ action in
            self.callReglas1()
        })
        
        alert.addAction(done)
        alert.addAction(rules)
        
        if let popoverController = alert.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func callReglas1(){
        let reglasAlert1 = UIAlertController(title: "Reglas", message: "¡Tienes 60 segundos para reciclar todo lo que puedas! \n Arrastra cada elemento a su contenedor correspondiente para conseguir puntos. \n  Haz la basura más grande para conseguir más puntos, pero no te pases o no cabrá en el contenedor.", preferredStyle: .actionSheet)
        
        let reglasGoOn = UIAlertAction(title: "Siguiente", style: .default, handler:{ action in
            self.callReglas2()
        })
        
        
        reglasAlert1.addAction(reglasGoOn)
        
        
        if let popoverController = reglasAlert1.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }
        
        self.present(reglasAlert1, animated: true, completion: nil)
        
    }
    
    func callReglas2(){
        let reglasAlert2 = UIAlertController(title: "Reglas", message: "Las botellas tendrás que meterlas boca abajo ¡Pero dan más puntos! \n Si te pasas de tamaño, haz doble tap para reducir a la mitad. \n Si te quedas sin basura, pulsa en la pantalla para generar más. \n Pulsa el botón para empezar.", preferredStyle: .actionSheet)
        
        let done = UIAlertAction(title: "Listo", style: .default, handler: { action in
        self.ready = true
        self.runTimer()
        })
        
        reglasAlert2.addAction(done)
        
        if let popoverController = reglasAlert2.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }
        
        self.present(reglasAlert2, animated: true, completion: nil)
    }
    
    @IBOutlet weak var scoreCount: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    func runTimer() {
         timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1
        timerLabel.text = "\(seconds)"
        if (seconds > 0){
            running = true}
        else{
            running = false
            seconds = 0
        }
    }
    
    func check_origins_bottle(){
        if bottleView.frame.origin == bottleOrigin{
        bottle_not_on_origin = false}
        else{
        bottle_not_on_origin = true
        }
    }
    
    func check_origins_chips(){
        if chipView.frame.origin == chipOrigin{
        chip_not_on_origin = false}
        else{
        chip_not_on_origin = true
        }
    }
    
    func check_origins_paper(){
        if paperView.frame.origin == paperOrigin{
        paper_not_on_origin = false}
        else{
        paper_not_on_origin = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    

        
    addPanGestureBottle(view: bottleView)
    addPanGesturePaper(view: paperView)
    addPanGestureChip(view: chipView)
        
    addRotateBottle(view: bottleView)
    addRotateChip(view: chipView)
    addRotatePaper(view: paperView)
        
    addPinchBottle(view: bottleView)
    addPinchChip(view: chipView)
    addPinchPaper(view: paperView)
    
    bottleOriH = bottleView.bounds.size.height
    bottleOriW = bottleView.bounds.size.width
        
    chipOriW = chipView.bounds.size.width
    chipOriH = chipView.bounds.size.height
        
    paperOriW = paperView.bounds.size.width
    paperOriH = paperView.bounds.size.height
        
    bottleOrigin = bottleView.frame.origin
    chipOrigin = chipView.frame.origin
    paperOrigin = paperView.frame.origin
    

        
    view.bringSubviewToFront(bottleView)
    view.bringSubviewToFront(chipView)
    view.bringSubviewToFront(paperView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callAlert()
    }
    
    func updateScore(){
        if (score < 0){
            scoreCount.text = "0"
        }
        else{
            scoreCount.text = "\(score)"
        }
        
    }
    
    func getBottleScale() -> Float {
        guard let b_oriH = bottleOriH else { return Float(bottleOriH) }
        guard let b_oriW = bottleOriW else { return Float(bottleOriW) }
        let b_actualH = bottleView.bounds.size.height
        let b_actualW = bottleView.bounds.size.width
        
        let scale = (b_actualH*b_actualW)/(b_oriH*b_oriW)
        
        return Float(scale)
    }
    
    func getChipScale() -> Float {
        guard let c_oriH = chipOriH else { return Float(chipOriH) }
        guard let c_oriW = chipOriW else { return Float(chipOriW) }
        let c_actualH = chipView.bounds.size.height
        let c_actualW = chipView.bounds.size.width
        
        let scale = (c_actualH*c_actualW)/(c_oriH*c_oriW)
        
        return Float(scale)
    }
    
    func getPaperScale() -> Float {
        guard let p_oriH = paperOriH else { return Float(paperOriH) }
        guard let p_oriW = paperOriW else { return Float(paperOriW) }
        let p_actualH = paperView.bounds.size.height
        let p_actualW = paperView.bounds.size.width
        
        let scale = (p_actualH*p_actualW)/(p_oriH*p_oriW)
        
        return Float(scale)
    }
    
    func getBottleAngle() -> CGFloat {
        let radians = atan2(bottleView.transform.b, bottleView.transform.a)
        var degrees = radians * 180 / .pi
        degrees.round()
        let realDegrees = degrees >= 0 ? abs(degrees) : 360 + degrees
        return realDegrees
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
     -> Bool {return true}
    
    
    func addRotateBottle(view: UIView){
        let rotBot = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotateBottle(sender:)))
        rotBot.delegate = self
        view.addGestureRecognizer(rotBot)
    }
    
    func addRotateChip(view: UIView){
        let rotChip = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotateChip(sender:)))
        view.addGestureRecognizer(rotChip)
    }
    
    func addRotatePaper(view: UIView){
        let rotPap = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotatePaper(sender:)))
        view.addGestureRecognizer(rotPap)
    }
    
    
    
    func addPinchBottle(view:UIView){
        let pinchBot = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.bottleZoom(sender:)))
        pinchBot.delegate = self
        view.addGestureRecognizer(pinchBot)
    }
    
    func addPinchChip(view:UIView){
        let pinchChip = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.chipZoom(sender:)))
        pinchChip.delegate = self
        view.addGestureRecognizer(pinchChip)
    }
    
    func addPinchPaper(view:UIView){
        let pinchPaper = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.paperZoom(sender:)))
        pinchPaper.delegate = self
        view.addGestureRecognizer(pinchPaper)
    }
    
    
    func addPanGestureBottle(view: UIView){
        let panBottle = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanBottle(sender:)))
        view.addGestureRecognizer(panBottle)
    }
    
    func addPanGestureChip(view: UIView){
        let panChip = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanChip(sender:)))
        view.addGestureRecognizer(panChip)
    }
    
    func addPanGesturePaper(view: UIView){
        let panPaper = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanPaper(sender:)))
        view.addGestureRecognizer(panPaper)
    }
    
    @IBAction func addTapGesture(_ sender: Any) {
        let mark = Int.random(in: 0...2)
        if mark == 0{
            generateTrashBottle()
        }
        else if mark == 1{
            generateTrashChips()
        }
        else if mark == 2{
            generateTrashPaper()
        }
    }
    
    @IBAction func rotateBottle(sender: UIRotationGestureRecognizer) {
        guard sender.view != nil else { return }
        var netRotation = 0
        if sender.state == .began || sender.state == .changed{
            sender.view?.transform = sender.view!.transform.rotated(by: sender.rotation)
            sender.rotation = 0
            netRotation += 1
        }
        else{
            sender.rotation = 0
        }
    }
    
    @IBAction func rotateChip(sender: UIRotationGestureRecognizer) {
        guard sender.view != nil else { return }
        var netRotation = 0
        if sender.state == .began || sender.state == .changed{
            sender.view?.transform = sender.view!.transform.rotated(by: sender.rotation)
            sender.rotation = 0
            netRotation += 1
        }
        else{
            sender.rotation = 0
        }
    }
    
    @IBAction func rotatePaper(sender: UIRotationGestureRecognizer) {
        guard sender.view != nil else { return }
        var netRotation = 0
        let angle = sender.rotation
        if sender.state == .began || sender.state == .changed{
            sender.view?.transform = sender.view!.transform.rotated(by: angle)
            sender.rotation = 0
            netRotation += 1
            
        }
        else{
            sender.rotation = 0
        }
    }
    
    
    
    @IBAction func bottle2Tap(_ sender: UITapGestureRecognizer) {
        let item = bottleView
        var newBounds = item!.bounds
        let oricenter = item!.center
        newBounds.size.height *= 0.5
        newBounds.size.width *= 0.5
        item!.bounds = newBounds
        item!.setNeedsDisplay()
        item!.center = oricenter
    }
    
    @IBAction func chip2Tap(_ sender: UITapGestureRecognizer) {
        let item = chipView
        var newBounds = item!.bounds
        let oricenter = item!.center
        newBounds.size.height *= 0.5
        newBounds.size.width *= 0.5
        item!.bounds = newBounds
        item!.setNeedsDisplay()
        item!.center = oricenter
    }
    
    
    @IBAction func paper2Tap(_ sender: UITapGestureRecognizer) {
        let item = paperView
        var newBounds = item!.bounds
        let oricenter = item!.center
        newBounds.size.height *= 0.5
        newBounds.size.width *= 0.5
        item!.bounds = newBounds
        item!.setNeedsDisplay()
        item!.center = oricenter
    }
    
    
    
    @objc func handlePanBottle(sender: UIPanGestureRecognizer){
        
        let bottle = sender.view!
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .began,.changed:
            bottleView.center = CGPoint(x: bottle.center.x + translation.x, y: bottle.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if bottleView.frame .intersects(greenTrash.frame){
                bottleDrop()
            }
        default:
            break
        }
    }
    
    @objc func handlePanChip(sender: UIPanGestureRecognizer){
        
        let chip = sender.view!
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .began,.changed:
            chipView.center = CGPoint(x: chip.center.x + translation.x, y: chip.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if chipView.frame .intersects(yellowTrash.frame){
                chipDrop()
            }
        default:
            break
        }
    }
    
    @objc func handlePanPaper(sender: UIPanGestureRecognizer){
        
        let paper = sender.view!
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .began,.changed:
            paperView.center = CGPoint(x: paper.center.x + translation.x, y: paper.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if paperView.frame .intersects(blueTrash.frame){
                paperDrop()
            }
        default:
            break
        }
    }
    
    
    
    @IBAction func bottleZoom(sender: UIPinchGestureRecognizer) {
        let item = bottleView
        if sender.state == .changed || sender.state == .ended{
            let scale = sender.scale
            var newBounds = item!.bounds
            newBounds.size.width *= scale
            newBounds.size.height *= scale
            item?.bounds = newBounds
            item?.setNeedsDisplay()
            sender.scale = 1.0
        }
    }
    
    @IBAction func chipZoom(sender: UIPinchGestureRecognizer) {
        let item = chipView
        if sender.state == .changed || sender.state == .ended{
            let scale = sender.scale
            var newBounds = item!.bounds
            newBounds.size.width *= scale
            newBounds.size.height *= scale
            item?.bounds = newBounds
            item!.setNeedsDisplay()
            sender.scale = 1.0
        }
    }
    
    @IBAction func paperZoom(sender: UIPinchGestureRecognizer) {
        let item = paperView
        if sender.state == .changed || sender.state == .ended{
            let scale = sender.scale
            var newBounds = item!.bounds
            newBounds.size.width *= scale
            newBounds.size.height *= scale
            item?.bounds = newBounds
            item!.setNeedsDisplay()
            sender.scale = 1.0
        }
    }
    
    func bottleDrop(){
        let angle = getBottleAngle()
        
        if (angle < 220 && angle > 150 && Int(getBottleScale()) < limitscale_bot) && running == true {
            begoneBottle()
            self.score += 100 * round(self.getBottleScale())
            self.updateScore()
        }
    }
    
    func chipDrop(){
        if (Int(getChipScale()) < limitscale && running == true) {
            begoneChip()
            self.score += 75 * round(self.getChipScale())
            self.updateScore()
        }
    }
    
    func paperDrop(){
        if (Int(getPaperScale()) < limitscale && running == true) {
            begonePaper()
            self.score += 75 * round(self.getPaperScale())
            self.updateScore()
        }
    }
    
    func begoneBottle(){
        UIView.animate(withDuration: 0.3) {
        self.bottleView.alpha=0.0
        }
    }
    
    func begoneChip(){
        UIView.animate(withDuration: 0.3) {
        self.chipView.alpha=0.0
        }
    }
    
    func begonePaper(){
        UIView.animate(withDuration: 0.3) {
        self.paperView.alpha=0.0
        }
    }
    
    func generateTrashBottle() {
        check_origins_bottle()
        if bottle_not_on_origin{
            bottleView.bounds.size.width = bottleOriW
            bottleView.bounds.size.height = bottleOriH
            bottleView.frame.origin = bottleOrigin
            bottleView.alpha=1.0
            bottleView.transform = .identity
        }
    }
    
    func generateTrashChips() {
        check_origins_chips()
        if chip_not_on_origin{
            chipView.bounds.size.width = chipOriW
            chipView.bounds.size.height = chipOriH
            chipView.frame.origin = chipOrigin
            chipView.alpha=1.0
        }
    }
    
    func generateTrashPaper() {
        check_origins_paper()
        if paper_not_on_origin{
            paperView.bounds.size.width = paperOriW
            paperView.bounds.size.height = paperOriH
            paperView.frame.origin = paperOrigin
            paperView.alpha=1.0
        }
    }
    
}


