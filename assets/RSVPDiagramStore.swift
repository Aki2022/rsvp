import Darwin
import Foundation

enum RSVPDiagramStoreError: Error {
    case unavailable
    case writeFailed
    case closed
}

final class RSVPDiagramStore {
    static let rootDirectoryName = "rsvp-html-sessions"

    private let temporaryDirectory: URL
    let rootURL: URL
    let sessionURL: URL
    let htmlURL: URL

    private let fileManager: FileManager
    private let lock = NSLock()
    private var sessionLockDescriptor: Int32

    init(temporaryDirectory: URL = FileManager.default.temporaryDirectory, fileManager: FileManager = .default) throws {
        self.temporaryDirectory = temporaryDirectory
        self.fileManager = fileManager
        rootURL = temporaryDirectory.appendingPathComponent(Self.rootDirectoryName, isDirectory: true)

        let coordinationDescriptor = Self.lockDirectory(temporaryDirectory)
        guard coordinationDescriptor >= 0 else { throw RSVPDiagramStoreError.unavailable }
        defer {
            flock(coordinationDescriptor, LOCK_UN)
            close(coordinationDescriptor)
        }

        try Self.ensurePrivateDirectory(rootURL)
        Self.removeStaleSessions(in: rootURL, fileManager: fileManager)

        let newSessionURL = rootURL.appendingPathComponent("session-\(UUID().uuidString)", isDirectory: true)
        try Self.ensurePrivateDirectory(newSessionURL)
        let newLockDescriptor = Self.openLockFile(at: newSessionURL.appendingPathComponent(".session.lock"))
        guard newLockDescriptor >= 0, flock(newLockDescriptor, LOCK_EX | LOCK_NB) == 0 else {
            if newLockDescriptor >= 0 { close(newLockDescriptor) }
            try? fileManager.removeItem(at: newSessionURL)
            throw RSVPDiagramStoreError.unavailable
        }

        sessionURL = newSessionURL
        htmlURL = newSessionURL.appendingPathComponent("diagram.html", isDirectory: false)
        sessionLockDescriptor = newLockDescriptor
    }

    deinit {
        cleanup()
    }

    func save(_ html: String) throws -> URL {
        let data = Data(html.utf8)
        guard data.count <= RSVPDiagramHTML.maximumByteCount else { throw RSVPDiagramStoreError.writeFailed }

        lock.lock()
        defer { lock.unlock() }
        guard sessionLockDescriptor >= 0 else { throw RSVPDiagramStoreError.closed }

        let temporaryURL = sessionURL.appendingPathComponent(".diagram-\(UUID().uuidString).tmp")
        let descriptor = Self.openPrivateFile(at: temporaryURL, flags: O_WRONLY | O_CREAT | O_EXCL)
        guard descriptor >= 0 else { throw RSVPDiagramStoreError.writeFailed }
        defer {
            close(descriptor)
            unlink(temporaryURL.path)
        }

        var offset = 0
        let didWrite = data.withUnsafeBytes { buffer -> Bool in
            guard let baseAddress = buffer.baseAddress else { return false }
            while offset < buffer.count {
                let count = Darwin.write(descriptor, baseAddress.advanced(by: offset), buffer.count - offset)
                if count < 0 {
                    if errno == EINTR { continue }
                    return false
                }
                offset += count
            }
            return true
        }
        guard didWrite, fsync(descriptor) == 0 else { throw RSVPDiagramStoreError.writeFailed }

        let renameStatus = temporaryURL.path.withCString { temporaryPath in
            htmlURL.path.withCString { destinationPath in
                Darwin.rename(temporaryPath, destinationPath)
            }
        }
        guard renameStatus == 0 else { throw RSVPDiagramStoreError.writeFailed }
        return htmlURL
    }

    func removeHTML() {
        lock.lock()
        defer { lock.unlock() }
        guard sessionLockDescriptor >= 0 else { return }
        unlink(htmlURL.path)
    }

    func cleanup() {
        lock.lock()
        defer { lock.unlock() }
        guard sessionLockDescriptor >= 0 else { return }

        let coordinationDescriptor = Self.lockDirectory(temporaryDirectory)
        try? fileManager.removeItem(at: sessionURL)
        flock(sessionLockDescriptor, LOCK_UN)
        close(sessionLockDescriptor)
        sessionLockDescriptor = -1

        if coordinationDescriptor >= 0 {
            if let entries = try? fileManager.contentsOfDirectory(atPath: rootURL.path), entries.isEmpty {
                _ = rmdir(rootURL.path)
            }
            flock(coordinationDescriptor, LOCK_UN)
            close(coordinationDescriptor)
        }
    }

    private static func ensurePrivateDirectory(_ url: URL) throws {
        let path = url.path
        if mkdir(path, mode_t(S_IRWXU)) != 0, errno != EEXIST {
            throw RSVPDiagramStoreError.unavailable
        }

        var metadata = stat()
        guard lstat(path, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFDIR,
              metadata.st_uid == getuid(),
              chmod(path, mode_t(S_IRWXU)) == 0
        else {
            throw RSVPDiagramStoreError.unavailable
        }
    }

    private static func lockDirectory(_ url: URL) -> Int32 {
        return url.path.withCString { path in
            let descriptor = Darwin.open(path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
            guard descriptor >= 0 else { return -1 }
            guard flock(descriptor, LOCK_EX) == 0 else {
                close(descriptor)
                return -1
            }
            return descriptor
        }
    }

    private static func openLockFile(at url: URL) -> Int32 {
        return url.path.withCString { path in
            Darwin.open(path, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW, mode_t(S_IRUSR | S_IWUSR))
        }
    }

    private static func openPrivateFile(at url: URL, flags: Int32) -> Int32 {
        url.path.withCString { path in
            Darwin.open(path, flags | O_NOFOLLOW, mode_t(S_IRUSR | S_IWUSR))
        }
    }

    private static func removeStaleSessions(in rootURL: URL, fileManager: FileManager) {
        guard let entries = try? fileManager.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else { return }
        for entry in entries where entry.lastPathComponent.hasPrefix("session-") {
            let lockURL = entry.appendingPathComponent(".session.lock")
            let descriptor = lockURL.path.withCString { path in
                Darwin.open(path, O_RDWR | O_NOFOLLOW)
            }
            if descriptor < 0 {
                if errno == ENOENT { try? fileManager.removeItem(at: entry) }
                continue
            }

            if flock(descriptor, LOCK_EX | LOCK_NB) == 0 {
                try? fileManager.removeItem(at: entry)
                flock(descriptor, LOCK_UN)
            }
            close(descriptor)
        }
    }
}
