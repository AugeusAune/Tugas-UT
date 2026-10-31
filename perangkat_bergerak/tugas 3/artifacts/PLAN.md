# Implementation Plan: Tugas 03 – Praktikum Pemrograman Perangkat Bergerak (MSIM4401)

## 1. Project Overview & Objectives
Build a mobile application using **Ionic Framework** with **Vue 3** (Composition API) to fetch and display cryptocurrency market ticker data from the Coinlore public API:
* **API Source:** `https://api.coinlore.net/api/tickers/`
* **Target Data Fields:** `rank`, `name`, `symbol`, and `price_usd`.
* **Visual Reference:** Matches the specification layout shown in `Tugas_03.pdf` (cream/light-yellow 3-column cards with top header Refresh button).
* **Execution & Display Mode:** Ionic Web App tested via Mobile Device Emulation Mode (Responsive Design Mode / Viewport HP: 390x844px).
* **Workspace Location:** `/home/fadtya/program/Tugas-UT/perangkat_bergerak/tugas 3`

---

## 2. Technical Stack
* **Runtime & Package Manager:** Bun / Node.js
* **Framework:** Vue 3 (Composition API, `<script setup lang="ts">`)
* **Mobile UI Toolkit:** `@ionic/vue`, `@ionic/vue-router`, `ionicons`
* **Bundler & Tooling:** Vite, TypeScript, `vue-tsc`
* **HTTP Client:** `axios`
* **Testing & Device Simulation:** Mobile Responsive Viewport (Chrome/Firefox Device Toolbar `Ctrl+Shift+M`)

---

## 3. Target File Structure
```text
perangkat_bergerak/tugas 3/
├── artifacts/
│   ├── Tugas_03.pdf                  # Original assignment PDF
│   ├── PLAN.md                       # This implementation plan
│   ├── laporan_tugas_3.md            # Final assignment report document with code & screenshots
│   └── screenshots/                  # Mobile capture results
│       ├── 1_tampilan_utama_mobile.png
│       └── 2_tampilan_full_list.png
├── dist/                             # Vite production build output
├── src/
│   ├── main.ts                       # Ionic Vue initialization & CSS imports
│   ├── App.vue                       # Root component with <ion-app> & <ion-router-outlet>
│   ├── shims-vue.d.ts                # TypeScript definition for .vue files
│   ├── router/
│   │   └── index.ts                  # Route definitions (/ -> CryptoListPage)
│   ├── types/
│   │   └── crypto.ts                 # TypeScript interfaces for API response
│   ├── services/
│   │   └── cryptoService.ts          # Axios data fetching service
│   └── views/
│       └── CryptoListPage.vue        # Main UI screen matching PDF reference
├── .gitignore                        # Git ignore patterns
├── index.html                        # Single page HTML entry
├── package.json                      # Dependencies & scripts
├── tsconfig.json                     # TypeScript configuration
└── vite.config.ts                    # Vite build configuration
```

---

## 4. Detailed Task Breakdown

### Task 1: Project Initialization & Configuration
* **Files:** `package.json`, `tsconfig.json`, `vite.config.ts`, `index.html`
* **Action:**
  1. Define dependencies: `@ionic/vue`, `@ionic/vue-router`, `ionicons`, `vue`, `vue-router`, `axios`.
  2. Setup TypeScript configuration supporting Vue SFCs (`vue-tsc`).
  3. Configure Vite with `@vitejs/plugin-vue`.
* **Acceptance Criteria:** `bun install` completes cleanly with no peer dependency errors.

### Task 2: Type Definitions & Service Layer
* **Files:** `src/types/crypto.ts`, `src/services/cryptoService.ts`
* **Action:**
  1. Create `CryptoTicker` interface with `id`, `name`, `symbol`, `rank`, `price_usd`.
  2. Create `CoinloreResponse` interface with `data: CryptoTicker[]`.
  3. Implement `getCryptoTickers()` using Axios with timeout and descriptive error handling.
* **Acceptance Criteria:** Service successfully fetches and parses data from `https://api.coinlore.net/api/tickers/`.

### Task 3: Vue & Ionic Application Entry
* **Files:** `src/main.ts`, `src/App.vue`, `src/router/index.ts`
* **Action:**
  1. Initialize Ionic in `src/main.ts` and import core Ionic CSS (`core.css`, `normalize.css`, `structure.css`, `typography.css`).
  2. Configure Vue Router with `createRouter` and `createWebHistory`.
  3. Set up root `App.vue` with `<ion-app>` and `<ion-router-outlet>`.
* **Acceptance Criteria:** Router navigates to `/` and mounts the main page without runtime errors.

### Task 4: UI Implementation (`CryptoListPage.vue`)
* **Files:** `src/views/CryptoListPage.vue`
* **Design Specifications:**
  * **Header:** Blue **Refresh** button positioned at the top (`ion-button color="primary"`).
  * **Loading State:** `<ion-spinner>` and message while fetching data.
  * **Error State:** Descriptive alert/banner with a retry button if network fails.
  * **Card Layout:** Each cryptocurrency row is styled with:
    * Background: Warm light-yellow/cream (`#fffbe6`).
    * Border: Subtle border with rounded corners (`border: 1px solid #e7dfb5`, `border-radius: 10px`).
    * **Column 1 (Rank):** Top label `"Rank"`, bottom large integer (`item.rank`).
    * **Column 2 (Name & Symbol):** Top small name (`item.name`), bottom large symbol (`item.symbol`).
    * **Column 3 (Price):** Top label `"USD"`, bottom large price string (`item.price_usd`).
* **Acceptance Criteria:** Visual appearance matches the mock provided in `Tugas_03.pdf`.

### Task 5: Mobile Emulation & Screenshot Capture
* **Action:**
  1. Execute `bun run build` to verify clean TypeScript compilation and asset bundling.
  2. Run local preview server and capture mobile viewport screenshots (390x844px) simulating native phone display.
* **Acceptance Criteria:** Build passes with zero errors; screenshots saved in `artifacts/screenshots/`.

### Task 6: Assignment Report Documentation (`artifacts/laporan_tugas_3.md`)
* **Files:** `artifacts/laporan_tugas_3.md`
* **Content:**
  1. Student identification (Nama, NIM, Program Studi).
  2. Explanation of created files and architecture.
  3. Step-by-step tutorial on running the application in browser mobile emulation mode.
  4. Complete source code listing.
  5. UI screenshots proving functional requirements.
* **Acceptance Criteria:** Fulfills all requirements specified in `Tugas_03.pdf`.
