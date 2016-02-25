REBOL [
	; -- Core Header attributes --
	title: "Glass window"
	file: %window.r
	version: 1.2.6
	date: 2013-11-20
	author: "Maxim Olivier-Adlhoch"
	purpose: {Default window manager for Glass, can be subclassed and changed.}
	web: http://www.revault.org/modules/window.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'window
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/window.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v1.2.5 - 2013-09-18
			-License changed to Apache v2

		v1.2.6 - 2013-11-20
			- added anti-aliasing to backplane rendering of window.
			- overhauled the drag and drop event handling.
			- added 'PRE-RELEASE mouse button event
			- fixed MANY drag and drop related bugs.
			- added 'DROP-BG event for releasing the mouse on background (window)
	}
	;-  \ history

	;-  / documentation
	documentation: {
		currently, windows are styles and derived from viewports.
		
		Windows implement some of the event handling like focus and window close/resize etc.
		The window is one of the three stream levels, it takes some of the low-level events
		and converts them to higher-level events like selections, hover and such.
		
		currently, the window is also where keystrokes are converted to logical events, these
		events are used directly by the field and other marbles.
		
		The window also handles overlay events and the input blocker.  The input blocker basically
		makes the whole window impervious to mouse events, leaving only the overlay to manage
		mouse events.
		
		One big limitation in this release of GLASS is the inability to have more than one active
		GLASS window per application.  The reasons are quite complex and event related.
		
		This limitation will be lifted in one of the next releases, but some more development of
		the streaming and timer event is required to properly map incomming events to opened windows.
		
		Some of this code is currently managed in the basic Event handler which is global to the 
		whole application.  Another limitation is that it is a bit complex to properly handle
		the window title right now.  these things will be taken care of as the system goes out of
		prototype stage.
		
		Eventually we will have different window styles like dialog and requestors, etc.
	}
	;-  \ documentation
]





