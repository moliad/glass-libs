REBOL [
	; -- Core Header attributes --
	title: "Glass button marble"
	file: %style-button.r
	version: 1.0.1
	date: 2014-6-4
	author: "Maxim Olivier-Adlhoch"
	purpose: "The core button style"
	web: http://www.revault.org/modules/style-button.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-button
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-button.r

	; -- Licensing details  --
	copyright: "Copyright © 2014 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2014 Maxim Olivier-Adlhoch

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
			-License changed to Apache v2
		v1.0.1 - 2014-06-04
			-can now use 'auto-size in layout spec.
	}
	;-  \ history

	;-  / documentation
	documentation: {
		The basic button style.
		
		Its very quickly hacked up but it works.
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'style-button
;
;--------------------------------------

slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	
	marble-lib: slim/open 'marble none
	event-lib: slim/open/expose 'event none [clone-event dispatch]
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
		dirty*: dirty
		attach*: attach
	]
	
	
	sillica-lib: slim/open/expose 'sillica none [
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
		prim-drop-shadow
		top-half
		bottom-half
		do-action 
		do-event
		clip-to-marble	
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]

	

	;--------------------------------------------------------
	;-   
	;- !BUTTON[ ]
	!button: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
			
			;-        focused?:
			; some buttons can be highlighted (ex: ok/cancel in requestors)
			focused?: false
			
			;-        selected?:
			selected?: false
			
			;-        label:
			label: "button"
			
			;-        color:
			color: theme-knob-color

			;-        border-color:
			border-color: theme-knob-border-color

			;-        label-color:
			label-color: black
			
			;-        font
			font: theme-knob-font
			
			;-        hidden?
			hidden?: false
			
			;-        inert?:
			;
			; when true, the button becomes dead, and its text is shaded.
			inert?: false
			
			;-        corner
			corner: 3
		]

		
		;-    Material[]
		material: make material []
		
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'button  
			
			
			;-        label-font:
			; font used by the gel.
			;label-font: theme-knob-font
			
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
						border-color !color (random white)
						label-color !color  (random white)
						label !string ("")
						focused? !bool
						hover? !bool
						selected? !bool
						align !word
						padding !pair
						font !any
						hidden? !bool
						inert? !bool
						corner !integer
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension hidden?
						[
							(
								either data/hidden?= [
									[]
								][
									compose [
										pen none 
										fill-pen (to-color gel/glob/marble/sid) 
										box (data/position=) (data/position= + data/dimension= - 1x1)
									]
								]
							)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension corner color border-color label-color label align hover? focused? selected? inert? padding font hidden?
						[
							(
								either data/hidden?= [
									[]
								][
									;print [ data/label= ": " data/label-color= data/color=]
									;draw bg and highlight border?
									any [
										
									
										all [ data/hover?= data/selected?= compose [
												; bg color
												pen none
												;line-width 0
												fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
												box (data/position= + 1x1) (data/position= + data/dimension= - 1x1) (data/corner= - 1)
		
												; shine
												pen none
												fill-pen (data/color= * 0.7 + 140.140.140.128)
												box ( top-half  data/position= data/dimension= ) (data/corner= - 1)
												
												;inner shadow
												pen shadow ; 0.0.0.50
												line-width 2
												fill-pen none
												box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) (data/corner= - 1)
		
												pen none
												line-width 0
												fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
												box (pos: (data/position= + (data/dimension= * 0x1) - -2x10)) (data/position= + data/dimension= - 2x1) (data/corner= - 1)
		
												; border
												fill-pen none
												line-width 1
												pen  (data/border-color=)
												box (data/position= ) (data/position= + data/dimension= - 1x1) (data/corner= )
	
												line-width 1
												pen none
												fill-pen (theme-glass-color + 0.0.0.175)
												;pen theme-knob-border-color
												box (data/position= + 3x3) (data/position= + data/dimension= - 3x3) 2
	
											]
										]
										
										; default
										compose [
											(
;												prim-knob 
;													data/position= 
;													data/dimension= - 1x1
;													data/color=
;													theme-knob-border-color
;													'horizontal ;data/orientation=
;													2
;													(data/corner= )
											)
											fill-pen (data/color=)
											pen (data/border-color=)
											line-width 1
											box (data/position= ) (data/position= + data/dimension= - 1x1) (data/corner= )
										]
									]
								]
							)
							(
							;------------------------
							; hover highlight
							either all [
								data/hover?=
								not data/selected?=
								not data/hidden?=
							][
								compose [
									(
;										prim-knob 
;											data/position= 
;											data/dimension= - 1x1
;											data/color=
;											theme-knob-border-color
;											'horizontal ;data/orientation=
;											4
;											(data/corner= )
													
									)
									line-width 1
									pen none
									fill-pen (
										;--------
										; if the color was manually changed... 
										; set its bg to that color, instead of pure white.
										;---
										either data/color= <> theme-knob-color [
											data/color=
										][
											white
										]
									)
									box (data/position=) (data/position= + data/dimension= - 1x1 ) (data/corner=)
									fill-pen (theme-glass-color + 0.0.0.175)
									pen (
										(theme-glass-color + 0.0.0.175)
									) 
									box (data/position=) (data/position= + data/dimension= - 1x1 ) (data/corner=)
									(prim-drop-shadow data/position=  data/dimension= - 1x1   data/corner= )
									
									
;									line-width 2
;									fill-pen none
;									pen (data/color=)
;									box (data/position= + 3x3 ) (data/position= + data/dimension= - 1x1 - 3x3 ) (max 0 data/corner= - 1)
								]
							][[]]
							)
							
							line-width 2
							pen none ;(data/label-color=)
							fill-pen (data/label-color=)
							; label
							(
							either data/hidden?= [
								[]
							][
								prim-label/pad data/label= data/position= + 1x0 data/dimension= (either data/inert?= [ data/label-color= / 2 + gray ][data/label-color=]) data/font= data/align=  data/padding=
							]
							)
							
							
							
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
			;-        button-handler()
			;
			; a basic button event handler. no frills, just simple and concisce.
			;-----------------
			button-handler: funcl [
				event [object!]
				/local button evt
			][
				vin [{HANDLE BUTTON}]
				vprint event/action
				button: event/marble
				
				
				if content* event/marble/aspects/inert? [
					;-----
					; when inert, we simply cancel all interaction.
					vout
					return none
				]
				
				; set this to an event so that the event is re-queued
				action-event: event
				
				switch event/action [
					start-hover [
						clip-to-marble button event/viewport
						fill* button/aspects/hover? true
					]
					
					end-hover [
						clip-to-marble button event/viewport
						fill* button/aspects/hover? false
					]
					
					select [
						fill* button/aspects/selected? true
						clip-to-marble button event/viewport
					]
					
					; successfull click
					; this causes an action event
					;
					; if fact, it may potentially cause two marble event actions to trigger.
					release [
						fill* button/aspects/selected? false
						if content button/aspects/hidden? [
							vprint "HIDDEN BUTTON, ignores select!!!"
							vout
							return none
						]
						clip-to-marble event/marble event/viewport
						do-event event
						do-action event
						action-event: none
					]
					
					; canceled mouse release event
					drop no-drop [
						fill* button/aspects/selected? false
						event
					]
					
					swipe [
						fill* button/aspects/hover? true
						event
					]
				
					drop? [
						fill* button/aspects/hover? false
						event
					]
				
					focus [
;						event/marble/label-backup: copy content* event/marble/aspects/label
;						if pair? event/coordinates [
;							set-cursor-from-coordinates event/marble event/coordinates false
;						]
;						fill* event/marble/aspects/focused? true
						event
					]
					
					unfocus [
;						event/marble/label-backup: none
;						fill* event/marble/aspects/focused? falssoure
						event
					]
					
					;text-entry [
					;	type event
					;	event
					;]
					
					action [
						;print  ":!!!!!!!!!!!!!!!!!!!!"
						;do-action event
						event
					]
				]
				
				if action-event [
					; totally configurable end-user event handling.
					; not all actions are implemented in the actions, but this allows the user to 
					; add his own events AND his own actions and still work within the API.
					do-event action-event
				]
				
				
;				if return-event [
;					help return-event
;					vprint return-event/action
;				]
				vout
				
				none
			]
			
						

			;-----------------
			;-        specify()
			;
			; parse a specification block during initial layout operation
			;
			; can also be used at run-time to set values in the aspects block directly by the application.
			;
			; but be carefull, as some attributes are very heavy to use like frame sub-marbles, which will 
			; effectively trash their content and rebuild the content again, if used blindly, with the 
			; same spec block over and over.
			;
			; the marble we return IS THE MARBLE USED IN THE LAYOUT
			;
			; so the the spec block can be used to do many wild things, even change the 
			; marble type or instance on the fly!!
			;
			; we now call the dialect() function which allows one to reuse the internal specify
			; dialect directly.
			;
			; dialect will simply be called after specify is done.
			;-----------------
			specify: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				;/local data pair-count tuple-count tmp
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/specify()}]
				
				pair-count: 0
				tuple-count: 0
				blk-count: 0
				parse spec [
					any [
						copy data ['with block!] (
							;print "SPECIFIED A WITH BLOCK"
							;marble: make marble data/2
							;liquid-lib/reindex-plug marble
							do bind/copy data/2 marble 
							
						) 
						
						| 'stiff (
							fill* marble/material/fill-weight 0x0
						) 
						
						| 'stretch set data pair! (
							fill* marble/material/fill-weight data
						) 
						
						| 'left (
							fill* marble/aspects/align 'WEST
						) 
						
						| 'right (
							fill* marble/aspects/align 'EAST
						) 
						
						| 'padding set data [pair! | integer!] (
							fill* marble/aspects/padding 1x1 * data
						) 
						
						| 'auto-size (
							marble: make marble [label-auto-resize-aspect: 'automatic]
						)
						
						
						;-----
						; attach a plug to ourself (keeping our value, if any).
						;
						; the net result is that he and we will be using OUR pipe server
						;-----
						| 'attach set client [object! | word!] (
							if word? client [client: get client]
							if liquid-lib/plug? client [
								aspect: marble/valve/get-default-aspect marble
								
								;----
								; get the aspect's current data, so we can put it back
								value-backup: content aspect
								
								attach* client aspect
								
								; sometimes, attaching clears the data, 
								; filling it up ensures it stays there and also generates a dirty propagation!
								fill aspect value-backup
							]
						) 
						
						;-----
						; attach ourself to another plug (keeping its data, if any).
						;
						; the net result is that he and we will be using ITS pipe server
						;-----
						| 'attach-to set pipe [object! | word!] (
							if word? pipe [pipe: get pipe]
							
							if liquid-lib/plug? pipe [
								aspect: marble/valve/get-default-aspect marble

								value-backup: content pipe
								attach* aspect pipe
								
								fill pipe value-backup
								
							]
						)
						
						| set data integer! (
							sz: content* marble/material/min-dimension
							sz/x: data
							fill* marble/material/min-dimension sz
						) 
						
						| set data tuple! (
							tuple-count: tuple-count + 1
							switch tuple-count [
								1 [set-aspect marble 'label-color data]
								2 [set-aspect marble 'color data]
							]
							
						) 
						
						| set data pair! (
							pair-count: pair-count + 1
							switch pair-count [
								1 [	fill* marble/material/min-dimension data ]
								2 [	fill* marble/aspects/offset data ]
							]
						) 
						
						| set data string! (
							set-aspect marble 'label data
						) 
						
						| set data block! (
							blk-count: blk-count + 1
							; an action (by default)
							if object? get in marble 'actions [
								switch blk-count [
									1 [
										marble/actions: make marble/actions [action: make function! [event] bind/copy data marble]
									]
									
									2 [
										marble/actions: make marble/actions [alt-action: make function! [event] bind/copy data marble]
									]
								]
							]
						) 
						
						| skip 
					]
				]
				
				; give custom marbles, a chance to setup their own dialect or alter this one.
				marble/valve/dialect marble spec stylesheet
				
				vout
				;ask ""
				marble
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
				
				; just a quick stream handler for all marbles
				event-lib/handle-stream/within 'button-handler :button-handler marble
				vout
			]
		]
	]
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

