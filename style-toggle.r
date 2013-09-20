REBOL [
	; -- Core Header attributes --
	title: "Glass popup base marble style"
	file: %style-toggle.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "A toggle style for Glass."
	web: http://www.revault.org/modules/style-toggle.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-toggle
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-toggle.r

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
		The basic toggle button style.
		
		Its very quickly hacked up but it works.

		note that you can also use the icon style and turn it into an icon toggle.
	}
	;-  \ documentation
]



;- SLIM/REGISTER
slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	
	marble-lib: slim/open 'marble none
	button-lib: slim/open 'style-button none
	event-lib: slim/open 'event none
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		[liquify* liquify ] 
		[content* content] 
		[fill* fill] 
		[link* link] 
		[unlink* unlink] 
		[dirty* dirty]
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
		prim-knob
		top-half
		bottom-half
		do-event
		do-action
		clip-to-marble
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]

	

	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;

	;--------------------------------------------------------
	;-   
	;- !TOGGLE[ ]
	!toggle: make button-lib/!button [
	
		;-    Aspects[ ]
		aspects: make aspects [
			;--------------------------
			;-             engaged?:
			;
			; is the toggle locked to on
			;--------------------------
			engaged?: false
			
			
		]

		
		;-    Material[]
		material: make material []
		
		
		;-    radio-list:
		; when this is filled with a block containing other marbles,
		; they will automatically be switched to off when this one is set to on.
		radio-list: none
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'toggle  
			
			
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
						engaged? !bool
						align !word
						padding !pair
						font !any
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
						position dimension color label-color label align hover? engaged? focused? selected? padding font
						[
							(
								;draw bg and highlight border?
								any [
									all [
										data/engaged?= 
										compose [
										
											; bg color
											pen white
											fill-pen white
											line-width 1
											box (data/position=) (data/position= + data/dimension= - 1x1) 3
											
											;inner shadow
											pen (black + 0.0.0.55)
											line-width 2
											fill-pen none
											box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) 2
	
											pen none
											(sl/prim-glass/corners/only (data/position= + 1x2) (data/position= + data/dimension= - 1x1) theme-color 210 2)

											pen white
											fill-pen 0.0.0.210
											line-width 1
											box (data/position= ) (data/position= + data/dimension= - 1x1) 2
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
							)
							(
							either all [
								data/hover?=
								not data/engaged?=
							][
								
								compose	[
										line-width 2
										;pen white
										pen (white + 0.0.0.125)
										fill-pen (theme-color + 0.0.0.200)
										box (data/position= + 2x2) (data/position= + data/dimension= - 3x3) 2
								]
							][[]]
							)
							;---
							; label
							line-width 2
							pen none ;(data/label-color=)
							fill-pen (data/label-color=)
							(prim-label/pad data/label= data/position= + 1x0 data/dimension= data/label-color= data/font= data/align=  data/padding=)
							
							
							
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
			;-----------------
			button-handler: func [
				event [object!]
				/local button state marble
			][
				vin [{HANDLE TOGGLE}]
				vprint event/action
				button: event/marble
				
				switch/default event/action [
					start-hover [
						fill* button/aspects/hover? true
						clip-to-marble event/marble event/viewport
					]
					
					end-hover [
						clip-to-marble event/marble event/viewport
						fill* button/aspects/hover? false
					]
					
					select [
						vprint "button pressed"
						clip-to-marble event/marble event/viewport
						fill* button/aspects/selected? true
						vprobe content* button/aspects/label
						vprobe content* button/aspects/engaged?
						;probe button/actions
						;event/action: 'engage
						state: content* button/aspects/engaged?
						
						either block? button/radio-list [
							vprobe length? button/radio-list
							
							;- do nothing if the button is already engaged?
							unless content* button/aspects/engaged? [
								foreach marble button/radio-list [
									vprint type? marble
									either same? marble button [
										;print "Not"
										fill* button/aspects/engaged? not state
									][
										;print "same!"
										fill* marble/aspects/engaged? false
									]
									clip-to-marble marble event/viewport
								]
							]
						][
							fill*  button/aspects/engaged? not state
						]
						do-action event
						;ask ""
					]
					
					; successfull click
					release [
						fill* button/aspects/selected? false
						;do-action event
					]
					
					; canceled mouse release event
					drop no-drop [
						;fill* button/aspects/selected? false
						;do-action event
					]
					
					swipe [
						fill* button/aspects/hover? true
						;do-action event
					]
				
					drop? [
						fill* button/aspects/hover? false
						;do-action event
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
				]
				
				; totally configurable end-user event handling.
				; not all actions are implemented in the actions, but this allows the user to 
				; add his own events AND his own actions and still work within the API.
				do-event event
				
				vout
				none
			]


			;-----------------
			;-        dialect()
			;
			; this uses the exact same interface as specify but is meant for custom marbles to 
			; change the default dialect.
			;
			; note that the default dialect is still executed, so you may want to "undo" what
			; it has done previously.
			;
			;-----------------
			dialect: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
			][
				vin [{toggle/dialect()}]
				parse spec  [
					here:
					['on | 'true | #[true]] (
						fill* marble/aspects/engaged? true
					)
					| skip
				]
				
				vout
			]
			

			
			;-----------------
			;-        post-specify()
			;-----------------
			post-specify: func [
				toggle
				stylesheet
			][
				vin [{post-specify()}]
				if all [
					block? toggle/radio-list 
					not find toggle/radio-list toggle
				][
					append toggle/radio-list toggle
				]
				vout
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
