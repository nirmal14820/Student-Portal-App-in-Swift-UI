import SwiftUI

// MARK: - Data Models (unchanged)
enum UserRole: String, Codable {
    case student
    case admin
}

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var password: String
    var role: UserRole
    var name: String
    var email: String
    var profileImage: String?
}

struct ClassSchedule: Identifiable, Codable {
    let id: UUID
    var className: String
    var instructor: String
    var room: String
    var day: String
    var startTime: String
    var endTime: String
}

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var isPinned: Bool
}

struct BusLocation: Identifiable, Codable {
    let id: UUID
    var busNumber: String
    var currentLocation: String
    var lastUpdated: Date
    var eta: String
}

struct AttendanceRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var status: AttendanceStatus
    var classId: UUID
}

enum AttendanceStatus: String, Codable {
    case present
    case absent
    case late
}

struct Notice: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var isEvent: Bool
    var eventDate: Date?
}

// MARK: - Data Manager (updated with note management)
class DataManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var classSchedules: [ClassSchedule] = []
    @Published var notes: [Note] = []
    @Published var busLocations: [BusLocation] = []
    @Published var attendanceRecords: [AttendanceRecord] = []
    @Published var notices: [Notice] = []
    
    init() {
        loadSampleData()
    }
    
    func login(username: String, password: String) -> Bool {
        let sampleUsers = createSampleUsers()
        if let user = sampleUsers.first(where: { $0.username == username && $0.password == password }) {
            currentUser = user
            isLoggedIn = true
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
    }
    
    // Note management functions
    func addNote(title: String, content: String, isPinned: Bool = false) {
        let newNote = Note(
            id: UUID(),
            title: title,
            content: content,
            date: Date(),
            isPinned: isPinned
        )
        notes.insert(newNote, at: 0)
    }
    
    func updateNote(id: UUID, title: String, content: String, isPinned: Bool) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].isPinned = isPinned
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
    
    func togglePin(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isPinned.toggle()
            // Move pinned notes to top
            notes.sort { $0.isPinned && !$1.isPinned }
        }
    }
    
    private func loadSampleData() {
        classSchedules = createSampleClassSchedules()
        notes = createSampleNotes()
        busLocations = createSampleBusLocations()
        attendanceRecords = createSampleAttendanceRecords()
        notices = createSampleNotices()
    }
    
    private func createSampleUsers() -> [User] {
        return [
            User(id: UUID(), username: "nirmal", password: "password", role: .student, name: "Nirmal Rohit", email: "23amtics227@gmail.com"),
            User(id: UUID(), username: "admin1", password: "admin123", role: .admin, name: "Admin User", email: "admin@school.edu")
        ]
    }
    
    private func createSampleClassSchedules() -> [ClassSchedule] {
        return [
            ClassSchedule(id: UUID(), className: "Mobile App Development with IOS", instructor: "Prof. Twinkle", room: "Room 101", day: "Monday", startTime: "09:00", endTime: "10:30"),
            ClassSchedule(id: UUID(), className: "Web Development", instructor: "Prof. Halak", room: "Room 205", day: "Tuesday", startTime: "11:00", endTime: "12:30"),
            ClassSchedule(id: UUID(), className: "Python", instructor: "Prof. Vidhi", room: "Room 302", day: "Wednesday", startTime: "14:00", endTime: "15:30")
        ]
    }
    
    private func createSampleNotes() -> [Note] {
        return [
            Note(id: UUID(), title: "Mobile App Development with IOS", content: "Mobile Application Development (MAD) with iOS involves creating apps specifically for Apple devices like iPhones, iPads, and iPods. These applications are primarily developed using programming languages such as Swift and Objective-C, with Swift being the preferred modern, safe, and fast language introduced by Apple. Developers use Xcode, the official integrated development environment (IDE) for iOS, which provides tools like a code editor, a visual UI designer called Interface Builder, and simulators for testing. iOS apps commonly follow the MVC (Model-View-Controller) architecture pattern, where the Model handles data, the View displays the interface, and the Controller manages logic and interaction. The main components of an iOS app include Swift files for logic, Storyboards or XIB files for layout, and plist files for configurations.", date: Date(), isPinned: true),
            Note(id: UUID(), title: "Physics Formulas", content: "Important physics formulas:\n\n1. Newton's Second Law: F = ma\n2. Kinetic Energy: KE = ½mv²\n3. Work-Energy Theorem: W = ΔKE\n4. Gravitational Force: F = G(m₁m₂)/r²\n5. Einstein's Mass-Energy Equivalence: E = mc²", date: Date().addingTimeInterval(-86400), isPinned: false)
        ]
    }
    
    private func createSampleBusLocations() -> [BusLocation] {
        return [
            BusLocation(id: UUID(), busNumber: "Bus 101", currentLocation: "Main Street", lastUpdated: Date(), eta: "10 min"),
            BusLocation(id: UUID(), busNumber: "Bus 202", currentLocation: "Central Station", lastUpdated: Date().addingTimeInterval(-300), eta: "15 min")
        ]
    }
    
    private func createSampleAttendanceRecords() -> [AttendanceRecord] {
        let classIds = classSchedules.map { $0.id }
        return [
            AttendanceRecord(id: UUID(), date: Date().addingTimeInterval(-86400), status: .present, classId: classIds[0]),
            AttendanceRecord(id: UUID(), date: Date().addingTimeInterval(-2*86400), status: .late, classId: classIds[1]),
            AttendanceRecord(id: UUID(), date: Date().addingTimeInterval(-3*86400), status: .absent, classId: classIds[2])
        ]
    }
    
    private func createSampleNotices() -> [Notice] {
        return [
            Notice(id: UUID(), title: "School Holiday", content: "School will be closed on Friday for a public holiday.", date: Date(), isEvent: false, eventDate: nil),
            Notice(id: UUID(), title: "Sports Day", content: "Annual sports day on next Saturday. All students must participate.", date: Date(), isEvent: true, eventDate: Date().addingTimeInterval(7*86400))
        ]
    }
}

