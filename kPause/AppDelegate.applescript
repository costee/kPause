--
--  AppDelegate.applescript
--  kPause
--
--  Created by Nagy Konstantin Olivér on 2013.07.12..
--  Copyright (c) 2013 Nagy Konstantin Olivér. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
    property myMenu : missing value
    property statusItem : missing value
    
    property my_title : "Stop at End of Current Track"
    property interval : 3 --Duration (in seconds) of delay before loop repeats.
    property stop_offset : 1 --Expected latency between when script stops playback and when playback actually stops.
    -- this property will be used to configure our notification
	property myNotification : missing value
    property scriptFile : missing value
    
    on awakeFromNib()
        set statusItem to current application's NSStatusBar's systemStatusBar's statusItemWithLength_(22)
        statusItem's setTitle_("♫")
        statusItem's setMenu_(myMenu)
        statusItem's setHighlightMode_(true)
    end awakeFromNib
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
    
    on just_pause_(sender)
        set iTunes_is_playing_bool to false
        set Rdio_is_playing_bool to false
        set Spotify_is_playing_bool to false
        
--        try
--            tell application "Finder" to get application file id "com.rdio.desktop"
--            set rdioExists to true
--            on error
--            set rdioExists to false
--        end try
--        if (rdioExists) then
--            tell the application "Rdio"
--                
--                if it is running then
--                    set Rdio_state to player state
--                    if (Rdio_state is stopped) or (Rdio_state is paused) then
--                        set Rdio_is_playing_bool to false
--                        else if Rdio_state is playing then
--                        set Rdio_is_playing_bool to true
--                    end if
--                end if
--                
--            end tell
--        end if

        try
            tell application "Finder" to get application file id "com.spotify.client"
            set spotifyExists to true
            on error
            set spotifyExists to false
        end try
        if (spotifyExists) then
            tell the application "Spotify"
                
                if it is running then
                    set Spotify_state to player state
                    if (Spotify_state is stopped) or (Spotify_state is paused) then
                        set Spotify_is_playing_bool to false
                        else if Spotify_state is playing then
                        set Spotify_is_playing_bool to true
                    end if
                end if
                
            end tell
        end if
        
        tell the application "iTunes"
            
            if it is running then
                set iTunes_state to player state
                if iTunes_state is stopped then
                    set iTunes_is_playing_bool to false
                    else if iTunes_state is playing then
                    set iTunes_is_playing_bool to true
                end if
            end if
            
        end tell
            
            if (not Rdio_is_playing_bool) and (not iTunes_is_playing_bool) and (not Spotify_is_playing_bool) then
                display dialog "iTunes, Rdio and Spotify are all stopped"
            end if
            if Rdio_is_playing_bool is true then
                just_pause_rdio_(sender)
            end if
            if iTunes_is_playing_bool is true then
                just_pause_itunes_(sender)
            end if
            if Spotify_is_playing_bool is true then
                just_pause_spotify_(sender)
            end if
    end just_pause

	on just_pause_itunes_(sender)
            tell application "iTunes"
                -- Get track fingerprint and finish time. If the player is stopped, the script quits immediately with an alert message.
                if player state is stopped then
                    display dialog "No track is playing." buttons {"OK"} default button 1
                    return 0
                end if
                try
                    set end_time to (get finish of current track) as real
                    copy (get database ID of current track) to Last_Song
                    on error
                    display dialog "No track is playing." buttons {"OK"} default button 1
                    return 0
                end try
                
                -- Script then repeats every interval until track ends or status changes.
                repeat
                    set time_left to (end_time - player position) as real
                    copy (get database ID of current track) to Current_Song
                    if player state is not playing then exit repeat -- Script quits if playback stopped already.
                    if Current_Song is not Last_Song then -- Script quits if user changed song.
                        stop
                        exit repeat
                    end if
                    if time_left < interval then
                        delay (time_left - stop_offset) -- Short interval
                        try
                            tell current track
                                set played count to (get played count) + 1
                                set played date to (get current date)
                            end tell
                        end try
                        stop
                        exit repeat
                        else
                        delay (interval) -- Wait one full interval
                    end if
                end repeat
            end tell
    end just_pause_itunes_
    
--    on just_pause_rdio_(sender)
--        tell application "Rdio"
--            -- Get track fingerprint and finish time. If the player is stopped, the script quits immediately with an alert message.
--            if (player state is paused) or (player state is stopped) then
--                display dialog "No track is playing." buttons {"OK"} default button 1
--                return 0
--            end if
--            try
--                set end_time to ((get duration of current track) - 1) as real
--                copy (get rdio url of current track) to Last_Song
--                on error
--                display dialog "No track is playing." buttons {"OKÉ"} default button 1
--                return 0
--            end try
--            
--            -- Script then repeats every interval until track ends or status changes.
--            repeat
--                set time_left to (end_time - player position) as real
--                copy (get rdio url of current track) to Current_Song
--                if player state is not playing then exit repeat -- Script quits if playback stopped already.
--                if Current_Song is not Last_Song then -- Script quits if user changed song.
--                    pause
--                    exit repeat
--                end if
--                if time_left < interval then
--                    delay (time_left) -- Short interval
--                    
--                    pause
--                    exit repeat
--                    else
--                    delay (interval) -- Wait one full interval
--                end if
--            end repeat
--        end tell
--    end just_pause_rdio_

    on just_pause_spotify_(sender)
        tell application "Spotify"
            -- Get track fingerprint and finish time. If the player is stopped, the script quits immediately with an alert message.
            if player state is stopped then
                display dialog "No track is playing." buttons {"OK"} default button 1
                return 0
            end if
            try
                set end_time to (get duration of current track) as real
                copy (get id of current track) to Last_Song
                on error
                display dialog "No track is playing." buttons {"OK"} default button 1
                return 0
            end try
            
            -- Script then repeats every interval until track ends or status changes.
            repeat
                set time_left to (end_time - player position) as real
                copy (get id of current track) to Current_Song
                if player state is not playing then exit repeat -- Script quits if playback stopped already.
                if Current_Song is not Last_Song then -- Script quits if user changed song.
                    stop
                    exit repeat
                end if
                if time_left < interval then
                    delay (time_left) -- Short interval
                    
                    pause
                    exit repeat
                else
                    delay (interval) -- Wait one full interval
                end if
            end repeat
        end tell
    end just_pause_spotify_
    
    on runScript_(sender)
        set scriptFile to (choose file)
        set posixPath to POSIX path of scriptFile
        just_pause_(sender)
        run script posixPath
    end runScript_
    
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script