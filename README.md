# Real-Tutor <img src="https://github.com/lxxyeon/Real-Tutor/assets/57200871/dbadbc61-983b-49f5-bfb3-43d666473f8e" width = 105 align = left>
특정 분야의 전문가인 멘토와 그 분야에 전문가가 되고 싶은 멘티를 연결해주는 비대면 커넥션 서비스

## Contact
- iOS : lxxyeon@gmail.com

## Feature  
- 자체 회원가입, 로그인 및 소셜 로그인(카카오톡, 구글, 애플)
- 카테고리 및 과목별 멘토 리스트 제공
- 멘토 멘티 1:1 실시간 채팅
- 멘토 리뷰 작성 및 추천 멘토 리스트 제공
- 마이페이지 및 멘토 등록
  
## Library  
* Alamofire  
  + HTTP 통신 처리  
* SwiftyJSON
  + JSON 파싱
* Firebase, GoogleSignIn
  + 소셜로그인
* Kingfisher
  + 이미지 캐싱처리

## Structure
```
.
├─ Resource
|   ├── CategoryName.swift
|   ├── PostData.swift
|   |
├─ First (record tab)
|   ├── MainPage.storyboard
|   ├── MainpageViewController.swift
|   ├── DetailViewController.storyboard
|   ├── DetailViewController.swift
|   ├── InformHelper.swift
|   ├── PostHelper.swift
|   |
├─ Second (create tab)
|   ├── Record.storyboard
|   ├── RecordViewController.swift
|   ├── UserInformation.swift
|   |
├─ Third (calendar tab)
|   ├── Third.storyboard
|   ├── CalendarVC.swift
|   ├── CabinetCVC.xib
|   ├── CabinetCVC.swift
|   |
├─ Fourth (my page tab)
|   ├── MyPage.storyboard
|   ├── MyPageViewController.swift
|   ├── UserData.swift
|   ├── UserHelper.swift
|   └── CategoryHelper.swift


```

## Vesion
- 1.0 배포

## Privacy Policy of RealTutor
https://leeyeonlog.tistory.com/4