// MARK: - Note Detail View
struct NoteDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    var note: Note
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedIsPinned: Bool
    
    init(note: Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedIsPinned = State(initialValue: note.isPinned)
    }
    
    var body: some View {
        Group {
            if isEditing {
                Form {
                    Section(header: Text("Note Title")) {
                        TextField("Title", text: $editedTitle)
                    }
                    
                    Section(header: Text("Content")) {
                        TextEditor(text: $editedContent)
                            .frame(minHeight: 200)
                    }
                    
                    Toggle("Pin Note", isOn: $editedIsPinned)
                }
                .navigationTitle("Edit Note")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            dataManager.updateNote(
                                id: note.id,
                                title: editedTitle,
                                content: editedContent,
                                isPinned: editedIsPinned
                            )
                            isEditing = false
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(note.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if note.isPinned {
                                Image(systemName: "pin.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Text(note.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Text("Created: \(note.date.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle(note.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Add Note View
struct AddNoteView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var content = ""
    @State private var isPinned = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Toggle("Pin Note", isOn: $isPinned)
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dataManager.addNote(title: title, content: content, isPinned: isPinned)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Notes View (updated)
struct NotesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(note.title)
                                    .font(.headline)
                                if note.isPinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            Text(note.content)
                                .font(.body)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                            Text(note.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .contextMenu {
                            Button {
                                dataManager.togglePin(note: note)
                            } label: {
                                Label(
                                    note.isPinned ? "Unpin" : "Pin",
                                    systemImage: note.isPinned ? "pin.slash" : "pin"
                                )
                            }
                        }
                    }
                }
                .onDelete(perform: dataManager.deleteNote)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
        }
    }
}

// MARK: - Other Views (unchanged from previous implementation)
struct LoginView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Amtics Student Portal")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                if dataManager.login(username: username, password: password) {
                    // Login successful
                } else {
                    alertMessage = "Invalid username or password"
                    showingAlert = true
                }
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ScheduleView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List(dataManager.classSchedules) { schedule in
            VStack(alignment: .leading) {
                Text(schedule.className)
                    .font(.headline)
                Text("\(schedule.day) \(schedule.startTime)-\(schedule.endTime)")
                    .font(.subheadline)
                Text("Room: \(schedule.room) with \(schedule.instructor)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Class Schedule")
    }
}

struct BusTrackingView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List(dataManager.busLocations) { bus in
            VStack(alignment: .leading) {
                Text(bus.busNumber)
                    .font(.headline)
                Text("Current location: \(bus.currentLocation)")
                Text("ETA: \(bus.eta)")
                    .foregroundColor(.blue)
                Text("Last updated: \(bus.lastUpdated, style: .time)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Bus Tracking")
    }
}

struct AttendanceView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack {
            // Attendance summary
            HStack {
                VStack {
                    Text("\(attendanceCount(for: .present))")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("Present")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(attendanceCount(for: .absent))")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Absent")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(attendanceCount(for: .late))")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("Late")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // Attendance list
            List(dataManager.attendanceRecords) { record in
                HStack {
                    VStack(alignment: .leading) {
                        Text(record.date, style: .date)
                        if let className = className(for: record.classId) {
                            Text(className)
                                .font(.caption)
                        }
                    }
                    Spacer()
                    statusIndicator(for: record.status)
                }
            }
        }
        .navigationTitle("Attendance")
    }
    
    private func attendanceCount(for status: AttendanceStatus) -> Int {
        dataManager.attendanceRecords.filter { $0.status == status }.count
    }
    
    private func className(for id: UUID) -> String? {
        dataManager.classSchedules.first { $0.id == id }?.className
    }
    
    private func statusIndicator(for status: AttendanceStatus) -> some View {
        let (text, color) = {
            switch status {
            case .present: return ("P", Color.green)
            case .absent: return ("A", Color.red)
            case .late: return ("L", Color.orange)
            }
        }()
        
        return Text(text)
            .foregroundColor(.white)
            .padding(8)
            .background(Circle().fill(color))
    }
}

struct NoticeBoardView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List(dataManager.notices) { notice in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(notice.title)
                        .font(.headline)
                    if notice.isEvent {
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(notice.content)
                    .font(.body)
                
                if notice.isEvent, let eventDate = notice.eventDate {
                    Text("Event date: \(eventDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("Posted: \(notice.date, style: .date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Notice Board")
    }
}

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    Image("nnr") // Replace with your actual image file name (without extension)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle()) // Optional: makes the image circular
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    Spacer()
                }
                .padding()
            }
            
            Section(header: Text("User Information")) {
                Text("Name: \(dataManager.currentUser?.name ?? "")")
                Text("Email: \(dataManager.currentUser?.email ?? "")")
                Text("Role: \(dataManager.currentUser?.role.rawValue.capitalized ?? "")")
            }
            
            Section {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .destructive(Text("Logout")) {
                            dataManager.logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Profile")
    }
}

// MARK: - Main Dashboard
struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TabView {
            NavigationView {
                ScheduleView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Schedule")
            }
            
            NavigationView {
                NotesView()
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
            
            NavigationView {
                BusTrackingView()
            }
            .tabItem {
                Image(systemName: "bus")
                Text("Bus")
            }
            
            NavigationView {
                AttendanceView()
            }
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("Attendance")
            }
            
            NavigationView {
                NoticeBoardView()
            }
            .tabItem {
                Image(systemName: "megaphone")
                Text("Notices")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject var dataManager = DataManager()
    
    var body: some View {
        Group {
            if dataManager.isLoggedIn {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .environmentObject(dataManager)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

