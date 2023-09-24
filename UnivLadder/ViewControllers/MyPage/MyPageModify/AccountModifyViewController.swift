//
//  AccountModifyViewController.swift
//  UnivLadder
//
//  Created by leeyeon2 on 2022/10/09.
//

import UIKit
import CoreData
import Alamofire

// 개인 정보 수정 화면
// 비밀번호는 확인 용
class AccountModifyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var Picker = UIImagePickerController()
    var container: NSPersistentContainer!
    
    let userInfo = CoreDataManager.shared.getUserInfo()
    var gender = ""
    var thumbnail = UserDefaults.standard.string(forKey: "thumbnail") ?? ""
    // 소셜 로그인 시 넘어온 정보
    var myEmail = ""
    var myNickName = ""
    var selectedImg = UIImage()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var accountImg: UIImageView!{
        didSet{
            accountImg.layer.cornerRadius = Constant.profileImgSize/2
            accountImg.clipsToBounds = true
            accountImg.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var accountImgModifyBtn: UIButton!
    @IBOutlet weak var saveModifiedUserInfoBtn: UIButton!{
        didSet{
            saveModifiedUserInfoBtn.layer.cornerRadius = 10
        }
    }
    @IBAction func maleBtn(_ sender: Any) {
        maleBtn.backgroundColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
        maleBtn.tintColor = UIColor.white
        femaleBtn.backgroundColor = UIColor.white
        femaleBtn.tintColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
        self.gender = "MAN"
    }
    
    @IBAction func femaleBtn(_ sender: Any) {
        femaleBtn.backgroundColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
        femaleBtn.tintColor = UIColor.white
        maleBtn.backgroundColor = UIColor.white
        maleBtn.tintColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
        self.gender = "WOMAN"
    }
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"){
            APIService.shared.getMyAccount(accessToken: accessToken, completion: { accountId in
                UserDefaults.standard.setValue(accountId, forKey: "accountId")
                // FCM 토큰 저장
                if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                    APIService.shared.putFCMToken(fcmToken: fcmToken, accessToken: accessToken, accountId: accountId)
                    print("accountId = \(accountId)")
                }
            })
        }
    }
    
    // 회원 탈퇴 버튼
    @IBAction func deleteUserBtnAction(_ sender: Any) {
        let alert = UIAlertController(title:"회원 탈퇴 하시겠습니까?",
                                      message: " ",
                                      preferredStyle: UIAlertController.Style.alert)
        //2. 확인 버튼 만들기
        let okLabel = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            // 회원 탈퇴 API 수행
            if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                APIService.shared.deleteUser(accessToken: accessToken,
                                             accountId: UserDefaults.standard.integer(forKey: "accountId"), completion: { res in
                    if res {
                        // 밑에 두개 언제?
                        let alert = UIAlertController(title:"👿회원 탈퇴 완료👿",
                                                      message: "",
                                                      preferredStyle: UIAlertController.Style.alert)
                        
                        let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(buttonLabel)
                        //            present(alert,animated: true,completion: nil)
                        
                        //2. 로그인 화면(맨처음) 이동
                        UIViewController.changeRootViewControllerToLogin()
                    }else{
                        
                    }
                })
            }
            
            
        })
        let cancleLabel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okLabel)
        alert.addAction(cancleLabel)
        
        //4. 경고창 보이기
        present(alert,animated: true,completion: nil)
    }
    
    
    
    // MARK: - Button Action
    // 회원 정보 저장 버튼
    @IBAction func saveModifiedUserInfoBtnAction(_ sender: Any) {
        // 비밀번호 불일치하는 경우 - 재입력 요청
        
        
        if let accesstoken = UserDefaults.standard.string(forKey: "accessToken"){
//            if let profileImg = self.accountImg.image{
                APIService.shared.fileUpload(imageData: selectedImg,
                                             completion: { url in
                    UserDefaults.standard.setValue(url, forKey: "thumbnail")
                    //
                    let parameter: Parameters = [
                        "thumbnail" : url,
                        "email": self.emailTextField.text ?? "",
                        "name" : self.nameTextField.text ?? "",
                        "gender" : self.gender,
                    ]
                    // 서버 저장
                    APIService.shared.modifyMyAccount(accessToken: accesstoken,
                                                      accountId: UserDefaults.standard.integer(forKey: "accountId"),
                                                      param: parameter,
                                                      completion: { res in
                        //coredata 저장
                        CoreDataManager.shared.updateUserInfo(thumbnail: url, email: self.emailTextField.text!, name: self.nameTextField.text!, gender: self.gender, onSuccess: { res in
                            
                        })
                        //alert + 화면 내리기 + 메인으로
                        if res {
                            let alert = UIAlertController(title:"⭐️회원 정보 수정 성공⭐️",
                                                          message: "",
                                                          preferredStyle: UIAlertController.Style.alert)
                            let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: { _ in
                                UIViewController.changeRootViewControllerToHome()
                            })
                            alert.addAction(buttonLabel)
                            self.present(alert,animated: true,completion: nil)
                        }
                    })
                })
            }
