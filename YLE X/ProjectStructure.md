//
//  ProjectStructure.md
//  YLE X
//
//  Cấu trúc thư mục theo chuẩn iOS
//

# YLE X - Project Structure

## 📁 Cấu trúc thư mục được đề xuất:

```
YLE X/
├── 📁 App/
│   ├── App.swift
│   ├── Info.plist
│   └── Assets/
│
├── 📁 Core/
│   ├── 📁 Models/
│   │   ├── Models.swift (✅ Đã có)
│   │   ├── UserProgress.swift
│   │   └── LearningSession.swift
│   │
│   ├── 📁 Services/
│   │   ├── AuthService.swift (✅ Đã có)
│   │   ├── FirestoreService.swift
│   │   ├── AudioService.swift
│   │   └── NetworkService.swift
│   │
│   └── 📁 Utils/
│       ├── Extensions/
│       ├── Constants/
│       └── Helpers/
│
├── 📁 Features/
│   ├── 📁 Authentication/
│   │   ├── Views/
│   │   │   ├── AuthFlowView.swift (✅ Đã có)
│   │   │   ├── SignInView.swift (✅ Đã có)
│   │   │   └── SignUpView.swift (✅ Đã có)
│   │   └── ViewModels/
│   │       └── SignInViewModel.swift (✅ Đã có)
│   │
│   ├── 📁 Home/
│   │   ├── Views/
│   │   │   └── HomeView.swift (✅ Đã có)
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift
│   │
│   ├── 📁 Learning/
│   │   ├── Views/
│   │   │   ├── ExerciseView.swift (✅ Đã có)
│   │   │   ├── LevelSelectionView.swift
│   │   │   └── SkillPracticeView.swift
│   │   └── ViewModels/
│   │       ├── LearningViewModel.swift (✅ Đã có)
│   │       └── ExerciseViewModel.swift
│   │
│   └── 📁 Profile/
│       ├── Views/
│       │   ├── ProfileView.swift
│       │   └── ProgressView.swift
│       └── ViewModels/
│           └── ProfileViewModel.swift
│
└── 📁 Shared/
    ├── 📁 UI/
    │   ├── DesignSystem.swift (✅ Đã có)
    │   ├── KidsUIComponents.swift (✅ Đã có)
    │   └── Styles/
    │
    └── 📁 Resources/
        ├── Sounds/
        ├── Images/
        └── Localizations/
```

## 🎯 Những file cần được di chuyển:

1. **Models.swift** → Core/Models/
2. **DesignSystem.swift** → Shared/UI/
3. **KidsUIComponents.swift** → Shared/UI/
4. **AuthFlowView.swift** → Features/Authentication/Views/
5. **SignInView.swift** → Features/Authentication/Views/
6. **SignUpView.swift** → Features/Authentication/Views/
7. **SignInViewModel.swift** → Features/Authentication/ViewModels/
8. **HomeView.swift** → Features/Home/Views/
9. **ExerciseView.swift** → Features/Learning/Views/
10. **LearningViewModel.swift** → Features/Learning/ViewModels/
11. **AuthService.swift** → Core/Services/

## ✅ Các bước tiếp theo:
1. Tổ chức lại cấu trúc thư mục
2. Tạo Firebase configuration
3. Implement audio service
4. Tạo onboarding flow
5. Tạo parent dashboard
6. Add push notifications
7. Implement offline mode