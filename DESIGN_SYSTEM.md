# AutoQuill - Minimalist Design System

This document outlines the design system used in AutoQuill, a desktop application for audio transcription and AI assistance.

## Design Philosophy

The AutoQuill design system follows minimalist principles, emphasizing:

- **Clarity**: Clean, readable interfaces with clear visual hierarchy
- **Whitespace**: Strategic use of negative space to improve readability and focus
- **Elegance**: Refined aesthetics with a restrained color palette
- **Consistency**: Uniform application of design tokens across the application

## Color Palette

The color system is intentionally limited to create a cohesive visual identity:

- **Primary Color**: Vibrant Coral (#F55036) - Used for primary actions, highlights, and key UI elements
- **Neutral Colors**:
  - True White (#FFFFFF) - Light mode backgrounds
  - Soft Gray (#F3F3F3) - Light mode surface backgrounds and inactive states
  - Pure Black (#000000) - Text and dark theme foundations
  - Dark Surface (#1A1A1A) - Dark mode surface backgrounds
  - Dark Divider (#333333) - Dark mode dividers and separators
  - Light Divider (#E0E0E0) - Light mode dividers and separators

## Typography

The application uses a modern sans-serif font (Inter) with defined sizes and weights:

- **Font Sizes**:
  - Headline Large: 32px
  - Headline Medium: 28px
  - Headline Small: 24px
  - Body Large: 16px
  - Body Medium: 14px
  - Caption: 12px

- **Font Weights**:
  - Bold: 700
  - Medium: 500
  - Regular: 400
  - Light: 300

## Spacing

Based on an 8pt grid system:

- XXS: 4px
- XS: 8px
- SM: 16px
- MD: 24px
- LG: 32px
- XL: 40px
- XXL: 48px

## Border Radius

- Small: 8px
- Medium: 16px
- Large: 24px

## Components

### Cards

The `MinimalistCard` component provides a container with consistent styling:
- Clean, subtle background
- Optional border
- Consistent padding and border radius
- Interactive states for hoverable cards

### Buttons

The `MinimalistButton` component comes in four variants:
- **Primary**: Solid background with the primary color
- **Secondary**: Outlined style with primary color border
- **Tertiary**: Text-only with primary color
- **Icon**: Icon-only button

### Input Fields

The `MinimalistInput` component provides a clean, consistent input experience:
- Clear labeling
- Error states
- Helper text
- Optional prefix and suffix icons

### Toggle Switch

The `MinimalistToggle` component offers a clean toggle experience:
- Multiple size options
- Consistent styling with the color system
- Optional label and description

### Divider

The `MinimalistDivider` component provides a subtle way to separate content:
- Horizontal and vertical options
- Customizable thickness and color
- Automatic theme adaptation

## Animation

- **Durations**:
  - Short: 150ms
  - Medium: 300ms
  - Long: 500ms

- **Curves**:
  - Default: easeInOut
  - Emphasized: fastOutSlowIn

## Implementation

The design system is implemented through:

1. **Design Tokens**: Constants defined in `design_tokens.dart`
2. **Theme Implementation**: Light and dark themes in `app_theme.dart`
3. **Component Library**: Reusable widgets that follow the design system

## Usage Guidelines

When implementing new features or components:

1. Use existing components whenever possible
2. Follow the spacing system for consistent layout
3. Adhere to the color palette for visual consistency
4. Ensure components work well in both light and dark themes
5. Maintain accessibility with sufficient contrast and clear visual hierarchy
