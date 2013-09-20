REBOL [
	; -- Core Header attributes --
	title: "Glass popup base marble style"
	file: %popup.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {POPUP base class which assigns an overlay and enables input blocker whenever its triggered.}
	web: http://www.revault.org/modules/popup.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'popup
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/popup.r

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
		v1.0.0 - 2013-09-17
			-License change to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		The popup is a base class which allows you to (more) easily build "floating"
		layouts which are meant to be modal.
		
		Popups usually block input on the window in which they are invoked and currently are
		mutually exclusive.
		
		This is a very hastily assembled style and is subject to major reworking, as the overlay
		system is improved.  one of the things which will most definitely change is the
		mutual exclusion.  At some point the overlay engine will allow a stacking of overlays, 
		and the popup will take full benefit from this.

		There are a few additional functions and attributes which I can think of adding to improve the
		popup's usefullness, especially wrt window edge detection.
		
		Note that your popup's layout may be stacked (like hierarchical drop-down menues), its 
		just that you may only have one	popup-based marble visible at a time in a window.
		
		Its also possible that some of the attribute naming will be uniformitized with other GLASS 
		base classes such as the group, since they share some functionality.
		
		so With this in mind, know that any custom popup derivative will probably require 
		refurbishing in a future version of GLASS.
	}
	;-  \ documentation
]




