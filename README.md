# <img src="Flowify/Assets.xcassets/flowify.imageset/flowify.png" alt="Flowify" width="30" height="30"> Flowify

A Swift-based screenshot management tool that automatically captures, processes, and combines multiple screenshots into composite images. Flowify bundles screenshots into albums and later merges and sends for easy export. If the flow contains more than 5 images, the flow is broken into a bundle of 5.

## Key Features
- Real-time screenshot observing
- Dynamic album organization
- Smart bundling system
- Streamlined export process

## How it works
1. Submit initial form details
2. The app creates and manages albums
3. Toggle the recording button and take screenshots as needed
4. Once toggling is off, Flowify will finish monitoring and start to process them
5. Processing adapts based on screenshot count:
     - 5+ images: Automatically split into bundles of 5
     - Less than 5: Processed as a single batch
6. Final composite images are prepared and sent to the email for export

## Technical Notes
- Due to PhotoKit API limitations, screenshots are copied to albums rather than moved
  
## TODO
- [ ] Separating Album-related functions to `AlbumManager` Class
- [ ] Start on the Email Manager to send to the email
- [ ] Enforcing order to photo Array with timestamp
- [ ] Separating array into bundles
- [ ] Explore other concepts to the project if needed
- [ ] Clean up/ Documentation
- [ ] Small tests
- [ ] Swiftlint cleaning

## Flowchart

<img src="Flowify/Assets.xcassets/flowify-flowchart.imageset/flowify.svg" alt="Flowify">
