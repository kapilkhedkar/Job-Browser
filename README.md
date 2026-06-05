# 📂 Job Browser iOS Application

A modular, production-ready SwiftUI application built to browse, search, and view corporate job openings. This codebase demonstrates a clean separation of concerns using the **MVVM** pattern, decoupled data ingestion protocols, native async/await concurrency primitives, and comprehensive unit test safety.

---

## 🏛️ Architecture Explanation
The codebase enforces a highly scalable Model-View-ViewModel (MVVM) topology coupled with clean Dependency Injection (DI) principles to keep layers decoupled and highly testable.

### Core Architecture Components
- The Model (Job.swift): A pure, immutable domain representation that implements Codable and Equatable. It isolates API networking key constraints (such as snake_case JSON fields) cleanly away from internal CamelCase properties via structural CodingKeys.
- The View Layer (SwiftUI + Custom Cards): Completely declarative interface layers that monitor state mutations. Instead of traditional lists with rigid layouts, the view harnesses a ScrollView and LazyVStack structure rendering bespoke high-fidelity Job Cards, giving the UI a premium look and feel.
- The ViewModel Layer (JobListViewModel.swift): Bound firmly to the @MainActor to guarantee UI updates occur safely on the main thread. It acts as a finite state machine managing a predictable ViewState enum (.idle, .loading, .empty, .success(T), .error(String)).
- Modern Thread-Safe Debouncing: Rather than relying on traditional Combine timers tied to RunLoop.main (which frequently freeze or lock up during unit testing execution streams), searching leverages Native Swift Concurrency. Typing actions cancel previous Task instances and use Task.sleep(nanoseconds:) for cooperative, non-blocking cancellations.
- The Service Layer (JobService.swift): Abstracted fully behind the JobServiceProtocol. By injecting this interface protocol into the ViewModel's initializer rather than hardcoding concrete instances, we can instantly mock network behaviors in unit tests without changing UI structures.

## 💡 Assumptions Made
- Local Bundled Storage over Live API: To ensure the app compiles and runs instantly out of the box without requiring fragile external keys, a static file named mock_jobs.json acts as our persistent backend database.
- Artificial Network Latency: Real-world networks don't return data instantaneously. To properly test UI loading indicators and thread performance, a deliberate 1-second non-blocking sleep delay (Task.sleep) was added directly to the service layer.
- Search Scope Parameters: Case-insensitive search evaluation covers both the title and companyName text boundaries simultaneously to prioritize candidate browsing speed.
