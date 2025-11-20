//
//  ViewController.swift
//  Image Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!

    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!

    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var rotateButton: UIButton!
    let captionTextView = UITextView()
    let captionPlaceholderLabel = UILabel()
    var captionHeightConstraint: NSLayoutConstraint?
    @objc public var initialMessageText: String?
    
    @objc public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    @objc public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    @objc public var colors  : [UIColor] = []
    
    @objc public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    @objc public var hiddenControls : [NSString] = []

    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    var currentRotationAngle: CGFloat = 0

    
    var stickersViewController: StickersViewController!

    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setImageView(image: image!)
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        hideControls()

        // set languages for controls
        doneButton.setTitle(TranslationService.shared.getTranslation(for: "doneTitle"), for: .normal)
        setupCaptionInput()
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }

    private func setupCaptionInput() {
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        captionTextView.backgroundColor = UIColor(red: 32/255, green: 43/255, blue: 44/255, alpha: 1)
        captionTextView.textColor = .white
        captionTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        captionTextView.layer.cornerRadius = 24
        captionTextView.clipsToBounds = true
        captionTextView.isScrollEnabled = false
        captionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        captionTextView.text = initialMessageText ?? ""
        captionTextView.tintColor = .white
        captionTextView.returnKeyType = .default
        captionTextView.autocorrectionType = .yes
        view.addSubview(captionTextView)

        captionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        captionPlaceholderLabel.text = "Add a caption..."
        captionPlaceholderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        captionPlaceholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        captionTextView.addSubview(captionPlaceholderLabel)

        captionHeightConstraint = captionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        captionHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            captionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            captionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            captionTextView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor, constant: 0),
            captionPlaceholderLabel.leadingAnchor.constraint(equalTo: captionTextView.leadingAnchor, constant: 24),
            captionPlaceholderLabel.topAnchor.constraint(equalTo: captionTextView.topAnchor, constant: 12)
        ])

        captionPlaceholderLabel.isHidden = !(captionTextView.text?.isEmpty ?? true)
        updateCaptionHeight()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captionTextDidChange),
            name: UITextView.textDidChangeNotification,
            object: captionTextView
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func captionTextDidChange() {
        captionPlaceholderLabel.isHidden = !(captionTextView.text?.isEmpty ?? true)
        updateCaptionHeight()
    }

    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: captionTextView)
        if !captionTextView.bounds.contains(location) {
            captionTextView.resignFirstResponder()
        }
    }

    private func updateCaptionHeight() {
        guard let constraint = captionHeightConstraint else { return }
        let width = captionTextView.bounds.width
        if width == 0 { return }
        let size = captionTextView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        constraint.constant = max(48, size.height)
        view.layoutIfNeeded()
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: captionTextView)
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}