slim/register [

	;- LIBS
	epoxy: slim/open 'epoxy none
	glob-lib: slim/open/expose 'glob none [!glob to-color]

	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		dirty?
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
		dirty*: dirty
		detach*: detach
		process*: --process
	]
	
	sillica-lib: sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		do-event
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	
	frame-lib: slim/open 'frame none
	viewport-lib: slim/open 'viewport none
	
	event-lib: slim/open/expose 'event none [
		queue-event
		clone-event
		coordinates-to-offset
		marble-at-coordinates
		!event
		dispatch
	]
	
	slim/open/expose 'utils-script none [get-application-title]
	

	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;
	item: none
	default-window-face: make face []
	foreach item next first default-window-face [
		set in default-window-face item none
	]
	
	default-window-face/color: white
	
	
	;--------------------------------------------------------
	;-   
	;- !WINDOW [ ]
	;
	; most of the window is the same as a frame.
	;
	; windows have extra event managing properties & rebol/view window stuff.
	!window: make viewport-lib/!viewport [
	
		;-    aspects[ ] 
		aspects: make aspects [
			;-        offset:
			offset: 100x100
			
			;-        label:
			label: any [get-application-title "Untitled"]
			
			
			;-        block-input?:
			; when set to true, the fg-glob's backplane will fill the whole window and send 
			; a user specified message (usually specified from the marble style) down the queue.
			block-input?: none
			
			
			;-        color:
			color: theme-window-color
			
		]
		
		
		;-    material[ ] 
		; same as a frame
		material: make material [
			;-        title:
			title: none
			
		]
	
		
		;-    refresh-interval:
		;
		; milliseconds between refresh
		;
		; each window may have its own interval
		;
		; because of view's timer limitations, any value lower than 30 is actually
		; going to equate to ~ 30 since we only receive ~30 timer events per second from
		; view to begin with.
		; 
		; the default is pretty high (20 frames/second) , its a good idea to
		; lower it when:
		;    viewing large windows 
		;    frames contains many marbles
		;    many opened window at a time
		;    machine is too slow
		;
		; note that if nothing changes in the viewport, no actual refresh will occur.
		; a side-effect of liquid's lazyness.
		refresh-interval: 20
		
		
		;-    next-refresh:
		; an internal value managed by glass which acts as the trigger for the next
		; possible refresh.
		;
		; this is managed by the core-glass-handler
		;
		; discovered that the time ticks can go to negative values (basically a side-effect when it goes beyond 31 bits)
		next-refresh: -1 * power 2 31
		
		
		;-    auto-silence?:
		; if true, the window's stream automatically disables 
		; refresh of a window when it is deactivated.
		;
		; this means only one window will actively refresh.
		auto-silence?: true
		
		
		;-    layout-method:
		; the window is a column by default, edit before wrapping a frame.
		layout-method: 'column
		
		
		;-    view-face:
		; stores the face which is added to screen face
		view-face: none
		
		
		;-    stream:
		; stores the input stream processors.
		;
		; this is a simple block containing functions which are executed in sequence, which are 
		; allowed to interfere with the events generated for that window.
		;
		; when events first come in, they are converted to an !event.  This object is then
		; used within GLASS instead of the view event!.
		stream: none
		
		
		;-    backplug:
		; a plug which connects to our glob's layer 0 (the backplane layer).
		;
		; the backplane is used to very quickly determine what face is under the mouse.
		;
		; only the top most glob is available, but the shape of the glob's backplane needs not be
		; the same as the visual layers... 
		;
		; this means that you can very easily disable a marble's mouse interaction
		; just by leaving its backplane draw block empty.
		;
		backplug: none
		
		
		;-    backplane:
		; rendered image of the backplug
		backplane: none
		
		
		;--------------------------
		;-         raster:
		;
		; rendered foreground
		;--------------------------
		raster: none
		
		
		;--------------------------
		;-         clip-regions:
		;
		; one or more regions which are used to clip the display
		;--------------------------
		clip-regions: []
		
		
		;--------------------------
		;-         rt-globs:
		;
		; link any glob to this in order to shortcut refresh into only redrawing this 
		; instead of the whole display
		;--------------------------
		rt-globs: none
		
		
		;-    overlay:
		; globs which are draw over all else, this ignores clipping.
		; they are used to show popups, menus, etc.
		;
		; when the overlay is visible, the window may block input to all other globs,
		; and will trigger an event of your choice when bg is clicked.
		;
		; queuing a 'REMOVE-OVERLAY message, removes the overlay from the display and
		; disables the input blocker
		;
		; this is a liquified glob which is compatible with glass, when the overlay is displayed.
		; otherwise its none.
		overlay: none
		

		;--------------------------
		;-         last-draw-clipped?:
		;
		;
		;--------------------------
		last-draw-clipped?: false
		
		
		;-    triggered-events:
		;
		; this block is responsible for storing pre-defined event which are triggered
		; when events happen relative to the window.
		;
		; for now only mouse down really makes sense.
		;
		; these events are queued by the TRIGGER-EVENTS() function.
		;
		; note that not all events are managed by trigger-event right now... that might change.
		;
		triggered-events: compose/deep [
			; under normal circumstances these are triggered (queued)
			normal [
				pointer-press [
					(
					make !event [
						action: 'unfocus
					]
					)
				]
			]
			
			; when an overlay is being used and the input-blocker is enabled, these events are
			; sent instead.
			;
			; these events change often, since overlay events usually
			; are set by the code generating the overlay itself.
			;
			; event/viewport:  will be set by trigger-events()
			overlay [
				pointer-press [
					(
					make !event [
						action: 'remove-overlay
					]
					)
				]
			]
		
		]
		
		
		
		;-                                                                                                         .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- FUNCTIONS
		;
		;-----------------------------------------------------------------------------------------------------------
		
		; since the number of windows is limited, and it's a rather high-level
		; marble, we add the various window control functions
		; in the plug directly, to make it easier to use.
		
		
		
		;-----------------
		;-    display()
		; make the window visible on the screen.
		;-----------------
		display: func [
			/center "centers the window in screen"
			/local screen off
		][
			vin [{display()}]
			unless visible? [
				screen: system/view/screen-face
				append system/view/screen-face/pane view-face
				
				view-face/size: content* material/dimension
				vprint ["window size: " content* material/dimension]
				
				view-face/text: any [
					content* self/aspects/label
					all [system/script/header system/script/title]
					view-face/text
					copy ""
				]

				vprint ["window offset: " content* aspects/offset]
				if center [
					;off: content* aspects/offset
					fill* aspects/offset ((screen/size - view-face/size / 2) )
				]
				view-face/offset: content* aspects/offset
				view-face/rate: 1 ; forces timer events in wake-event
				view-face/options: [resize]
				show screen
			]
			vout
		]
		
		
		
		;-----------------
		;-    hide()
		;-----------------
		hide: func [
			
		][
			vin [{hide()}]
			if visible? [
				remove find system/view/screen-face/pane view-face
				show system/view/screen-face
			]
			vout
		]
		
		
		
		;-----------------
		;-    visible?()
		;-----------------
		visible?: func [][
			; always returns logic value
			not not find system/view/screen-face/pane view-face
		]
		
		
		
		;-----------------
		;-    actions[]
		;-----------------
		actions: context [
			i: 0
		
			;-----------------
			;-        close-window()
			;
			; note: the return value is used as the confirmation to close the window.
			;       so returning none, prevents the window from closing.
			;-----------------
			close-window: func [
				event
			][
				true
			]
		]
		
		
		
		;-    valve []
		valve: make valve [
			;-        type:
			type: '!window


			;-        style-name:
			style-name: 'window
			

			;-        fg-glob-class:
			; class used to allocate and link a glob drawn IN FRONT OF the marble collection
			;
			; we use this to create an input blocker.
			fg-glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						block-input? !any (false)
						dimension !pair
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; block inputs
						block-input? dimension
						[
							(
							either (data/block-input?=) [
								compose [
									pen none 
									fill-pen (to-color gel/glob/marble/sid)
									box (0x0) (data/dimension= )
								]
							][
								; nothing to add to block
								[]
							]
							)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						block-input? dimension
						[
							; here we restore our parent's clip region  :-)
							;clip (data/parent-clip-region=)
							
							(
							either (data/block-input?=) [
								compose [
									pen none 
									; dim interface, to indicate blocked input
									fill-pen (0.0.0.200) 
									box (0x0) (data/dimension= )
								]
							][
								; nothing to add to block
								[]
							]
							)
						]
						
						; controls layer
						;[]
						
						
					]
				]
			]

			;-        bg-glob-class:
			; class used to allocate and link a glob drawn BEHIND ALL OTHER marbles
			;
			; we use this to detect ckiking on the bg of the window.
			;
			; when this glob is selected, the window event handler will have special events
			; triggered.
			bg-glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						color !color
						dimension !pair
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; block inputs
						dimension
						[
							pen none 
							fill-pen (to-color gel/glob/marble/sid)
							box (0x0) (data/dimension= )
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						color dimension
						[
							pen none
							fill-pen (data/color=)
							box 0x0 (data/dimension= )
						]
						
						; controls layer
						;[]
						
						
					]
				]
			]

			
			
			;-----------------
			;-        detect-marble()
			;
			; returns the marble at specified coordinates for given window
			;
			; if the backplane layer has changed, it refreshes the backplane image.
			;
			; note that because the backplane layer usually only connects to the least 
			; materials and aspects it needs, it rarely ever changes, except when the layout
			; changes.
			;
			; also, because the backplane is only rendered when mouse interaction is required,
			; things like scrolling will not cause it to refresh automatically like the main layer would.
			;-----------------
			detect-marble: funcl [
				window [object!] 
				coordinates [pair!]
				;/local size marble blk
			][
				vin [{detect-marble()}]
				marble: none
				
				; is backplane up to date?
				if window/backplug/dirty? [
					vprint "we must redraw backplane"
					
					size: content* window/material/dimension
					if any [
						none? window/backplane
						all [
							image? window/backplane
							window/backplane/size <> size
						]
					][
						;vprint ["..................> Window Size changed: " size]
						;v?? size
						size: any [size 2x2]
						window/backplane: make image! max size 2x2
					]
					
					; make sure we don't rely on an out of date backplane, and correctly trap any errors
					; which might occur while trying to rebuild it.
					;window/backplane: none
					
					
					;-           render backplane
					if block? blk: content* window/backplug [
						;vprint "...................> Redraw-backplane"
						draw  window/backplane compose [ pen none anti-alias (none) fill-pen (white) box 0x0 (size) (blk) ]
						;set 'global-bkplane window/backplane
					]
				]
				
				if image? window/backplane [
					;vprint "backplane image exists"
					; make sure coordinates are within backplane bounds
					
					coordinates: min window/backplane/size coordinates
					v?? coordinates
					
					; low-level image to plug 
					marble: marble-at-coordinates window/backplane coordinates
					
					if marble[vprobe marble/sid]
				]
				vout
				
				; this can be none or a pointer to the marble
				marble
			]
			
			
			;-----------------
			;-        collect()
			;-----------------
			collect: func [
				glob [object!]
			][
				vin [{collect()}]
				
				vout
			]
			

			;-----------------
			;-        trigger-events()
			;-----------------
			trigger-events: func [
				window [object!]
				event [object!]
				mode [word!]
				/local
			][
				vin [{trigger-events()}]
				if mode: select window/triggered-events mode [
					if mode: select mode event/action [
						foreach evt mode [
							queue-event clone-event/with evt [
								viewport: event/viewport 
								coordinates: event/coordinates 
								view-window: event/view-window
							]
						]
					]
				]
				
				vout
			]
			
			
			;-----------------
			;-        set-overlay-trigger()
			;
			; a handy function which resolves various trigger setups.
			;
			; the word triggers basically act as often-used predefined operations
			; which can be asked for instead of built manually.
			;-----------------
			set-overlay-trigger: func [
				window [object!] "the window MARBLE, not the view-face"
				trigger [object! none! word! block!]
			][
				vin [{set-overlay-trigger()}]
				switch type?/word trigger [
					object! [
					]
					
					none! [
						clear window/triggered-events/overlay/pointer-press
					]
					
					word! [
						switch/default trigger [
							; the default action
							; simply streams a remove-overlay event. 
							remove [
								window/triggered-events/overlay/pointer-press: reduce [
									make !event [
										action: 'remove-overlay
									]
								]
							]
							ignore [
								window/triggered-events/overlay/pointer-press: none 
								reduce [
;									make !event [
;										action: 'remove-overlay
;									]
								]
							]
						][
							; this is an error, because its a programming error, which must be dealt with
							; at development time.
							;
							; there is no reason to fallback to anything, since this means the programmer
							; isn't aware of the api and issued an invalid event.
							to-error "unknown trigger preset specified in set-overlay-trigger()"
						]
					]
					
					block! [
						; <TO DO> make sure block contains only events
						change head clear window/triggered-events/overlay/pointer-press event/trigger
						
					]
					
					
				]
				
				vprint "input-blocker trigger was set"
				vout
			]
			
			
			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				win [object!]
			][
				vin [{materialize()}]
				
				win/material/title: liquify*/link process*/with 'window-title [window][
					if window: plug/window/view-face [
						window/text: pick data 1
						window/changes:  [text]
						show window
						window: plug: data: none
					]
				][
					stainless?: true ; always update when dirty.
					window: win
				] win/aspects/label
				
				vout
			]
			
			
			
		

			;-----------------
			;-        setup-style()
			;-----------------
			setup-style: func [
				window
			][
				vin [{glass/!} uppercase to-string window/valve/style-name {[} window/sid {]/setup-style()}]
				vprint "SETTING UP WINDOW!"
				; we setup the face, so it links back to the !window (which is a viewport)
				window/view-face: make default-window-face [viewport: window]
				
				; allocate space for the viewport stream
				window/stream: copy []
				
				; create a generic handle to our glob's internal backplane (layer 1)
				window/backplug: liquify* epoxy/!merge
				
				;-        handler context[]
				context copy/deep [
				
					;-             hovered-marble:
					; what marble is currently hovered? 
					;
					; this stores the marble which generated the 'START-HOVER event (if any).
					hovered-marble: none
					
					
					;-             selected-marble:
					; what marble is currently selected?
					;
					; this stores the marble which generated the 'SELECT event (if any).
					selected-marble: none
					
					
					;--------------------------
					;-             dragged-marble:
					;
					; stores which marble is being dragged, usually the same as the selected marble.
					; 
					; the reason to have a separate select & drag reference, is that is allows us to detect when the
					; selection becomes a drag (usually on the first SWIPE event).
					;
					; when the first swipe event is triggered, it generates a DRAG? event, which is responsible for
					; for setting the 
					;--------------------------
					dragged-marble: none
					
					
					;--------------------------
					;-             drag-down-event:
					;
					; stores the event which starts the dragging, so we can
					; store an origin of the marble being dragged or swipped
					;--------------------------
					drag-down-event: none
					
					
										
					
					;--------------------------
					;-             ctx-selected-marble:
					;
					; stores the marble which caused the context-press event.
					;
					; eventually, both selected and ctx selection will be available simultatneously
					; (under R3)
					;--------------------------
					ctx-selected-marble: none
					
					
					
					
				
					; add viewport handlers!
					vprint "adding refresh handler"
					event-lib/handle-stream/within 'window-handler 
						;-             window event handler
						; note, if we return an event, we intend for the streaming to continue
						; returning none or false will consume the event and this event is considered
						; completely managed.
						;
						; as usual, we may modify or even allocate a new event, and even queue new ones!
						func [
							event [object!]
							/local window marble qevent  wglob oglob  data img size
						][
							vin "WINDOW HANDLER"
							vprint event/action
							
							window: event/viewport
							
							rval: switch/default event/action [
								;----------------------------------
								;-                  -POINTER-MOVE
								POINTER-MOVE [
									;vprint "------------------->hovering mouse!"
									;vprint event/coordinates
									marble: detect-marble window event/coordinates
									
									
									either selected-marble [
										vprint "dragging"
										;print "SWIPE?"
										; enter swipe mode
										
										;slim/vdump/ignore marble [valve OBSERVERS subordinates]
										
										either drag-down-event [
											event: make event compose [
												DRAG-ORIGIN: drag-down-event/drag-origin
											]
										][
											if marble [
												drag-down-event: event: make event compose [
													DRAG-ORIGIN: (content marble/material/position)
												]
											]
										]


										event/marble: selected-marble
										event/offset: coordinates-to-offset selected-marble event/coordinates

										either same? selected-marble marble [
											event/action: 'SWIPE
										][
											; enables temporary drag & drop solution
											event: make event compose [drag-drop-candidate: ( marble)]
											event/action: 'DROP?
										]
									][
										vprint "hovering"
										
										; enter hover mode
										either all [
											same? hovered-marble marble 
											
										][
											event/action: 'HOVER
											event/marble: hovered-marble
											if event/marble [
												event/offset: coordinates-to-offset hovered-marble event/coordinates
											]
										][
											if hovered-marble [
												qevent: clone-event/with event compose [
													to-marble: (marble)
													to-offset: (either marble [coordinates-to-offset marble event/coordinates][0x0]) 
												]
												
												qevent/action: 'END-HOVER
												qevent/marble: hovered-marble
												qevent/offset: coordinates-to-offset hovered-marble event/coordinates
												
												; we cause an event to be triggered right now.
												; our event handling is halted, until that terminates.
												;
												; when the dispatched event is done, the next part of hovering is
												; done, which might cause the original event to become a 'START-HOVER
												; event and be handled AFTER the dispatched event!
												dispatch qevent
											]
											
											;vprint "=============>"
											if marble [
;												unless in marble/valve 'style-name [
;													global-plug: marble
;												]
												;slim/vdump/ignore marble [object!]
												
												event/action: 'START-HOVER
												event/marble: marble
												event/offset: coordinates-to-offset marble event/coordinates
											]
											;vprint "############"
											; rememeber new marble (or lack of)
											hovered-marble: marble
											marble: none
											;event
										]
									]
									event
								]
								
								
								
								;----------------------------------
								;-                  -RAW-KEY
								; we simply send raw key events to the marble which is under the mouse.
								; this is quite useful since you can be handling key repeat events and 
								; just swipe the mouse over marbles, and they will receive the events.
								;
								RAW-KEY [
									marble: detect-marble window event/coordinates
									event/marble: marble
									vprint "window detected raw key"
									vprobe event/key

									; we only return the event if the marble isn't the window									
									unless same? marble window [event]
								]
								
								
								;----------------------------------
								;-                  -SCROLL-LINE
								; generate a scrollwheel event .
								; 
								; its cool that we can queue these and implement our own scrolling based on
								; other events... like swiped release, which slowly nudges a value
								; until the end is reached.  :-)
								;
								SCROLL-LINE [
									;vprint "SCROLL-LINE"
									;vprobe event/coordinates
									if marble: detect-marble window event/coordinates [
									;	vprint "MARBLE UNDER CURSOR"
										event/marble: marble
										event/offset: coordinates-to-offset marble event/coordinates
									]
									event/action: 'SCROLL
									queue-event event
									
									; we consume the event since we requeued it.
									; the core handler might want to react to scrolling over a specific marble
									none
								]
								
								
								;----------------------------------
								;-                  -REFRESH
								REFRESH [
									vprint "------------------->Refresh!"
									;ask "!!"
									wglob: oglob: none
									case [
										all [
											window/last-draw-clipped?
											empty? clip-regions
										][
											draw window/raster content* window/glob
											window/last-draw-clipped?: false
										]
											
										any [
											window/glob/dirty?
											all [
												window/overlay
												window/overlay/dirty?
											]
											
										][
											if sl/debug-mode? > 0 [
												prin ">"
											]
											; get new draw block(s) from our glob(s).
											if window/glob/dirty?  [
												vprint "window glob is dirty"
											]
											clear wglob
											
											wglob: content* window/glob
											oglob: all [
												object? window/overlay 
												content* window/overlay ; can be none
											] 
											
											;------
											; detect size changes so we rebuild a new raster to draw on
											;
											; assiging window/raster to a word is beneficial since path access is slow
											; and we will be accessing img several times later.
											img: window/raster
											
											if any [
												all [
													image? img
													img/size <> content* window/material/dimension
												]
												none? img
											][
												vprint  "making new raster to draw on"
												; 2x2 is only there to prevent transient liquid linking issues
												; where the dimension is temporarily none
												window/raster: img: make image! any [content* window/material/dimension 2x2]
											
											]
											
											
											
											window/view-face/image: img
											
											clip-regions: window/clip-regions
											either empty? clip-regions [
												window/last-draw-clipped?: false
												vprint "CLIPPING"
												vprobe clip-regions
												
;												insert wglob reduce ['gamma .5  'clip ( clip-regions/1 ) ( clip-regions/2 ) ]
												insert wglob reduce [  'clip ( clip-regions/1 ) ( clip-regions/2 ) ]
												clear clip-regions
											][
												window/last-draw-clipped?: true
											]
											
											insert wglob ['gamma 1.3]
											
											draw img wglob
											if oglob [draw img oglob]
	;										
	;										
	;										either oglob [
	;											window/view-face/effect: reduce ['draw  wglob 'draw oglob]
	;										][
	;											window/view-face/effect: reduce ['draw  wglob]
	;										]
											;-----------------
											; saves out the complete draw block when problems occur,
											; very helpful to cure AGG or draw glitches.
											;
											; the debug-mode? is set in sillica.
											;
											; a few things will trigger when debug-mode is set.
											if sl/debug-mode? > 2 [	
												vprint "-> saving draw block to disk <-"
												if block? wglob [
													save join glass-debug-dir %draw-blk.r wglob
												]
											]
											
											;window/view-face/image: img
											;draw
											;show window/view-face
											
										]
									]
									show window/view-face
									none
								]
								
								
								;----------------------------------
								;-                  -POINTER-PRESS
								POINTER-PRESS [
									vprint "------------------->Moused button pressed!"
									vprint event/coordinates
									if object? marble: detect-marble window event/coordinates [
										; are these messages for ME?
										either same? marble window [
											vprint "========================================="
											vprint "             window bg clicked"
											vprint "========================================="
											selected-marble: window
											trigger-mode: either content* window/aspects/block-input? ['overlay]['normal]
											
											trigger-events window event trigger-mode
											
											;rectify the up/down symmetry
											event/action: 'SELECT
											event/marble: marble
											event/offset: event/coordinates
											queue-event event
											none
										][
											selected-marble: marble
											event/marble: marble
											event/offset: coordinates-to-offset selected-marble event/coordinates
											event/action: 'SELECT
											event
										]
									]
								]
								
								
								
								;----------------------------------
								;-                  -POINTER-RELEASE
								POINTER-RELEASE [
									vprint "------------------->Moused button released!"
									vprint event/coordinates
									;-------
									; some styles have curious dragging habbits which require some immediate
									; fixup when they are released.
									; 
									; this event allows them to prepare the marble before the real
									; pointer release occurs.
									;---
									if selected-marble [
										dispatch clone-event/with event [
											action: 'PRE-RELEASE 
											marble: selected-marble
										]
									]
									
									marble: detect-marble window event/coordinates 
									
									either marble [
										if in marble/aspects 'label [
											vprobe content marble/aspects/label
										]
										vprobe content marble/material/position
										vprobe content marble/material/dimension
										vprobe content window/material/dimension
										vprobe same? window marble
									][
										vprint "NO MARBLE"
									]

									; are these messages for a marble or the window?
									either all [
										selected-marble
										not same? marble window
									][
										vprint "marble is not a window"
										;---------
										; pointer was released from a marble selection
										event/offset: coordinates-to-offset selected-marble event/coordinates
										event/marble: selected-marble
										either marble <> selected-marble [
											vprint "marble isn't the selected marble"
											; give another marble the chance to refresh if the mouse is over it.
											dispatch clone-event/with event compose [
												action: 'END-HOVER
												to-marble: (marble)
												to-offset: (either marble [coordinates-to-offset marble event/coordinates][0x0]) 
											]
											vprint "end hover done"
											
											either marble [
												vprint "There is a marble"
												dispatch qevent: clone-event/with event compose [
													action: 'START-HOVER 
													marble: (marble)
													offset: (if marble [coordinates-to-offset marble event/coordinates])
												]
												
												
												;--------
												; we released mouse over another marble
												;--------
												
												; expand event
												event: make event compose [
													dropped-on: (marble)
													dropped-offset: qevent/offset ; saves processing
												]
												
												; released on another marble
												event/action: 'DROP
												
											][
												; released on bg
												event/action: 'NO-DROP
											]
										][
											;--------
											; we released mouse over ourself
											;--------
											
											event/action: 'RELEASE
										]
									][
										if selected-marble [
											dispatch clone-event/with event compose [
												;---
												; there aren't many styles which need this event.
												action: 'DROP-BG 
												marble: selected-marble
												window: (window)
											]
										]

										;---------
										; pointer was released from a window selection
										vprint "========================================="
										vprint "             window released"
										vprint "========================================="
										trigger-events window event 'normal
										event: none
									]
									selected-marble: none
									drag-down-event: none

									event
								]
								
								
								
								;----------------------------------
								;-                  -CONTEXT-PRESS
								CONTEXT-PRESS [
									vprint "------------------->context Mouse button pressed!"
									vprint event/coordinates
									if object? marble: detect-marble window event/coordinates [
									
										event/marble: marble
										ctx-selected-marble: marble  ; context doesn't trigger drag/drop!
										
										; are these messages for ME?
										either same? marble window [
											vprint "========================================="
											vprint "             window bg clicked"
											vprint "========================================="
											trigger-mode: either content* window/aspects/block-input? ['overlay]['normal]
											
											trigger-events window event trigger-mode
											
											;rectify the up/down symmetry
											event/offset: event/coordinates
											event/action: 'WINDOW-CTX-PRESS ; allows us to easily create bg-activated property pages.
											queue-event event
											none
										][
											;event/marble: marble
											event/offset: coordinates-to-offset marble event/coordinates
											event
										]
									]
								]
								
								
								

								;----------------------------------
								;-                  -CONTEXT-RELEASE
								CONTEXT-RELEASE [
									vprint "------------------->Moused button released!"
									vprint event/coordinates
									marble: detect-marble window event/coordinates 
									; are these messages for a marble or the window?
									either all [
										ctx-selected-marble
										not same? ctx-selected-marble window
									][
										;---------
										; pointer was released from a pressed marble
										event/offset: coordinates-to-offset ctx-selected-marble event/coordinates
										event/marble: ctx-selected-marble
										
										;------------
										; context button currently doesn't cause any kind of drag&drop
										;------------
;										either marble <> selected-marble [
;											; give another marble the chance to refresh if the mouse is over it.
;											dispatch clone-event/with event [
;												action: 'END-HOVER 
;											]
;											dispatch qevent: clone-event/with event compose [
;												action: 'START-HOVER 
;												marble: (marble)
;												offset: (if marble [coordinates-to-offset marble event/coordinates])
;											]
;											
;											either marble [
;												;--------
;												; we released mouse over another marble
;												;--------
;												
;												; expand event
;												event: make event [
;													dropped-on: marble
;													dropped-offset: qevent/offset ; saves processing
;												]
;												
;												; released on another marble
;												event/action: 'DROP
;												
;											][
;												; released on bg
;												event/action: 'NO-DROP
;											]
;										][
											;--------
											; we released mouse over ourself
											;--------
											
;										]
									][
										;---------
										; pointer was released from a window press
										vprint "========================================="
										vprint "             window released"
										vprint "========================================="
										event/action: 'WINDOW-CTX-RELEASE
											
										trigger-events window event 'normal
										event: none
									]
									ctx-selected-marble: none
									event
								]
								
								
								
								
								;----------------------------------
								;-                  -ADD-OVERLAY
								;
								; <TO DO>: support multiple overlays
								; <TO DO>: change all references of ADD-OVERLAY to ADD-OVERLAY!
								;
								; this tells the window to do its overlay handling stuff.
								ADD-OVERLAY ADD-OVERLAY! [
									vprint "ADDING AN overlay to WINDOW: "
									if event/view-window [
										vprint  [event/view-window/text]
									]
									
									either all [
										in event 'frame   ; the marble to display (should be a frame subclass)
										in event 'trigger ; events put in triggered events
										object? event/frame
										;event/marble  ; who initiated the overlay
									][
										unless none? event/trigger [
											fill* window/aspects/block-input? true
										]
										set-overlay-trigger window event/trigger
										
										; set overlay
										window/overlay: event/frame/glob
										; link overlay back plane
										link* window/backplug event/frame/glob/layers/1
										none
									][
										event
									]
								]


								;----------------------------------
								;-                  -REMOVE-OVERLAY
								; this tells the window to do its overlay handling stuff.
								REMOVE-OVERLAY [
									vprint "Make sure the input blocker is removed"
									if content* window/aspects/block-input? [
										fill* window/aspects/block-input? false
									]
									if window/overlay [
										unlink*/only window/backplug window/overlay/layers/1
										window/overlay: none
									]
									
									
									event
								]


								;----------------------------------
								;-                  -CLOSE-WINDOW
								CLOSE-WINDOW [
									vprint "------------------->Window closed!"
									vprint window/aspects/label
									; the result of this action determines if we should close the window
									event/marble: window
									if do-event event [
										window/hide
									]
									none
								]


								;----------------------------------
								;-                  -WINDOW-POSITION
								WINDOW-POSITION [
									vprint "------------------->Window positioned!"
									vprint event/coordinates
									fill* window/aspects/offset event/coordinates
									
									event/marble: window
									do-event event
									
									; below is not currently required and because we receive hundreds of events,
									; it because a HUGE CPU hog.
									;
									; if you need to respond to window moves, link to window/aspects/offset.
									;show event/view-window
									none
								]
								

								
								;----------------------------------
								;-                  -WINDOW-RESIZED
								WINDOW-RESIZED [
									vprint "------------------->Window Resized!"
									vprint event/coordinates
									
									; we consume resize events.
									fill* window/material/dimension event/coordinates
									;window/view-face/effect: [draw []] 
									;show window/view-face
									;window/view-face/effect: reduce ['draw content* window/glob]
									;show window/view-face
									;window/view-face/effect: reduce ['draw  copy/deep content* window/glob]
									;show window/view-face
									
									
									;<TO DO>: resize and re-assign the bitmap we draw in
									
									; cause a refresh
									;event/action: 'REFRESH
									
									
									event/marble: window
									do-event event
									none
								]

							
								;----------------------------------
								;-                  -DEACTIVATE-WINDOW!
								DEACTIVATE-WINDOW! [
									; tells window to deactivate a window.. this isn't an event generate by view, 
									; but is a constructed event.  
									;
									; its actually a command, so we use the ! at the end of the event name (just for style).
									event/marble: window
									if data: do-event event [event/coordinates: data]
									event/view-window/changes: [deactivate]
									show event/view-window
									none
								]
							
							
								;----------------------------------
								;-                  -ACTIVATE-WINDOW!
								ACTIVATE-WINDOW! [
									; tells window to activate a window.. this isn't an event generate by view, 
									; but is a constructed event.  
									;
									; its actually a command, so we use the ! at the end of the event name (just for style).
									event/marble: window
									if data: do-event event [event/coordinates: data]
									event/view-window/changes: [activate]
									show event/view-window
									none
								]
							
							
								;----------------------------------
								;-                  -RESIZE-WINDOW!
								RESIZE-WINDOW! [
									; tells window to resize  window.. this isn't an event generate by view, 
									; but is a constructed event.  
									;
									; this event occurs BEFORE the actual resize occurs!
									;
									; if you return a pair! that is the offset which is really used.
									;
									; its actually a command, so we use the ! at the end of the event name (just for style).
									;
									; note that as a side-effect of this "event" a real 'resize event will be triggered by view.
									event/marble: window
									if pair? data: do-event event [event/coordinates: data]
									event/view-window/size: event/coordinates 
									event/view-window/changes: [size]
									show event/view-window
									none
								]
								
								
								;----------------------------------
								;-                  -MOVE-WINDOW!
								MOVE-WINDOW! [
									; tells stream to change window offset.. this isn't an event generate by view, 
									; but is a constructed event.  
									;
									; this event occurs BEFORE the actual resize occurs!
									;
									; if you return a pair! that is the offset which is really used.
									;
									; its actually a command, so we use the ! at the end of the event name (just for style).
									;
									; note that as a side-effect of this "event" a real 'window-resize event will be triggered by view.
									if pair? data: do-event event [event/coordinates: data]
									event/view-window/offset: event/coordinates
									event/view-window/changes: [offset]
									show event/view-window
									
									none
								]
							
							
							][
								vprint ["Window Unhandled: " event/action]
								; leave for next handler
								event
							]
							
							vout
							rval
						] window
					
				] ; end of event handler context
				;ask "!!"
				vout
			]
			
			;-----------------
			;-        fasten()
			;
			; we keep the core GLASS frame setup, but tweak it to match !window specifics
			;-----------------
			fasten: func [
				window
			][
				vin [{fasten()}]
				; our offset is a reflection of the actual window's screen position
				; so our position should not be related to it in any way
				unlink*/only window/material/position window/aspects/offset
				
				; the internal position of a window's frame is always 0x0
				; this could eventually be pluged to scroll bars
				fill* window/material/position 0x0
				
				; connect our backplane plug to the glob's backplane layer directly
				link*/reset window/backplug window/glob/layers/1
				vout
			]
			
			
		
		]
	]
]
