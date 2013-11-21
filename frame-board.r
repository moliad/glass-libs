REBOL [
	; -- Core Header attributes --
	title: "board | manual layout frame"
	file: %frame-board.r
	version: 1.0.1
	date: 2013-11-20
	author: "Maxim Olivier-Adlhoch"
	purpose: {A frame which doesn't do layout so you can move things around manually.}
	web: http://www.revault.org/modules/frame-board.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'frame-board
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/frame-board.r

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
		v1.0.0 - 2013-11-05
			-created style
	
		v1.0.1 - 2013-11-20
			-fully functional style, uses updates to window style v1.2.6
	}
	;-  \ history

	;-  / documentation
	documentation: {        
		Use this frame when you need to control how things layout manually.
		
		Its great to provide desktop-style control for things such as panes or even single controls.
		
		Its the basis for things like node graphs and drawing canvases.
	}
	;-  \ documentation
]






;- SLIM/REGISTER
slim/register [


	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob]

	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
		detach*: detach
		process*: --process
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
	]
	epoxy-lib: slim/open/expose 'epoxy none [  !box-intersection  !pair-add  ]
	slim/open/expose 'fluid none [flow]

	
	slim/open/expose 'frame none [ !frame ]
	group-lib: slim/open 'group none
	
	slim/open/expose 'marble none [!marble]
	
	;--------------------------------------------------------
	;-   
	;- !BOARD[ ]
	!board: make !frame [
		;--------------------------
		;-    aspects[ ]
		;--------------------------
		aspects: make aspects [
			;--------------------------
			;-         offset:
			;
			; offset from our parent frame.  If the parent moves, we move too.
			;--------------------------
			offset: 0x0
			
		]
		
		
		;--------------------------
		;-    material[ ]
		;
		; ** ATTENTION **
		; ** we only inherit the basic marble! materials.  To allow our parent frame to layout us.
		;--------------------------
		material: make !marble/material [
			fill-weight: 1x1
			fill-accumulation: 0x0
			stretch: 0x0
		]

		
		;-    layout-method:
		layout-method: 'relative ; relative : Our children get our offset added to theirs
								 ; absolute : We do not play around with collection at all
		
		
		;--------------------------
		;-         collect-method:
		;
		; how do place new marbles in our collection ?
		;
		; maybe any of [ 'stack-right 'stack-down ]
		;--------------------------
		collect-method: none
		
		
		
		;-    valve []
		valve: make valve [

			type: '!marble


			;-        style-name:
			style-name: 'board
		

			;-        bg-glob-class:
			; no need for any globs.  just specification, materialization and fastening .
			bg-glob-class: none

			;-        bg-glob-class:
			; class used to allocate and link a glob drawn BEHIND the marble collection
			bg-glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair (random 200x200)
						dimension !pair (300x300)
						color !color
						frame-color  !color (random white)
						corner !integer
						; uncomment to debug
;						clip-region !block ([0x0 1000x1000])
;						min-dimension !pair
;						content-dimension !pair
;						content-min-dimension !pair
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						
						; FG LAYER
						position dimension color frame-color corner
						;------
						; uncomment following for debugging
						;
						;   min-dimension content-dimension content-min-dimension
						;------
						[
							; here we restore our parent's clip region  :-)
							;clip (data/parent-clip-region=)
							
							fill-pen (data/color=)
							pen (data/frame-color=)
							line-width 1
							box (data/position=) (data/position= + data/dimension= - 1x1) (data/corner=)
							;------
							; uncomment for debugging purposes.
							;	line-width 1
							;	pen blue 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/content-dimension=)
							;	pen red 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/dimension=)
							;	pen black 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/min-dimension=)
							;	pen white 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/content-min-dimension=)
							;------
						
						]
						
						
						; controls layer
						;[]
						
						
						; overlay 
						;[]
					]
				]
			]
			

			;-----------------
			;-        gl-materialize()
			;
			; see !marble for details
			;-----------------
			gl-materialize: func [
				frame [object!]
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-materialize()}]
				
				
				vout
			]



			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				frame
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/materialize()}]
				frame/material/position: liquify/fill !plug frame/material/position
				frame/material/dimension: liquify/fill !plug frame/material/dimension
				frame/material/min-dimension: liquify/fill !plug frame/material/min-dimension
				
				frame/material/fill-weight: liquify/fill !plug frame/material/fill-weight
				frame/material/fill-accumulation: liquify/fill !plug frame/material/fill-accumulation
				
				
