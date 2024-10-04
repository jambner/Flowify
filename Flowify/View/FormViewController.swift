//
//  FormViewController.swift
//  Flowify
//
//  Created by Ramon Martinez on 7/13/24.
//

import UIKit
import Photos

protocol DataRetrieval {
    func retrieveData(from textfields: [UITextField]) -> Bool
}

protocol KeyAssociable {
    var key: String? { get }
}

class FormViewController: UIViewController, ImagePickerDelegate {
    private var presenter = FormPresenter()
    private let imagePicker = ImagePicker()
    private var selectedImages: [UIImage] = []

    var dataDelegate: DataRetrieval!

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Flow Name"
        textField.borderStyle = .roundedRect
        return textField
    }()

    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()

    lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retrieveDataDelegate), for: .touchUpInside)
        return button
    }()

    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var mergeLink: UILabel = {
        let label = UILabel()
        label.text = "Already have screenshots? Merge"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mergeAction))
        label.addGestureRecognizer(tapGesture)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(submitButton)
        stackView.addArrangedSubview(recordButton)
        stackView.addArrangedSubview(mergeLink)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        dataDelegate = presenter
        nameTextField.validateEditedField(target: self, action: #selector(validateTextFields(_:)))
        emailTextField.validateEditedField(target: self, action: #selector(validateTextFields(_:)))

        // Set the image picker delegate
        imagePicker.delegate = self
    }

    @objc func toggleButtonAction() {
        presenter.recordingToggle { success in
            if success {
                print("worked")
            } else {
                print("no work")
            }
        }
    }

    @objc func retrieveDataDelegate() {
        let textFields = [nameTextField, emailTextField] // Add new text fields here as needed

        if let success = dataDelegate?.retrieveData(from: textFields), success {
            print("Data retrieval successful for all fields")
            presenter.photoAccessAuthorization()
        } else {
            print("Data retrieval failed for one or all fields")
        }
    }
    
    @objc func mergeAction() {
        imagePicker.present(from: self)
    }

    // ImagePickerDelegate method
    func didSelectImages(images: [UIImage]) {
        selectedImages = images
        let imageMerger = ImageMerger()
        let mergedImage = imageMerger.mergeImages(images: selectedImages)
        saveImageToPhotoLibrary(mergedImage)
    }

    private func saveImageToPhotoLibrary(_ image: UIImage?) {
        guard let image = image else { return }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                print("Image saved successfully.")
            } else {
                print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    @objc func validateTextFields(_ textfield: UITextField) {
        if textfield.text != "" {
            submitButton.isEnabled = true
            recordButton.isEnabled = true
            recordButton.backgroundColor = .systemRed
            submitButton.backgroundColor = .systemBlue
        } else {
            recordButton.isEnabled = false
            submitButton.isEnabled = false
        }
    }
}
