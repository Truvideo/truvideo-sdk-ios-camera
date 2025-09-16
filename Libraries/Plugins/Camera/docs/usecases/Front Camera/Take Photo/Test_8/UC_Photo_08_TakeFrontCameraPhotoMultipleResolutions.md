# 🎥 Use Case: Take Photo with Front Camera in Multiple Resolutions  

## 🎯 Objective  
Validate that front camera photos can be captured correctly across different supported resolutions (HD, FHD, SD).  

## 🧪 Test Scope  
- **Included:**  
  - Capturing photos in multiple resolutions: HD, FHD, SD.  
- **Excluded:**  
  - Flash, zoom, orientation changes.  
  - Active call or notifications.  

## 📝 Preconditions  
- User is authenticated.  
- SDK camera is installed, initialized, and launched.  
- Device has granted **camera** permissions.  
- **Front camera** is selected and functional.  
- Device supports all tested resolutions (HD, FHD, SD).  

## ✅ Expected Visible UI Elements  
- **Capture Button**: visible and enabled.  
- **Resolution Selector**: visible, allows selection of HD, FHD, or SD.  
- **Switch Camera Button**: visible. 

## ✋ Interaction Rules  
- **Resolution Selector** → Select desired resolution before capture.  
- **Capture Button** → Tap → Take photo in the selected resolution.  

## 📸 Test Steps  
1. Launch the SDK camera and select **front camera**.  
2. For each resolution (HD, FHD, SD):  
   - Select the resolution.  
   - Tap **Capture Button**.  
   - Verify photo is captured in the correct resolution.  

### ✅ Expected Result  
- Photos are captured successfully in each selected resolution.  
- Resolution selector correctly applies the chosen resolution.  

## ✅ Pass Criteria  
- Captured photos match the selected resolution.  
- Camera UI remains responsive.  

## 📎 Notes  
- Sub-cases exist for HD, FHD, and SD, detailing individual resolution tests. 