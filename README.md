# Boarding.lk - Real-Time Student Accommodation Marketplace 🏠🇱🇰

![Next.js](https://img.shields.io/badge/Next.js-14-black)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green)
![Tailwind](https://img.shields.io/badge/Tailwind-CSS-blue)
![Leaflet](https://img.shields.io/badge/Maps-Leaflet.js-orange)

> 🔒 **Note:** This repository is a **Technical Showcase**. The full source code is private to protect intellectual property as this is a live commercial product. This documentation demonstrates the architecture, design patterns, and technical challenges solved.

**🔗 Live Demo:** [https://boardinglk.netlify.app](https://boardinglk.netlify.app)

---

## 📖 The Problem
The student accommodation market in Sri Lanka is largely unorganized. Students rely on:
1.  **Physical Banners:** Requiring physical travel to specific areas.
2.  **Unverified Facebook Groups:** Prone to scams, spam, and outdated listings.
3.  **Word of Mouth:** Inefficient and limited in scope.

There was no central, verified, and real-time platform to connect students with landlords.

## 💡 The Solution
**Boarding.lk** is a Full-Stack Progressive Web App (PWA) that acts as a trust bridge. It digitizes the entire process: finding, verifying, and communicating with landlords.

### Core Features
* **Students:** Filter by location/facilities, view real-time bed availability, and chat instantly with owners.
* **Landlords:** Post ads for free, manage occupancy status, and receive inquiries via WhatsApp or in-app chat.
* **Admins:** A real-time command center to approve/reject ads and moderate users.

---

## 🏗️ Technical Architecture

I utilized the **T3 Stack philosophy** (Typescript/JS, Tailwind, Serverless) to prioritize type safety, development speed, and scalability without infrastructure bloat.
<img width="2816" height="1536" alt="System_Archi" src="https://github.com/user-attachments/assets/7185e1a7-5202-46e2-84b5-c2dcd7b378c9" />


### ⚡ Tech Stack
* **Frontend:** [Next.js 14](https://nextjs.org/) (App Router) for Server-Side Rendering (SSR) and SEO.
* **Styling:** [Tailwind CSS](https://tailwindcss.com/) for a mobile-first, responsive UI.
* **Backend & DB:** [Supabase](https://supabase.com/) (PostgreSQL) for relational data and Auth.
* **Realtime:** Supabase Realtime (WebSockets) for Chat and Admin Dashboard.
* **Maps:** [Leaflet.js](https://leafletjs.com/) (OpenStreetMap) for cost-effective geolocation.
* **Emails:** [Resend](https://resend.com/) for transactional notifications.

---

## ⚙️ Key Technical Implementations

### 1. The "Optimistic" Admin Command Center
The Admin Panel is designed to feel instant.
* **Challenge:** Waiting for the database to confirm a "Delete" or "Approve" action makes the app feel sluggish.
* **Solution:** I implemented **Optimistic UI Updates**. When an admin clicks "Approve", the UI immediately removes the item from the 'Pending' list before the network request finishes.
* **Safety Net:** A background listener subscribes to DB changes. If the network request fails, the UI automatically reverts to the correct state.

### 2. Custom Relational Chat System
I built a chat system from scratch rather than using a paid SDK.
* **Schema:** Relational design with `Conversations` (Parent) and `Messages` (Child).
* **Real-time:** The chat interface uses a `useEffect` hook to subscribe to `INSERT` events on the `messages` table via WebSockets.
* **UX:** Implemented auto-scroll, unread message badges, and mobile-responsive layouts.

### 3. Advanced Search & Filtering
The search logic happens client-side for speed after an initial server fetch.
* **Logic:**
    1.  Fetch all active properties.
    2.  Filter locally based on 5 dimensions: `Location`, `Gender`, `Price`, `Facilities` (Array overlap), and `Text Match`.
    3.  Sort results prioritizing "Available" beds over "Fully Occupied" ones.

---

## 🛡️ Security Policies (Row Level Security)

Instead of relying solely on API middleware, security is enforced at the database layer using PostgreSQL RLS policies.

| Policy Name | Description | SQL Logic (Simplified) |
| :--- | :--- | :--- |
| **Public Read Active** | Anyone can see ads where status is 'active'. | `status = 'active'` |
| **Owner Edit Own** | Users can only UPDATE/DELETE their own properties. | `auth.uid() = owner_id` |
| **Admin God Mode** | Secure policy granting full CRUD access to specific emails. | `auth.jwt() ->> 'email' = 'admin@boarding.lk'` |

---

## 🚀 Deployment & CI/CD

* **Host:** [Netlify](https://www.netlify.com/) (Free Tier).
* **Pipeline:** Connected to GitHub. Every push to `main` triggers an automatic build and deploy.
* **Environment:** Sensitive keys (`SUPABASE_KEY`, `RESEND_API`) are injected at build time via Netlify Environment Variables.
* **Image Optimization:** Configured `next.config.js` to allow remote patterns from Supabase Storage and Google Auth domains.

---

## 🔮 Future Improvements

* **AI Recommendations:** Integrating vector embeddings to suggest rooms based on "vibe" and amenities.
* **Payment Gateway:** Adding Stripe or PayHere (Sri Lankan Gateway) for landlords to boost their ads.
* **PWA Offline Mode:** Caching recent listings for offline viewing using Service Workers.

---

### 📬 Contact

I built Boarding.lk to solve a real-world problem using modern web technologies. I am open to Full-Stack Developer opportunities.
* **Email:** ietampawala2002@gmail.com
* **LinkedIn:** [https://www.linkedin.com/in/isuru-sasanga-etampawala](https://www.linkedin.com/in/isuru-sasanga-etampawala/)
