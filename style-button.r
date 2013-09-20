REBOL [
	; -- Core Header attributes --
	title: "Glass button marble"
	file: %style-button.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "The core button style"
	web: http://www.revault.org/modules/style-button.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-button
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-button.r

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
			-License changed to Apache v2
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
			
			;-        pressed?:
			selected?: false
			
		
			;-        label:
			label: "button"
			
			
			;-        color:
			color: theme-knob-color


			;-        label-color:
			label-color: black
			
			
			;-        font
			font: theme-knob-font
			
			
			;-        hidden?
			hidden?: false
			
			
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
						label-color !color  (random white)
						label !string ("")
						focused? !bool
						hover? !bool
						selected? !bool
						align !word
						padding !pair
						font !any
						hidden? !bool
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
						position dimension color label-color label align hover? focused? selected? padding font hidden?
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
												line-width 0
												fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
												box (data/position= + 1x1) (data/position= + data/dimension= - 1x1) 2
		
												; shine
												pen none
												fill-pen (data/color= * 0.7 + 140.140.140.128)
												box ( top-half  data/position= data/dimension= ) 2
												
												;inner shadow
												pen shadow ; 0.0.0.50
												line-width 2
												fill-pen none
												box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) 2
		
												pen none
												line-width 0
												fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
												box (pos: (data/position= + (data/dimension= * 0x1) - -2x10)) (data/position= + data/dimension= - 2x1) 2
		
												; border
												fill-pen none
												line-width 1
												pen  theme-knob-border-color
												box (data/position= ) (data/position= + data/dimension= - 1x1) 3
	
	
											]
										]
										
										; default
										compose [
											(
												prim-knob 
													data/position= 
													data/dimension= - 1x1
													data/color=
													theme-knob-border-color
													'horizontal ;data/orientation=
													1
													4
											)
										]
									]
								]
							)
							(
							either all [
								data/hover?=
								not data/hidden?=
							][
								compose [
									line-width 1
									pen none
									fill-pen (theme-glass-color + 0.0.0.200)
									;pen theme-knob-border-color
									box (data/position= + 3x3) (data/position= + data/dimension= - 3x3) 2
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
								prim-label/pad data/label= data/position= + 1x0 data/dimension= data/label-color= data/font= data/align=  data/padding=
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
				
				
				; set this to an event so that the event is re-queued
				action-event: event
				
				switch/default event/action [
					start-hover [
						clip-to-marble event/marble event/viewport
						fill* button/aspects/hover? true
					]
					
					end-hover [
						clip-to-marble event/marble event/viewport
						fill* button/aspects/hover? false
					]
					
					select [
						fill* button/aspects/selected? true
						clip-to-marble event/marble event/viewport
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
					
					text-entry [
;						type event
						event
					]
					
					action [
						;print  ":!!!!!!!!!!!!!!!!!!!!"
						;do-action event
						event
					]
				][
					vprint "IGNORED"
					action-event: none
				]
				
				if action-event [
					; totally configurable end-user event handling.
					; not all actions are implemented in the actions, but this allows the user to 
					; add his own events AND his own trtueactions and still work within the API.
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

