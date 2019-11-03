import UIKit

//UIButton.appearance().contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
//UIButton.appearance().titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

// Subclassing
class BaseButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class RoundedButton: BaseButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    clipsToBounds = true
    layer.cornerRadius = 6
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class FilledButton: RoundedButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    tintColor = .white
    backgroundColor = .black
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// Composition
extension UIButton {
  static var base: UIButton {
    let button = UIButton()
    button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

    return button
  }

  static var filled: UIButton {
    let button = self.base
    button.tintColor = .white
    button.backgroundColor = .black

    return button
  }

  static var rounded: UIButton {
    let button = self.filled
    button.clipsToBounds = true
    button.layer.cornerRadius = 6

    return button
  }
}

// Functions
func baseButtonStyle(_ button: UIButton) {
  button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
  button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}

func <> <A>(_ f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}

let roundedStyle: (UIView) -> Void = {
  $0.clipsToBounds = true
  $0.layer.cornerRadius = 6
}

func borderStyle(color: UIColor, width: CGFloat) -> (UIView) -> Void {
  return {
    $0.layer.borderWidth = width
    $0.layer.borderColor = color.cgColor
  }
}

let baseTextFieldStyle: (UITextField) -> Void =
  roundedStyle
    <> borderStyle(color: UIColor(white: 0.75, alpha: 1), width: 1)
    <> { (textField: UITextField) in
      textField.borderStyle = .roundedRect
      textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
}

let roundedButtonStyle = baseButtonStyle
  <> roundedStyle

let filledButtonStyle = roundedButtonStyle
  <> {
    $0.tintColor = .white
    $0.backgroundColor = .black
}

let borderButtonStyle =
    roundedStyle
    <> borderStyle(color: .black, width: 2)

final class SignInViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    let gradientView = GradientView()
    gradientView.fromColor = UIColor(red: 0.5, green: 0.85, blue: 1, alpha: 0.85)
    gradientView.toColor = .white
    gradientView.translatesAutoresizingMaskIntoConstraints = false

    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: logoImageView.frame.width / logoImageView.frame.height).isActive = true

    let gitHubButton = UIButton(type: .system)
    filledButtonStyle(gitHubButton)
    gitHubButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    gitHubButton.setImage(UIImage(named: "github"), for: .normal)
    gitHubButton.setTitle("Sign in with GitHub", for: .normal)

    let orLabel = UILabel()
    orLabel.font = .systemFont(ofSize: 14, weight: .medium)
    orLabel.textAlignment = .center
    orLabel.textColor = UIColor(white: 0.625, alpha: 1)
    orLabel.text = "or"

    let emailField = UITextField()
    baseTextFieldStyle(emailField)
    emailField.keyboardType = .emailAddress
    emailField.placeholder = "blob@pointfree.co"

    let passwordField = UITextField()
    baseTextFieldStyle(passwordField)
    passwordField.isSecureTextEntry = true
    passwordField.placeholder = "••••••••••••••••"

    let signInButton = UIButton(type: .system)
    borderButtonStyle(signInButton)
    signInButton.setTitleColor(.black, for: .normal)
    signInButton.setTitle("Sign in", for: .normal)

    let forgotPasswordButton = UIButton(type: .system)
    forgotPasswordButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    forgotPasswordButton.setTitleColor(.black, for: .normal)
    forgotPasswordButton.setTitle("I forgot my password", for: .normal)

    let legalLabel = UILabel()
    legalLabel.font = .systemFont(ofSize: 11, weight: .light)
    legalLabel.numberOfLines = 0
    legalLabel.textAlignment = .center
    legalLabel.textColor = UIColor(white: 0.5, alpha: 1)
    legalLabel.text = "By signing into Point-Free you agree to our latest terms of use and privacy policy."

    let rootStackView = UIStackView(arrangedSubviews: [
      logoImageView,
      gitHubButton,
      orLabel,
      emailField,
      passwordField,
      signInButton,
      forgotPasswordButton,
      legalLabel,
      ])

    rootStackView.axis = .vertical
    rootStackView.isLayoutMarginsRelativeArrangement = true
    rootStackView.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
    rootStackView.spacing = 16
    rootStackView.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(gradientView)
    self.view.addSubview(rootStackView)

    NSLayoutConstraint.activate([
      gradientView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      gradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      gradientView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor),

      rootStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      ])
  }
}

import PlaygroundSupport
PlaygroundPage.current.liveView = SignInViewController()
