# GlowPlan Extensions

This directory contains extension components that can be shared across the project.

## NavigationBarExtension

The `NavigationBarExtension.swift` file contains a SwiftUI ViewModifier (`GlowNavigationBarModifier`) that allows for customizing the navigation bar appearance.

### Usage

In Swift, since we don't currently have proper module support set up, you'll need to:

1. Import both SwiftUI and UIKit in your file:
   ```swift
   import SwiftUI
   import UIKit
   ```

2. Use the modifier directly:
   ```swift
   .modifier(GlowNavigationBarModifier(backgroundColor: UIColor(...), textColor: UIColor(...)))
   ```

## Future Work

In the future, we'll set up proper module support so you can import extensions directly:

```swift
import GlowPlan.Extensions
```

Until then, use the direct modifier approach to avoid naming conflicts. 