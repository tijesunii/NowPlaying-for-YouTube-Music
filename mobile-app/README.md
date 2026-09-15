# NowPlaying Remote (Flutter)

Native client for the NowPlaying ecosystem.

## Technical Scope

This application interfaces with the stateless PHP backend to pull live track status and push execution commands.

*   **Security Bypass**: Uses dynamically spoofed `Referer` headers based on the endpoint domain to bypass strict Apache `.htaccess` hotlink restrictions.
*   **Media Optimization**: Native regex parsing (`replaceAllMapped`) dynamically rewrites Google's `w120-h120` URL parameters to `w1024-h1024`, upscaling assets on the client device to preserve backend bandwidth.
*   **State Management**: Optimized polling interval (3s) with immediate optimistic updates (500ms post-command) for zero-latency UX.
