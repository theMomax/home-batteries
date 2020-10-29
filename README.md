# Home Batteries

An app for displaying and managing home batteries integrated with Apple HomeKit written with SwiftUI.


## Feature Overview


Inspect live data and add devices  |  Display and create automations     |  Inspect triggers and conditions      |  Add characteristic triggers
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
<img src="https://user-images.githubusercontent.com/21169289/91665914-367adf80-eaf9-11ea-9c05-3c7f735cb599.gif" width="200"/> | <img src="https://user-images.githubusercontent.com/21169289/83887812-4331a680-a749-11ea-830e-c5660fca6fc9.PNG" width="200"/>  |  <img src="https://user-images.githubusercontent.com/21169289/83887816-43ca3d00-a749-11ea-90b8-3aa68edf5940.PNG" width="200"/>  |  <img src="https://user-images.githubusercontent.com/21169289/83887821-4462d380-a749-11ea-91d5-af6ffc80df2d.PNG" width="200"/> 


The main focus currently lies on providing a good visualization for the services provided by Home Batteries and accessories often used in combination with these. Customization (e.g. renaming accessories or moving them to another room) is not supported yet, as this can be done in Apple's Home App.

🟢 Live Data

🟢 Display Automations
* ✅ Display Home Hub Status
* ✅ Display Enabled/Disabled Status
* ✅ Display all types of Triggers
* ✅ Display all types of Conditions
* ✅ Display all types of Actions
* ✅ Display all types of End-Triggers

🟠 Create/Edit Automations
* ✅ Create new named Automations
* ✅ Delete Automations
* ❌ Rename Automations
* ✅ Enable/Disable Automations
* ✅ Add Characteristic Triggers
* ✅ Remove Triggers
* ✅ Add mandatory Characteristic Conditions
* ❌ Add mandatory Non-Characteristic Conditions
* ✅ Remove single mandatory Conditions
* ❌ Edit/Create Conditions recursively (enabling alternative conditions and negation)
* ❌ Edit/Create Actions
* ✅ Remove Actions
* ❌ Edit/Create End-Triggers
* ✅ Remove End-Triggers

🟠 Customization
* ✅ Add new Accessories
* ❌ Remove Accessories, Move Accessories to another Room
* ❌ Move Accessories to another Room
* ❌ Manage Favorites

🔴 iOS 14 Widgets

🔴 Historic Data

🔴 Siri Support

🔴 iPadOS Version

🔴 macOS Version

## Supported Accessories

* Home Batteries and their Services as defined at https://github.com/theMomax/homekit-battery-integration#services
* Electric Vehicles and Charging Stations and their Services as defined at https://github.com/theMomax/homekit-ovms-integration
* The Outlet Service as defined by Apple
* Koogeek's Outlet Service 4AAAF930-0DEC-11E5-B939-0800200C9A66:

    * Currently Active Power: 4AAAF931-0DEC-11E5-B939-0800200C9A66
    * Hourly Data (Today - 7 days before): 4AAAF933-0DEC-11E5-B939-0800200C9A66 - 4AAAF93A-0DEC-11E5-B939-0800200C9A66
    * Daily Data (this and last month): 4AAAF93B-0DEC-11E5-B939-0800200C9A66 & 4AAAF93C-0DEC-11E5-B939-0800200C9A66
    * Monthly Data (this and last year): 4AAAF93D-0DEC-11E5-B939-0800200C9A66 & 4AAAF93E-0DEC-11E5-B939-0800200C9A66
