# YLE X - Product Documentation

## Product Vision
YLE X is a cutting-edge media platform designed to deliver personalized, high-quality content to users across Finland and beyond. Our goal is to create an engaging, intuitive, and inclusive user experience that celebrates diversity, promotes Finnish culture, and embraces innovative technologies to keep users connected with the world.

## Audience
- Finnish-speaking users interested in news, culture, entertainment, and educational content.
- Users across all age groups, with specific focus on young adults and families.
- Users seeking a seamless multi-device experience (mobile, tablet, web).
- Accessibility-conscious users requiring inclusive design.

## UX Principles
- **Simplicity:** Clear, minimalistic interfaces with easy navigation.
- **Accessibility:** Compliance with WCAG standards to support all users.
- **Personalization:** Tailored content recommendations based on user preferences.
- **Performance:** Fast load times and smooth interactions.
- **Consistency:** Uniform experience across platforms and devices.

## Architecture

### Clean Architecture
- Separation of concerns into layers: Presentation, Domain, Data.
- Use cases implement business logic in the domain layer.
- Data layer handles API, database, and external services.
- Dependency inversion to ensure testability and maintainability.

### MVVM (Model-View-ViewModel)
- **Model:** Represents the data structures and business models.
- **View:** UI components observing the ViewModel.
- **ViewModel:** Handles presentation logic, state management, and data binding.

## Folder Structure
