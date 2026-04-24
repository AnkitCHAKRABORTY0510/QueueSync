# QueueSync 🚀

**QueueSync** is a high-performance, sequential file transfer utility designed to move massive amounts of data from macOS to a Linux environment with surgical precision. 

It combines a sleek, modern **SwiftUI macOS App** with a robust, automated **Linux Receiver environment**, ensuring your transfers are reliable, resumable, and easy to manage.

---

## 💡 The Idea

Moving files to a server often involves either clunky SFTP clients or messy manual `rsync` commands that fail halfway. QueueSync solves this by:
1. **Queuing**: Drop dozens of files/folders; they wait their turn instead of fighting for bandwidth.
2. **Persistence**: The queue is saved locally. If you restart the app, your pending items are still there.
3. **Resilience**: Integrated retry logic with exponential backoff handles network flickers automatically.
4. **Visibility**: Real-time progress bars and detailed transfer logs keep you in control.

---

## 🛠 Features

- **Modern macOS GUI**: A glassmorphic SwiftUI dashboard for effortless management.
- **Drag & Drop**: Simply drag files from Finder directly into the queue.
- **Robust Engine**: Powered by `rsync` over `SSH` for industry-standard speed and security.
- **Linux Receiver Script**: A dedicated engineer-grade setup script to prepare your destination server in seconds.
- **Zero Configuration (Almost)**: Automatically uses your existing SSH keys for passwordless transfers.
- **CLI Support**: A full-featured command-line interface for power users.

---

## 🚀 Getting Started

### 1. Setup the Linux Receiver
First, prepare your Linux (Ubuntu recommended) server to receive files.

```bash
# Copy the receiver script to your server and run:
sudo bash QueueSync-Recever-Setup.sh
```
*This creates a dedicated `queuesync` user, locks down permissions, and sets up `/home/queuesync/Incoming`.*

**Recommended**: Enable passwordless login from your Mac:
```bash
ssh-copy-id queuesync@your-server-ip
```

### 2. Install the macOS App
Clone this repository and build the installer:

```bash
./build_app.sh
```
This generates a `QueueSync_Installer.dmg` in the `Release/` folder. Open it and drag **QueueSync** to your Applications folder.

---

## 📖 Usage

1. **Configure**: Open Settings and enter your server IP, user (`queuesync`), and destination path (`/home/queuesync/Incoming`).
2. **Add Files**: Click the **+** button or drag and drop files/folders into the window.
3. **Sync**: Click **Start Sync**. QueueSync will process each item sequentially.
4. **Manage**: 
   - Use the **Trash** icon on a row to remove an individual item.
   - Use the **Clear** button to remove all completed or failed items.

---

## 💻 Contributing

We welcome contributions!
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

**Tech Stack**:
- **App**: Swift 5.7+, SwiftUI, macOS 11.0+.
- **Engine**: rsync, SSH.
- **Receiver**: POSIX Bash.

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Created with ❤️ for high-speed workflows.*
