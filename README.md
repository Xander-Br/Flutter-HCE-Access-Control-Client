# sicpa

A Flutter Proof-Of-Concept demonstrating the use of TOTP with NFC HCE on a mobile device to enable access control to physical infrastructure and mitigate the risk of badge duplication.

## User Stories (Mobile App)

- The user should be able to authenticate.
- The user should be able to add an access card.
- The user should be able to remove an access card.
- The user should be able to emulate the access card.

## Application Structure

The application follows a feature-driven development approach to separate concerns, focus on essentials, and facilitate easier testing of individual components.

These features are implemented in this application, reflecting the user stories:
- `auth` (Authentication) (Usage is questionned)
- `hce` (Host Card Emulation / NFC interaction)
- `access_card` (Access Card Management)

Material 3 is used as the UI library for its ease of rapid prototyping, cohesive design system, and adherence to defined UI/UX guidelines. A `shared` folder is utilized to house reusable widgets accessible across different features.

Riverpod is selected for state management due to personal familiarity, strong community support, and extensive maintenance.

GoRouter has been chosen for routing as it aligns with the aforementioned architectural and development principles.