;- SLIM/REGISTER
slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	marble-lib: slim/open 'marble none
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		[liquify* liquify ] 
		[content* content] 
		[fill* fill] 
		[link* link] 
		[unlink* unlink] 
		[dirty* dirty]
	]
	
	sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		prim-knob
		top-half
		bottom-half
		do-event
		do-action
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	event-lib: slim/open 'event none
	frame-lib: slim/open 'frame none
	

	;--------------------------------------------------------
	;-   
	;- !POPUP[ ]
	!popup: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
			
			;-        focused?:
			; some popups can be highlighted (ex: ok/cancel in requestors)
			focused?: false
			
			;-        pressed?:
			selected?: false
			
		
			;-        label:
			label: "popup"
			
			
			;-        color:
			color: theme-knob-color


			;-        label-color:
			label-color: black
			
			
		]

		
		;-    Material[]
		material: make material [
		
			;-        popped-up?:
			; (read only)
			;
			; will be managed by events, cannot be used as a switch to activate the overlay.
			;
			; this is mainly used for our glob's gel spec or other tricks which require to react
			; to popup state changing (maybe another marble wants to reflect the popup state).
			;
			; use reveal() to setup the popup within the overlay
			; use conceal() to remove it from the overlay
			popped-up?: none
			
			
		]
		
		
		
		;-    overlay-glob:
		;
		; this stores the liquified and faceted glob which will be used in the overlay.
		;
		; each instance, MUST have its own private copy of this glob, which is usually linked 
		; in position (at least) to its popup aspects/material.
		;
		; you are totally free to implement this glob as you wish (as long at it can be used in
		; glass as an interface element normally).
		overlay-glob: none
		
		
		;-    overlay-scroll-frame:
		;
		; we only create the scrollframe on demand.
		overlay-scroll-frame: none
		
		;-    max-size:
		max-size: 20000x20000
		
		
		
		;-    valve[ ]
		valve: make valve [
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'popup  
			
			
			;-        label-font:
			; font used by the gel.
			label-font: theme-knob-font
			


			;-        overlay-glob-class:
			;
			; this attribute is special in that if its a block, we'll call a layout on it
			; as part of the default materialize setup.
			;
			; if its a marble, it just liquifies it directly, if it's none, you are
			; expected to build your overlay manually within materialize.
			;
			overlay-glob-class: [column [button "pop!"]]



			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				pos: none
				
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						label-color !color  (random white)
						label !string ("")
						focused? !bool
						hover? !bool
						selected? !bool
						popped-up? !bool ; if true, means that overlay is active.
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension 
						[
							line-width 1 
							pen none 
							fill-pen (to-color gel/glob/marble/sid) 
							box (data/position=) (data/position= + data/dimension= - 1x1)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color label-color label hover? focused? selected?
						[
							; this is a simple base class... it isn't meant to be used as-is,
							; but this default gel-spec can be used by many pop-ups anyways.
							(
								prim-knob 
									data/position= 
									data/dimension= - 1x1
									none
									theme-knob-border-color
									'horizontal ;data/orientation=
									1
									6
							)
							
							
							line-width 0.5
							pen (data/label-color=)
							fill-pen (data/label-color=)
							; label
							(prim-label data/label= data/position= + 1x0 data/dimension= data/label-color= none 'center)
							
							
							
						]
							
						; controls layer
						;[]
						
						; overlay layer
						; like the bg, it may switched off, so don't depend on it.
						;[]
					]
				]
			]
			
			
			
			;-----------------
			;-        reveal()
			;
			; signals glass to put our popup glob in the overlay
			;
			; note that the overlay is managed via the stream, not function calls.
			;
			; the main reason is that someone in the event stream may want to react to
			; overlay being shown or hidden.
			;
			; one example is the window even-handler which triggers events differently  
			; based on an overlay being live or not.
			;
			; because the stream is a system which any marble may link itself into
			; they can react based on this information.
			;
			; another reason is that as a marble, we have no clue as to who or what
			; manages an overlay... all we know is that someone will pick it up.
			;
			; this forces popup use to be explicitely managed by glass, and not by some
			; stray user-built hack which won't remain future proof.
			;
			; currently, there is no explicit control as to where the popup appears, 
			; but that will change at some point.
			;
			; also, window bounds checking might eventually be enabled directly by the
			; reveal function,  displacing and/or resizing the popup based on if it fits
			; within the window or not.
			;
			; also, some functions will be built which allow a popup marble to perform
			; window bounds management manually, possibly switching between different 
			; setups based on size constraints.
			;-----------------
			reveal: func [
				popup [object!] "marble which wants to reveal its popup"
				event [object!]
				/local win-size pop-size pop-pos sf
			][
				vin [{glass/popup/reveal()}]
				if object? popup/overlay-glob [
					vprint "READY TO POP!"
					; verify out of bounds
					pop-size: content* popup/overlay-glob/material/dimension
					win-size: content* event/viewport/material/dimension
					pop-pos: event-lib/offset-to-coordinates popup 0x0
					v?? win-size
					v?? pop-size
					v?? pop-pos
					
					either all [
						pop-size/y < win-size/y
						pop-size/y < popup/max-size/y
					][
						; make sure we discard ourself from scrollframe.
						
						vprint "--->"
						if object? popup/overlay-glob/frame [
							print "UNLINK FROM SCROLLFRAME!"
							popup/overlay-glob/frame/valve/gl-discard popup/overlay-glob/frame popup/overlay-glob
						]
						
						vprobe type? popup/overlay-glob/frame
						if (pop-pos/y + pop-size/y) > win-size/y [
							pop-pos/y: win-size/y - pop-size/y
						]
						if (pop-pos/x + pop-size/x) > win-size/x [
							pop-pos/x: win-size/x - pop-size/x - 5
						]

						; set popup position
						fill* popup/overlay-glob/material/position pop-pos
						fill* popup/overlay-glob/material/dimension pop-size
						
						event-lib/queue-event make event [
							action: 'add-overlay
							; the glob we want to overlay
							frame: popup/overlay-glob
							
							; the event to trigger when input-blocker is clicked on.
							; note if this is none, input-blocker is not enabled.
							;
							; if set to 'remove  then the trigger is the default, which
							; simply removes the overlay and disables input-blocker.
							trigger: 'remove
							
						]					
					][
						;-------------------------------------------------------------------
						;-------------------------------------------------------------------
						;-------------------------------------------------------------------
						; window doesn't properly fit popup in display!
						vprint "WINDOW TOO SMALL!"
						
						popup/overlay-scroll-frame: sl/layout/within/options [
								scroll-frame tight [
									sf: column tight [
									]
								]
						] 'column [0.0.0.128 2x2]
						
						
						sf/valve/gl-collect sf popup/overlay-glob
						
						fill* popup/overlay-glob/aspects/offset 0x0
						fill* popup/overlay-glob/material/border-size 0x0
						
						
						sf/valve/gl-fasten sf
;						
						popup/overlay-scroll-frame/valve/gl-fasten popup/overlay-scroll-frame
						
						pop-size/y: min pop-size/y popup/max-size/y
						
						if pop-size/y > win-size/y [
							pop-pos/y: 5
							pop-size/y: win-size/y - 10
						]
						
						pop-size/x: pop-size/x + 25
						
						if (pop-pos/y + pop-size/y) > win-size/y [
							pop-pos/y: win-size/y - pop-size/y
						]
					
						
						if (pop-pos/x + pop-size/x) > win-size/x [
							pop-pos/x: win-size/x - pop-size/x - 5
						]
						
						fill* popup/overlay-scroll-frame/material/position pop-pos
						fill* popup/overlay-scroll-frame/material/dimension pop-size

						event-lib/queue-event make event [
							action: 'add-overlay
							; the glob we want to overlay
							frame: popup/overlay-scroll-frame
							
							; the event to trigger when input-blocker is clicked on.
							; note if this is none, input-blocker is not enabled.
							;
							; if set to 'remove  then the trigger is the default, which
							; simply removes the overlay and disables input-blocker.
							trigger: 'remove
							
						]					
					]
				]
				vout
			]
			
			
			;-----------------
			;-        conceal()
			;
			; signals glass to remove our popup glob from the overlay
			;-----------------
			conceal: func [
				popup
			][
				vin [{glass/popup/conceal()}]
				vout
			]
			
			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				popup
				/local ovr-mtrl min-size
			][
				vin [{glass/popup/materialize()}]
				; create our overlay instance.
				switch/default type?/word popup/valve/overlay-glob-class [
					; for now, the only supported type.  eventually we will support marble classes directly.
					block! [
						popup/overlay-glob: sl/layout/within/options popup/valve/overlay-glob-class 'column [tight 0.0.255 0.0.255]
						ovr-mtrl: popup/overlay-glob/material
						;min-size: content* ovr-mtrl/dimension
						;ovr-mtrl/material/dimension: max min-size ((min-size * 0x1) + (second content* popup/))
						;link*/reset ovr-mtrl/position popup/material/position
						
						; will be filled by reveal()
						fill* ovr-mtrl/position 0x0
						
						link*/reset ovr-mtrl/dimension ovr-mtrl/min-dimension
					]
					
				][
					vprint ["warning: bad or no default overlay to setup in popup: " popup/valve/style-name]
				]
				vout
			]
			
			
			;-----------------
			;-        popup-handler()
			;
			;-----------------
			popup-handler: func [
				event [object!]
				/local popup
			][
				vin [{HANDLE POPUP}]
				vprint event/action
				popup: event/marble
				
				action-event: event
				
				switch/default event/action [
					start-hover [
						fill* popup/aspects/hover? true
					]
					
					end-hover [
						fill* popup/aspects/hover? false
					]
					
					select [
						fill* popup/aspects/selected? true
						
						; we call do-action BEFORE our handling, cause it might 
						; manipulate the overlay before we use it.
						do-event event
						
						action-event: none
						popup/valve/reveal popup event
						
						
					]
					
					; successfull click
					release [
						fill* popup/aspects/selected? false
					]
					
					; canceled mouse release event
					drop no-drop [
						fill* popup/aspects/selected? false
					]
					
					swipe [
						fill* popup/aspects/hover? true
					]
				
					drop? [
						fill* popup/aspects/hover? false
					]
				
					focus [
;						event/marble/label-backup: copy content* event/marble/aspects/label
;						if pair? event/coordinates [
;							set-cursor-from-coordinates event/marble event/coordinates false
;						]
;						fill* event/marble/aspects/focused? true
					]
					
					unfocus [
;						event/marble/label-backup: none
;						fill* event/marble/aspects/focused? false
					]
					
					text-entry [
;						type event
					]
				][
					vprint "IGNORED"
					action-event: none
				]
				
				; totally configurable end-user event handling.
				; not all actions are implemented in the actions, but this allows the user to 
				; add his own events AND his own actions and still work within the API.
				if action-event [
					do-event action-event
				]
				
				vout
				none
			]
			
						

			;-----------------
			;-        setup-style()
			;-----------------
			; a callback to extend anything in the marble AFTER Glass has finished with its own setup
			;
			; this is used by styles for their own custom data requirements.
			;
			; styles may also provide application setup hooks, but usually do so via extensions to the
			; the specification parser, using dialect()
			; 
			; some styles will also add default stream handlers (like viewports)
			;-----------------
			setup-style: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/stylize()}]
				
				event-lib/handle-stream/within 'popup-handler :popup-handler marble
				vout
			]
		]
	]
]
