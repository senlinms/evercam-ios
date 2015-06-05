//
//  Config.h
//  evercamPlay
//

#ifndef EvercamPlay_Config_h
#define EvercamPlay_Config_h

#pragma-mark Google Analythic Event Tracking Categories

#define category_menu                       @"Menu"
#define category_sign_up                    @"Create Account"
#define category_add_camera                 @"Add Camera"
#define category_shortcut                   @"Home Shortcut"
#define category_streaming_rtsp             @"RTSP Streaming"
#define category_streaming_jpg              @"JPG Streaming"

#pragma-mark Event Tracking Action

#define action_refresh                      @"Refresh"
#define action_logout                       @"Log Out"
#define action_manage_account               @"Manage Account"
#define action_settings                     @"Settings"
#define action_add_camera                   @"Add Camera"
#define action_signup_success               @"New account created"
#define action_addcamera_success            @"New camera created"
#define action_addcamera_success_manual     @"New camera added manually"
#define action_addcamera_success_scan       @"New camera added from scanning"
#define action_streaming_rtsp_success       @"Successfully played RTSP stream"
#define action_streaming_rtsp_failed        @"Failed to play RTSP stream"
#define action_streaming_jpg_success        @"Successfully played JPG stream"
#define action_streaming_jpg_failed         @"Failed to play JPG stream"
#define action_shortcut_create              @"Create a shortcut"
#define action_shortcut_use                 @"Use shortcut"

#pragma-mark Event Tracking Label

#define label_list_refresh                  @"Refresh Camera List"
#define label_user_logout                   @"Log out from menu"
#define label_settings                      @"Click on settings menu"
#define label_account                       @"Click on manage account"
#define label_add_camera_manually           @"Click on add camera in menu, and choose manually."
#define label_add_camera_scan               @"Click on add camera in menu, and choose scan."
#define label_signup_successful             @"A new user created successfully"
#define label_addcamera_successful          @"A new camera successfully created, either manually or from scanning"
#define label_addcamera_successful_manual   @"A new camera successfully added  manually"
#define label_addcamera_successful_scan     @"A scanned camera successfully added"
#define label_streaming_rtsp_success        @"Successfully played RTSP stream"
#define label_streaming_rtsp_failed         @"Failed to play RTSP stream while the camera is online and has a valid RTSP URL."
#define label_streaming_jpg_success         @"Successfully played JPG stream"
#define label_streaming_jpg_failed          @"Failed to play JPG stream while the camera is online"
#define label_shortcut_create               @"Create a single camera shortcut on home screen"
#define label_shortcut_use                  @"Use shortcut from desktop"

#pragma-mark Event Tracking Screen names
#define screen_add_camera                   @"Add Camera"
#define screen_edit_camera                  @"Edit Camera"

#pragma-mark Event Tracking Exception description
#define exception_user_not_saved            @"User saved locally is null."
#define exception_failed_load_cameras       @"Failed to load camera list in LoadCameraListTask"
#define exception_error_login               @"Show error dialog because unknown error when logging in."
#define exception_error_empty_user          @"Show error dialog because user detail is empty."

#pragma mark Mixpanel Event

#define mixpanel_event_sign_in              @"Sign In"
#define mixpanel_event_sign_up              @"Create Account"
#define mixpanel_event_create_camera        @"Create a camera"
#define mixpanel_event_create_shortcut      @"Create a shortcut"
#define mixpanel_event_use_shortcut         @"Use shortcut"

#endif