;				flow [
;					/using frame/material
;					min-dimension: 
;				]
				vout
			]
			
			
			
			;-----------------
			;-        gl-fasten()
			;-----------------
			gl-fasten: funcl [
				board
				;/local mtrl aspects
			][
				vin [{glass/!} uppercase to-string board/valve/style-name {[} board/sid {]/gl-fasten()}]
				
				foreach marble board/collection [
					switch board/layout-method [
						relative [
							; collection follows this board if it moves.
							vprint "RELATIVE BOARD"
							
							; mutation!
							flow [
								/sharing <mrbl> marble/aspects
								/sharing <mrbl> marble/material
								/sharing  board/material
								/remodel mrbl.position !pair-add
								
								-| mrbl.position |-
								
								mrbl.position < [ mrbl.offset position ]
							]
						]
						
						absolute [
							; things are completely detached... there is no link between this board and its collection
							vprint "ABSOLUTE BOARD"
							
							flow [
								/using marble/aspects
								/sharing marble/material
								
								offset > position 
								size >  min-dimension  > dimension 
								mrbl.size: 200x40
							]
						]
					]
				]
				board/valve/fasten board
				vout
			]
			
			
			
			

			;-----------------
			;-        specify()
			;
			; parse a specification block during initial layout operation
			;
			; frames create new marble instances at specify time.
			; they are also responsible for calling layout setup operations providing any
			; environment which is required by new marbles
			;-----------------
			specify: func [
				frame [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				;/wrapper "this is a wrapper, call gl-fasten() accordingly"
				/local marble item pane data marbles set-word pair-count tuple-count
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/specify()}]
				;v?? spec
				
				stylesheet: any [stylesheet master-stylesheet]
				pair-count: 1
				tuple-count: 1
				
				parse spec [
					any [
						copy data ['with block!] (
							;print "SPECIFIED A WITH BLOCK"
							;frame: make frame data/2
							;liquid-lib/reindex-plug frame
							
							do bind/copy data/2 frame 
							
							
							;probe marble/actions
							;ask ""
						)  
						
						| 'absolute (
							frame/layout-method: 'absolute
						)
						
						| 'relative (
							frame/layout-method: 'relative
						)
						
						| 'corner set data integer! (
								fill* frame/aspects/corner data
						) 
						
						|'tight (
							frame/spacing-on-collect: 0x0
							if block? frame/collection [
								foreach marble frame/collection [
									fill* marble/aspects/offset 0x0
								]
							]
							;fill* frame/aspects/frame-color red
							fill* frame/material/border-size 0x0
						)
						
						| set data tuple! (
							switch tuple-count [
								1 [
									vprint "frame COLOR!" 
									vprint data
									fill* frame/aspects/frame-color data
								]
								
								2 [
									fill* frame/aspects/color data
								]
							]
							tuple-count: tuple-count + 1
						)
						
						| set data pair! (
							switch pair-count [
								1 [  
									print "min-dimension!" 
									probe type? frame
									fill* frame/material/min-dimension data
								]
								
								2 [
									;frame/spacing-on-collect: data
								]
							]
							pair-count: pair-count + 1
						
						)
						
						| set data block! (
							vprint "frame MARBLES!" 
							pane: regroup-specification data
							new-line/all pane true
							vprint "skipping inner pane attributes"
							pane: find pane block!
							
							if pane [
								
								; create & specify inner marbles
								foreach item pane [
									if set-word? set-word: pick item 1 [
										; store the word to set, then skip it.
										; after we use set on the returned marble.
										;print "SET WORD!"
										
										item: next item
									]
									either marble: alloc-marble/using first item next item stylesheet [
										marbles: any [marbles copy []]
										
										; set the frame, just so child gl-fasten, may use the frame to take
										; contextual decisions.
										append marbles marble
										marble/frame: frame
										
										marble/valve/gl-fasten marble
										
										if set-word? :set-word [
											set :set-word marble
										]
										
									][
										; because of specification's parsing, this code should never really be reached
										vprint ["ERROR creating new marble of type: " item " in frame!"]
									]
								]
								
								; add all children to our collection
								frame/valve/accumulate frame marbles
							]
							
							
							; take this frame and fasten it. (might be empty)
							; we remove this since it caused a double fastening of all frames!
							; it was instead added to the layout function directly.
							;frame/valve/gl-fasten frame
							
						)
						| skip 
					]
				]
				
				frame/valve/dialect frame spec stylesheet
				
				;------
				; cleanup GC
				marbles: spec: stylesheet: marble: pane: item: data: none
				vout
				frame
			]
			
		]
	]
]
