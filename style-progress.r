REBOL [
	; -- Core Header attributes --
	title: "Glass progress bar marble"
	file: %style-progress.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {Progress bar style which allows callbacks to automatically update the bar on processing.}
	web: http://www.revault.org/modules/style-progress.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-progress
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-progress.r

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
		v1.0.0 - 2013-09-18
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		Simple no non-sense progress-bar.
		
		When implementing a progress indicator within a process, be sure to use the gl/refresh function to
		force a refresh of the gui, or the user won't see it change  :-)
		
		also make sure not to refresh too often, or the GUI will actually slow down your loop. usually
		once every 5 to 10 percent is enough for the user to be reassured that your application
		isn't stalled or crashed.
		
		eventually we might add a little improvement where a refresh is automatically called 
		everytime the progress passes a certain amount.  This would make it simpler for people
		to use without caring for such details.
	}
	;-  \ documentation
]




slim/register [

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	slim/open/expose 'glob none [!glob to-color]
	slim/open/expose 'marble none [!marble]
	
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
		prim-recess
		prim-cavity
		prim-glass
		top-half
		bottom-half
		sub-box
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]

	

	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;

	;--------------------------------------------------------
	;-   
	;- !PROGRESS[ ]
	!progress: make !marble [
	

		;-    Aspects[ ]
		aspects: make aspects [
			
			;-        color:
			color: theme-glass-color


			;-        bg-color:
			bg-color: theme-progress-bg-color
			
			
			;-        minimum:
			minimum: 1
			
			
			;-        maximum:
			maximum: 10
			
			
			;-        progress:
			progress: 5


		]

		
		;-    Material[]
		material: make material [
			
			;-        orientation:
			; in what orientation will the progress work. 'vertical 'horizontal 'auto
			; if its set to 'auto, fasten() will set this depending on parent frame orientation.
			orientation: 'horizontal
			
			
			;-        min-dimension
			min-dimension: 20x20
		]
		
		
		
		
			
		
		;-    valve[ ]
		valve: make valve [
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'progress  
			
			
			
			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				end: none
				
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						bg-color !color
						minimum !integer
						maximum !integer
						progress !integer
						orientation !word
						label !string
						label-color  !color
						font !any
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						none ;position dimension 
						[
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension minimum maximum progress color bg-color orientation label label-color font
						[
							
							; BG
							(
								prim-recess 
									data/position= 
									data/dimension= - 1x1
									data/bg-color=
									theme-border-color
									data/orientation=
							)
							
							
							; BAR
							fill-pen white
							pen none
							(
								end: data/position= + sub-box/orientation data/dimension= - 2x2 data/minimum= data/maximum= data/progress= data/orientation=
								[]
							)
							(prim-glass/corners data/position= + 1x1  end  data/color=  theme-glass-transparency  2)
;							(prim-label data/position= + 1x1  end  data/color=  theme-glass-transparency  )
							
							line-width 1
							fill-pen none
							pen none
							(
								;probe data/label=
								;probe data/font=
								data/font=/size: 12
								prim-label data/label= data/position= + 1x0 data/dimension=  black  data/font= 'center  
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
				vin [{glass/!} uppercase to-string scroller/valve/style-name {[} scroller/sid {]/setup-style()}]
				
				; just a quick stream handler for all scrollers
				vout
			]
			
			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				scroller
			][
				vin [{glass/!} uppercase to-string scroller/valve/style-name {[} scroller/sid {]/materialize()}]
				scroller/material/orientation: liquify*/fill !plug scroller/material/orientation

				vout
			]
			
			
			
			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				scroller
				/local value mtrl aspects vertical? 
			][
				vin [{glass/!} uppercase to-string scroller/valve/style-name {[} scroller/sid {]/fasten()}]
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
							vertical?: false
						]
						if scroller/frame/layout-method = 'row [
							fill* mtrl/orientation 'vertical
							vertical?: true
						]
					]
				]
				
				; if orientation was set to 'auto
				if logic? vertical? [
					fill* mtrl/fill-weight either vertical? [0x1][1x0]
				]
					
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
				int-count: 1
				
				parse spec [
					any [
						set data number! (
							switch int-count [
								1 [
									fill marble/aspects/minimum data
									;print "min"
									int-count: int-count + 1
								]
								
								2 [
									fill marble/aspects/maximum data
									;print "max"
									int-count: int-count + 1
								]
								
								3 [
									fill marble/aspects/progress data
									;print "progress"
									int-count: int-count + 1
								]
							]
						)
						| set data tuple! (
							fill marble/aspects/color data
						)
						| skip
					]
				]

				vout
			]			
		]
	]
]