//        }
    }
    
    func viewInit() {
        self.gender = self.userInfo[0].gender ?? ""
        var tmpImg = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), renderingMode: .alwaysOriginal)
        
        self.thumbnail = UserDefaults.standard.string(forKey: "thumbnail") ?? ""
        // 소셜 로그인 시 넘어온 정보
        self.myEmail = self.userInfo[0].email ?? ""
        self.myNickName = self.userInfo[0].name ?? ""
        
        if self.userInfo[0].gender?.lowercased() == "male"{
            maleBtn.backgroundColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
            maleBtn.tintColor = UIColor.white
            femaleBtn.backgroundColor = UIColor.white
        }else{
            maleBtn.backgroundColor = UIColor.white
            femaleBtn.backgroundColor = #colorLiteral(red: 0.4406229556, green: 0.350309521, blue: 0.9307079911, alpha: 1)
            femaleBtn.tintColor = UIColor.white
        }
        
        emailTextField.text = self.myEmail
        nameTextField.text = self.myNickName
        maleBtn.layer.borderWidth = 1
        maleBtn.layer.borderColor = Colors.mainPurple.color.cgColor
        maleBtn.layer.cornerRadius = 10
        femaleBtn.layer.borderWidth = 1
        femaleBtn.layer.borderColor = Colors.mainPurple.color.cgColor
        femaleBtn.layer.cornerRadius = 10
        
        if self.thumbnail == "" {
            accountImg.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }else{
            //url 처리
            let url = URL(string: self.thumbnail)!
            accountImg.loadwithURLSession(url: url)
        }
        
        accountImgModifyBtn.layer.cornerRadius = accountImgModifyBtn.frame.height/2
        accountImgModifyBtn.setTitle("", for: .normal)
    }
    
    /// 계정 정보 이미지 변경 버튼
    /// - Parameter sender: sender
    @IBAction func accountImgModifyAction(_ sender: Any) {
        showActionSheet()
    }
                                    

    /// 이미지 변경 버튼 클릭시 생성되는 action sheet
    func showActionSheet() {
        
        // 액션 시트 초기화
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction 설정
        // handler : 액션 발생시 호출
        let actionAlbum = UIAlertAction(title: "사진 등록하기", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openGallery()
        })
        let actionCamera = UIAlertAction(title: "사진 찍기", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openCamera()
        })
        let actionFile = UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            //기존 이미지로 변경
            self.accountImg.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), renderingMode: .alwaysOriginal)
        })
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionAlbum)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionFile)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
    
    /// actionsheet1. 카메라 촬영
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.Picker.sourceType = UIImagePickerController.SourceType.camera;
            self .present(self.Picker, animated: true, completion: nil)
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
        }
    }
    
    /// actionsheet2. 앨범에서 가져오기
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            self.Picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
            self.present(self.Picker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image Picker Delegate methods
//    사진 이미지 선택 취소 시 호출
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            self.dismiss(animated: true, completion: nil)
//        }
//

//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        if let selectedImg = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
//        {
//            self.accountImg.image = selectedImg
//            //local db 저장
//            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
//            let context = container.viewContext
//            let userEntity = UserEntity(context: context)
//            userEntity.thumbnail = selectedImg.toPngString()
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    // 갤러리 이미지 선택시 실행되는 메소드
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //선택한 이미지 처리
            //1. imageView로 보여주기
            
            let resizedImage = resizeImage(image: image, newWidth: 300)
            selectedImg = resizedImage
            
            DispatchQueue.main.async {
                self.accountImg.image = image
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
