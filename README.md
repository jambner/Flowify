# <img src="Flowify/Assets.xcassets/flowify.imageset/flowify.png" alt="Flowify" width="30" height="30"> Flowify

UIKit/Swift

## Inital SS Flowchart:
<img src="Flowify/Assets.xcassets/flowify-flowchart.imageset/flowify-flowchart.svg" alt="Flowify">

## Filter through selection Flowchart:


## Responsibilities in MVP

### Model:
#### Core Business Logic:
- Storing and Managing Screenshots: Keep track of the screenshots and handle their storage.
- Merging Screenshots: Implement the logic to merge the screenshots into a single image. This might involve using CoreGraphics or similar frameworks to perform the image rendering.
- Saving Results: Handle saving the final image to a file or directory, and manage any associated data.

### Presenter:
#### Business Logic Coordination:
- Handling User Actions: Respond to user actions (e.g., form submission) and trigger the appropriate methods in the Model.
- Processing Workflow: Coordinate the sequence of operations, such as capturing screenshots, merging them, and notifying the View once the process is complete.
- Update the View: Provide status updates or results to the View, such as showing the merged image or indicating completion.

### View:
#### User Interface:
- Displaying the Form: Show the form for user input and handle the form submission.
- Showing Feedback: Display progress updates, final results, or error messages.
- Initiate Actions: Trigger the Presenter when the user performs actions like submitting the form.
