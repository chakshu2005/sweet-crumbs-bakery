# Sweet Crumbs Bakery — SwiftUI iOS App

## How to open this in Xcode

1. Xcode → **File → New → Project → iOS → App**.
   - Product Name: `SweetCrumbs`
   - Interface: **SwiftUI**, Language: **Swift**
   - Minimum Deployments: **iOS 17.0**
2. In Finder, delete Xcode's auto-generated `ContentView.swift` and the
   auto-generated `SweetCrumbsApp.swift` inside your new project folder.
3. Drag the `SweetCrumbs` folder from this zip into your Xcode project
   navigator (check "Copy items if needed" and "Create groups").
   You should end up with `SweetCrumbsApp.swift`, `Theme.swift`, and the
   `Models/`, `Managers/`, `Components/`, `Views/` groups.
4. Select an iPhone 15/16 simulator (iOS 17+) and press **⌘R**.

## Demo login

- Tap **"Use demo account"** on the login screen, or enter manually:
  - Email: `demo@sweetcrumbs.com`
  - Password: `bakery123`

## Testing the checkout flow

1. Add a few items from Home or Explore (tap the **+** on a card, or open
   a product for size/add-on options).
2. Go to the **Cart** tab, optionally apply a coupon: `SWEET20`,
   `BUY2GET1`, or `FREEDEL`.
3. Tap **Proceed to Checkout**, fill in:
   - Phone: any 10 digits (e.g. `9876543210`)
   - Pincode: any 6 digits (e.g. `110043`)
4. Tap **Place Order** to see the confirmation animation, then
   **Track Order** to watch the order progress automatically.

## Optional: real product photos

Add images named `product_1` through `product_13` to `Assets.xcassets`
to replace the emoji placeholders — everything falls back gracefully if
an image is missing.

No backend, no third-party dependencies — everything runs with local
mock data.
# sweet-crumbs-bakery
