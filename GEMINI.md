# Developer Profile & Coding Guidelines

## Tech Stack & Architecture Philosophy
- **Raw & Lightweight:** Favor raw PHP, Vanilla JS, and MySQL. Avoid heavy Node.js setups, complex frameworks, or unnecessary dependencies unless explicitly requested.
- **Client-Side Heavy Lifting:** Prioritize server performance and bandwidth. When handling heavy assets (like 1024x1024 HD images), serve lightweight thumbnails from the server and upscale/process them natively on the client device (e.g., using Dart Regex).
- **Pragmatic MVPs:** Treat custom builds (especially DOM scraping projects) as fast, fun "hacker MVPs". Focus on getting a stable v1.0 running and published before over-engineering.

## Workflow & Implementation Plans
- **Plan First, Code Later:** Before working on any new feature or deep bug, always generate or update an `implementation_plan.md` artifact.
- **Sequential Execution:** Break implementation plans down into distinct, numbered steps. 
- **Wait for Permission:** NEVER execute code changes or run modifying terminal commands without explicit approval. Always stop, present the plan, and wait for a direct command (e.g., "Proceed", "Execute step one", "Go") before taking action.
- **Commits & Syncs:** At the end of a successful feature phase or debugging session, proactively generate a professional, formatted `git commit` message summarizing the exact changes so the user can easily commit and push.

## Design Philosophy (UI/UX)
- **Apple Ecosystem Aesthetic:** Strive for premium, sleek, and minimalist designs mirroring iOS apps.
- **Color Palette:** Use deep OLED blacks (e.g., `#030303`) for backgrounds with vibrant accents (e.g., `#FF0000` for branding/controls).
- **Styling:** heavily utilize glassmorphism (frosted glass/blurs using `BackdropFilter`), highly rounded corners, and smooth layout structures.
- **Icons & Assets:** Use Cupertino icons where possible. Keep graphic assets (like app icons) strictly flat, 2D, and completely devoid of text.

## Security Stance
- **Strict Server Security:** Never loosen server-side security to bypass client errors.
- **Firewall First:** Enforce strict Hotlink Protection and `.htaccess` whitelisting. Block empty referrers.
- **Client Adaptation:** If a client app (like Flutter) gets blocked by the firewall, fix the client by spoofing required headers (like `Referer`) rather than relaxing the server's `.htaccess` rules.

## Coding Style & Communication
- **Comments:** Write professional, very simple, and concise comments. Avoid overly verbose or "beginner-friendly" explanations in the code.
- **Debugging:** When encountering complex errors, perform deep root-cause analysis (OS-level permissions, manifest files, DNS caching) rather than applying superficial code tweaks.
