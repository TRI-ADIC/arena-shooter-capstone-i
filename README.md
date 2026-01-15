# Arena Shooter: Capstone Project

A graphically simple, top-down arena shooter with roguelite elements developed for the CS Capstone course.

## 🎮 Project Overview
The objective is to create a fast-paced survival experience where players face waves of enemies in a randomized arena. This project focuses on solid game-loop mechanics and procedural elements rather than high-fidelity graphics.

### Core Featur   ges
**Top-Down Combat:** Precise 8-directional movement and mouse-aimed shooting mechanics.
**Roguelite Progression:** Randomized power-ups and upgrades available upon leveling up.
**Procedural Arenas:** Dynamic floor generation to ensure no two runs are the same.
**AI Enemies:** Various enemy types with unique tracking and attacking behaviors.

## 🛠 Tech Stack
* **Engine:** Godot Engine (v4.x).
* **Language:** GDScript.
* **Version Control:** Git/GitHub for collaborative development.

## 👥 The Team & Roles
The team has been assigned specific user stories to complete during the current sprint:
* **Piero:** Core Player Movement & Physics.
* **Jason:** Combat & Projectile Systems.
* **Marco:** Enemy AI & Pathfinding.
* **Mahian:** Roguelite Logic & UI Systems.
* **Marcos:** Procedural Generation & Environment.

## 🚀 Getting Started
To run the project locally:
1. Ensure you have **Godot 4.x** installed.
2. Clone this repository:
   `git clone https://github.com/TRI-ADIC/arena-shooter-capstone-i.git`.
3. Open `project.godot` in the Godot Editor.
4. Press **F5** to run the main scene.

## 🤝 Contribution Guide
To maintain a clean codebase and fulfill our Capstone grading requirements for collaboration, please follow these workflows:

### 1. Branching Strategy
* Never push directly to the `main` branch. 
* Create a feature branch for your specific User Story using the format: `feature/name-description`.
* This allows us to track individual progress for our weekly status reports.

### 2. Preventing Merge Conflicts
* Godot scenes (`.tscn`) and resources (`.tres`) can be difficult to merge.
* Communicate in the daily standup before making major changes to shared scenes.
* Work in separate sub-scenes to keep files distinct whenever possible.

### 3. Pull Requests & Code Reviews
* Once your task is complete, open a **Pull Request (PR)** toward the `main` branch.
* At least one other teammate must review and approve the PR before merging. 
* Reviewing code counts toward your required daily collaboration minutes.

### 4. Daily Standups
* Ensure you log more than **1 hour** of work per day to receive full points.
* Log at least **15 minutes** of collaborative work daily.
* All team members must upload the exact same copy of the meeting minutes.

---
[cite_start]**Current Status:** Sprint 1 - Core MVP Development[cite: 1, 6].
