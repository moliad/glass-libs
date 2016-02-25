REBOL [
	; -- Core Header attributes --
	title: "a resizing dragbar marble"
	file: %style-dragbar.r
	version: 1.0.0
	date: 2015-4-10
	author: "Maxim Olivier-Adlhoch"
	purpose: "The core button style"
	web: http://www.revault.org/modules/style-dragbar.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-dragbar
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-dragbar.r

	; -- Licensing details  --
	copyright: "Copyright © 2015 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2015 Maxim Olivier-Adlhoch

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
		place in between two frames and you will be able to resize them.
		
		by default the drag bar will stop when it tries to resize a sibling beyond its minimum size.
		
		if you place min-prev and min-next aspects, it will use those values to limit itself.
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

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     LIBS
	;
	;-----------------------------------------------------------------------------------------------------------

	glob-lib: slim/open/expose 'glob none [!glob to-color]
	marble-lib: slim/open 'marble none
	event-lib: slim/open/expose 'event none [clone-event dispatch]

	sillica-lib: slim/open/expose 'sillica none [
		do-event
		do-action 
		clip-to-marble	
	]

	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- !DRAGBAR
	;
	;-----------------------------------------------------------------------------------------------------------

	!dragbar: make marble-lib/!marble [
		
		;--------------------------
		;-     drag-start-adjust:
		;
		; stores where the user clicked on the control.
		;--------------------------
		drag-start-adjust: none
		
		
		
		;-     Aspects[ ]
		aspects: make aspects [
			;-         prev-min:
			prev-min: none  ; set this to an integer to limit dragging to a given amount.
			
			;-         next-min:
			next-min: none  ; set this to an integer to limit dragging to a given amount.
			
			;-         bar-width:
			bar-width: 10   ; will set the width of the bar in the proper axis based on Vertical or Horizontal property.
			
			;-         corner:
			corner: 2

			;-         color:
			color: none ; theme-bg-color
			;color: black

			;-         hi-color:
			hi-color:  theme-hi-color
			
			;--------------------------
			;-         freedom:
			;
			; in what axis can the drag bar move? (i.e. freedom of movement)
			;
			; sets how the bar will operate based on layout orientation.
			;
			; a 1x0 drag-bar will slide left and right, a 0x1 one will slide up and down.
			; 
			; a few things behave and are setup differently on init based on this value.
			;
			; this is why glaze collects two different styles. vbar and hbar
			;
			; when set to none, it is set automatically based on parent's group orientation.
			;--------------------------
			;freedom: 0x1
			freedom: none
			
		]
		
		
		;-     material[ ]
		material: make material [
			stretch: 0x0
			min-dimension: 10x-1 
			fill-weight: 1x1
		]

		;-     valve[ ]
		valve: make valve [
			type: '!marble
			style-name: 'marble  


			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair
						dimension !pair 
						color !color
						hi-color !color
						corner !integer
						hover? !bool
					]
					
					
					;---
					; declare gel variables
					rtclr: none
					
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension 
						[
							pen none 
							fill-pen (to-color gel/glob/marble/sid) 
							box (data/position=) (data/position= + data/dimension= - 1x1)
						]

						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color corner hi-color hover?
						[
							line-width 0
							fill-pen (  rtclr: either data/hover?= [data/hi-color=][data/color=] )
							line-width 1
							;pen  ( either data/hover?= [rtclr * .75 ][ none ]  ) 
							pen none
							box (data/position=) (data/position= + data/dimension= - 1x1) ( data/corner=)
							
						]
							
						; controls layer
						;[]
						
						; overlay layer
						; like the bg, it may switched off, so don't depend on it.
						;[]
					]
				]
			]
			
			




			;--------------------------
			;-         get-prev-sibling()
			;--------------------------
			; purpose:  
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    
			;
			; to do:    
			;
			; tests:    
			;--------------------------
			get-prev-sibling: funcl [
				bar [object!]
			][
				;vin "get-prev-sibling()"
				
				sibling: all [
					blk: find bar/frame/collection bar
					blk: back blk
					sibling: pick blk 1
					sibling <> bar
					sibling
				]
				
				;vout
				sibling
			]


			;--------------------------
			;-         get-next-sibling()
			;--------------------------
			; purpose:  
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    
			;
			; to do:    
			;
			; tests:    
			;--------------------------
			get-next-sibling: funcl [
				bar [object!]
			][
				;vin "get-next-sibling()"
				
				sibling: all [
					blk: find bar/frame/collection bar
					blk: next blk
					sibling: pick blk 1
					sibling <> bar
					sibling
				]
			
				;vout
				sibling
			]


			;-----------------
			;-         dragbar-handler()
			;-----------------
			dragbar-handler: funcl [
				event [object!]
			][
				bar: event/marble

				;vprint ["bar event: " event/action]
				
				action-event: event
				
				switch event/action [
					select [
						if sibling: get-prev-sibling bar [
							bar/drag-start-adjust: content sibling/aspects/dimension-adjust
						]
					]
				
					drop? drop drop-bg swipe release [
						all [
							in event 'drag-delta 
							sibling: get-prev-sibling bar
							freedom: content bar/aspects/freedom
							fill sibling/aspects/dimension-adjust (bar/drag-start-adjust + event/drag-delta * freedom)
						]
					]
				
;					start-hover: funcl [event] [
;						fill event/marble/aspects/color        theme-hi-color
;						fill event/marble/aspects/border-color theme-hi-color
;					]
					start-hover [
						clip-to-marble bar event/viewport
						fill bar/aspects/hover? true
					]
					
;					end-hover: funcl [event] [
;						fill event/marble/aspects/color        white
;						fill event/marble/aspects/border-color white
;					]
					end-hover [
						clip-to-marble bar event/viewport
						fill bar/aspects/hover? false
						vprint "off"
					]
				]
				
				if action-event [
					; totally configurable end-user event handling.
					; not all actions are implemented in the actions, but this allows the user to 
					; add his own events AND his own actions and still work within the API.
					do-event action-event
				]
				
				none
			]
			
			

			;-----------------
			;-         setup-style()
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
				vin [{glass/!dragbar/setup-style()}]
				
				; just a quick stream handler for all marbles
				event-lib/handle-stream/within 'dragbar-handler :dragbar-handler marble
				vout
			]

			;--------------------------
			;-         fasten()
			;--------------------------
			; purpose:  here we detect our parent's orientation and adapt.
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    
			;
			; to do:    
			;
			; tests:    
			;--------------------------
			fasten: funcl [
				bar
			][
				vin "fasten()"
				frame: bar/frame
				
				;vprobe type? frame
				if object? frame [
					;vprint "yay!"
					;vprobe frame/layout-method 
					switch/default frame/layout-method [
						row [
							fill bar/aspects/freedom 1x0
							fill bar/material/fill-weight 0x1
						]
						
						column [
							fill bar/aspects/freedom 0x1
							fill bar/material/fill-weight 1x0
						]
					][
						to-error "glass/!dragbar/fasten(): invalid parent frame for dragbar (must be a row or column type frame)"
					]
					
					;vprobe content bar/aspects/freedom
					
					;---
					; we will try to find the previous marble in the gui.
					
				]
				
				vout
			]
		]
		
	]
]