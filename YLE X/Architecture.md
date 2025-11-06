# YLE X - Proper iOS Architecture Structure

## 📁 Current File Organization Plan:

```
YLE X/
├── 📁 Core/
│   ├── 📁 Models/
│   │   └── Models.swift ✅
│   │
│   ├── 📁 Services/
│   │   ├── AuthService.swift ✅
│   │   ├── AudioService.swift (to be created)
│   │   ├── FirebaseManager.swift (to be created)
│   │   └── NotificationService.swift (to be created)
│   │
│   └── 📁 Utils/
│       ├── DesignSystem.swift ✅
│       └── KidsUIComponents.swift (to be created)
│
├── 📁 Features/
│   ├── 📁 Authentication/
│   │   ├── 📁 Views/
│   │   │   ├── AuthFlowView.swift ✅
│   │   │   ├── SignInView.swift ✅
│   │   │   └── SignUpView.swift ✅
│   │   └── 📁 ViewModels/
│   │       └── SignInViewModel.swift ✅
│   │
│   ├── 📁 Learning/
│   │   ├── 📁 Views/
│   │   │   ├── ExerciseView.swift ✅
│   │   │   ├── VocabularyView.swift ✅
│   │   │   └── HomeView.swift (to be created)
│   │   └── 📁 ViewModels/
│   │       ├── LearningViewModel.swift ✅
│   │       └── SessionViewModel.swift ✅
│   │
│   ├── 📁 Onboarding/
│   │   ├── 📁 Views/
│   │   │   └── OnboardingView.swift (to be created)
│   │   └── 📁 ViewModels/
│   │       └── OnboardingViewModel.swift (to be created)
│   │
│   └── 📁 Dashboard/
│       ├── 📁 Views/
│       │   └── ParentDashboardView.swift (to be created)
│       └── 📁 ViewModels/
│           └── DashboardViewModel.swift (to be created)
│
└── 📁 App/
    ├── MainAppFlowLegacy.swift ✅
    └── App.swift (main app entry point)
```

## ✅ Action Plan:

1. Keep files in root for now (as per Xcode simulator limitations)
2. Add proper comments indicating intended folder structure
3. Fix import issues in all files
4. Ensure proper separation of concerns
5. Make sure ViewModels are ObservableObject compliant

## 🔧 Files needing fixes:
- Add Combine import to ViewModels
- Fix ObservableObject conformance
- Organize imports properly
- Add proper file headers with intended paths