REBOL [
	; -- Core Header attributes --
	title: "Glass scroller marble style"
	file: %style-scroller.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "Scroller style for GLASS."
	web: http://www.revault.org/modules/style-scroller.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-scroller
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-scroller.r

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
		The scroller is very practical since it has aspects for min/max/range & knob.
		
		when piped, the visible and value will adjust automatically to your input and will automatically
		set your input as well.
		
		orientation can be set manually or left to auto, in which case it will adjust to its frame
		and orient itelf to the opposite by default, which is usually what you need.
		
		The aspects aren't all connected to the visuals, since the theme is current in a rather locked state.
		
		That will all be fixed when the shader system is up and running.
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
		prim-recess
		prim-cavity
		top-half
		bottom-half
		do-event
		do-action
	]
	epoxy-lib: slim/open 'epoxy none
	event-lib: slim/open 'event none

	

	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;

	;--------------------------------------------------------
	;-   
	;- !SCROLLER[ ]
	!scroller: make marble-lib/!marble [
		;-    knob-selected-event:
		; when user selects the knob, we store its event, for reference while dragging
		knob-selected-event: none
		
		
		;-    stiff?:
		stiff?: none
		
	
		;-    Aspects[ ]
		aspects: context [
			offset: -1x-1
			
			;-        focused?:
			; some scrollers can be highlighted
			focused?: false
			
			;-        pressed?:
			selected?: false
			
			;-       hover?:
			hover?: none
	
			;-        color:
			color: white * .8


			;-        minimum:
			minimum: 1
			
			
			;-        maximum:
			maximum: 100
			
			
			;-        visible:
			visible: 5


			;-        size:
			size: 20x20
			

			;-        value:
			; the current value of the scroller within the range
			; if min or max are decimal, this will also be a decimal.
			; otherwise value will set itself to an integer
			;
			; the material has a plug called index, its piped with the value.
			; the value has a purify method which rounds the index to its own range type.
			value: 3
			
			
		]


	



		
		;-    Material[]
		material: make material [
		
			;-        knob-position:
			; offset of knob in pixels
			knob-position: 0x0
			
			
			;-        knob-offset:
			; the pixel offset of the knob.  this is bridged with the 
			; value aspect.
			;
			; note that the channel used is called: 'offset
			;
			; the aspects will use the 'value channel.
			;
			; this is materialized as a epoxy/offset-value-bridge plug.
			;
			; fasten will attach aspects/value to the pipe server, and link the min/max/dimension to appropriate plugs.
			knob-offset: none
			
			
			;-        scroll-space:
			; 
			; the available space which the scroller knob has for movement
			;
			; basically:  (dimension - knob-dimension)
			scroll-space: 0x0
			
			
			
			;-        scroll-range:
			; this is the maximum amount to return in scroll value.
			;
			; basically maximum - visible
			scroll-range: 1
			
			
			
			;-        knob-scale:
			; size of the knob along its orientation  
			knob-scale: 100x100
			
			
			;-        knob-dimension:
			; final calculated size of the knob in pixels 
			knob-dimension: 100x100
			
			
			
			;-        index:
			; like the value, but internal
			index: none
			
			
			
			;-        orientation:
			; in what orientation will the scroller work.
			; its in material, because the fasten call will set this depending on
			; parent frame, if its set to 'auto when fasten looks at it.
			orientation: 'auto
			
			
			
			;-        min-dimension
			min-dimension: 20x20
		]
		
		
		
		
			
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'scroller  
			
			
			
			
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
						;label-color !color  (random white)
						;label !string ("")
						focused? !bool
						hover? !bool
						selected? !bool
						knob-position !pair
						knob-dimension !pair ( 100x100)
						knob-position !pair (0x0)
						orientation !word
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
						position dimension color hover? focused? selected? knob-position knob-dimension orientation
						[
							
							; BG
							(
								prim-recess 
									data/position= 
									data/dimension= - 1x1
									theme-recess-color
									theme-border-color
									data/orientation=
							)
							(
								prim-cavity/colors
									data/position= 
									data/dimension= - 1x1
									none
									theme-border-color
							)
							
							
							; KNOB
							(
								prim-knob/grit 
									data/knob-position= + 1x1 
									data/knob-dimension= - 3x3
									none
									none ;theme-knob-border-color * 0.5
									data/orientation=
									max 0 (data/dimension=/y - data/knob-dimension=/y - data/knob-position=/y) + 10
									3
							)
							
							(
								either data/hover?= [
									compose [
										line-width 1
										fill-pen (theme-glass-color + 0.0.0.220)
										pen theme-knob-border-color
										pen none
										box (data/knob-position= + 3x3) (data/knob-position= + data/knob-dimension= - 3x3) 2
									]
								][[]]
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
			;-        scroller-HANDLER()
			;-----------------
			scroller-handler: func [
				event [object!]
				/local scroller kpos ksize kend action val
			][
				vin [{HANDLE SCROLLER}]
				vprint event/action
				scroller: event/marble
				
				switch/default event/action [
					start-hover [
						fill* scroller/aspects/hover? true
					]
					
					end-hover [
						fill* scroller/aspects/hover? false
					]
					
					hover [
						;prin "."
						
						kpos: content* scroller/material/knob-position 
						kpos: kpos - content* scroller/material/position
						ksize: content* scroller/material/knob-dimension
						kend: kpos + ksize
						either within? event/offset kpos ksize  [
							unless content* scroller/aspects/hover? [
								fill* scroller/aspects/hover? true
							]
						][
							if content* scroller/aspects/hover? [
								fill* scroller/aspects/hover? false
							]
						
						]
					]
					
					select [
						;print "scroller pressed"
						fill* scroller/aspects/selected? true
						;probe content* scroller/aspects/label
						;probe scroller/actions
						
						kpos: content* scroller/material/knob-position 
						kpos: kpos - content* scroller/material/position
						ksize: content* scroller/material/knob-dimension
						kend: kpos + ksize
						action: any [
							all [within? event/offset kpos ksize 'select-knob]
							all [event/offset/y < kpos/y 'select-pull]
							all [event/offset/y >= kend/y 'select-push]
						]
						switch action [
							select-knob [
								;print "CLICKED ON KNOB"
								scroller/knob-selected-event: make event [knob-offset-start: content* scroller/material/knob-offset]
							]
							
							select-pull [
								vprint "PULL KNOB UP" 
							
							]
							
							select-push [
								vprint "PULL KNOB DOWN"
							]
						]
						
						;do-event event
						;ask ""
					]
					
					; successfull click
					release [
						fill* scroller/aspects/selected? false
						scroller/knob-selected-event: none
						;do-action event
					]
					
					; canceled mouse release event
					drop no-drop [
						fill* scroller/aspects/selected? false
						;do-action event
					]
					
					swipe drop? [
						;fill* scroller/aspects/hover? true
						if scroller/knob-selected-event [
							;probe event/drag-delta
							;probe event/drag-start
							
							fill* scroller/material/knob-offset scroller/knob-selected-event/knob-offset-start + event/drag-delta
							do-action event
						]
					]
					
					scroll [
						val: content* scroller/aspects/value
						switch event/direction [
							push [
								fill* scroller/aspects/value val - 1
							]
							
							pull [
								fill* scroller/aspects/value val + 1
								
							]
						]
					]
;					drop? [
;						;fill* scroller/aspects/hover? false
;						;do-action event
;					]
				
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
			;-        freeze-backplane()
			;-----------------
			freeze-backplane: func [
				scroller
			][
				vin [{freeze-backplane()}]
				scroller/glob/layers/1/freeze scroller/glob/layers/1
				vout
			]
			
			
			;-----------------
			;-        thaw-backplane()
			;-----------------
			thaw-backplane: func [
				scroller
			][
				vin [{thaw-backplane()}]
				scroller/glob/layers/1/thaw scroller/glob/layers/1
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
				scroller
			][
				vin [{glass/!} uppercase to-string scroller/valve/style-name {[} scroller/sid {]/stylize()}]
				
				; just a quick stream handler for all scrollers
				event-lib/handle-stream/within 'scroller-handler :scroller-handler scroller
				vout
			]
			
			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				scroller
				/local ko mtrl
			][
				vin [{glass/!} uppercase to-string scroller/valve/style-name {[} scroller/sid {]/materialize()}]
				
				mtrl: scroller/material
				
				
				ko: mtrl/knob-offset: liquify* epoxy-lib/!offset-value-bridge
				ko/valve/fill/channel ko 0x33 'offset


				mtrl/knob-position: liquify* epoxy-lib/!pair-add
				
				mtrl/knob-dimension: liquify* epoxy-lib/!to-pair 
				mtrl/knob-scale: liquify* epoxy-lib/!range-scale

				
				mtrl/orientation: liquify*/fill !plug mtrl/orientation

				mtrl/scroll-space: liquify* epoxy-lib/!pair-subtract
				mtrl/scroll-range: liquify* epoxy-lib/!range-sub

				vout
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
				/local data img-count icon
			][
				vin [{dialect()}]
				img-count: 1
				
				parse spec [
					any [
						'stiff (
							marble/stiff?:  0x0
						)
						| skip
					]
				]

				vout
			]			



			
			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				scroller
				/local value mtrl aspects vertical? 
			][
				vin [{fasten()}]
								
				mtrl: scroller/material
				aspects: scroller/aspects
				
				;-----------
				; specify orientation based on frame, if its not explictely set.
				; note that because the orientation depends on fastening and that this isn't
				; a liquified process, the layout method is an attribute of the frame directly.
				if 'auto = content* mtrl/orientation [
					if in scroller/frame 'layout-method [
						if scroller/frame/layout-method = 'column [
							fill* mtrl/orientation 'horizontal
							;vertical?: false
						]
						if scroller/frame/layout-method = 'row [
							fill* mtrl/orientation 'vertical
							;vertical?: true
						]
					]
				]
				
				vertical?: 'vertical = content* mtrl/orientation

				
				; if orientation was set to 'auto
				fill* mtrl/fill-weight any [ scroller/stiff? either vertical? [0x1][1x0]]
					
				
				; setup knob size & related
				link* mtrl/knob-scale aspects/minimum
				link* mtrl/knob-scale aspects/maximum
				link* mtrl/knob-scale aspects/visible
				link* mtrl/knob-scale mtrl/dimension
				
				either vertical? [
					link* mtrl/knob-dimension mtrl/dimension
					link* mtrl/knob-dimension mtrl/knob-scale
				][
					link* mtrl/knob-dimension mtrl/knob-scale
					link* mtrl/knob-dimension mtrl/dimension
				]
				
				link* mtrl/scroll-space mtrl/dimension
				link* mtrl/scroll-space mtrl/knob-dimension
				
				link* mtrl/scroll-range aspects/maximum
				link* mtrl/scroll-range aspects/visible
				
				
				;------------
				; setup value & knob-offset BRIDGE
				value: aspects/value
				value/valve/attach/to value mtrl/knob-offset 'value
				
				value/valve/link/pipe-server value aspects/minimum
				value/valve/link/pipe-server value mtrl/scroll-range
				value/valve/link/pipe-server value mtrl/scroll-space
				value/valve/link/pipe-server value mtrl/orientation
				
				
				; setup knob position (knob offset + marble position)
				link* mtrl/knob-position mtrl/position 
				link* mtrl/knob-position mtrl/knob-offset 
				
				
				vout
			]
		]
	]
]
