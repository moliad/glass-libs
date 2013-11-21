REBOL [
	; -- Core Header attributes --
	title: "Control Vertice style"
	file: %style-cv.r
	version: 1.0.0
	date: 2013-11-20
	author: "Maxim Olivier-Adlhoch"
	purpose: {Provides interactive controls to any liquid network or glass marble.}
	web: http://www.revault.org/modules/style-cv.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-cv
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-cv.r

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
		v1.0.0 - 2013-11-20
			-first release of style
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Control vertice, use it to plug coordinates in other styles.
	}
	;-  \ documentation
]





;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'style-cv
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
	;- !CV[ ]
	!cv: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
			;-        focused?:
			; some cvs can be highlighted (ex: ok/cancel in requestors)
			focused?: false
			
			;-        pressed?:
			selected?: false
			
			;-        label:
			label: "cv"
			
			;-        color:
			color: theme-knob-color

			;-        label-color:
			label-color: black
			
			;-        font
			font: theme-knob-font
			
			;-        hidden?
			hidden?: false
			
			;-        scale:
			scale: 1.0
			
			;-        type:
			type: 'vertice
			
			;-        drag-delta:
			drag-delta: 0x0
			
			;--------------------------
			;-             ghost?:
			;
			; the input handler sets this to true while dragging, in order to disable the 
			; cv from the backplane
			;--------------------------
			ghost?: false
		]

		
		;-    Material[]
		material: make material [
			
		]
		
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'cv  
			
			
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
						
						ghost? !bool (false)
						drag-delta !pair
						type !word
						scale !decimal
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension type scale ghost? drag-delta
						[
							(
							either not data/ghost?= [
								switch data/type= [
									vertice [
										compose [
											line-width 5
											fill-pen (to-color gel/glob/marble/sid)
											line-pattern none
											;pen      (to-color gel/glob/marble/sid) 
											pen none
											
											circle (data/position=) (9 * data/scale=)
										]
									]
									crosshair [ 
										compose [
											line-width 5
											fill-pen (to-color gel/glob/marble/sid)
											pen      (to-color gel/glob/marble/sid) 
											line (data/position= - (data/scale= * 10x0)) (data/position= + (data/scale= * 10x0) ) 
											line (data/position= - (data/scale= * 0x10)) (data/position= + (data/scale= * 0x10) ) 
										]
									]
								]
							][
								; return nothing
								[]
							])
						]
						

		
		
;						;-        -graphics
;						[]
						
						;-        -overlay
						position hidden? type scale color hover? drag-delta selected?
						[
							(
							; hide CV when dragging around
							if data/drag-delta= <> 0x0 [data/hidden?=: false]
							
							either not data/hidden?= [
								tmp-offset: data/position= + data/drag-delta= 
								tmp-color: data/color= 
								tmp-in-color: tmp-color
								tmp-arc-off: 115
								either data/hover?= [
									out-radius: 10
									in-radius: 4
									tmp-color: (theme-glass-color + 0.0.0.200)
									unless data/selected?= [
										tmp-in-color: tmp-in-color + 100.100.100
									]
								][
									out-radius: 10
									in-radius: 4
								]
								if data/selected?=[
									tmp-arc-off: 295
									tmp-in-color: tmp-color - 100.100.100
									in-radius: 4
								]
			
								switch data/type= [
									vertice [
										compose [
											fill-pen (tmp-color)
											pen black
											line-width 1
											line-width 1
											pen white
											
											;line (1x1 + tmp-offset - (data/scale= * 8x0)) (1x1 + tmp-offset + (data/scale= * 8x0) ) 
											;line (1x1 + tmp-offset - (data/scale= * 0x8)) (1x1 + tmp-offset + (data/scale= * 0x8) )
											
											line-width 1.5
											pen black
											
											;line (tmp-offset - (data/scale= * 8x0)) (tmp-offset + (data/scale= * 8x0) ) 
											;line (tmp-offset - (data/scale= * 0x8)) (tmp-offset + (data/scale= * 0x8) )
											
											line-width 1
											circle (tmp-offset) (out-radius * data/scale=)
											pen (tmp-color * .3)
											fill-pen (tmp-in-color)
											line-width 1.5 
											circle (tmp-offset) (in-radius * data/scale=)
											pen white (tmp-color + 200.200.200)
											arc (tmp-offset) (in-radius * data/scale= * 1x1) (tmp-arc-off) 180
										]
									]
									crosshair [ 
										compose [
											line (tmp-offset - (data/scale= * 10x0)) (tmp-offset + (data/scale= * 10x0) ) 
											line (tmp-offset - (data/scale= * 0x10)) (tmp-offset + (data/scale= * 0x10) ) 
										]
									]
								]
							][
								; object is invisible while dragging!
								[]
							])
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
			;-        cv-handler()
			;
			; a basic cv event handler. no frills, just simple and concisce.
			;-----------------
			cv-handler: funcl [
				event [object!]
			][
				vin [{HANDLE CV}]
				vprint event/action
				cv: event/marble


				;slim/vdump/ignore event [object!]

				
				; set this to an event so that the event is re-queued
				action-event: event
				
				switch/default event/action [
					start-hover [
						clip-to-marble event/marble event/viewport
						fill* cv/aspects/hover? true
					]
					
					end-hover [
						clip-to-marble event/marble event/viewport
						fill* cv/aspects/hover? false
					]
					
					select [
					
						fill* cv/aspects/selected? true
						clip-to-marble event/marble event/viewport
						fill* cv/aspects/ghost? true
						fill* cv/aspects/offset content cv/aspects/offset
					]
					
					pre-release [
						; update the layout metrics of the cv, before letting go,
						; or else the engine will lookup the backplane at its previous
						; (pre-drag) coordinates.
						offset: content cv/aspects/offset
						fill cv/aspects/offset offset + event/drag-delta
						fill* cv/aspects/drag-delta  0x0
						fill* cv/aspects/ghost? false
						
					]
					
					
					; successfull click
					; this causes an action event
					;
					; if fact, it may potentially cause two marble event actions to trigger.
					release drop no-drop [
						vprobe "RELEASE!"
						fill* cv/aspects/selected? false
						if content cv/aspects/hidden? [
							;vprint "HIDDEN CV, ignores select!!!"
							vout
							return none
						]
						
						
						clip-to-marble event/marble event/viewport
						
						do-event event
						do-action event
						
						
						action-event: none
						
					]
					
;					; canceled mouse release event
;					drop no-drop [
;						fill* cv/aspects/selected? false
;						
;						offset: content cv/aspects/offset
;						fill cv/aspects/offset offset + event/drag-delta
;						fill* cv/aspects/drag-delta  0x0
;					
;						event
;					]

					swipe [
						vprobe content cv/aspects/ghost?
					]
					
					drop? [
						fill* cv/aspects/drag-delta event/drag-delta
						if event/drag-drop-candidate [
							vprobe event/drag-drop-candidate/valve/style-name
						]
						
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
					;vprint "IGNORED"
					action-event: event
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
			
			
			
			;--------------------------
			;-             dialect()
			;--------------------------
			; purpose:  
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    
			;
			; tests:    
			;--------------------------
			dialect: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				/local data img-count icon
			][
				vin [{dialect()}]
				vprint "YAY"
				
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
				event-lib/handle-stream/within 'cv-handler :cv-handler marble
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

