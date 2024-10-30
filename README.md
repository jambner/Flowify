# <img src="Flowify/Assets.xcassets/flowify.imageset/flowify.png" alt="Flowify" width="30" height="30"> Flowify

UIKit/Swift

## Overview
This application streamlines the process of capturing, organizing and validating screenshots for QA flows. it helps QA engineers to systematic capture and manage screenshots while testing application flows. the tool significantly reduce manual effort.
Process Flow
Initial Checks and Setup

The app first verifys if user completed required form inputs

If form is incomplete, button functionality is disabled
Form data is stored in SessionData for future reference
data persistence is critical for workflow



## Album Creation and Screenshot Process

When user starts new flow:

System creates new Album for storing screenshots
FormData is stored in system memory
memory allocation might effect performance


## Screenshot Capture Process:

User manually capture screenshots during testing
Application records each screenshot in sequence
Process continue until user indicates completion
Screenshots are temporary stored in system memory
IMPORTANT: due to API limitations, system must create new assets rather than moving existing files
each screenshot requires individual API call for creation



## File Management

After screenshot capture completion:

App creates new assets in designated Album using API calls
Each screenshot is renamed following pattern: "flowName_X"
(where X represents the sequence number)
original files remain in temporary storage
deletion of temporary files must be handled seperately



## Validation and Processing

Screenshot Validation:

System compares actual screenshots vs recorded session array
Ensures all required screens were captured
Validates screenshot sequence matches expected flow
validation may fail if API calls timeout


## Image Processing:

System checks if flow contains more than 5 images
If yes: Breaks down into sets of 5 screenshots
If no: Proceeds to single image processing
processing time varies based on network speed



# Final Steps

Coreographic Processing:

System renders new image flow
Processed images are sent to designated Album thru API
Process completes with successful storage
multiple API calls may cause latency



## Common Issues and Troubleshooting

Missing screenshots: Verify the complete flow was captured
Naming errors: Ensure flowName is properly defined before starting
Storage issues: Confirm sufficient space in destination Album
API timeouts: Check network connection
Duplicate assets: May occur due to failed API calls
Memory leaks: Temporary files not properly cleaned up

## Known API Limitations

Cannot move existing assets between folders
Must create new asset for each screenshot
API calls required for each individual file
Rate limiting may cause delays
Timeout issues common with large files
No batch processing available
Asset creation may fail silently
API doesn't support parallel processing
Limited error reporting
No automatic cleanup of failed assets

# Limitations

Processing time increases with number of images
Network speed affects performance
Temp storage must be monitored
No automatic error recovery
Manual intervention required for failures
Limited to single flow processing
