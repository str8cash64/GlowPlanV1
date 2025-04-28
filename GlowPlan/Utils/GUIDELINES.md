# GlowPlan Utils

This directory contains utility components that can be shared across the project.

## Important Notice

The `NavigationBarModifier` has been moved to `GlowPlan/Extensions/NavigationBarExtension.swift` and renamed to `GlowNavigationBarModifier` to avoid naming conflicts.

### Migration Guide

If you're using `NavigationBarModifier` directly:

```swift
// Old code
.modifier(NavigationBarModifier(backgroundColor: color, textColor: textColor))

// New code
.modifier(GlowNavigationBarModifier(backgroundColor: color, textColor: textColor))
```

If you're using the View extension:

```swift
// Old code
.navigationBarColor(backgroundColor: color, textColor: textColor)

// New code
.applyGlowNavigationBarStyle(backgroundColor: color, textColor: textColor)
```

### Temporary Solution

Until proper module structure is set up, you'll need to:

1. Import both the typical UI frameworks and include a comment about NavigationBarExtension:
   ```swift
   import SwiftUI
   import UIKit
   
   // Using GlowNavigationBarModifier from Extensions/NavigationBarExtension.swift
   ```

2. Use the modifier directly until imports are fixed:
   ```swift
   .modifier(GlowNavigationBarModifier(backgroundColor: color, textColor: textColor))
   ```

### To Do
- [ ] Set up proper module structure for the project to support easier imports
- [ ] Create a centralized utilities module 