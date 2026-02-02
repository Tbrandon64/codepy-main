# MathBlat Multiplayer Testing Guide

Complete guide for testing multiplayer functionality across different network scenarios.

## Test Environments

### 1. Local Testing (Single Machine)

**Objective**: Verify ENet communication between two game instances

**Setup**:
```bash
# Terminal 1 - Instance A (Host)
cd /home/Thomas/codepy
godot

# Terminal 2 - Instance B (Client)
cd /home/Thomas/codepy
godot
```

**Test Steps**:
1. **Instance A**: Main Menu → Host → Easy
   - Console output: "Server started on port 12345"
   - GameScene loads with blank problem waiting

2. **Instance B**: Main Menu → Join → "localhost" → Easy
   - Console output: "Connected to server"
   - GameScene loads
   - Both instances show same problem

3. **Verify Sync**:
   - [ ] Problem text identical on both screens
   - [ ] 4 answer options in same order
   - [ ] Countdown timer synced (within 1 second)
   - [ ] Answer from B updates score on both screens

4. **Verify Gameplay**:
   - [ ] A answers correctly: Both scores increase (+10 Easy)
   - [ ] B answers wrong: No score change
   - [ ] New problem auto-generates on next cycle
   - [ ] Victory at 100 points on both sides

**Expected Console Output**:
```
[GameManager] Generate problem: num1=5, operation=+, num2=3
[main_menu] Starting ENet server on port 12345
[ENetMultiplayerPeer] peer_connected signal emitted
[game_scene] _on_peer_connected: peer_id = 2
[game_scene] RPC sync_problem to peer 2
[client] Received problem via RPC: "8"
```

---

### 2. LAN Testing (Two Machines on Same Network)

**Network Topology**:
```
Router (192.168.1.1)
├── Machine A (192.168.1.100) - Host
└── Machine B (192.168.1.101) - Client
```

**Prerequisites**:
- Both machines on same WiFi/Ethernet
- Firewall allows port 12345 (TCP/UDP)
- Ping test successful: `ping 192.168.1.100`

**Finding IP Address**:

Linux/macOS:
```bash
ifconfig | grep "inet "
# Output: inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
```

Windows:
```cmd
ipconfig | findstr "IPv4 Address"
# Output: IPv4 Address. . . . . . . . . : 192.168.1.100
```

**Firewall Configuration**:

Linux (UFW):
```bash
sudo ufw allow 12345/tcp
sudo ufw allow 12345/udp
sudo ufw reload
```

Windows (Defender):
1. Open Windows Defender Firewall
2. Advanced Settings → Inbound Rules
3. New Rule → Port 12345 → Allow TCP/UDP

macOS:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which godot)
```

**Setup**:
1. Launch Godot on Machine A: `godot --path /home/Thomas/codepy`
2. Launch Godot on Machine B: `godot --path /home/Thomas/codepy`

**Test Steps**:

**Host Setup (Machine A - 192.168.1.100)**:
1. Main Menu → Host
2. Difficulty: Medium
3. Wait for "Server started" message
4. Note port (should be 12345)

**Client Setup (Machine B - 192.168.1.101)**:
1. Main Menu → Join
2. IP Address: 192.168.1.100
3. Port: 12345
4. Difficulty: Medium
5. Wait for "Connected to server" message

**Verification Checklist**:
- [ ] Connection established (no timeout error)
- [ ] Same problem displays on both screens
- [ ] Answer from B syncs to A with <100ms latency
- [ ] Scores update simultaneously
- [ ] Pause menu on A pauses timer on B
- [ ] Victory screen appears on both at 100 points

**Stress Test** (5+ minutes):
- [ ] No disconnects during extended play
- [ ] Scores remain consistent
- [ ] No animation stuttering
- [ ] Pause/resume cycles work repeatedly

---

### 3. Internet Testing (Port Forwarding)

**Network Setup**:
```
Internet (Public IP: 203.0.113.45)
		 ↓
	Router (192.168.1.1)
	├── Machine A (192.168.1.100) - Host
	└── Machine B (External network) - Client
```

**Prerequisites**:
1. Router with port forwarding support
2. Determine Public IP

**Find Public IP**:
```bash
curl ifconfig.me
# Output: 203.0.113.45
```

**Configure Port Forwarding on Router**:

Typical steps (varies by router):
1. Log into router admin: `http://192.168.1.1`
2. Find "Port Forwarding" section
3. Add rule:
   - External Port: 12345
   - Internal Port: 12345
   - Internal IP: 192.168.1.100
   - Protocol: TCP + UDP
