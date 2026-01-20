# MathBlat Game - Complete Multiplayer Math Duel Game
# Compatible with Tkinter (Python 3.8+)
# Features: Single-player practice, Multiplayer LAN/Internet duels
# Run as: python mathblat.py
# For multiplayer: One player runs with --host, other with --connect IP:PORT

import tkinter as tk
from tkinter import messagebox, simpledialog
import threading
import socket
import json
import random
import time
from enum import Enum

class Difficulty(Enum):
    EASY = 1
    MEDIUM = 2
    HARD = 3

class GameMode(Enum):
    SINGLE = 1
    HOST = 2
    CLIENT = 3

class MathBlat:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("MathBlat - Math Duel Game")
        self.root.geometry("800x600")
        self.root.configure(bg='black')
        
        self.mode = None
        self.difficulty = Difficulty.EASY
        self.opponent_score = 0
        self.my_score = 0
        self.current_problem = None
        self.options = []
        self.correct_answer = 0
        self.timer = 0
        self.server_socket = None
        self.client_socket = None
        self.running = False
        
        self.setup_ui()
        self.show_menu()
    
    def setup_ui(self):
        # Title
        self.title_label = tk.Label(self.root, text="MATHBLAT", font=("Arial", 48, "bold"), fg='cyan', bg='black')
        self.title_label.pack(pady=20)
        
        # Menu frame
        self.menu_frame = tk.Frame(self.root, bg='black')
        
        # Scores frame
        self.score_frame = tk.Frame(self.root, bg='black')
        self.my_score_label = tk.Label(self.score_frame, text="Your Score: 0", font=("Arial", 24), fg='green', bg='black')
        self.opp_score_label = tk.Label(self.score_frame, text="Opponent: 0", font=("Arial", 24), fg='red', bg='black')
        
        # Problem frame
        self.problem_frame = tk.Frame(self.root, bg='black')
        self.problem_label = tk.Label(self.problem_frame, text="", font=("Arial", 36, "bold"), fg='white', bg='black')
        
        # Options frame
        self.options_frame = tk.Frame(self.root, bg='black')
        
        # Timer label
        self.timer_label = tk.Label(self.root, text="", font=("Arial", 28, "bold"), fg='yellow', bg='black')
        
        # Status label
        self.status_label = tk.Label(self.root, text="", font=("Arial", 20), fg='white', bg='black')
    
    def show_menu(self):
        self.clear_ui()
        self.title_label.pack(pady=20)
        
        single_btn = tk.Button(self.menu_frame, text="Single Player", font=("Arial", 20), bg='blue', fg='white', 
                               command=lambda: self.start_single())
        single_btn.pack(pady=10)
        
        host_btn = tk.Button(self.menu_frame, text="Host Multiplayer Game", font=("Arial", 20), bg='green', fg='white',
                             command=lambda: self.start_host())
        host_btn.pack(pady=10)
        
        client_btn = tk.Button(self.menu_frame, text="Join Multiplayer (Connect)", font=("Arial", 20), bg='orange', fg='white',
                               command=self.start_client)
        client_btn.pack(pady=10)
        
        quit_btn = tk.Button(self.menu_frame, text="Quit", font=("Arial", 20), bg='red', fg='white',
                             command=self.root.quit)
        quit_btn.pack(pady=10)
        
        self.menu_frame.pack(expand=True)
    
    def clear_ui(self):
        for widget in self.root.winfo_children():
            widget.pack_forget()
    
    def start_single(self):
        self.mode = GameMode.SINGLE
        self.show_difficulty_menu()
    
    def start_host(self):
        self.mode = GameMode.HOST
        port = simpledialog.askinteger("Host Game", "Enter port (default 12345):", parent=self.root, minvalue=1024, maxvalue=65535) or 12345
        self.host_server(port)
        self.show_difficulty_menu()
    
    def start_client(self):
        ip = simpledialog.askstring("Join Game", "Enter host IP:", parent=self.root)
        port = simpledialog.askinteger("Join Game", "Enter port (default 12345):", parent=self.root, minvalue=1024, maxvalue=65535) or 12345
        if ip:
            self.mode = GameMode.CLIENT
            self.connect_client(ip, port)
            self.show_difficulty_menu()
    
    def show_difficulty_menu(self):
        self.clear_ui()
        self.title_label.pack(pady=20)
        
        tk.Button(self.root, text="Easy", font=("Arial", 24), bg='green', fg='white',
                  command=lambda: self.start_game(Difficulty.EASY)).pack(pady=10, fill='x', padx=100)
        tk.Button(self.root, text="Medium", font=("Arial", 24), bg='yellow', fg='black',
                  command=lambda: self.start_game(Difficulty.MEDIUM)).pack(pady=10, fill='x', padx=100)
        tk.Button(self.root, text="Hard", font=("Arial", 24), bg='red', fg='white',
                  command=lambda: self.start_game(Difficulty.HARD)).pack(pady=10, fill='x', padx=100)
        
        tk.Button(self.root, text="Back", font=("Arial", 20), command=self.show_menu).pack(pady=20)
    
    def start_game(self, diff):
        self.difficulty = diff
        self.my_score = 0
        self.opponent_score = 0
        self.running = True
        self.update_scores()
        self.next_problem()
        threading.Thread(target=self.game_loop, daemon=True).start()
    
    def game_loop(self):
        while self.running:
            time.sleep(0.1)
            if self.mode != GameMode.SINGLE:
                self.check_network()
    
    def next_problem(self):
        if not self.running:
            return
        
        num1, num2 = self.generate_numbers()
        op = random.choice(['+', '-', '*', '/'])
        if op == '/':
            num1 = num2 * random.randint(2, 10)
            num2 = random.randint(2, 10)
        
        problem_str = f"{num1} {op} {num2} = ?"
        self.current_problem = problem_str
        
        if op == '+':
            self.correct_answer = num1 + num2
        elif op == '-':
            self.correct_answer = num1 - num2
        elif op == '*':
            self.correct_answer = num1 * num2
        elif op == '/':
            self.correct_answer = num1 // num2
        
        self.options = [self.correct_answer]
        wrong = []
        while len(wrong) < 3:
            wrong_opt = self.correct_answer + random.randint(-20, 20)
            if wrong_opt != self.correct_answer and wrong_opt > 0 and wrong_opt not in wrong:
                wrong.append(wrong_opt)
        
        self.options += wrong
        random.shuffle(self.options)
        
        self.timer = 15  # 15 seconds per problem
        self.update_ui()
        self.send_problem_to_opponent()
    
    def generate_numbers(self):
        d = self.difficulty.value
        if d == 1:  # Easy
            return random.randint(1, 10), random.randint(1, 10)
        elif d == 2:  # Medium
            return random.randint(1, 50), random.randint(1, 50)
        else:  # Hard
            return random.randint(1, 100), random.randint(1, 100)
    
    def update_ui(self):
        self.root.after(0, self._update_ui)
    
    def _update_ui(self):
        self.clear_ui_except_frames()
        
        self.title_label.pack(pady=20)
        self.score_frame.pack(pady=10)
        self.my_score_label.pack()
        self.opp_score_label.pack()
        
        self.problem_frame.pack(pady=20)
        self.problem_label.config(text=self.current_problem)
        self.problem_label.pack()
        
        self.timer_label.config(text=f"Time: {self.timer}s")
        self.timer_label.pack(pady=10)
        
        for opt in self.options:
            btn = tk.Button(self.options_frame, text=str(opt), font=("Arial", 24, "bold"), 
                            bg='purple', fg='white', width=8, height=2,
                            command=lambda o=opt: self.select_answer(o))
            btn.pack(pady=5)
        
        self.options_frame.pack(pady=20)
        self.status_label.pack()
    
    def clear_ui_except_frames(self):
        # Hide all but keep frames ready
        for child in self.root.winfo_children():
            child.pack_forget()
    
    def select_answer(self, selected):
        if not self.running:
            return
        
        if selected == self.correct_answer:
            self.my_score += 10 * self.difficulty.value
            self.status_label.config(text="Correct! +10 points", fg='green')
            self.send_answer(True)
        else:
            self.status_label.config(text="Wrong!", fg='red')
            self.send_answer(False)
        
        self.update_scores()
        self.root.after(1000, self.next_problem)
    
    def update_scores(self):
        self.my_score_label.config(text=f"Your Score: {self.my_score}")
        self.opp_score_label.config(text=f"Opponent: {self.opponent_score}")
    
    def timer_tick(self):
        if self.timer > 0:
            self.timer -= 1
            self.root.after(1000, self.timer_tick)
            self.update_ui()
        else:
            self.status_label.config(text="Time up!", fg='orange')
            self.root.after(1000, self.next_problem)
    
    # Network functions
    def host_server(self, port):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind(('0.0.0.0', port))
        self.server_socket.listen(1)
        threading.Thread(target=self.accept_client, args=(port,), daemon=True).start()
        messagebox.showinfo("Host", f"Hosting on port {port}. Share your IP: {socket.gethostbyname(socket.gethostname())}:{port}")
    
    def accept_client(self, port):
        conn, addr = self.server_socket.accept()
        self.client_socket = conn
        print(f"Client connected from {addr}")
    
    def connect_client(self, ip, port):
        self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.client_socket.connect((ip, port))
            messagebox.showinfo("Connected", "Connected to host!")
        except:
            messagebox.showerror("Error", "Failed to connect!")
            self.mode = GameMode.SINGLE
    
    def send_problem_to_opponent(self):
        if self.client_socket:
            try:
                data = {'type': 'problem', 'problem': self.current_problem, 'options': self.options}
                self.client_socket.send(json.dumps(data).encode())
            except:
                pass
    
    def send_answer(self, correct):
        if self.client_socket:
            try:
                data = {'type': 'answer', 'correct': correct, 'score': self.my_score}
                self.client_socket.send(json.dumps(data).encode())
            except:
                pass
    
    def check_network(self):
        if self.client_socket:
            try:
                data = self.client_socket.recv(1024).decode()
                if data:
                    msg = json.loads(data)
                    if msg['type'] == 'problem':
                        self.current_problem = msg['problem']
                        self.options = msg['options']
                        self.update_ui()
                    elif msg['type'] == 'answer':
                        if msg['correct']:
                            self.opponent_score += 10 * self.difficulty.value
                            self.update_scores()
            except:
                pass
    
    def quit_game(self):
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        if self.client_socket:
            self.client_socket.close()
        self.show_menu()
    
    def run(self):
        self.root.protocol("WM_DELETE_WINDOW", self.quit_game)
        self.root.mainloop()

if __name__ == "__main__":
    import sys
    game = MathBlat()
    game.run()