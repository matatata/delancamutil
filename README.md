# DelanCamUtil

This is a little macOS Utility that will put [Delan Engineering Ltd's](https://delanclip.com)
 `Delan Cam 1` IR-Camera into the right state for IR Head-Tracking using Opentrack. It's currently not supported on macOS and without configuration the exposure time may be too long and tracking won't work optimally.
 
The DelanCamUtil app will only be visible as a little menu-item and configure the camera's exposure on app start and whenever it is connected or re-connected. You can also manually push the settings to the camera via the respective menu item. When the camera is connected the icon will be filled otherwise not.

**Caution:** When disconnecting and reconnecting the camera while DelanCamUtil is running appararently not always manages to successfully push the settings to the camera. In this case please use the "Reapply camera settings now" menu item and restart the tracking.

I'm not affiliated with Delan Engineering, but I'm a happy customer who is dedicated to bring IR-Head-Trackin to macOS. For that I've been also contributing to the opensource Tracking-Software `opentrack` focusing on the macOS build and the X-Plane Plugin. See my [fork](https://github.com/matatata/opentrack) where I also provide macOS binaries of opentrack.

Credits go to Jeffrey Frey's [uvc-util](https://github.com/jtfrey/uvc-util) for the heavy lifting under the hood.