4. Save and restart router

**Test**:

Host (Machine A - 192.168.1.100):
```
Main Menu → Host → Medium → Wait for "Server started"
```

Client (Remote network):
```
Main Menu → Join → IP: 203.0.113.45 → Port: 12345 → Medium
```

**Verification**:
- [ ] Connection established from external network
- [ ] Problem syncs to remote client
- [ ] Answer from remote updates host score
- [ ] No timeout errors
- [ ] Victory works from both sides

**Troubleshooting**:
- **Connection refused**: Check port forwarding rule
- **Timeout**: Check public IP is correct (verify with `curl ifconfig.me`)
- **NAT issues**: Router might not support port forwarding; try relay service

---

### 4. Mobile Testing (Android)

**Prerequisites**:
- Android phone on same WiFi as host
- MathBlat APK installed on phone
- Phone has phone's IP address

**Find Phone IP**:
```bash
# On Android via adb:
adb shell ip addr show wlan0 | grep "inet "
# Output: inet 192.168.1.105/24 scope global wlan0
```

**Host Setup (Desktop/Laptop - 192.168.1.100)**:
1. Launch Godot version
2. Main Menu → Host → Easy
3. Wait for "Server started"

**Client Setup (Android Phone - 192.168.1.105)**:
1. Launch MathBlat app
2. Main Menu → Join
3. Enter host IP: 192.168.1.100
4. Port: 12345
5. Difficulty: Easy

**Verification Checklist**:
- [ ] Touch buttons respond to tap
- [ ] Problem displays in correct layout
- [ ] Answer selection syncs to desktop host
- [ ] Scores update on both screens
- [ ] Screen orientation change doesn't break game
- [ ] High score saves to phone storage

**Performance Check**:
- [ ] Game runs at 30+ FPS on phone
- [ ] No lag when answering questions
- [ ] Battery drain minimal (<5%/hour)

---

### 5. Cross-Platform Testing

**Scenarios to Test**:

| Host | Client | Notes |
|------|--------|-------|
| Linux | Linux | Same OS reference |
| Linux | Windows | Cross-OS validation |
| Windows | Mac | Desktop compatibility |
| Desktop | Android | Mobile compatibility |
| Desktop | iOS | iOS compatibility |
| Desktop | Web | Browser compatibility |

**Example: Linux Host + Windows Client**:
1. Linux machine: `godot` → Host → Medium
2. Windows machine: `godot` → Join → [Linux IP] → Medium
3. Verify all sync works as expected

---

## Network Debugging

### Check Port Binding

Linux/macOS:
```bash
netstat -an | grep 12345
# Output: tcp6       0      0 :::12345                :::*                    LISTEN
```

Windows (PowerShell):
```powershell
netstat -an | findstr "12345"
# Output: TCP    0.0.0.0:12345          0.0.0.0:0              LISTENING
```

### Check Connectivity

```bash
# Ping test (host must respond)
ping 192.168.1.100

# Port test (TCP)
nc -zv 192.168.1.100 12345
# Output: Connection to 192.168.1.100 12345 port [tcp/*] succeeded!

# Port test (UDP)
echo "" | nc -u -w1 192.168.1.100 12345
# (No error = port open)
```

### Monitor Network Traffic

```bash
# Linux/macOS (capture all traffic on port 12345)
sudo tcpdump -i any port 12345 -v

# Windows PowerShell (monitor port 12345)
netsh trace start capture=yes TracingForVeryverbose protocol=tcp,udp
# (Stop with: netsh trace stop)
```

---

## Common Issues & Solutions

### Issue: "Failed to connect to server"

**Causes**:
1. Host not running
2. Wrong IP address
3. Port blocked by firewall
4. Wrong port number

**Fixes**:
1. Verify host running: Check console for "Server started"
2. Verify IP: Run `ifconfig` / `ipconfig`
3. Check firewall: `netstat -an | grep 12345`
4. Verify port in main_menu.gd: Should be 12345

### Issue: "Timed out waiting for peer"

**Causes**:
1. Network latency >2000ms
2. Packet loss on connection
3. NAT/firewall blocking responses

**Fixes**:
1. Test ping: `ping -c 4 [host-ip]` (should be <100ms)
2. Try localhost first (rules out network)
3. Check firewall on both machines
4. Restart router/modem

### Issue: "Problem not syncing to client"

**Causes**:
1. RPC not connected in tscn
2. Host authority not set in decorator
3. Peer not recognized in signal

**Fixes**:
1. Verify game_scene.tscn has all signal connections
2. Check game_scene.gd: `@rpc("authority", "call_local", "reliable")`
3. Check console for "peer_connected" signal

### Issue: "Scores don't match between host and client"

**Causes**:
1. Answer validation logic differs
2. RPC sync failed silently
3. Timer sync issues

**Fixes**:
1. Both use same GameManager.check_answer() logic
2. Check console for RPC method calls
3. Ensure countdown synced: `time_remaining` synced via `_sync_answer()` RPC

### Issue: "Client disconnects randomly"

**Causes**:
1. Network instability
2. Timeout too aggressive (default 10s)
3. Godot peer timeout settings

**Fixes**:
1. Test network: `ping -c 100 [host]` (look for packet loss)
2. Increase timeout in main_menu.gd:
   ```gdscript
   enet_peer.connect_timeout = 20000  # 20 seconds
   ```
3. Check Godot project settings: Network → Limits

---

## Performance Monitoring

### FPS Counter

In game_scene.gd, add to `_process()`:
```gdscript
func _process(delta: float) -> void:
	if Engine.get_frames_drawn() % 60 == 0:
		var fps = 1.0 / delta
		print("FPS: %.1f" % fps)
```

### Network Latency

In game_scene.gd:
```gdscript
var rpc_send_time: float = 0.0

func _on_option_pressed(option_index: int) -> void:
	rpc_send_time = Time.get_ticks_msec()
	_sync_answer.rpc(option_index, player_score)

@rpc("any_peer", "call_remote_sync", "reliable")
func _sync_answer(option_index: int, score: int) -> void:
	var latency_ms = Time.get_ticks_msec() - rpc_send_time
	print("RPC Latency: %d ms" % latency_ms)
```

### Packet Loss Simulation

Linux (use `tc` to simulate 10% packet loss):
```bash
# Add 10% packet loss on wlan0
sudo tc qdisc add dev wlan0 root netem loss 10%

# Verify
sudo tc qdisc show dev wlan0

# Remove
sudo tc qdisc del dev wlan0 root
```

---

## Relay Service Setup (Advanced)

For internet play without port forwarding, use a relay server.

### Option 1: Self-Hosted Relay (Python)

Create `relay_server.py`:
```python
import socket
import threading

class Relay:
	def __init__(self, port=12345):
		self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.socket.bind(('0.0.0.0', port))
		self.peers = {}
	
	def run(self):
		while True:
			data, addr = self.socket.recvfrom(4096)
			if addr not in self.peers:
				self.peers[addr] = len(self.peers) + 1
				print(f"New peer: {addr} -> ID {self.peers[addr]}")
			
			# Relay to all other peers
			for peer_addr in self.peers:
				if peer_addr != addr:
					self.socket.sendto(data, peer_addr)

if __name__ == "__main__":
	relay = Relay(12345)
	print("Relay server running on port 12345...")
	relay.run()
```

Run:
```bash
python3 relay_server.py
```

Then modify MathBlat to connect through relay (requires code change).

### Option 2: Use Godot Relay Service

[Godot Relay](https://github.com/godotengine/godot/tree/master/modules/enet) provides relay service documentation.

---

## QA Sign-Off Checklist

Before release, verify all tests pass:

- [ ] Local (single machine) multiplayer: 10+ matches without disconnect
- [ ] LAN multiplayer: Desktop-to-desktop, desktop-to-mobile, mobile-to-mobile
- [ ] Port forwarding: 5+ minute session with internet player
- [ ] Mobile: Android and iOS both platforms tested
- [ ] Cross-platform: Windows-to-Mac, Linux-to-Windows verified
- [ ] Network stress: 100+ RPC calls without corruption
- [ ] Disconnection: Graceful handling when peer drops
- [ ] Score sync: Verified identical scores on both sides
- [ ] High scores: Save/load works after multiplayer session

---

## Performance Targets

| Metric | Desktop | Mobile | Web |
|--------|---------|--------|-----|
| FPS | 60 | 30 | 60 |
| RPC Latency | <50ms | <150ms | <200ms |
| Frame Jitter | <10ms | <50ms | <100ms |
| CPU Usage | <15% | <25% | <20% |
| Memory | <256MB | <128MB | <150MB |

---

**Last Updated**: 2024
**Tested On**: Godot 4.5, Linux, Windows, macOS, Android, iOS, Web browsers
